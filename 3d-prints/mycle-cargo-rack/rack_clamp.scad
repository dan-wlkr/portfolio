// Mycle Cargo front-rack clamp mount for a Basil bicycle crate (two-piece)
// Each clamp grips one of the rack's long side tubes and gives a flat slotted
// flange. The crate sits on 4 flanges; M5 bolts go up through the flange slots
// and the crate's grid floor into a printed spreader plate inside the crate.
// Sized for the Bambu Lab A1 (256 x 256 x 256 mm). Also fits rear racks.
//
// Measure your rack rail with calipers and set tube_d before printing.
// Print in PETG or ASA (not PLA: it creeps in sun/heat), 4 walls, 40% gyroid.

/* [Rack] */
tube_d      = 20;    // rack tube outside diameter (mm), estimated from photo: MEASURE
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
flange_t    = 5;
slot_len    = 10;    // slots let you match the crate's hole spacing
slot_x      = 15;    // slot offset along rail from centre

/* [Crate spreader] */
spreader_t  = 4;     // plate inside the crate that spreads the bolt load

/* [Output] */
part = "both";       // [upper, lower, both, plate, spreader, spreaders, all]

$fn = 96;
r       = (tube_d + clearance) / 2;
bolt_y  = r + 2.5 + bolt_d / 2;
block_w = 2 * (bolt_y + bolt_d / 2 + 3.5);
top_z   = r + wall;            // top of clamp body (bottom of flange)
cap_z   = -(r + 5);            // bottom of lower cap
// slots start 5 mm clear of the clamp body so bolt heads fit underneath
slot_y  = block_w/2 + 5 + slot_len/2;
flange_w = 2 * (slot_y + slot_len/2 + 6);
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
                translate([x, s * slot_y + dy, top_z - 1])
                    cylinder(d = bolt_d, h = flange_t + 2);
    }
}

// Sits on the crate floor inside the crate, holes matching the flange slots
module spreader() {
    difference() {
        hull() for (x = [-1, 1], y = [-1, 1])
            translate([x * (length/2 - 4), y * (flange_w/2 - 4), 0]) cylinder(r = 4, h = spreader_t);
        for (x = [-slot_x, slot_x], s = [-1, 1])
            hull() for (dy = [-slot_len/2, slot_len/2])
                translate([x, s * slot_y + dy, -1])
                    cylinder(d = bolt_d, h = spreader_t + 2);
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
if (part == "spreader") spreader();
if (part == "spreaders")
    for (i = [0:3]) translate([(i - 1.5) * (length + 8), 0, 0]) spreader();
// "all": 4 clamps + 4 crate spreaders on one A1 plate
plate_d = flange_w + 10 + block_w + 10 + flange_w;
if (part == "all")
    for (i = [0:3]) translate([(i - 1.5) * (length + 8), 0, 0]) {
        translate([0, -plate_d/2 + flange_w/2, 0]) print_pair();
        translate([0, plate_d/2 - flange_w/2, 0]) spreader();
    }
