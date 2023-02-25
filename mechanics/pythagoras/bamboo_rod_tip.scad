// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;

bamboo_d=9.6;

print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
large=1000;

belt_w=6;
pulley_w=6.5;
flange=1;
pulley_total_h=pulley_w+2*flange;//8.5

small_bearing_or=16/2;
small_bearing_w=5;
t=2;

belt_l=500;

l=300;//belt_l/2 - PI*(small_bearing_or+t); 

rod_w=20;

/*
hull(){
    x_mirror()translate([l/2,0,0])cylinder(belt_w, r=rod_w/2);   
}*/

module guide(){
    r=rod_w/2;
    w=pulley_w;
    rotate_extrude(){
        polygon(points=[
        [0,0], 
        [r+flange, 0],
        [r, flange],
        [r, flange+w],
        [r+flange, 2*flange+w],
        [0, 2*flange+w]        
        /*
        [r, 3+w],
        [r, 3+2*w],
        [r+1, 4+2*w],
        [0, 4+2*w]*/
        ]);
    }
}

module bamboo_tip(r){
    difference(){
        guide();
        translate([-rod_w/4,0,pulley_total_h/2])rotate(v=[0,1,0], a=90)cylinder(large, r);
    }
}

bamboo_tip(9.6/2);
s=rod_w+3;
translate([s,0,0])bamboo_tip(8.7/2);
translate([0,s,0])bamboo_tip(8.7/2);
translate([s,s,0])bamboo_tip(7.8/2);
translate([-s,s,0])bamboo_tip(7.1/2);

// height of tensioner: 19;
module tensioner(){
    c=0.5;
    g=2;
    bar_w=rod_w-2*g;
    f=2;
    screw_r=1.45;
    screw_r_loose=1.6;
    expand=2;
    screw_l=30;
    max_expansion=5;
    screw_head_r=3;
    screw_and_wrench_h=55;
    difference(){

        union(){
            translate([-l/2,0,0])guide();
            translate([l/2,0,0])guide();
            translate([l/2,0,pulley_total_h])guide();            
            box([-l/2, -bar_w/2, 0], [l/2, bar_w/2, pulley_total_h]);
            hull(){
                box([0, -bar_w/2, 0], [l/2, bar_w/2, pulley_total_h]);
                box([l/2-1, -bar_w/2, 0], [l/2, bar_w/2, pulley_total_h*2]);
            }
        }
        // Ball bearing hole
        translate([l/2,0,0]){
            cylinder(small_bearing_w, r=small_bearing_or);
            cylinder(large, r=small_bearing_or-0.5);
            up(pulley_total_h*2-small_bearing_w)cylinder(small_bearing_w+1, r=small_bearing_or);
        }
        
        // Tensioning mechanism
        translate([rod_w/2-l/2,0,0]){
            box([0, -large, -large], [c, bar_w/2-f, large]);
            box([c+f, -(bar_w/2-f), -large], [2*c+f, large, large]);
            box([2*(c+f), -large, -large], [2*(c+f)+c, bar_w/2-f, large]);
            up(pulley_total_h/2)rotate(v=[0,1,0], a=90){
                hull(){
                    y_mirror()translate([0,expand,0])cylinder(2*(c+f)+c, r=screw_r_loose);                
                }
                cylinder(h=screw_l, r=screw_r);                
                up(-rod_w/2)cylinder(h=rod_w/2, r=screw_r_loose);
                up(screw_l-rod_w/2-max_expansion){
                    x_mirror()hull(){
                        h=screw_and_wrench_h;
                        cylinder(h=h, r=screw_head_r);
                        box([-large, 2.5-bar_w/2, 0], [-pulley_total_h/2, bar_w/2-2.5, h]);
                    }
                }
            }
        }
    }
}

//tensioner();
