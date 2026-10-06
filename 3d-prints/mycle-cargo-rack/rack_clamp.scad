// Mycle Cargo rear-rack clamp mount (two-piece)
// Bolts onto a rack rail and gives a flat slotted flange for fixing a crate,
// deck board, box or basket. Sized for the Bambu Lab A1 (256 x 256 x 256 mm).
//
// Measure your rack rail with calipers and set tube_d before printing.
// Print in PETG or ASA (not PLA: it creeps in sun/heat), 4 walls, 40% gyroid.

/* [Rack] */
tube_d      = 16;    // rack rail outside diameter (mm)
clearance   = 0.4;   // added to bore diameter; wrap rail in 0.5 mm rubber tape

/* [Clamp] */
length      = 50;    // along the rail
wall        = 6;     // material around the bore
split_gap   = 1.0;   // total gap between halves so bolts can pull them tight
bolt_d      = 5.5;   // M5 clearance
head_d      = 9.5;   // M5 socket head counterbore
nut_af      = 8.4;   // M5 nut across flats + clearance
nut_depth   = 4.5;

/* [Mounting flange] */
flange_w    = 80;    // across the rail
flange_t    = 5;
slot_len    = 10;    // slots let you match the crate's hole spacing
slot_x      = 15;    // slot offset along rail from centre

/* [Output] */
part = "both";       // [upper, lower, both, plate]

$fn = 96;
r       = (tube_d + clearance) / 2;
bolt_y  = r + 2.5 + bolt_d / 2;
block_w = 2 * (bolt_y + bolt_d / 2 + 3.5);
top_z   = r + wall;            // top of clamp body (bottom of flange)
cap_z   = -(r + 5);            // bottom of lower cap
eps     = 0.01;

module bore() {
    rotate([0, 90, 0]) cylinder(r = r, h = length + 2, center = true);
    // 1 mm entry chamfers
    for (s = [-1, 1]) translate([s * (length / 2 - 0.5), 0, 0])
        rotate([0, s * 90, 0]) cylinder(r1 = r, r2 = r + 1.5, h = 1.5 + eps, center = true);
}

module bolt_holes() {
    for (y = [-bolt_y, bolt_y]) translate([0, y, 0])
        cylinder(d = bolt_d, h = 200, center = true);
}

module upper() {
    difference() {
        union() {
            translate([-length/2, -block_w/2, split_gap/2]) cube([length, block_w, top_z - split_gap/2]);
            translate([-length/2, -flange_w/2, top_z]) cube([length, flange_w, flange_t]);
        }
        bore();
        bolt_holes();
        // counterbores from the top, leaving 8 mm of material above the split
        for (y = [-bolt_y, bolt_y]) translate([0, y, split_gap/2 + 8])
            cylinder(d = head_d, h = 100);
        // crate mounting slots (outside the clamp body so nuts fit underneath)
        for (x = [-slot_x, slot_x], s = [-1, 1])
            hull() for (dy = [-slot_len/2, slot_len/2])
                translate([x, s * ((block_w/2 + flange_w/2) / 2) + dy, top_z - 1])
                    cylinder(d = bolt_d, h = flange_t + 2);
    }
}

module lower() {
    difference() {
        translate([-length/2, -block_w/2, cap_z]) cube([length, block_w, -cap_z - split_gap/2]);
        bore();
        bolt_holes();
        for (y = [-bolt_y, bolt_y]) translate([0, y, cap_z - eps])
            cylinder(d = nut_af / cos(30), h = nut_depth + eps, $fn = 6);
    }
}

// Print orientations: flange face down / cap bottom down, bore channel up. No supports.
module print_pair() {
    translate([0, 0, top_z + flange_t]) rotate([180, 0, 0]) upper();
    translate([0, flange_w/2 + block_w/2 + 10, -cap_z]) lower();
}

// "plate": 4 complete clamps (2 per rail) for one Bambu A1 plate (256 x 256)
if (part == "plate")
    for (i = [0:3]) translate([(i - 1.5) * (length + 8), -(flange_w + block_w + 10) / 2 + flange_w / 2, 0])
        print_pair();

if (part == "upper" || part == "both")
    translate([0, 0, top_z + flange_t]) rotate([180, 0, 0]) upper();
if (part == "lower" || part == "both")
    translate([0, flange_w/2 + block_w/2 + 10, -cap_z]) lower();
