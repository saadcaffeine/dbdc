// DBDC Open-Source Refreshable Braille Display -- design history (03_worm_strip_4mm.scad)
// Superseded by ../dbdc_3cell.scad; kept for reference.
// SPDX-FileCopyrightText: 2026 Saad Chinoy
// SPDX-License-Identifier: CERN-OHL-S-2.0
// Source location: https://github.com/saadcaffeine/dbdc

// =====================================================================
//  Worm-driven de Bruijn cam braille strip -- 3 cells, 4 mm micro steppers
//  Saad Chinoy / Refreshable Braille Tactile Display (open hardware)
//
//  Each braille column is one 1.6 mm disc that combines:
//    * a cam arc on top (one copy of de Bruijn 00010111, 15 deg steps,
//      R = 2.5 / sin 15 = 9.66 mm), read by 3 pins 2.5 mm apart
//    * a worm-wheel tooth sector on the bottom (60-tooth equivalent,
//      module 0.3, so 6 deg per tooth)
//  A disc only ever turns through 7 cam steps (105 deg), so the cam arc
//  and the tooth sector never need to overlap. No face gears, so cells
//  sit at a standard 6.2 mm pitch.
//
//  Each disc is driven by a single-start worm on a shaft tangent to the
//  disc. A 4.3 mm motor is narrower than the 6.2 mm cell pitch, so two
//  worm positions are enough, alternating column by column:
//     left columns  (dots 1-3): worm at the front (217 deg), motor
//                               runs forward and slightly up, in front
//     right columns (dots 4-6): worm at the back (140 deg), motor
//                               runs backward and slightly up, behind
//  Motors form two straight rows at the cell pitch (6.2 mm apart),
//  roughly level with the axle. Nothing hangs more than ~10 mm below
//  the axle, so the strip is low and flat.
//
//  Motor: 4.3 mm diameter, 2-phase 4-wire micro stepper with a 0.7 mm
//  x 1.7 mm shaft (placeholder sizes: measure yours). The worm rides on
//  a 0.7 mm rod joined to the motor shaft by a short brass tube coupler.
//
//  Drive maths: 1 worm turn = 1 tooth = 6 deg; 1 cam step = 15 deg
//  = 2.5 worm turns = 50 full steps of an 18 deg micro stepper.
//
//  Coordinates: axle along X (reading direction), Z up, reader at -Y.
//  Angles theta are measured from +Z (top) toward +Y (back).
//
//  Torque is the open question for 4 mm motors: estimated need at the
//  motor is ~0.3-0.6 gf.cm; these motors are not rated, ~1 gf.cm is a
//  scaling guess. Test one disc before building a line.
//
//  Not modelled yet: the bearing comb that supports each worm shaft and
//  the rack that clamps the motors. The shafts are drawn full length.
//
//  Export:  openscad -D 'part="disc"' -o disc.stl braille_worm_strip_4mm.scad
//           openscad -D 'part="worm"' -o worm.stl braille_worm_strip_4mm.scad
// =====================================================================

/* [View] */
part = "assembly"; // [assembly, mechanism, disc, worm, frame, end_view]
// Text shown in the assembly, as braille dot lists (one per cell)
cells = [[1,4], [1], [2,3,4,5]];   // "c", "a", "t"

/* [Braille geometry] */
cell_pitch = 6.2;
dot_pitch  = 2.5;
dot_height = 0.6;
pin_d      = 1.5;
pin_clear  = 0.15;

/* [Cam disc] */
seq     = [0,0,0,1,0,1,1,1];   // binary de Bruijn B(2,3)
dwell   = 0.4;
disc_t  = 1.6;
axle_d  = 3.0;
bore_d  = 3.25;

/* [Worm wheel sector] */
wm           = 0.3;   // module
wheel_teeth  = 60;    // full-circle equivalent (6 deg per tooth)
sector_from  = 130;   // disc-frame angle where the teeth start
sector_to    = 333;   // ...and end (cam arc is -18.75..127.5)
pressure_ang = 20;

/* [Worm] */
worm_pd    = 2.4;     // pitch diameter (OD = pd + 2 m = 3.0)
worm_len   = 4.0;
worm_bore  = 0.7;     // rod matching the motor shaft (wall to thread root ~0.47 mm)
mesh_clear = 0.05;

/* [Motor placement] */
motor_d     = 4.3;
motor_len   = 6.7;    // can length without shaft
motor_shaft_len = 1.7;
coupler_d   = 1.3;    // brass tube joining motor shaft to the 0.7 mm worm rod
coupler_len = 3.0;
motor_start = 8.5;    // distance along the shaft from tangent point to motor face
                      // (minimum that keeps the can clear of neighbouring discs)
shaft_back  = 4.0;    // shaft stub beyond the worm on the far side (bearing)
worm_angles = [217, 140];   // front, back
// slot = [worm angle index, motor direction along tangent (+1 = increasing theta)]
// even discs (left columns) use slot 0, odd discs (right columns) slot 1
slots = [[0, 1], [1, -1]];

/* [Frame] */
wall_t    = 2.0;
guide_h   = 5.0;
guide_gap = 1.0;

$fn = 40;
worm_slices = 60;

// ---------------- derived ----------------
L        = len(seq);
step_ang = 15;
R        = dot_pitch / sin(step_ang);
r_max    = R + dot_height;
rp_wheel = wheel_teeth * wm / 2;
tooth_ang = 360 / wheel_teeth;
centre_d = rp_wheel + worm_pd / 2 + mesh_clear;
lead     = PI * wm;
lead_ang = atan(lead / (PI * worm_pd));
wheel_skew = tan(lead_ang) * disc_t / rp_wheel * 180 / PI; // helical skew of wheel teeth

n_cells  = len(cells);
n_discs  = 2 * n_cells;
function disc_x(j) = floor(j / 2) * cell_pitch + (j % 2) * dot_pitch;
y_row    = [dot_pitch, 0, -dot_pitch];
j_row    = [1, 0, -1];
guide_bot = r_max + guide_gap;
z_top    = guide_bot + guide_h;

// ---------------- sequence helpers ----------------
function bit(i) = seq[((i % L) + L) % L];
function cam_f(p) =
    let(i = round(p), d = p - i, ad = abs(d),
        nb = d >= 0 ? i + 1 : i - 1, h = dwell / 2)
    ad <= h ? bit(i)
            : let(t = (ad - h) / (1 - dwell)) bit(i) * (1 - t) + bit(nb) * t;
function find_k(top, mid, bot) =
    [for (k = [0:L-1]) if (bit(k+1) == top && bit(k) == mid && bit(k-1) == bot) k][0];
function has(list, d) = len([for (x = list) if (x == d) 1]) > 0 ? 1 : 0;
// step for disc j (even = left column dots 1-3, odd = right column dots 4-6)
function disc_k(j) = let(c = cells[floor(j/2)], o = (j % 2) * 3)
    find_k(has(c, 1+o), has(c, 2+o), has(c, 3+o));

function contact_z(y, r) = sqrt(r*r - y*y);
function pin_len(y) = z_top - contact_z(y, R);

// ---------------- worm placement ----------------
function slot_of(j)  = slots[j % len(slots)];
function worm_th(j)  = worm_angles[slot_of(j)[0]];
function worm_dir(j) = slot_of(j)[1];
function worm_P(j)   = centre_d * [sin(worm_th(j)), cos(worm_th(j))];          // (y, z)
function worm_v(j)   = worm_dir(j) * [cos(worm_th(j)), -sin(worm_th(j))];      // unit (y, z)
function worm_alpha(j) = atan2(-worm_v(j)[0], worm_v(j)[1]);  // rotate([a,0,0]) maps +Z to v

// worm spin that puts a thread in the wheel gap facing it
function worm_phase(j, b) =
    let(th = worm_th(j), s = worm_dir(j),
        psi_c = s > 0 ? 90 : 270,                       // local angle facing the axle
        t_gap = (tooth_ang/2 - b - th) * PI * rp_wheel / 180)  // wheel teeth sit at theta = 6i - b
    psi_c - 180 + 360 * (s * t_gap + worm_len/2) / lead + 30 * s + phase_trim;
phase_trim = 0;     // +30*s offset above was found by interference search (zero overlap)

// ---------------- report ----------------
echo(str("Cam R = ", R, " mm; wheel pitch radius ", rp_wheel, ", tip ", rp_wheel + wm,
         "; worm OD ", worm_pd + 2*wm, ", lead angle ", lead_ang, " deg"));
echo(str("Worm centre distance ", centre_d, " mm; motor steps per cam step (18 deg motor) = ",
         step_ang / tooth_ang * 20));
echo(str("Strip width over discs = ", disc_x(n_discs-1) - disc_x(0) + disc_t, " mm"));
for (j = [0 : n_discs-1])
    echo(str("disc ", j, " (cell ", floor(j/2)+1, j%2 ? " right" : " left",
             "): step k = ", disc_k(j), ", slot ", j % len(slots)));

// ---------------- 2D profiles ----------------
function inv_deg(a) = (tan(a) - a * PI / 180) * 180 / PI;
function tooth_psi(r, rb, half) = max(0, half - inv_deg(acos(min(1, rb / r))));

module spur_2d(teeth, m, pa = pressure_ang) {
    rp = teeth * m / 2; rb = rp * cos(pa); ra = rp + m; rf = rp - 1.25 * m;
    r0 = max(rb, rf); half = 90 / teeth + inv_deg(pa); n = 6;
    rs = [for (i = [0:n]) r0 + (ra - r0) * i / n];
    union() {
        circle(r = rf, $fn = teeth * 3);
        for (t = [0 : teeth - 1]) rotate(t * 360 / teeth)
            polygon(concat([[0, 0]],
                [for (r = rs) let(a = tooth_psi(r, rb, half)) [r * cos(-a), r * sin(-a)]],
                [for (i = [n:-1:0]) let(r = rs[i], a = tooth_psi(r, rb, half))
                    [r * cos(a), r * sin(a)]]));
    }
}

// wedge between disc-frame angles a0..a1 (theta from +Z toward +Y), radius r
module wedge_2d(a0, a1, r) {
    polygon(concat([[0, 0]], [for (a = [a0 : 2 : a1]) r * [sin(a), cos(a)]],
                   [r * [sin(a1), cos(a1)]]));
}

samples = 16;
module cam_arc_2d() {   // positions -1..8 plus ramp margins
    p0 = -1.25; p1 = L + 0.5;   // trimmed at the start so the front worm clears it at step 7
    polygon(concat([[0, 0]],
        [for (s = [0 : (p1 - p0) * samples])
            let(p = p0 + s / samples, th = p * step_ang, r = R + dot_height * cam_f(p))
            [r * sin(th), r * cos(th)]]));
}

module worm_2d() {
    ha = wm; hf = 1.25 * wm; rpw = worm_pd / 2;
    wt = lead/2 - 2*ha*tan(pressure_ang); wb = lead/2 + 2*hf*tan(pressure_ang);
    n = 72;
    polygon([for (i = [0 : n-1])
        let(phi = i * 360 / n, s = phi / 360 * lead, u = abs(s - lead/2),
            h = u <= wt/2 ? ha : (u >= wb/2 ? -hf
                : ha - (u - wt/2) / ((wb - wt)/2) * (ha + hf)))
        (rpw + h) * [cos(phi), sin(phi)]]);
}

// ---------------- parts ----------------
module disc() {   // axis along X, centred on x = 0, disc frame (b = 0)
    difference() {
        union() {
            rotate([90, 0, 90]) linear_extrude(disc_t, center = true) {
                cam_arc_2d();
                circle(r = rp_wheel - 1.25 * wm - 0.01, $fn = 90);
            }
            // tooth sector, skewed to the worm lead (2D angle = 90 - theta)
            rotate([90, 0, 90])
                linear_extrude(disc_t, center = true, twist = wheel_skew * skew_sign, slices = 2)
                    intersection() {
                        spur_2d(wheel_teeth, wm);
                        wedge_2d(sector_from, sector_to, rp_wheel + 2);
                    }
        }
        rotate([0, 90, 0]) cylinder(d = bore_d, h = 10, center = true);
        // lightening/index hole marks step 0 (cam position 0 is at theta = 0)
        rotate([0, 0, 0]) translate([0, 0, R - 3]) rotate([0, 90, 0])
            cylinder(d = 1.2, h = 10, center = true, $fn = 16);
    }
}
skew_sign = 1;

module worm() {   // along local +Z, centred
    difference() {
        linear_extrude(worm_len, center = true, twist = 360 * worm_len / lead,
                       slices = worm_slices) worm_2d();
        cylinder(d = worm_bore, h = worm_len + 2, center = true, $fn = 16);
    }
}

// everything that rides on one disc's shaft, in world coords
module drive(j, b) {
    P = worm_P(j);
    translate([disc_x(j), P[0], P[1]]) rotate([worm_alpha(j), 0, 0]) {
        color("Orange") rotate([0, 0, worm_phase(j, b)]) worm();
        // shaft from the bearing stub to the motor face
        color("Silver") translate([0, 0, -(worm_len/2 + shaft_back)])
            cylinder(d = worm_bore, h = worm_len/2 + shaft_back + motor_start - 0.1, $fn = 12);
    }
}

module motor_of(j) {
    P = worm_P(j);
    translate([disc_x(j), P[0], P[1]]) rotate([worm_alpha(j), 0, 0])
        translate([0, 0, motor_start]) cylinder(d = motor_d, h = motor_len, $fn = 32);
}

module coupler_of(j) {
    P = worm_P(j);
    translate([disc_x(j), P[0], P[1]]) rotate([worm_alpha(j), 0, 0])
        translate([0, 0, motor_start - coupler_len]) difference() {
            cylinder(d = coupler_d, h = coupler_len, $fn = 16);
            translate([0, 0, -0.1]) cylinder(d = worm_bore, h = coupler_len + 0.2, $fn = 12);
        }
}

module pins_of(j) {
    k = disc_k(j);
    for (r = [0:2]) {
        y = y_row[r];
        f = bit(k + j_row[r]);
        color(f ? "Gold" : "DarkGoldenrod")
            translate([disc_x(j), y, contact_z(y, R + dot_height * f) + pin_d/2]) {
                sphere(d = pin_d, $fn = 16);
                cylinder(d = pin_d, h = pin_len(y) - pin_d/2, $fn = 16);
            }
    }
}

x_lo = disc_x(0) - motor_d/2 - 0.6;
x_hi = disc_x(n_discs-1) + motor_d/2 + 0.6;

module frame() {
    difference() {
        union() {
            for (x0 = [x_lo - wall_t, x_hi])
                translate([x0, -r_max - 2, -6]) cube([wall_t, 2*r_max + 4, z_top + 6]);
            translate([x_lo - wall_t, -dot_pitch - 2, guide_bot])
                cube([x_hi - x_lo + 2*wall_t, 2*dot_pitch + 4, guide_h]);
        }
        rotate([0, 90, 0]) cylinder(d = axle_d + 0.1, h = 200, center = true);
        for (j = [0 : n_discs-1], y = y_row)
            translate([disc_x(j), y, guide_bot - 1])
                cylinder(d = pin_d + 2*pin_clear, h = guide_h + 2, $fn = 20);
    }
}

module discs_placed() {
    for (j = [0 : n_discs-1])
        color(j % 2 ? "IndianRed" : "SteelBlue")
            translate([disc_x(j), 0, 0]) rotate([disc_k(j) * step_ang, 0, 0]) disc();
}

module assembly(show_frame = true) {
    if (show_frame) color("Gainsboro", 0.55) frame();
    color("Silver") rotate([0, 90, 0]) translate([0, 0, x_lo - wall_t - 1])
        cylinder(d = axle_d, h = x_hi - x_lo + 2*wall_t + 2);
    discs_placed();
    for (j = [0 : n_discs-1]) {
        drive(j, disc_k(j) * step_ang);
        color("DimGray") motor_of(j);
        color("Goldenrod") coupler_of(j);
        pins_of(j);
    }
}

// ---------------- part selector ----------------
if (part == "assembly") assembly();
else if (part == "mechanism") assembly(show_frame = false);
else if (part == "end_view") assembly(show_frame = false);
else if (part == "disc") rotate([0, 90, 0]) disc();
else if (part == "worm") worm();
else if (part == "frame") frame();
