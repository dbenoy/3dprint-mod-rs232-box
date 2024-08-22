include <NopSCADlib/lib.scad>

module aligned_cube(size, alignment=[0, 0, 0]) {
    translate([size[0] / 2 * alignment[0], size[1] / 2 * alignment[1], size[2] / 2 * alignment[2]]) cube(size, center=true);
}

shell_thickness_face = 1.2;
shell_thickness_sides = 2;
clearance_below_connector = 4.5;
pcb_thickness = 1.6;

module cube_shell(size, thickness_xy, thickness_z) {
        difference() {
            translate([-thickness_xy, -thickness_xy, -thickness_z]) cube(2 * [thickness_xy, thickness_xy, thickness_z] + size);
            cube(size);
        }
}

interior_dimensions = [d_flange_length(DCONN9) + 1, d_flange_width(DCONN9) + clearance_below_connector, 32.5];
difference() {
    // Shell
    union() {
        cube_shell(interior_dimensions, shell_thickness_sides, shell_thickness_face);
        translate([interior_dimensions[0], interior_dimensions[1], interior_dimensions[2]]) {
            rotate([90, 0, -90]) linear_extrude(interior_dimensions[0]) {
                polygon([
                  [0, 0],
                  [clearance_below_connector - pcb_thickness, 0],
                  [clearance_below_connector - pcb_thickness, -5],
                  [0, -15]
                ]);
            }
        }
    }
    // DB9 Hole
    translate([d_flange_length(DCONN9) / 2 + 0.5, d_flange_width(DCONN9) / 2, 0]) mirror([0, 1, 0]) {
        d_hole(DCONN9, h=10, clearance=0.1);
        d_connector_holes(DCONN9) cylinder(d=4, h=10, center=true);
    }
    // UEXT hole
    translate([0, -shell_thickness_sides - 0.1, 21.5]) cube([interior_dimensions[0], interior_dimensions[1] + shell_thickness_sides + 0.1 - (clearance_below_connector - pcb_thickness), 30]);
    //translate([0, -shell_thickness_sides - 0.1, 21.5]) cube([interior_dimensions[0], 13, 30]);
    // Screw holes
    translate([7, 0, 0]) cube([interior_dimensions[0] - 14, interior_dimensions[1], interior_dimensions[2] + shell_thickness_face + 0.1]);
    translate([3.5, interior_dimensions[1] + 0.5, 29.7]) rotate([90, 0, 0]) cylinder(h=100, r=screw_pilot_hole(M3_cap_screw));
    translate([interior_dimensions[0] - 3.5, interior_dimensions[1] + 0.5, 29.7]) rotate([90, 0, 0]) cylinder(h=100, r=screw_pilot_hole(M3_cap_screw));
}
