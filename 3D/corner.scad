// corner.scad
// Ramon Ricca 2025

$fn=45;
length=40;
width=12;
counter=6;

difference() {
    // Main Cube
    cube([length, width, width]);
    
    // Screw Tap Left
    translate([-1,width/2,width/2]) rotate([0,90,0]) cylinder(h=15, d=2.5);
    // Screw Tap Right
    translate([length-14,width/2,width/2]) rotate([0,90,0]) cylinder(h=15, d=2.5);
    
    // Bottom Panel Cut
    translate([8,-1,2.9]) cube([3.4,10.1,15]);
    // PCB Cut
    translate([25,-1,2.9]) cube([2,10.1,15]);
    // Top Panel Cut
    translate([32,-1,2.9]) cube([3.4,10.1,15]);
    
    // Left Countersink
    translate([-1,width/2,width/2]) rotate([0,90,0]) cylinder(h=3, d=counter);
    // Right Countersink
    translate([length-2,width/2,width/2]) rotate([0,90,0]) cylinder(h=6, d=counter);
    //translate([39.9,11.8,5.6]) rotate([-90,270,0]) linear_extrude(height=10) text("MIXTAPE", size=4.2, font="Noto Sans:Bold", direction="ttb", spacing=0.7);
}

// Arrow
translate([8.4,2,10]) rotate([0,0,0]) linear_extrude(height=3) text("\u2192", size=14);

 