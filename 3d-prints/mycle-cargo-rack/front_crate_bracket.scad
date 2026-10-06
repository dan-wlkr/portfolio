// Mycle Cargo front crate bracket for a Basil bicycle crate
// Bolts to the 4 threaded bosses on the front of the head tube (the same
// bosses Mycle's own front rack uses). A cantilever tongue sticks forward
// over the front wheel; two cross arms bolt on top and the crate bolts to
// the arms. Sized for the Bambu Lab A1 (256 x 256 x 256 mm).
//
// PRINT THE FIT TEMPLATE FIRST (part = "template") and set the boss
// spacing below until it drops straight onto all 4 bosses.
//
// Strength: the bracket is printed on its side so every load runs along
// the layers, not across them. Use PETG or ASA, 6 walls, 50% gyroid.

/* [Head tube bosses] */
// Same 4-bolt pattern as Rad Power Bikes' front rack mount:
// 1 3/16" x 3.5" centre to centre, M5 bolts (4 mm Allen key, 5-8 Nm).
boss_v      = 88.9;  // centre-to-centre, lower pair to upper pair, along the head tube
boss_h      = 30.2;  // centre-to-centre, left boss to right boss
boss_d      = 13;    // outside diameter of a boss (template only)
bolt_d      = 5.5;   // M5 clearance (set 6.6 if your bosses take M6)
head_d      = 10;    // M5 socket/button head counterbore (12 for M6)
head_angle  = 70;    // head tube angle from horizontal (phone level app)

/* [Bracket] */
strip_t     = 24;    // thickness of the part against the head tube
tongue_len  = 200;   // how far the tongue reaches forward
tip_depth   = 16;    // tongue depth at the front
root_depth  = 38;    // tongue depth where it meets the head tube
crown_clear = 15;    // set-back below the lower bosses, clears headset/fork crown
light_hole  = true;  // M5 hole under the tip to re-mount the headlight

/* [Cross arms] */
arm_len     = 240;   // across the bike
arm_w       = 30;
arm_h       = 18;
arm_bolt_d  = 5.5;   // M5
nut_af      = 8.4;   // M5 nut across flats + clearance

/* [Output] */
part = "plate";      // [plate, bracket, arm, washers, template, assembly]

$fn = 64;
eps = 0.01;
W   = max(60, boss_h + 30);          // bracket width across the bike
c = cos(head_angle); s = sin(head_angle);

// Side profile coordinates: x forward, y up, origin = lower boss centre on
// the plane the boss faces sit in. a = up the head tube, n = straight out of it.
function at(u, n) = [-c * u + s * n, s * u + c * n];

front_low  = at(0, strip_t);
tongue_top = front_low[1] - head_d/2 * s - 3;   // just under the lower bolt head
tongue_bot = tongue_top - root_depth;
// where the strip's front face meets the tongue top
x_face     = front_low[0] + (tongue_top - front_low[1]) * (-c / s);
arm1_x     = x_face + 8 + arm_w/2;
arm2_x     = tongue_len - 12 - arm_w/2;
arm_hole_z = [W/2 - 15, W/2 + 15];

module profile() {
    difference() {
        union() {
            // strip against the head tube
            multmatrix([[s, -c, 0, 0], [c, s, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]])
                translate([0, -80]) square([strip_t, boss_v + 18 + 80]);
            // tapered tongue
            polygon([[x_face - 40, tongue_top], [tongue_len, tongue_top],
                     [tongue_len, tongue_top - tip_depth], [tongue_len * 0.55, tongue_bot],
                     [x_face - 40, tongue_bot]]);
            // fillet between strip face and tongue top
            polygon([[x_face - 10, tongue_top - 1], [x_face + 8, tongue_top - 1],
                     [x_face - 8 * c / s, tongue_top + 8]]);
        }
        // nothing behind the boss faces
        multmatrix([[s, -c, 0, 0], [c, s, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]])
            translate([-200, -300]) square([200, 600]);
        // set back below the lower bosses for the headset / fork crown
        multmatrix([[s, -c, 0, 0], [c, s, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]])
            translate([-200, -300]) square([200 + crown_clear, 300 - 12]);
        // nothing below the tongue
        translate([-300, tongue_bot - 300]) square([600, 300]);
    }
}

module bracket() {
    difference() {
        linear_extrude(W) profile();
        // head tube bolts (straight out of the head tube), counterbored from the front
        for (u = [0, boss_v], z = [W/2 - boss_h/2, W/2 + boss_h/2]) {
            p = at(u, 0);
            translate([p[0], p[1], z]) rotate([0, 0, 90 - head_angle]) rotate([0, 90, 0]) {
                translate([0, 0, -5]) cylinder(d = bolt_d, h = strip_t + 10);
                translate([0, 0, 12]) cylinder(d = head_d, h = 60);   // leaves 12 mm under the head
            }
        }
        // arm bolts: straight down through the tongue, nut pockets from below
        for (x = [arm1_x, arm2_x], z = arm_hole_z) {
            translate([x, 0, z]) rotate([90, 0, 0]) cylinder(d = arm_bolt_d, h = 400, center = true);
            translate([x, tongue_top - 12, z]) rotate([90, 0, 0]) rotate([0, 0, 30])
                cylinder(d = nut_af / cos(30), h = 100, $fn = 6);
        }
        if (light_hole) translate([tongue_len - 10, 0, W/2]) rotate([90, 0, 0])
            cylinder(d = 5.5, h = 400, center = true);
    }
}

module arm() {
    difference() {
        translate([-arm_len/2, -arm_w/2, 0]) cube([arm_len, arm_w, arm_h]);
        for (z = arm_hole_z) translate([z - W/2, 0, -1]) cylinder(d = arm_bolt_d, h = arm_h + 2);
        // long slots so the crate bolts can find gaps in the crate floor grid
        for (sx = [-1, 1]) hull() for (x = [45, arm_len/2 - 12]) translate([sx * x, 0, -1])
            cylinder(d = arm_bolt_d, h = arm_h + 2);
    }
}

module washer() {
    difference() {
        translate([-20, -20, 0]) cube([40, 40, 4]);
        translate([0, 0, -1]) cylinder(d = arm_bolt_d, h = 6);
    }
}

module template() {
    difference() {
        hull() for (x = [-boss_h/2, boss_h/2], y = [0, boss_v])
            translate([x, y, 0]) cylinder(d = boss_d + 12, h = 3);
        for (x = [-boss_h/2, boss_h/2], y = [0, boss_v])
            translate([x, y, -1]) cylinder(d = boss_d + 0.6, h = 5);
        translate([0, boss_v/2, 2]) linear_extrude(2)
            text(str(boss_h, "x", boss_v), size = 6, halign = "center", valign = "center");
    }
}

// Everything on one A1 plate: bracket on its side, 2 arms, 8 washers
if (part == "plate") {
    bracket();
    for (i = [0:1]) translate([tongue_len/2 - 10, tongue_bot - 10 - arm_w/2 - i * (arm_w + 6), 0]) arm();
    for (i = [0:7]) translate([x_face + 30 + (i % 4) * 44, tongue_top + 26 + floor(i / 4) * 44, 0]) washer();
}

// How it sits on the bike (not for printing). x forward, y up, z across.
module along_tube() rotate([0, 0, 90 - head_angle]) rotate([-90, 0, 0]) children();
module out_of_tube() rotate([0, 0, 90 - head_angle]) rotate([0, 90, 0]) children();
if (part == "assembly") rotate([90, 0, 0]) {
    color("gold") translate(at(-20, -32)) along_tube() cylinder(d = 44, h = boss_v + 80);
    color("gold") for (u = [0, boss_v], z = [-boss_h/2, boss_h/2])
        translate([at(u, -12)[0], at(u, -12)[1], z]) out_of_tube() cylinder(d = boss_d, h = 12);
    color("royalblue") translate([0, 0, -W/2]) bracket();
    for (x = [arm1_x, arm2_x]) color("orange") translate([x, tongue_top, 0])
        multmatrix([[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, 0], [0, 0, 0, 1]]) arm();
    color("sandybrown", 0.3) translate([x_face + 4, tongue_top + arm_h, -150]) cube([300, 4, 300]);  // crate floor
}

if (part == "bracket") bracket();
if (part == "arm") arm();
if (part == "washers") for (i = [0:7]) translate([(i % 4) * 46, floor(i / 4) * 46, 0]) washer();
if (part == "template") template();
