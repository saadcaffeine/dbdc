// DBDC Open-Source Refreshable Braille Display -- design history (01_cam_cell_stepper.scad)
// Superseded by ../dbdc_3cell.scad; kept for reference.
// SPDX-FileCopyrightText: 2026 Saad Chinoy
// SPDX-License-Identifier: CERN-OHL-S-2.0
// Source location: https://github.com/saadcaffeine/dbdc

// =====================================================================
//  Rotary de Bruijn cam braille cell -- single test cell, stepper drive
//  Saad Chinoy / Refreshable Braille Tactile Display (open hardware)
//
//  Principle
//  ---------
//  Each braille column (3 dots) is driven by one thin cam disc.
//  The 3 pins of a column sit 2.5 mm apart front-to-back and rest on
//  the disc rim at 3 *consecutive* cam positions. The rim carries the
//  binary de Bruijn sequence 00010111, so every 3-dot pattern appears
//  exactly once per 8 steps. Repeating the sequence 3x around the rim
//  (24 steps of 15 deg) sets the drum radius so the step arc matches
//  the 2.5 mm dot pitch: R = 2.5 / sin(15 deg) ~= 9.66 mm.
//
//  Drive
//  -----
//  Each disc has a spur gear moulded onto its OUTER face (left disc on
//  its left face, right disc on its right face), so the two discs of a
//  cell keep their 2.5 mm column spacing. A micro stepper on each side
//  wall drives its gear through a small pinion. With an 18 deg/step
//  motor and a 6:1 ratio, one cam step (15 deg) = 5 full motor steps.
//
//  The left and right discs are MIRROR IMAGES, not the same part
//  flipped (flipping would reverse the cam sequence). Export both.
//
//  Coordinates: axle along X (reading direction), Z up,
//  reader sits at -Y, so dot 1 (top of cell) is at +Y.
//
//  Parts: set `part` and export STL (F6 then F7), or use the CLI:
//    openscad -D 'part="disc_left"'  -o disc_left.stl  braille_cam_cell.scad
//    openscad -D 'part="disc_right"' -o disc_right.stl braille_cam_cell.scad
//    openscad -D 'part="pinion"'     -o pinion.stl     braille_cam_cell.scad
//    openscad -D 'part="frame"'      -o frame.stl      braille_cam_cell.scad
// =====================================================================

/* [View] */
part = "assembly"; // [assembly, mechanism, section, disc_left, disc_right, pinion, frame, pins]
// Braille dots to show raised in the assembly (1..6). [1,2,4] = "f"
dots = [1, 2, 4];
// Which of the 3 equivalent sequence repeats to use (0..2)
repeat_slot = 0;

/* [Braille geometry] */
dot_pitch  = 2.5;   // dot centre spacing within a cell
dot_height = 0.6;   // cam lift = pin protrusion (target ~0.5 mm dot)
pin_d      = 1.5;   // pin diameter (1.5 mm brass/steel rod recommended)
pin_clear  = 0.15;  // radial clearance in guide holes

/* [Cam disc] */
seq       = [0,0,0,1,0,1,1,1]; // binary de Bruijn B(2,3)
repeats   = 3;                 // sequence copies around the rim
dwell     = 0.4;               // flat fraction of each step (rest is ramp)
disc_t    = 1.6;               // cam thickness (gap to neighbour = pitch - t)
axle_d    = 3.0;               // axle rod diameter
bore_d    = 3.25;              // disc bore (free running on axle)
tick_depth = 0.3;              // index tick grooves on disc faces

/* [Gear drive] */
gear_module   = 0.3;   // 0.3 suits resin / 0.2 mm nozzle; 0.4 + 8T pinion for FDM
pinion_teeth  = 10;    // set to match the motor's own brass pinion if it has one
gear_ratio    = 6;     // gear teeth = ratio x pinion teeth
pressure_ang  = 20;
gear_t        = 1.2;   // gear face width
mesh_clear    = 0.05;  // extra centre distance for printed-gear backlash
// Pinion/motor position: degrees from straight down, swinging toward the reader
motor_ang     = 45;

/* [Micro stepper (placeholders: measure yours)] */
motor_step     = 18;   // full-step angle in degrees (20 steps/rev)
motor_d        = 8.0;  // can diameter
motor_len      = 10.0; // can length
motor_boss_d   = 2.0;  // front bearing boss around the shaft
motor_shaft_d  = 1.0;
motor_shaft_len = 3.0; // shaft length beyond the motor face
sleeve_wall    = 1.2;  // printed clamp sleeve around the can

/* [Frame] */
wall_t     = 2.0;
wall_web   = 0.8;   // wall thickness left in front of the motor pocket
side_clear = 0.4;
guide_h    = 5.0;   // length of pin guide bores (keeps pins vertical)
guide_gap  = 1.0;   // clearance between cam max radius and guide block

$fn = 48;

// ---------------- derived values ----------------
L        = len(seq);
N        = L * repeats;
step_ang = 360 / N;
R        = dot_pitch / sin(step_ang);   // base (low) cam radius
r_max    = R + dot_height;
samples  = 24;                          // profile samples per step

gear_teeth = gear_ratio * pinion_teeth;
rp_gear    = gear_teeth * gear_module / 2;
rp_pinion  = pinion_teeth * gear_module / 2;
centre_d   = rp_gear + rp_pinion + mesh_clear;
gear_tip_r = rp_gear + gear_module;
motor_y    = -centre_d * sin(motor_ang);
motor_z    = -centre_d * cos(motor_ang);
phi_pinion = atan2(motor_z, motor_y);   // pinion direction in gear 2D coords

x_col    = [0, dot_pitch];              // column centres (dots 1-3, dots 4-6)
y_row    = [dot_pitch, 0, -dot_pitch];  // dot 1/4, 2/5, 3/6  (j = +1, 0, -1)
j_row    = [1, 0, -1];

// left-side reference planes (right side is the mirror about x = pitch/2)
gear_x0  = -disc_t/2 - gear_t;          // outer face of the left gear
x_in_l   = gear_x0 - side_clear;        // inner face of the left wall
x_in_r   = dot_pitch - x_in_l;
x_out_l  = x_in_l - wall_t;
x_out_r  = x_in_r + wall_t;
motor_face_x = x_in_l - wall_web;
pinion_x0 = gear_x0 - 0.25;             // pinion spans the gear plane, stops short of the cam
pinion_w  = gear_t + 0.1;
guide_bot = r_max + guide_gap;
z_top    = guide_bot + guide_h;
y_half   = r_max + 3;
z_bot    = -r_max - 3;

// ---------------- sequence helpers ----------------
function bit(i) = seq[((i % L) + L) % L];

// smooth cam value (0..1) at fractional step position p
function cam_f(p) =
    let(i  = round(p), d = p - i, ad = abs(d),
        nb = d >= 0 ? i + 1 : i - 1, h = dwell / 2)
    ad <= h ? bit(i)
            : let(t = (ad - h) / (1 - dwell)) bit(i) * (1 - t) + bit(nb) * t;

// step k puts cam position k under the middle pin; the pin at row j reads k+j
function find_k(top, mid, bot) =
    [for (k = [0:L-1]) if (bit(k+1) == top && bit(k) == mid && bit(k-1) == bot) k][0];

function has(d) = len([for (x = dots) if (x == d) 1]) > 0 ? 1 : 0;

k_left  = find_k(has(1), has(2), has(3)) + repeat_slot * L;
k_right = find_k(has(4), has(5), has(6)) + repeat_slot * L;

function contact_z(y, r) = sqrt(r*r - y*y);
function pin_len(y) = z_top - contact_z(y, R);

// ---------------- gear helpers ----------------
function inv_deg(a) = (tan(a) - a * PI / 180) * 180 / PI;
function tooth_psi(r, rb, half) = max(0, half - inv_deg(acos(min(1, rb / r))));

// pinion angle that keeps it meshed with a gear turned by b degrees
function pinion_rot(b) =
    phi_pinion + 180 - (b - (phi_pinion - 180 / gear_teeth)) * gear_ratio;

// ---------------- report ----------------
steps_per_cam_step = step_ang * gear_ratio / motor_step;
shaft_needed = pinion_x0 + pinion_w - motor_face_x;
echo(str("Cam base radius R = ", R, " mm, diameter = ", 2*R,
         " mm, max radius = ", r_max, " mm, steps = ", N));
echo(str("Gear ", gear_teeth, "T / pinion ", pinion_teeth, "T, module ", gear_module,
         ", gear tip radius ", gear_tip_r, " mm, centre distance ", centre_d, " mm"));
echo(str("Motor full steps per cam step = ", steps_per_cam_step,
         (steps_per_cam_step == round(steps_per_cam_step)) ? "" :
         "  WARNING: not a whole number, choose another gear_ratio"));
echo(str("Motor shaft reach needed = ", shaft_needed, " mm",
         motor_shaft_len < shaft_needed ? "  WARNING: shaft too short" :
         str(" (trim ", motor_shaft_len - shaft_needed, " mm off a ",
             motor_shaft_len, " mm shaft)")));
if (gear_tip_r > guide_bot - 0.5)
    echo("WARNING: gear tip hits the pin guide block, reduce module or teeth");
echo(str("Cell width at the walls = ", x_out_r - x_out_l,
         " mm; in a line the cell pitch would be ~", 2*(dot_pitch/2 - gear_x0) + 0.4, " mm"));
for (pat = [0:7]) {
    t = floor(pat/4) % 2; m = floor(pat/2) % 2; b = pat % 2;
    echo(str("column pattern top/mid/bot = ", t, m, b,
             "  -> step k = ", find_k(t, m, b), " (+8, +16 equivalent)"));
}
echo(str("Showing dots ", dots, ": left disc step ", k_left,
         ", right disc step ", k_right));
for (j = [0:2])
    echo(str("Pin length row ", j+1, " (y=", y_row[j], "): ",
             pin_len(y_row[j]), " mm"));

// ---------------- 2D profiles ----------------
module cam_profile() {
    polygon([for (s = [0 : N*samples - 1])
        let(p = s / samples, th = p * step_ang,
            r = R + dot_height * cam_f(p))
        [r * sin(th), r * cos(th)]]);   // 2D x -> world Y, 2D y -> world Z
}

module spur_2d(teeth, m = gear_module, pa = pressure_ang) {
    rp = teeth * m / 2;
    rb = rp * cos(pa);
    ra = rp + m;
    rf = rp - 1.25 * m;
    r0 = max(rb, rf);
    half = 90 / teeth + inv_deg(pa);
    n = 8;
    rs = [for (i = [0:n]) r0 + (ra - r0) * i / n];
    union() {
        circle(r = rf, $fn = teeth * 4);
        for (t = [0 : teeth - 1]) rotate(t * 360 / teeth)
            polygon(concat([[0, 0]],
                [for (r = rs) let(a = tooth_psi(r, rb, half)) [r * cos(-a), r * sin(-a)]],
                [for (i = [n:-1:0]) let(r = rs[i], a = tooth_psi(r, rb, half))
                    [r * cos(a), r * sin(a)]]));
    }
}

// ---------------- parts ----------------
// Left disc: cam centred on x = 0, gear on its -X (outer) face.
module disc_left() {
    difference() {
        union() {
            rotate([90, 0, 90]) linear_extrude(disc_t, center = true) cam_profile();
            translate([gear_x0, 0, 0]) rotate([90, 0, 90])
                linear_extrude(gear_t + 0.01) spur_2d(gear_teeth);
        }
        rotate([0, 90, 0]) cylinder(d = bore_d, h = 20, center = true);
        // index ticks on the inner cam face and the outer gear face;
        // long tick at the start of each sequence repeat
        for (i = [0 : N-1], fx = [disc_t/2, gear_x0])
            rotate([-i * step_ang, 0, 0])
                translate([fx - tick_depth, -0.2,
                           (i % L == 0) ? bore_d/2 + 0.8 : 4.5])
                    cube([2 * tick_depth, 0.4,
                          (i % L == 0) ? 7 - bore_d/2 - 0.8 : 2.5]);
    }
}

module disc_right() { mirror([1, 0, 0]) disc_left(); }  // about its own centre

module pinion() {   // axis along X, starts at x = 0
    difference() {
        rotate([90, 0, 90]) linear_extrude(pinion_w) spur_2d(pinion_teeth);
        rotate([0, 90, 0]) cylinder(d = motor_shaft_d - 0.05, h = 10, center = true, $fn = 16);
    }
}

module pin(len) {
    // rounded bottom tip rides the cam; origin at the lowest point of the tip
    translate([0, 0, pin_d/2]) {
        sphere(d = pin_d);
        cylinder(d = pin_d, h = len - pin_d/2);
    }
}

// mirror children about the cell centre plane x = dot_pitch/2
module about_centre(on) {
    if (on) translate([dot_pitch, 0, 0]) mirror([1, 0, 0]) children();
    else children();
}

sleeve_len = max(0, motor_len - (wall_t - wall_web) - 1);

module frame() {
    difference() {
        union() {
            // side walls
            for (x0 = [x_out_l, x_in_r])
                translate([x0, -y_half, z_bot])
                    cube([wall_t, 2*y_half, z_top - z_bot]);
            // pin guide block bridging the walls
            translate([x_out_l, -dot_pitch - 2, guide_bot])
                cube([x_out_r - x_out_l, 2*dot_pitch + 4, guide_h]);
            // base plate
            translate([x_out_l, -y_half, z_bot - 2])
                cube([x_out_r - x_out_l, 2*y_half, 2]);
            // motor clamp sleeves on the outside of each wall
            for (s = [0, 1]) about_centre(s)
                translate([x_out_l, motor_y, motor_z]) rotate([0, -90, 0])
                    cylinder(d = motor_d + 2*sleeve_wall, h = sleeve_len);
        }
        // axle holes (snug: axle is fixed, discs spin on it)
        rotate([0, 90, 0]) cylinder(d = axle_d + 0.1, h = 80, center = true);
        // pin guide bores
        for (x = x_col, y = y_row)
            translate([x, y, guide_bot - 1])
                cylinder(d = pin_d + 2*pin_clear, h = guide_h + 2, $fn = 24);
        // thumb window in the base for turning discs by hand before motors go in
        translate([x_in_l, -y_half + 3, z_bot - 3])
            cube([x_in_r - x_in_l, 2*y_half - 6, 4]);
        for (s = [0, 1]) about_centre(s) {
            // motor pocket through the sleeve, stopping at the wall web
            translate([motor_face_x, motor_y, motor_z]) rotate([0, -90, 0])
                cylinder(d = motor_d + 0.15, h = sleeve_len + wall_t);
            // hole through the web for the bearing boss and shaft
            translate([x_in_l + 0.1, motor_y, motor_z]) rotate([0, -90, 0])
                cylinder(d = motor_boss_d + 0.3, h = wall_web + 0.3, $fn = 24);
            // wire slot along the top of the sleeve
            translate([x_out_l - sleeve_len - 0.1, motor_y - 0.6, motor_z])
                cube([sleeve_len + 0.1, 1.2, motor_d/2 + sleeve_wall + 0.1]);
        }
    }
}

module motor() {   // placeholder can + shaft, left side
    color("DimGray")
        translate([motor_face_x - motor_len, motor_y, motor_z]) rotate([0, 90, 0])
            cylinder(d = motor_d, h = motor_len);
    color("Silver")
        translate([motor_face_x, motor_y, motor_z]) rotate([0, 90, 0])
            cylinder(d = motor_shaft_d, h = shaft_needed, $fn = 16);
}

module axle() {
    color("silver") rotate([0, 90, 0])
        translate([0, 0, x_out_l - 1])
            cylinder(d = axle_d, h = x_out_r - x_out_l + 2);
}

module assembly(show_frame = true) {
    ks = [k_left, k_right];
    if (show_frame) color("Gainsboro", 0.6) frame();
    axle();
    for (c = [0:1]) {
        b = ks[c] * step_ang;
        about_centre(c) {
            color(c == 0 ? "SteelBlue" : "IndianRed")
                rotate([b, 0, 0]) disc_left();
            color("Orange")
                translate([pinion_x0, motor_y, motor_z])
                    rotate([pinion_rot(b), 0, 0]) pinion();
            motor();
        }
        for (r = [0:2]) {
            y  = y_row[r];
            f  = bit(ks[c] + j_row[r]);
            zc = contact_z(y, R + dot_height * f);
            color(f ? "Gold" : "DarkGoldenrod")
                translate([x_col[c], y, zc]) pin(pin_len(y));
        }
    }
}

// ---------------- part selector ----------------
if (part == "assembly") assembly();
else if (part == "mechanism") assembly(show_frame = false);
else if (part == "section")       // thin slice through the left cam, wall removed
    intersection() {
        assembly();
        translate([-0.5, -50, -50]) cube([0.5, 100, 100]);
    }
else if (part == "disc_left")
    rotate([0, 90, 0]) translate([-gear_x0, 0, 0]) disc_left();    // gear face down
else if (part == "disc_right")
    rotate([0, -90, 0]) translate([gear_x0, 0, 0]) disc_right();   // gear face down
else if (part == "pinion")
    rotate([0, -90, 0]) pinion();      // print a few; small teeth are fragile
else if (part == "frame")
    frame();                           // print base down; pin bores come out vertical
else if (part == "pins")               // reference only: rod is better
    for (r = [0:2], c = [0:1])
        translate([r * 4, c * 3, pin_d/2]) rotate([0, 90, 0])
            rotate([0, 180, 0]) pin(pin_len(y_row[r]));
