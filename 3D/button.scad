// button.scad
// Ramon Ricca 2025

$fn=200;
width_d=9.2;
skirt_d=13;
height_w=8;
height_s=0.6;
square_d=4.4;
square_h=4;

difference() {
    union() {
        cylinder(h=height_w, d=width_d);
        cylinder(h=height_s, d=skirt_d);
        //translate([0,0,height_w]) sphere(d=width_d);
    }
    translate([-2.2,-2.2,-1]) cube([square_d, square_d, square_h]);
    chamfer(h=height_w, r=(width_d/2), chamfer=1.4);
}

/*
* helper for the chamfer 
*/
module chamfer(h, r, chamfer) {
    rotate_extrude($fn=200) translate([r-2-chamfer,h-6-chamfer,0]) polygon( points=[[0,10],[10,10], [10,0]] );
}
