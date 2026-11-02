// =====================================================================
//  DBDC Open-Source Refreshable Braille Display -- 3-cell prototype v0.2
//  DBDC = de Bruijn Disc Cell: one cam disc per braille cell, encoded with
//  the de Bruijn sequence B(4,3), turned by a worm and a plain N20 DC gearmotor
//  (no encoder needed).
//
//  SPDX-FileCopyrightText: 2026 Saad Chinoy
//  SPDX-License-Identifier: CERN-OHL-S-2.0
//  Source location: https://github.com/saadcaffeine/dbdc
//
//  This source describes Open Hardware and is licensed under the CERN-OHL-S v2.
//  You may redistribute and modify this source and make products using it
//  under the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).
//  This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
//  INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
//  PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.
//
//  Principle
//  ---------
//  One disc carries two cam tracks side by side (left column = dots 1-2-3,
//  right column = dots 4-5-6), 2.5 mm apart along the axle. Each rim
//  position holds 2 bits, and the 3 pins of each column read 3 consecutive
//  positions, so a 3-position window gives all 6 dots. The rim carries
//  the de Bruijn sequence B(4,3): 64 positions, every 6-dot pattern
//  exactly once. Positions are 5.625 deg apart and the radius is set so
//  that step matches the 2.5 mm dot pitch: R = 2.5 / sin(5.625) = 25.5 mm.
//
//  Drive (v0.2: plain N20 gearmotors, no encoder)
//  -----
//  A 64-tooth worm wheel sits beside each disc, in the 2 mm gap between
//  cells, with its root circle outside the cam. 64 teeth = 64 positions,
//  so ONE TURN OF THE SINGLE-START WORM MOVES THE DISC EXACTLY ONE POSITION.
//  The worm is printed with a sleeve that slips over the 3 mm D-shaft of a
//  plain N20 gearmotor, and a collar on that sleeve carries a small index
//  magnet. A hall switch in the motor rail sees the magnet once per worm
//  turn, i.e. once per braille position, exactly when the cam is in the
//  middle of its flat dwell. Counting these pulses replaces the encoder.
//  Cells alternate: even cells worm at the front, odd cells at the back,
//  both at axle height with the motor hanging straight down. The worm is
//  self-locking, so the motor is unpowered between moves.
//
//  Homing: a 3 x 1 mm magnet in each worm wheel passes a second hall switch
//  standing on a pedestal beside the wheel rim at the bottom. The home switch
//  stays active over a few positions; position 0 is the middle index pulse
//  of those seen while it is active.
//
//  Worm support: a 2 mm metal journal pin in each worm's free end runs in
//  a printed comb, so the worm can't be pushed away from the wheel.
//
//  Printable frame (every part prints flat, no supports):
//    panel_left, panel_right  end plates; locating pockets on the inside
//                             face, blind axle holes, 4 x M3 tie-bolt holes
//    guide_plate              pin guide above the wheels
//    rail_front, rail_back    N20 holders: gearbox pocket, top lip, and a
//                             tower holding the index hall switch
//    comb_front, comb_back    bearing holes for the worm journal pins
//    sensor_rail              pedestals and seats for the home hall switches
//    base                     channels for the motor ends, terminal reliefs,
//                             carries the two lower tie bolts
//  Assembly: lay one panel flat, thread the drum, stand the cross parts
//  (not the base) in its pockets, fit the hall switches, push each motor
//  and worm up through its rail until the gearbox meets the lip, slide the
//  base in, close with the other panel, clamp with 4 x M3 bolts.
//
//  Coordinates: axle along X (reading direction), Z up, reader at -Y.
//  Angles theta are measured from +Z (top) toward +Y (back).
//
//  Not modelled yet: pin return spring/foam, electronics.
//
//  Export one part, already laid flat for printing:
//    openscad -D 'part="print_rail_front"' -o rail_front.stl dbdc_3cell.scad
//  print_ parts: disc, worm_front, worm_back, panel_left, panel_right,
//                guide_plate, rail_front, rail_back, comb_front, comb_back,
//                sensor_rail, base
// =====================================================================

/* [View] */
part = "assembly"; // [assembly, mechanism, end_view, exploded, print_disc, print_worm_front, print_worm_back, print_panel_left, print_panel_right, print_guide_plate, print_rail_front, print_rail_back, print_sensor_rail, print_base, print_comb_front, print_comb_back]
// Text shown in the assembly, as braille dot lists (one per cell)
cells = [[1,4], [1], [2,3,4,5]];   // "c", "a", "t"

/* [Braille geometry] */
cell_pitch = 6.2;
dot_pitch  = 2.5;
dot_height = 0.6;
pin_d      = 1.5;
pin_clear  = 0.15;

/* [Cam disc] */
// B(4,3): symbol = 2*left_bit + right_bit
seq = [0,0,0,1,0,0,2,0,0,3,0,1,1,0,1,2,0,1,3,0,2,1,0,2,2,0,2,3,0,3,1,0,
       3,2,0,3,3,1,1,1,2,1,1,3,1,2,2,1,2,3,1,3,2,1,3,3,2,2,2,3,2,3,3,3];
dwell   = 0.4;     // flat fraction of each step
track_w = 2.05;    // each track width; disc is 2 x track_w thick
axle_d  = 3.0;
bore_d  = 3.25;

/* [Worm wheel (side gear)] */
gear_teeth  = 64;     // = positions: one worm turn per braille position
gm          = 60 / gear_teeth;   // module 0.9375 -> pitch r 30, root 28.83 (> cam max 26.1)
gear_t      = 1.2;
gear_gap    = 0.45;   // gap disc face -> gear face (and gear -> next disc)
web_margin  = 0.1;    // the solid web joining disc and wheel stops this far inside the cam's
                      // lowest radius, so nothing turning ever reaches the pins (see hub_r)
pressure_ang = 20;

/* [Worm] */
worm_pd    = 7.0;     // OD 8.9, root 4.7 on a 3 mm D-shaft; lead angle ~7.7 deg (self-locking)
worm_len   = 9.0;
// collar on the worm sleeve carrying the index magnet (radial, pole facing outward)
collar_r   = 4.0;
collar_s0  = 11.6;    // collar starts this far from the worm centre (clears the wheel tips)
collar_len = 3.0;
idx_mag_d  = 2.0;     // index magnet 2 x 1.5 mm, in a radial pocket
idx_mag_t  = 1.5;
sleeve_d   = 4.6;     // worm sleeve over the motor shaft (0.8 mm wall)
sleeve_start = 4.5;   // sleeve begins here (worm-centre distance), clear of the wheel tips
shaft_d    = 3.0;     // N20 output D-shaft
shaft_flat = 2.5;
mesh_clear = 0.05;

/* [N20 gearmotor, plain (no encoder)] */
mot_w      = 10;      // along X
mot_h      = 12;      // across, in the disc plane
gbox_len   = 9;
can_len    = 15;
tail_len   = 3.0;     // end cap + solder tabs
shaft_len  = 10;
motor_start = 18.0;   // worm centre -> gearbox face (min ~16.6 to clear the wheel)
motor_rpm  = 600;     // N20 output rpm you pick; one worm turn = one position
worm_angles = [270, 90];   // front, back (axle height)
worm_dirs   = [-1, 1];     // both point the motor straight down

/* [Homing] */
magnet_d = 3.0;
magnet_t = 1.0;
magnet_r = 26.9;      // home magnet radius in the wheel web (edge 0.4 below the tooth root)
// TO-92 hall switches (e.g. TI DRV5023 in the LPG package), stood on edge
hall_w = 4.1;  hall_h = 3.0;  hall_t = 1.52;
hall_gap = 0.5;       // branded face -> wheel face

/* [Frame] */
guide_h   = 5.0;
guide_clear = 0.7;    // guide plate sits this far above the wheel tips
guide_w   = 14;       // guide plate depth (y)
panel_t   = 4.0;
pocket_d  = 1.5;      // locating pockets in the panels
fit       = 0.2;      // clearance for pockets
mfit      = 0.15;     // clearance around the motor in its pockets
rail_inner_wall = 1.15;
rail_outer_wall = 1.35;
lip_t     = 2.0;
// worm support: a 2 mm metal pin in the free (top) end of each worm runs in a hole in a
// comb bar, so the mesh force can't push the worm away from the wheel teeth
journal_d    = 2.0;   // pin diameter (brass or steel rod)
journal_in   = 5.0;   // depth of the pin hole in the worm
journal_out  = 4.5;   // pin length above the worm's end
journal_clear = 0.1;  // radial clearance of the pin in the comb hole
comb_gap     = 2.0;   // worm end -> comb underside
comb_t       = 3.0;   // comb thickness
comb_wall    = 1.2;   // material around the hole on the wheel side
base_t    = 8.0;      // base thickness (tie bolts run through it below the pockets)
bolt_d    = 3.4;      // M3 clearance
axle_hole_depth = 3.0;
disc_boss_r = 4;      // spacer boss on each disc's left face
// label debossed into the left panel's outer face (CERN-OHL-S source location)
label_lines = ["DBDC v0.2", "CERN-OHL-S-2.0", "github.com/saadcaffeine/dbdc"];
label_font  = "Liberation Sans:style=Bold";
label_depth = 0.6;

$fn = 40;
worm_slices = 60;
phase_trim = 10;   // worm spin offset, found by interference search (zero overlap)

// ---------------- derived ----------------
L        = len(seq);                 // 64
step_ang = 360 / L;                  // 5.625
R        = dot_pitch / sin(step_ang);
// Solid web filling the gap between the disc and its wheel, out to just inside the cam
// surface. Prints without bridging (the wheel is on the bed); above the cam radius the gap
// stays open so the wheel clears the right-hand column of pins by 0.6 mm.
hub_r    = R - web_margin;
r_max    = R + dot_height;
rp_gear  = gear_teeth * gm / 2;
tip_r    = rp_gear + gm;
root_r   = rp_gear - 1.25 * gm;
tooth_ang = 360 / gear_teeth;
centre_d = rp_gear + worm_pd / 2 + mesh_clear;
lead     = PI * gm;
lead_ang = atan(lead / (PI * worm_pd));
gear_skew = tan(lead_ang) * gear_t / rp_gear * 180 / PI;

disc_half = track_w;                          // disc spans -track_w..+track_w
gear_x0   = disc_half + gear_gap;             // gear spans gear_x0..gear_x0+gear_t
gear_xc   = gear_x0 + gear_t / 2;
col_x     = [-dot_pitch/2, dot_pitch/2];
y_row     = [dot_pitch, 0, -dot_pitch];
j_row     = [1, 0, -1];
guide_bot = tip_r + guide_clear;
z_top     = guide_bot + guide_h;

n_cells = len(cells);
function cell_x(c) = c * cell_pitch;

// ---------------- sequence helpers ----------------
function sym(i)   = seq[((i % L) + L) % L];
function lbit(i)  = floor(sym(i) / 2);
function rbit(i)  = sym(i) % 2;
function tbit(t, i) = t == 0 ? lbit(i) : rbit(i);
function cam_f(t, p) =
    let(i = round(p), d = p - i, ad = abs(d),
        nb = d >= 0 ? i + 1 : i - 1, h = dwell / 2)
    ad <= h ? tbit(t, i)
            : let(u = (ad - h) / (1 - dwell)) tbit(t, i) * (1 - u) + tbit(t, nb) * u;
function has(list, d) = len([for (x = list) if (x == d) 1]) > 0 ? 1 : 0;
// position k: row j reads position k + j (j = +1 top row ... -1 bottom row)
function find_k(c) = [for (k = [0:L-1])
    if (lbit(k+1) == has(c,1) && lbit(k) == has(c,2) && lbit(k-1) == has(c,3) &&
        rbit(k+1) == has(c,4) && rbit(k) == has(c,5) && rbit(k-1) == has(c,6)) k][0];
function cell_k(c) = find_k(cells[c]);

function contact_z(y, r) = sqrt(r*r - y*y);
function pin_len(y) = z_top - contact_z(y, R);

// ---------------- worm placement ----------------
function wslot(c)  = c % 2;
function worm_th(c)  = worm_angles[wslot(c)];
function worm_dir(c) = worm_dirs[wslot(c)];
function worm_P(c)   = centre_d * [sin(worm_th(c)), cos(worm_th(c))];
function worm_v(c)   = worm_dir(c) * [cos(worm_th(c)), -sin(worm_th(c))];
function worm_alpha(c) = atan2(-worm_v(c)[0], worm_v(c)[1]);
function worm_phase(c, b) =
    let(th = worm_th(c), s = worm_dir(c), psi_c = s > 0 ? 90 : 270,
        t_gap = (tooth_ang/2 - b - th) * PI * rp_gear / 180)
    psi_c - 180 + 360 * (s * t_gap + worm_len/2) / lead + phase_trim * s;

// index magnet: centre of the collar's cylindrical part, pointing radially outward from the
// drum axis whenever the disc sits exactly on a position (worm phase repeats every position)
idx_mag_s = collar_s0 + (collar_r - sleeve_d/2) + collar_len/2;
function mag_angle(sl) =
    let(a = worm_alpha(sl), sg = worm_P(sl)[0] < 0 ? -1 : 1)
    atan2(sg * cos(a), 0) - worm_phase(sl, 0);

// ---------------- report ----------------
turns_per_pos = gear_teeth / L;
pos_per_s = motor_rpm / 60 / turns_per_pos;
echo(str("Cam R = ", R, " mm (dia ", 2*R, "), max ", r_max, "; disc thickness ", 2*track_w));
echo(str("Worm wheel ", gear_teeth, "T m", gm, ": pitch dia ", 2*rp_gear, ", tip dia ", 2*tip_r,
         ", root r ", root_r, "; worm OD ", worm_pd + 2*gm, ", lead angle ", lead_ang, " deg"));
echo(str("Worm turns per position ", turns_per_pos, " (index pulses per position: 1)"));
echo(str("At ", motor_rpm, " rpm: ", pos_per_s, " positions/s, worst case (32 positions) ",
         32 / pos_per_s, " s"));
echo(str("Device envelope (end view): depth ", 2*(centre_d + mot_h/2), " mm, height ",
         z_top + motor_start + gbox_len + can_len + tail_len, " mm"));
echo(str("Pin guide block z ", guide_bot, "..", z_top, "; pin lengths ",
         pin_len(dot_pitch), " / ", pin_len(0), " mm"));
for (c = [0 : n_cells-1])
    echo(str("cell ", c+1, ": position k = ", cell_k(c), ", worm ", wslot(c) == 0 ? "front" : "back"));

// ---------------- 2D profiles ----------------
function inv_deg(a) = (tan(a) - a * PI / 180) * 180 / PI;
function tooth_psi(r, rb, half) = max(0, half - inv_deg(acos(min(1, rb / r))));

module spur_2d(teeth, m, pa = pressure_ang) {
    rp = teeth * m / 2; rb = rp * cos(pa); ra = rp + m; rf = rp - 1.25 * m;
    r0 = max(rb, rf); half = 90 / teeth + inv_deg(pa); n = 5;
    rs = [for (i = [0:n]) r0 + (ra - r0) * i / n];
    union() {
        circle(r = rf, $fn = teeth * 2);
        for (t = [0 : teeth - 1]) rotate(t * 360 / teeth)
            polygon(concat([[0, 0]],
                [for (r = rs) let(a = tooth_psi(r, rb, half)) [r * cos(-a), r * sin(-a)]],
                [for (i = [n:-1:0]) let(r = rs[i], a = tooth_psi(r, rb, half))
                    [r * cos(a), r * sin(a)]]));
    }
}

samples = 10;
module track_2d(t) {
    polygon([for (s = [0 : L*samples - 1])
        let(p = s / samples, th = p * step_ang, r = R + dot_height * cam_f(t, p))
        [r * sin(th), r * cos(th)]]);
}

module worm_2d() {
    ha = gm; hf = 1.25 * gm; rpw = worm_pd / 2;
    wt = lead/2 - 2*ha*tan(pressure_ang); wb = lead/2 + 2*hf*tan(pressure_ang);
    n = 72;
    polygon([for (i = [0 : n-1])
        let(phi = i * 360 / n, s = phi / 360 * lead, u = abs(s - lead/2),
            h = u <= wt/2 ? ha : (u >= wb/2 ? -hf
                : ha - (u - wt/2) / ((wb - wt)/2) * (ha + hf)))
        (rpw + h) * [cos(phi), sin(phi)]]);
}

module d_shape(d, flat) {
    intersection() { circle(d = d, $fn = 24); translate([-d/2, -d/2]) square([d, flat]); }
}

// ---------------- parts ----------------
// disc + spacer + worm wheel, one print. Axis along X, cell centre x = 0.
module disc() {
    difference() {
        union() {
            // left and right cam tracks
            translate([-track_w, 0, 0]) rotate([90, 0, 90])
                linear_extrude(track_w + 0.01) track_2d(0);
            rotate([90, 0, 90]) linear_extrude(track_w) track_2d(1);
            // solid web between disc and wheel (was a 10 mm hub, which left a 0.55 mm
            // unsupported gap under the cam when printing)
            translate([track_w - 0.01, 0, 0]) rotate([0, 90, 0])
                cylinder(r = hub_r, h = gear_gap + 0.02);
            // spacer boss on the left face: sets the 6.2 mm cell pitch on the axle
            translate([-track_w - (cell_pitch - 2*track_w - gear_gap - gear_t) + 0.05, 0, 0])
                rotate([0, 90, 0])
                cylinder(r = disc_boss_r, h = cell_pitch - 2*track_w - gear_gap - gear_t - 0.05 + 0.01);
            // worm wheel, teeth skewed to the worm lead
            translate([gear_x0, 0, 0]) rotate([90, 0, 90])
                linear_extrude(gear_t, twist = gear_skew, slices = 2)
                    spur_2d(gear_teeth, gm);
        }
        rotate([0, 90, 0]) cylinder(d = bore_d, h = 30, center = true);
        // home magnet pocket at disc-frame angle 180 (bottom at position 0)
        translate([gear_x0 - 0.1, 0, -magnet_r]) rotate([0, 90, 0])
            cylinder(d = magnet_d + 0.15, h = gear_t + 0.2, $fn = 20);
        // lightening holes in the cam body (keep a solid rim)
        for (a = [0 : 60 : 300]) rotate([a, 0, 0]) translate([0, 0, 16])
            rotate([0, 90, 0]) cylinder(d = 9, h = 30, center = true);
    }
}

// worm + sleeve + index collar, one print, along local +Z (motor side), worm centred on 0.
// mag_ang: direction of the index magnet in the worm's own frame (differs front/back)
module worm(mag_ang = 0) {
    difference() {
        union() {
            linear_extrude(worm_len, center = true, twist = 360 * worm_len / lead,
                           slices = worm_slices) worm_2d();
            // sleeve stops 1.2 mm short of the gearbox face (clears its bearing boss)
            translate([0, 0, worm_len/2 - 0.5])
                cylinder(d = sleeve_d, h = motor_start - 1.2 - worm_len/2 + 0.5, $fn = 32);
            // index collar; 45-degree chamfer underneath so it prints without support
            translate([0, 0, collar_s0]) {
                cylinder(r1 = sleeve_d/2, r2 = collar_r, h = collar_r - sleeve_d/2, $fn = 40);
                translate([0, 0, collar_r - sleeve_d/2])
                    cylinder(r = collar_r, h = collar_len, $fn = 40);
            }
        }
        // radial pocket for the index magnet, pole facing outward
        translate([0, 0, idx_mag_s]) rotate([0, 0, mag_ang]) rotate([0, 90, 0])
            translate([0, 0, collar_r - idx_mag_t - 0.05]) cylinder(d = idx_mag_d + 0.1, h = idx_mag_t + 1, $fn = 20);
        // D bore for the motor shaft, 0.5 mm deeper than the shaft
        translate([0, 0, motor_start - shaft_len - 0.5]) linear_extrude(shaft_len + 1)
            offset(delta = 0.05) d_shape(shaft_d, shaft_flat);
        // blind hole in the free end for the journal pin (press fit)
        translate([0, 0, -worm_len/2 - 0.01]) cylinder(d = journal_d - 0.05, h = journal_in + 0.01, $fn = 20);
    }
}

module n20() {    // along local +Z from the gearbox face; 10 mm along X, 12 mm across
    color("Goldenrod") translate([-mot_w/2, -mot_h/2, 0]) cube([mot_w, mot_h, gbox_len]);
    color("DimGray") translate([0, 0, gbox_len]) intersection() {
        cylinder(d = mot_h, h = can_len, $fn = 32);
        translate([-mot_w/2, -mot_h/2, 0]) cube([mot_w, mot_h, can_len]);
    }
    // end cap and solder tabs (no encoder)
    color("DimGray") translate([0, 0, gbox_len + can_len]) intersection() {
        cylinder(d = mot_h - 1, h = 1.2, $fn = 32);
        translate([-mot_w/2, -mot_h/2, 0]) cube([mot_w, mot_h, 1.2]);
    }
    color("Goldenrod") for (sx = [-1, 1])
        translate([-0.3, sx * 3 - 1, gbox_len + can_len + 1.2]) cube([0.6, 2, tail_len - 1.2]);
}

// worm + motor for cell c, in world coords; disc turned by b degrees
module drive(c, b) {
    P = worm_P(c);
    translate([cell_x(c) + gear_xc, P[0], P[1]]) rotate([worm_alpha(c), 0, 0]) {
        rotate([0, 0, worm_phase(c, b)]) {
            color("Orange") worm(mag_angle(wslot(c)));
            // index magnet
            color("SlateGray") translate([0, 0, idx_mag_s]) rotate([0, 0, mag_angle(wslot(c))])
                rotate([0, 90, 0]) translate([0, 0, collar_r - idx_mag_t - 0.05])
                    cylinder(d = idx_mag_d, h = idx_mag_t, $fn = 20);
            // journal pin in the free end, running in the comb
            color("Silver") translate([0, 0, -worm_len/2 - journal_out])
                cylinder(d = journal_d, h = journal_in + journal_out, $fn = 20);
            // motor D-shaft, turning with the worm
            color("Silver") translate([0, 0, motor_start - shaft_len])
                linear_extrude(shaft_len) d_shape(shaft_d, shaft_flat);
        }
    }
}
module motor_of(c) {
    P = worm_P(c);
    // motor face is at +motor_start along v; shaft points back toward the worm
    translate([cell_x(c) + gear_xc, P[0], P[1]]) rotate([worm_alpha(c), 0, 0])
        translate([0, 0, motor_start]) n20();
}

module pins_of(c) {
    k = cell_k(c);
    for (col = [0:1], r = [0:2]) {
        y = y_row[r];
        f = tbit(col, k + j_row[r]);
        color(f ? "Gold" : "DarkGoldenrod")
            translate([cell_x(c) + col_x[col], y, contact_z(y, R + dot_height * f) + pin_d/2]) {
                sphere(d = pin_d, $fn = 16);
                cylinder(d = pin_d, h = pin_len(y) - pin_d/2, $fn = 16);
            }
    }
}


// =====================================================================
//  Printable frame
// =====================================================================
last = n_cells - 1;
x_in_l = -track_w - (cell_pitch - 2*track_w - gear_gap - gear_t);        // left panel inner face
x_in_r = cell_x(last) + gear_xc + mot_w/2 + 0.5;                          // right panel inner face
px0 = x_in_l - pocket_d;            // cross parts run from px0 ...
px1 = x_in_r + pocket_d;            // ... to px1 (ends sit in the panel pockets)
plen = px1 - px0;

// motor / rail geometry (worms at 270 and 90 deg, motors vertical)
gbox_top = -motor_start;
gbox_bot = -motor_start - gbox_len;
mot_bot  = -(motor_start + gbox_len + can_len + tail_len);
rail_y_in  = centre_d - mot_h/2 - mfit - rail_inner_wall;
rail_y_out = centre_d + mot_h/2 + mfit + rail_outer_wall;
worm_r_max = max(worm_pd/2 + gm, collar_r);      // widest part pushed up past the lip
lip_y_in   = centre_d + worm_r_max + 0.3;   // clear of worm and collar, so the motor can be pushed up past the lip
base_top   = mot_bot + 2.0;                  // channels 2.2 deep hold the motor end caps
base_bot   = base_top - base_t;
bolt_z_low = (base_bot + mot_bot - 0.2) / 2;  // lower tie bolts run through the base
bolt_pos   = [[36, 30], [-36, 30], [20, bolt_z_low], [-20, bolt_z_low]];   // (y, z)
// index hall switch, in a tower on each motor rail, facing the worm collar
idx_face_y = lip_y_in + 0.15;                 // branded face (world |y|)
tower_top  = -idx_mag_s + hall_w/2 + 2.0;
// home hall switch: stands on a pedestal beside the wheel rim, as high as the next disc allows
home_top = -(r_max + 0.5);                   // top of the sensor body (clear of the next disc)
// hall sensor rail
sens_top = -(tip_r + 0.5);                   // rail top, below the wheel tips
sens_bot = sens_top - 4;
sens_w   = 5;                                // half depth (y)
hall_seat = 0.6;
panel_y  = rail_y_out + 2.7;
panel_z0 = base_bot;
panel_z1 = z_top + 1;

function cells_in_slot(sl) = [for (c = [0:last]) if (wslot(c) == sl) c];
function slot_sign(sl) = worm_angles[sl] == 270 ? -1 : 1;    // front rail at -y

echo(str("Frame: inner span ", x_in_r - x_in_l, " mm, cross parts ", plen,
         " mm long; panel ", 2*panel_y, " x ", panel_z1 - panel_z0, " mm; M3 bolts ",
         x_in_r - x_in_l + 2*panel_t, " mm grip (use M3 x 40)"));
echo(str("Axle: 3 mm rod, ", x_in_r - x_in_l + 2*axle_hole_depth - 0.4, " mm long"));
echo(str("Index hall: branded face ", idx_face_y - centre_d - collar_r, " mm from the collar; ",
         "home hall: centre ", -home_top + hall_h/2 - magnet_r, " mm below the home magnet centre"));
echo(str("Rails: wheel clearance at the inner top edge = ",
         sqrt(rail_y_in*rail_y_in + gbox_top*gbox_top) - tip_r, " mm"));

module rounded_rect_yz(y0, y1, z0, z1, r) {   // 2D in (y, z)
    hull() for (y = [y0 + r, y1 - r], z = [z0 + r, z1 - r]) translate([y, z]) circle(r = r, $fn = 24);
}

// ---- cross parts, in assembly position --------------------------------
module guide_plate() {
    difference() {
        translate([px0, -guide_w/2, guide_bot]) cube([plen, guide_w, guide_h]);
        for (c = [0:last], x = col_x, y = y_row)
            translate([cell_x(c) + x, y, guide_bot - 1])
                cylinder(d = pin_d + 2*pin_clear, h = guide_h + 2, $fn = 20);
    }
}

module motor_rail(sl) {
    sg = slot_sign(sl);
    mirror([0, sg > 0 ? 0 : 1, 0]) union() {
        difference() {
            translate([px0, rail_y_in, gbox_bot]) cube([plen, rail_y_out - rail_y_in, gbox_len]);
            for (c = cells_in_slot(sl))
                translate([cell_x(c) + gear_xc - mot_w/2 - mfit, centre_d - mot_h/2 - mfit, gbox_bot - 1])
                    cube([mot_w + 2*mfit, mot_h + 2*mfit, gbox_len + 2]);
        }
        // lip over the outer part of each gearbox (stops the motor moving up), and a tower on it
        // holding the index hall switch upside down (legs up), branded face toward the collar
        difference() {
            translate([px0, lip_y_in, gbox_top])
                cube([plen, rail_y_out - lip_y_in, tower_top - gbox_top]);
            for (c = cells_in_slot(sl)) {
                x = cell_x(c) + gear_xc;
                translate([x - hall_w/2 - 0.15, idx_face_y - 0.15, -idx_mag_s - hall_h/2 - 0.1])
                    cube([hall_w + 0.3, hall_t + 0.3, hall_h + 0.2]);
                // leg slot up through the tower top
                translate([x - 1.8, idx_face_y + hall_t/2 - 0.45, -idx_mag_s])
                    cube([3.6, 0.9, tower_top + idx_mag_s + 1]);
            }
        }
    }
}

module sensor_rail() {
    ped_top = home_top - hall_h + hall_seat;                  // pedestal top surface
    difference() {
        union() {
            translate([px0, -sens_w, sens_bot]) cube([plen, 2*sens_w, sens_top - sens_bot]);
            // pedestal beside each wheel, lifting the home switch close to its magnet
            for (c = [0:last]) {
                hx = cell_x(c) + gear_x0 + gear_t + hall_gap;
                translate([hx - 0.2, -hall_w/2 - 1.0, sens_top - 0.01])
                    cube([hall_t + 1.2, hall_w + 2.0, ped_top - sens_top + 0.01]);
            }
        }
        for (c = [0:last]) {
            hx = cell_x(c) + gear_x0 + gear_t + hall_gap;           // branded face plane
            // seat for the sensor body, stood on edge
            translate([hx - 0.1, -hall_w/2 - 0.15, ped_top - hall_seat])
                cube([hall_t + 0.3, hall_w + 0.3, hall_seat + 1]);
            // slot for the three legs
            translate([hx + hall_t/2 - 0.45, -1.8, sens_bot - 1])
                cube([0.9, 3.6, ped_top - sens_bot + 1]);
        }
    }
}

module base() {
    difference() {
        translate([px0, -rail_y_out, base_bot]) cube([plen, 2*rail_y_out, base_t]);
        for (sl = [0:1], c = cells_in_slot(sl)) {
            sg = slot_sign(sl);
            x = cell_x(c) + gear_xc;
            // channel along the whole base for this row of motor end caps, so the base can
            // slide in last, along the axle direction, after the motors are fitted
            translate([px0 - 1, sg * centre_d - mot_h/2 - mfit, mot_bot - 0.2])
                cube([plen + 2, mot_h + 2*mfit, base_t]);
            // relief for the solder tabs and wires, through the floor
            translate([x - 3, sg * centre_d - 4.5, base_bot - 1]) cube([6, 9, base_t + 2]);
        }
        for (b = bolt_pos) if (b[1] < 0)
            translate([px0 - 1, b[0], b[1]]) rotate([0, 90, 0]) cylinder(d = bolt_d, h = plen + 2, $fn = 20);
    }
}

// comb above each row of worms: holes carry the worm journal pins
comb_z0   = worm_len/2 + comb_gap;                 // worms sit at axle height
comb_z1   = comb_z0 + comb_t;
comb_y_in = centre_d - (journal_d/2 + journal_clear) - comb_wall;
comb_y_out = centre_d + journal_d/2 + journal_clear + 2.0;
echo(str("Worm comb: wheel clearance at its inner lower edge = ",
         sqrt(comb_y_in*comb_y_in + comb_z0*comb_z0) - tip_r, " mm; pin engagement ",
         journal_out - comb_gap, " mm"));

module worm_comb(sl) {
    sg = slot_sign(sl);
    mirror([0, sg > 0 ? 0 : 1, 0]) difference() {
        translate([px0, comb_y_in, comb_z0]) cube([plen, comb_y_out - comb_y_in, comb_t]);
        for (c = cells_in_slot(sl))
            translate([cell_x(c) + gear_xc, centre_d, comb_z0 - 1])
                cylinder(d = journal_d + 2*journal_clear, h = comb_t + 2, $fn = 24);
    }
}

// outlines of the cross parts in (y, z), for the panel pockets
module part_sections_2d() {
    translate([-guide_w/2, guide_bot]) square([guide_w, guide_h]);
    for (sl = [0:1]) mirror([slot_sign(sl) > 0 ? 0 : 1, 0]) {
        translate([rail_y_in, gbox_bot]) square([rail_y_out - rail_y_in, gbox_len]);
        translate([lip_y_in, gbox_top]) square([rail_y_out - lip_y_in, tower_top - gbox_top]);
        translate([comb_y_in, comb_z0]) square([comb_y_out - comb_y_in, comb_t]);
    }
    translate([-sens_w, sens_bot]) square([2*sens_w, sens_top - sens_bot]);
    translate([-rail_y_out, base_bot]) square([2*rail_y_out, base_t]);
}

// end panel; inner face at x = xin, body extends away from the cells (dir = -1 left, +1 right)
module panel(xin, dir) {
    difference() {
        union() {
            translate([dir < 0 ? xin - panel_t : xin, 0, 0]) rotate([90, 0, 90])
                linear_extrude(panel_t) rounded_rect_yz(-panel_y, panel_y, panel_z0, panel_z1, 4);
            // right panel: spacer boss on the axle up to the last wheel
            if (dir > 0) {
                bx = cell_x(last) + gear_x0 + gear_t + 0.05;
                translate([bx, 0, 0]) rotate([0, 90, 0]) cylinder(r = disc_boss_r, h = xin - bx + 0.01);
            }
        }
        // locating pockets
        translate([dir < 0 ? xin - pocket_d : xin - 0.01, 0, 0]) rotate([90, 0, 90])
            linear_extrude(pocket_d + 0.01) offset(delta = fit) part_sections_2d();
        // blind axle hole (from the inner face / boss)
        translate([dir < 0 ? xin - axle_hole_depth : cell_x(last) + gear_x0 + gear_t - 1, 0, 0])
            rotate([0, 90, 0]) cylinder(d = axle_d + 0.15,
                h = dir < 0 ? axle_hole_depth + 0.1 : (xin - (cell_x(last) + gear_x0 + gear_t - 1)) + axle_hole_depth, $fn = 24);
        // tie bolt holes
        for (b = bolt_pos)
            translate([xin - 10, b[0], b[1]]) rotate([0, 90, 0]) cylinder(d = bolt_d, h = 20, $fn = 20);
        // source-location label, debossed into the left panel's outer face
        if (dir < 0)
            translate([xin - panel_t - 0.01, 0, 0]) rotate([90, 0, 90])
                linear_extrude(label_depth + 0.01)
                    mirror([1, 0]) for (i = [0 : len(label_lines) - 1])   // reads correctly from outside
                        translate([0, -15 - i * 5.5])
                            text(label_lines[i], size = i == 0 ? 4 : 3, font = label_font,
                                 halign = "center", valign = "center");
        // windows
        translate([xin - 10, 0, 0]) rotate([90, 0, 90]) linear_extrude(20) {
            rounded_rect_yz(-18, 18, 8, guide_bot - 4, 3);
            if (sens_bot - 3 - (base_top + 3) > 8)
                rounded_rect_yz(-18, 18, base_top + 3, sens_bot - 3, 3);
        }
    }
}
module panel_left()  { panel(x_in_l, -1); }
module panel_right() { panel(x_in_r, 1); }

// ---- non-printed parts --------------------------------------------------
module hall_sensors() {
    for (c = [0:last]) {
        // home switch beside the wheel
        hx = cell_x(c) + gear_x0 + gear_t + hall_gap;
        color("Black") translate([hx, -hall_w/2, home_top - hall_h]) cube([hall_t, hall_w, hall_h]);
        color("Silver") for (i = [-1:1])
            translate([hx + hall_t/2, i * 1.27, sens_bot - 3])
                cylinder(d = 0.4, h = home_top - hall_h - sens_bot + 3, $fn = 8);
        // index switch in the rail tower, facing the worm collar
        sg = slot_sign(wslot(c));
        x = cell_x(c) + gear_xc;
        mirror([0, sg > 0 ? 0 : 1, 0]) {
            color("Black") translate([x - hall_w/2, idx_face_y, -idx_mag_s - hall_h/2])
                cube([hall_w, hall_t, hall_h]);
            color("Silver") for (i = [-1:1])
                translate([x + i * 1.27, idx_face_y + hall_t/2, -idx_mag_s + hall_h/2])
                    cylinder(d = 0.4, h = tower_top + idx_mag_s + 3, $fn = 8);
        }
    }
}
module magnets() {
    for (c = [0:last]) translate([cell_x(c), 0, 0]) rotate([cell_k(c) * step_ang, 0, 0])
        color("SlateGray") translate([gear_x0, 0, -magnet_r]) rotate([0, 90, 0])
            cylinder(d = magnet_d, h = magnet_t, $fn = 20);
}
module bolts() {
    color("DarkGray") for (b = bolt_pos)
        translate([x_in_l - panel_t - 2, b[0], b[1]]) rotate([0, 90, 0])
            cylinder(d = 3, h = x_in_r - x_in_l + 2*panel_t + 4, $fn = 12);
}
module axle() {
    color("Silver") translate([x_in_l - axle_hole_depth + 0.2, 0, 0]) rotate([0, 90, 0])
        cylinder(d = axle_d, h = x_in_r - x_in_l + 2*axle_hole_depth - 0.4);
}

module frame_parts() {
    guide_plate(); motor_rail(0); motor_rail(1); sensor_rail(); base();
    worm_comb(0); worm_comb(1);
    panel_left(); panel_right();
}

module discs_placed() {
    for (c = [0 : n_cells-1])
        color(c % 2 ? "IndianRed" : "SteelBlue")
            translate([cell_x(c), 0, 0]) rotate([cell_k(c) * step_ang, 0, 0]) disc();
}

module mechanism_only() {
    axle(); discs_placed(); magnets(); hall_sensors();
    for (c = [0 : n_cells-1]) { drive(c, cell_k(c) * step_ang); motor_of(c); pins_of(c); }
}

module assembly(show_frame = true, explode = 0) {
    mechanism_only();
    if (show_frame) {
        color("Gainsboro", 0.5) translate([-explode, 0, 0]) panel_left();
        color("Gainsboro", 0.5) translate([explode, 0, 0]) panel_right();
        color("LightSteelBlue") translate([0, 0, explode/2]) guide_plate();
        color("Wheat") translate([0, -explode/3, 0]) motor_rail(0);
        color("Wheat") translate([0, explode/3, 0]) motor_rail(1);
        color("PaleGreen") translate([0, 0, -explode/3]) sensor_rail();
        color("Tan") translate([0, 0, -explode/2]) base();
        color("Plum") translate([0, -explode/2, explode/4]) worm_comb(0);
        color("Plum") translate([0, explode/2, explode/4]) worm_comb(1);
        if (explode == 0) bolts();
    }
}

// ---- print layouts (flat side on z = 0) ---------------------------------
module lay(zmin) { translate([0, 0, -zmin]) children(); }

// ---------------- part selector ----------------
if (part == "assembly") assembly();
else if (part == "mechanism") assembly(show_frame = false);
else if (part == "end_view") assembly(show_frame = false);
else if (part == "exploded") assembly(explode = 40);
else if (part == "print_disc") rotate([0, 90, 0]) translate([-(gear_x0 + gear_t), 0, 0]) disc();  // wheel face on the bed
else if (part == "print_worm_front") translate([0, 0, worm_len/2]) worm(mag_angle(0));  // free end on the bed
else if (part == "print_worm_back")  translate([0, 0, worm_len/2]) worm(mag_angle(1));
else if (part == "print_panel_left")  rotate([0, -90, 0]) translate([-(x_in_l - panel_t), 0, 0]) panel_left();
else if (part == "print_panel_right") rotate([0, 90, 0]) translate([-(x_in_r + panel_t), 0, 0]) panel_right();
else if (part == "print_guide_plate") lay(guide_bot) guide_plate();
else if (part == "print_rail_front") lay(gbox_bot) motor_rail(0);
else if (part == "print_rail_back")  lay(gbox_bot) motor_rail(1);
else if (part == "print_sensor_rail") lay(sens_bot) sensor_rail();
else if (part == "print_base") lay(base_bot) base();
else if (part == "print_comb_front") lay(comb_z0) worm_comb(0);
else if (part == "print_comb_back")  lay(comb_z0) worm_comb(1);
