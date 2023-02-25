// (C) 2023 Dmytry Lavrov.
$fa=3;
$fs=0.2;

use <../common/common.scad>

/*
bolt_r_loose=1.2;
bolt_r=1.1;
thread_hole_r=1;
nut_r=4.4/2 + 0.2;
nut_h=1.5;*/

bamboo_rod_r=2.1;


t=1;

h=5;
large=100;
alpha=atan(0.5);

w=10;


module OUT_corner(){
    // needs to be thicker to avoid bending momentum from the string
    h=2*t+bamboo_rod_r*6;
    ex=1;
    
    difference(){
        intersection(){
            box([-large, -large, 0], [large, large, h]);
            hull(){
                //cyl_rounded_box([-t-bamboo_rod_r, -t-bamboo_rod_r, 0], [w, w, h], t);
                up(t+bamboo_rod_r*3){
                    rotate(v=[0,1,0], a=90)cylinder(w+bamboo_rod_r, r=bamboo_rod_r+t+ex);
                    rotate(v=[1,0,0], a=-90)cylinder(w+bamboo_rod_r, r=bamboo_rod_r+t+ex);                    
                }
                up(t+bamboo_rod_r)rotate(v=[-1,2,0], a=90)up(bamboo_rod_r)cylinder(w, r=bamboo_rod_r+t);
                cylinder(h, r=1+t);
            }
        }
        
        up(t+bamboo_rod_r*3){
            rotate(v=[0,1,0], a=90)up(bamboo_rod_r)cylinder(large, r=bamboo_rod_r);
            rotate(v=[1,0,0], a=-90)up(bamboo_rod_r)cylinder(large, r=bamboo_rod_r);
        }
        up(t+bamboo_rod_r)rotate(v=[-1,2,0], a=90)up(bamboo_rod_r)cylinder(large, r=bamboo_rod_r);
        
        // superglue fill ports
        up(t+bamboo_rod_r*3)translate([w/2, 0, 0])cylinder(h, r=1);
        up(t+bamboo_rod_r*3)translate([0, w/2, 0])cylinder(h, r=1);        
        up(t+bamboo_rod_r)translate([w*2/3, w/3, 0])cylinder(h, r=1);
        
        // Slot for the rope
        up(-1)hull(){
            cylinder(large, r=1);
            translate([-20,-20, 0])cylinder(large, r=1);
        }
        // Aux mounting hole
        //translate([w-t-1, w-t-1, -1])cylinder(large, r=1);
    }
}

translate([-25,-25,0])OUT_corner();
translate([25,-25,0])OUT_corner();
translate([25,25,0])OUT_corner();
translate([-25,25,0])OUT_corner();

module OUT_edge(){
    h=2*t+bamboo_rod_r*2;
    ex=0.5;    
    intersection(){
        box([-large, -large, 0], [large, large, h]);
        up(h/2)
        difference(){
            hull(){
                rotate(a=90, v=[0,1,0])up(-w)cylinder(2*w, r=bamboo_rod_r+t+ex);
                rotate(a=90, v=[-1,0,0])cylinder(w+bamboo_rod_r, r=bamboo_rod_r+t+ex);
            }
            rotate(a=90, v=[0,1,0])up(-w*2)cylinder(4*w, r=bamboo_rod_r);
            rotate(a=90, v=[-1,0,0])up(bamboo_rod_r)cylinder(w+1, r=bamboo_rod_r);
            
            // superglue fill holes
            cylinder(large, r=1);
            translate([0, w/2 + bamboo_rod_r/2])cylinder(large, r=1);
        }
    }
}

//translate([30,0,0])OUT_edge();
//translate([-30,0,0])OUT_edge();
translate([0,30,0])OUT_edge();
translate([0,-30,0])OUT_edge();

module OUT_spider(){
    h=2*t+bamboo_rod_r*6;
    r=bamboo_rod_r;
    ex=0.5;
    intersection(){
        box([-large, -large, 0], [large, large, h]);        
        difference(){
            hull(){
                up(t+r)rotate(a=90, v=[1,2,0])up(-w)cylinder(2*w, r=bamboo_rod_r+t+ex);                
                up(t+r*5)rotate(a=90, v=[-1,2,0])up(-w)cylinder(2*w, r=bamboo_rod_r+t+ex);
                up(t+r*3)rotate(a=90, v=[1,0,0])up(-w)cylinder(2*w, r=bamboo_rod_r+t+ex);
                translate([5*r,0,0])cylinder(h, r=bamboo_rod_r+t+ex);
            }
            
            up(t+r)rotate(a=90, v=[1,2,0])up(-large/2)cylinder(large, r=bamboo_rod_r);                
            up(t+r*5)rotate(a=90, v=[-1,2,0])up(-large/2)cylinder(large, r=bamboo_rod_r);
            up(t+r*3)rotate(a=90, v=[1,0,0])up(-large/2)cylinder(large, r=bamboo_rod_r);
            translate([5*r,0,-1])cylinder(h+2, r=bamboo_rod_r);
            /*union(){
                rotate(a=90, v=[0,1,0])up(-w)cylinder(2*w, r=bamboo_rod_r+t+ex);
                rotate(a=90, v=[-1,0,0])cylinder(w+bamboo_rod_r, r=bamboo_rod_r+t+ex);
            }*/            
        }
    }
}
OUT_spider();

module OUT_rope_cross(){
    or=bamboo_rod_r+t;
    rope_w=1;
    w=5;
    difference(){
        union(){
            cylinder(w, r=or);
            up(w){
                difference(){
                    sphere(r=or);
                    rotate(a=90, v=[2,1,0])up(-rope_w/2)cylinder(rope_w, r=or+2);
                    rotate(a=90, v=[-2,1,0])up(-rope_w/2)cylinder(rope_w, r=or+2);
                }
                hull(){
                    sphere(r=bamboo_rod_r);
                    up(-1)cylinder(1, r=or);
                }
            }
        }
        cylinder(w, r=bamboo_rod_r);
    }
}
translate([30,0,0])OUT_rope_cross();
translate([20,0,0])OUT_rope_cross();

