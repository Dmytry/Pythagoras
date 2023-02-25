// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
large=100;

pulley_r=12/2;
belt_t=1.5;
belt_clearance=1;
small_bearing_or=16/2;
big_bearing_or=22/2;
big_bearing_ir=8/2;
big_bearing_t=7;

bolt_head_r=3.5;
bolt_thread_l=16;

large_gap=2*big_bearing_or+belt_clearance+belt_t;
small_gap=pulley_r+2*belt_t+belt_clearance+big_bearing_or;

x=large_gap/2;
y=sqrt(small_gap*small_gap-x*x);

t=5;

module bottom(){
    difference(){
        union(){
            hull(){
                x_mirror()translate([x, 0, 0])cylinder(t, r=big_bearing_ir+2);
                translate([0,y,0])cylinder(t, r=small_bearing_or+3);
            }
            x_mirror()translate([x, 0, 0]){
                cylinder(t+1.3, r=big_bearing_ir+2);
                cylinder(t+1.3+big_bearing_t, r=big_bearing_ir /*-print_dilation */);
            }
        }
        translate([0,y,-1])cylinder(large, r=small_bearing_or+print_dilation);
        
        x_mirror()translate([x, 0, -1]){
                cylinder(large, r=2);
                //up(bolt_thread_l)cylinder(large, r=bolt_head_r);
        }
    }
}
bottom();

module top(){
    h=bolt_thread_l-(t+1.3+big_bearing_t);
    difference(){
        union(){
            hull(){
                x_mirror()translate([x, 0, 0])cylinder(h-0.5, r=big_bearing_ir+2);                
            }
            x_mirror()translate([x, 0, 0]){
                cylinder(h, r=big_bearing_ir+2);                
            }
        }
        x_mirror()translate([x, 0, -1]){
                cylinder(large, r=2.2);                
        }
    }
}

translate([0, -20, 0])top();