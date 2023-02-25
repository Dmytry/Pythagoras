// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;

w=146;
l=197;
t=2;
t2=2;
lip=2;
r=1.7;
hole_offset=4;

difference(){
    union(){
        box([-l/2, -w/2, 0], [l/2, w/2, t+t2]);
        box([-l/2-lip, -w/2-lip, 0], [l/2+lip, w/2+lip, t]);
    }
    y_mirror()translate([l/2-hole_offset, w/2-hole_offset, -1])cylinder(10, r=r);
    translate([-l/2+hole_offset, 0, -1])cylinder(10, r=r);
    
    up(-1)cylinder(10, r=44);
    xy_mirror()translate([82.5/2, 82.5/2,]){
        cylinder(10, r=2.6);
        cylinder(2, r1=3.2, r2=1.2);
    }
}