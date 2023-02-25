// (C) 2023 Dmytry Lavrov.
$fa=3;
$fs=0.2;

use <../common/common.scad>

bolt_hole_r=2.4;
bearing_r=8;
bearing_h=5;

t=3;

angle=45;
angle_2=5;
//tool_h=20;

large=100;

tube_r=2;

holes_r=bearing_r*sin(angle) - 0.5;// 0.5 fudge factor for 

holes_r_high=bearing_r+tube_r;

tool_r=holes_r_high+bolt_hole_r+t;

module rotate_repeat(){
    children();
    rotate([0,0,180])children();    
}

module place_bearing(){
    rotate_repeat()translate([holes_r,0,tool_h])rotate([0, angle, 0])children();
}

module bearing(){
    c=0.3;
    #cylinder(bearing_h, r=bearing_r);
    hull(){
        cylinder(bearing_h+c, r=bearing_r+1);
        translate([50,0,0])cylinder(bearing_h+c, r=bearing_r+1);
    }
    up(-large/2)cylinder(large, r=bolt_hole_r);
}

difference(){    
    //cylinder(tool_h, r=tool_r);
    
    
    point_h=t+sin(angle)*bearing_r*2 + cos(angle)*bearing_h;
    point2_h=point_h+cos(angle)*bearing_h;
    tool_h=point2_h;
    
    union(){    
        box([-tool_r, -tool_r, 0], [tool_r, tool_r, tool_h]);
        box([-tool_r, -50, 0], [tool_r, tool_r, t]);
    }
    
    up(point_h)cylinder(tool_h, r=5);
    
    rotate_repeat(){
        translate([0,0,point_h])rotate([0, angle, 0])translate([bearing_r,0,0])bearing();
        rotate([0,0,90])translate([0,0,point2_h])rotate([0, angle_2, 0])translate([bearing_r+tube_r,0,0])bearing();
    }
    
    cylinder(large, r=bolt_hole_r);
}