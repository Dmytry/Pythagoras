// (C) 2023 Dmytry Lavrov.
$fa=3;
$fs=0.2;

use <../common/common.scad>

bolt_hole_r=2.4;
bearing_r=8;
bearing_h=5;

t=3;

angle=20;
tool_h=20;

large=100;

v1=[sin(angle), 0, cos(angle)];
v2=[sin(angle)*cos(120), sin(angle)*sin(120), cos(angle)];
abv=atan2(norm(cross(v1, v2)), v1*v2);

echo(abv);

//center_to_center_dist=sin(abv/2);

holes_r=bearing_r*cos(abv/2)/sin(60);


tool_r=holes_r+bolt_hole_r+t;

module rotate_repeat(){
    children();
    rotate([0,0,120])children();
    rotate([0,0,240])children();
}

module place_bearing(){
    rotate_repeat()translate([holes_r,0,tool_h])rotate([0, angle, 0])children();
}

difference(){    
    cylinder(tool_h+tool_r*tan(angle), r=tool_r);
    place_bearing(){
        cylinder(tool_h, r=bearing_r*5);
        #cylinder(bearing_h, r=bearing_r);
        mirror([0,0,1])cylinder(large, r=bolt_hole_r);
    }
    cylinder(large, r=bolt_hole_r);
}