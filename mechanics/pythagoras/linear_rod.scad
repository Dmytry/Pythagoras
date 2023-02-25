// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
large=100;

belt_w=6;
pulley_w=7;
margin=pulley_w-belt_w;
margin_t=0.75;

small_bearing_or=16/2;
small_bearing_w=5;
t=2;

belt_l=500;

l=belt_l/2 - PI*(small_bearing_or+t);

module margin(){
    hull(){
        x_mirror()translate([l/2,0,0])cylinder(margin/2, r1=small_bearing_or+t+margin_t, r2=small_bearing_or+t);
    }
}

difference(){
    union(){
        hull(){
            x_mirror()translate([l/2,0,0])cylinder(margin/2+belt_w, r=small_bearing_or+t);
        }
        margin();
        up(margin+belt_w)mirror([0,0,1])margin();
    }
    translate([l/2,0,-1])cylinder(large, r=small_bearing_or-0.5);
    translate([l/2,0, (pulley_w-small_bearing_w)/2])cylinder(large, r=small_bearing_or+print_dilation);
    
    x_mirror(){
        translate([10, 0, pulley_w/2])rotate(v=[1,0,0], a=90)up(-large/2)cylinder(large, r=1.5);
    }
}