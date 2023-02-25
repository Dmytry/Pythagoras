// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;

bolt_r_loose=1.2;
bolt_r=1.1;
thread_hole_r=1;
nut_r=4.4/2 + 0.2;
nut_h=1.5;
t=2;

h=5;
large=100;

module curved_cyl(h, r1, r2, slotted=true){
    intersection(){
        box([-large, -large, 0], [large, large, h]);
        translate([0, r2, 0])rotate(v=[0,1,0], a=90)rotate_extrude(angle=90, convexity=4)translate([-r2, 0, 0]){
            circle(r1);
            if(slotted)polygon([[-r1, 0], [r1, 0], [r1, -10], [-r1, -10]]);
        }
    }
}

//curved_cyl(10, 2, 20);

module head(){
    spacing=thread_hole_r+bolt_r_loose+1;
    difference(){
        hull(){
            x_mirror()translate([-spacing,0,0])cylinder(h, r=thread_hole_r+t);
        }
        
        x_mirror()translate([-spacing,0.5-thread_hole_r,0]){
            //sphere(r=thread_hole_r);
            //cylinder(h/2, r=thread_hole_r);
            curved_cyl(h+1, thread_hole_r, h*1.5);
        }
        up(-1)cylinder(h+2, r=bolt_r_loose);
    }
}

module tail(){
    spacing=thread_hole_r+bolt_r+1;
    up(h)mirror([0,0,1])
    difference(){
        hull(){
            x_mirror()translate([-spacing,0,0])cylinder(h, r=thread_hole_r+t);
        }
        
        x_mirror()translate([-spacing,0.5-thread_hole_r,0]){
            //sphere(r=thread_hole_r);
            //cylinder(h/2, r=thread_hole_r);
            curved_cyl(h+1, thread_hole_r, h*1.5);
        }
        up(-1)cylinder(h+2, r=bolt_r);
        cylinder(nut_h, r=nut_r, $fn=6);
        
    }
}

head();
translate([0, 10, 0])tail();