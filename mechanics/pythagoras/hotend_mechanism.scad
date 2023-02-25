// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
large=1000;
support_thickness=0.4;

hotend_h=55;

hotend_tip=5;
hotend_clearance=16;


bearing_or=11/2;
bearing_h=4;
t=2;

bar_t=3;

bar_h=hotend_h+bearing_h/2;

back_l=30;


module hotend_mechanism(){
    w=bearing_or+t;
    module cyl(x, z){
        translate([x, 0, z])rotate([90,0,0])cylinder(2*w, r=0.5*bar_t, center=true);
    }
    difference(){
        union(){
            up(2*bar_h-bearing_h/2){
                cylinder(bearing_h, r=bearing_or+t);
                box([0, -w, 0], [hotend_clearance+bar_t*2, w, bearing_h]);
                hull(){
                    box([0, -w, 0], [hotend_clearance+2*bar_t, w, bearing_h]);
                    translate([hotend_clearance+2*bar_t+back_l, 0, 0])cylinder(bearing_h, r=t+1);
                }
            }
            
            sequential_hull(){
                box([hotend_clearance+bar_t, -w, 0], [hotend_clearance+bar_t*2, w, bearing_h]);
                box([hotend_clearance, -w, bar_h-0.1], [hotend_clearance+bar_t, w, bar_h+0.1]);
                box([hotend_clearance+bar_t, -w, 2*bar_h-0.5*bearing_h], [hotend_clearance+bar_t*2, w, 2*bar_h+0.5*bearing_h]);
                
            }
            sequential_hull(){
                cyl(hotend_clearance+bar_t*1.5, bar_h*2);
                cyl(hotend_clearance+bar_h*sin(60), bar_h*1.5);
                cyl(hotend_clearance+bar_t*0.5, bar_h+bar_t*0.3);
                cyl(hotend_clearance+bar_t*0.5, bar_h-bar_t*0.3);
                cyl(hotend_clearance+bar_h*sin(60), bar_h*0.5);
                cyl(hotend_clearance+bar_t*1.5, 0);
            }
            hull(){
                cyl(hotend_clearance+bar_h*sin(60), bar_h*1.5);
                cyl(hotend_clearance+bar_h*sin(60), bar_h*0.5);
            }
        }

        up(-0.5)cylinder(large, r=bearing_or);
    }
}

hotend_mechanism();