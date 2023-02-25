// (C) 2023 Dmytry Lavrov.
use <../../common/common.scad>

$fa=3;
$fs=0.2;

screw_r=1;

w=100;
h=100;
t=7.75; // compatibility with a popular toy.

pulley_r=2.5;
ex=pulley_r+1;

bar_t=3;

large=200;

module pulley_hole(){
    cylinder(t*3, r=screw_r, center=true);
    up(t-2)cylinder(t, r=pulley_r);
}

module frame(w,h){
    union(){
        y_mirror()hull()x_mirror()translate([h/2, w/2, 0])cylinder(t, r=bar_t/2);
        x_mirror()hull()y_mirror()translate([h/2, w/2, 0])cylinder(t, r=bar_t/2);
        xy_mirror()translate([h/2, w/2, 0])cylinder(t, r=ex);
    }
}


module OUT_base(){
    difference(){
        //cyl_rounded_box([-w/2 - ex, -h/2-ex, 0], [w/2+ex, h/2+ex, t], ex);
        union(){
            frame(w,h);
            frame(w/2, h/2);
            xy_mirror()hull(){
                translate([w/2, h/4, 0])cylinder(t, r=bar_t/2);
                translate([w/4, h/4, 0])cylinder(t, r=bar_t/2);
            }
            xy_mirror()hull(){
                translate([w/4, h/2, 0])cylinder(t, r=bar_t/2);
                translate([w/4, h/4, 0])cylinder(t, r=bar_t/2);
            }
        }
        xy_mirror(){
            translate([w/2, h/2, 0]){
                pulley_hole();
            }
            translate([w/4, h/4, 0])mirror([0,0,1])up(-t){
                pulley_hole();
            }
        }
        
        
    }
}

OUT_base();

module OUT_arm(n){
    arm_h=16;
    step=arm_h/8;
    arm_l=norm([w/2, h/2]);
    joint_ir=2.2;
    joint_or=3.2;
    clear=10;
    difference(){        
        union(){
            cylinder(arm_h, r=joint_or);
            hull(){
                box([0, -joint_or, 0], [arm_l/2, 0, arm_h]);
                translate([arm_l, 0, 3])rotate([90,0,0]){
                    cylinder(joint_or, r=3);
                }
            }
        }
        cylinder(3*h, r=joint_ir, center=true);
        box([-2*joint_or, -2*joint_or, -1], [clear, 2*joint_or, n*step]);
        up(step*(n+1))box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, step*3]);
        up(step*(n+1)+arm_h/2)box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, arm_h]);
        
        up(arm_h/2)box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, n*step]);
        
        translate([arm_l, 0, 3])rotate([90,0,0]){
            cylinder(large, r=1);
            cylinder(1, r=pulley_r);
        }
    }
}

for(i=[0:3])
translate([w/2+20, i*20, 0])OUT_arm(i);