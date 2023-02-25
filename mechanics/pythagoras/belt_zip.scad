// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;

belt_w=6;
clearance=0.4;
mm_per_tooth=2;
//aspect=0.125;
aspect=0.25;

belt_high=1.5;
belt_low=0.75;
t=1.5;
l=20;
s=0.75;

n_teeth=5;
large=100;

// Not trying to be exact
module lockpiece(n){  
    tooth_h=belt_high-belt_low;
    polygon([
    [0,-1],[0, 0],
    for(i=[1 : n*2]) [floor(i/2)*mm_per_tooth, tooth_h*(1-2*(i/2-floor(i/2)))],
    [mm_per_tooth*n, -1-mm_per_tooth*n*aspect]
    ]);
}

module lockpiece_hole(n, expand=0){
    polygon([
    [0,-1-expand],[0, belt_high+expand], 
    [mm_per_tooth*n, belt_high+expand],
    [mm_per_tooth*n, -1-mm_per_tooth*n*aspect-expand]
    ]);
}

module OUT_lockpiece(){
    linear_extrude(belt_w)lockpiece(n_teeth);
}

a=2;
module OUT_container(){
    h=belt_w+2*t+clearance;
    l=(n_teeth+a)*mm_per_tooth;
    difference(){
        union(){
            linear_extrude(belt_w+2*t+clearance)lockpiece_hole(n_teeth+a, t);
        }
        up(t)linear_extrude(belt_w+clearance)lockpiece_hole(n_teeth+a+1, 0);
        translate([((n_teeth+a-1)*mm_per_tooth), belt_high-0.5*belt_low, -1])cylinder(large, r=1);
    }
}

bearing_r=3.5+0.1;
bearing_h=3;
rope_hole_r=1;

rod_r=2.3;

module OUT_bearing_belt(){
    a=1;
    h=belt_w+2*t+clearance;
    l=(n_teeth+a)*mm_per_tooth;
    b=16;
    difference(){
        union(){
            linear_extrude(h)lockpiece_hole(n_teeth+a, t);
            difference(){                
                hull(){
                    linear_extrude(h)lockpiece_hole(n_teeth+a, t);
                    translate([l+b, belt_high-belt_low/2, 0]) cylinder(h, r=bearing_r+t);
                    translate([l+b+bearing_r+1+rope_hole_r, belt_high-belt_low/2, 0]) cylinder(h, r=rope_hole_r+t);
                }
                box([l, -large, t], [l+b, large, h-t]);
                
            }
            translate([l+b, belt_high-belt_low/2, 0]) cylinder(h, r=bearing_r+t);
        }
        up(t)linear_extrude(belt_w+clearance)lockpiece_hole(n_teeth+a+1, 0);
        
        translate([l+b, belt_high-belt_low/2, -1]) cylinder(h+2, r=bearing_r-0.5);
        translate([l+b, belt_high-belt_low/2, h/2-bearing_h/2]) cylinder(h+2, r=bearing_r);
        
        translate([l+b+bearing_r+1+rope_hole_r, belt_high-belt_low/2, -1]) cylinder(h+2, r=rope_hole_r);
        //translate([((n_teeth+a-1)*mm_per_tooth), belt_high-0.5*belt_low, -1])cylinder(large, r=1);
    }
}

module OUT_bearing_belt_v2(){
    a=1;
    h=belt_w+2*t+clearance;
    l=(n_teeth+a)*mm_per_tooth;
    b=16;
    difference(){
        union(){
            linear_extrude(h)lockpiece_hole(n_teeth+a, t);
            difference(){                
                hull(){
                    linear_extrude(h)lockpiece_hole(n_teeth+a, t);
                    translate([l+b, belt_high-belt_low/2, 0]) cylinder(h, r=rod_r+t);
                    //translate([l+b+bearing_r+1+rope_hole_r, belt_high-belt_low/2, 0]) cylinder(h, r=rod_r+t);
                }
                box([l, -large, t], [l+b+2, large, h-t]);
                
            }
            translate([l+b, belt_high-belt_low/2, 0]) cylinder(h+0.2, r=rod_r+t);
        }
        up(t)linear_extrude(belt_w+clearance)lockpiece_hole(n_teeth+a+1, 0);
        
        translate([l+b, belt_high-belt_low/2, -1]) cylinder(h+2, r=rod_r);
        //translate([l+b, belt_high-belt_low/2, h/2-bearing_h/2]) cylinder(h+2, r=rod_r);
        
        translate([l+b+bearing_r+1+rope_hole_r, belt_high-belt_low/2, -1]) cylinder(h+2, r=rope_hole_r);
        
        box([l+b-rod_r-t-1, -large, h/4], [large, large, h*3/4]);
        //translate([((n_teeth+a-1)*mm_per_tooth), belt_high-0.5*belt_low, -1])cylinder(large, r=1);        
    }
}

module OUT_bearing_rope(){
    h=(belt_w+2*t+clearance)/2-0.2;
    difference(){
        hull(){
            cylinder(h, r=rod_r+t);
            translate([rod_r+t+1,0,0])cylinder(h, r=1+t);
        }
        cylinder(h, r=rod_r);
        translate([rod_r+t+1,0,0])cylinder(h, r=1);
    }
}


module OUT_container2(){
    a=1;
    h=belt_w+2*t+clearance;
    l=(n_teeth+a)*mm_per_tooth;
    b=16;
    difference(){
        union(){
            linear_extrude(h)lockpiece_hole(n_teeth+a, t);
            difference(){                
                hull(){
                    linear_extrude(h)lockpiece_hole(n_teeth+a, t);
                    translate([l+b, belt_high-belt_low/2, 0]) cylinder(h, r=rope_hole_r+t);                    
                }
                box([l, -large, t], [l+b, large, h-t]);
                
            }
            translate([l+b, belt_high-belt_low/2, 0]) cylinder(h, r=rope_hole_r+t);
        }
        up(t)linear_extrude(belt_w+clearance)lockpiece_hole(n_teeth+a+1, 0);
        
        translate([l+b, belt_high-belt_low/2, -1]) cylinder(h+2, r=rope_hole_r);
    }
}

OUT_lockpiece();
translate([0,-7,0])OUT_lockpiece();
translate([0,-14,0])OUT_lockpiece();

translate([-(n_teeth+a)*mm_per_tooth-1,0,0])OUT_container();

translate([0,20,0])OUT_bearing_belt_v2();
translate([-50,20,0])OUT_bearing_rope();
translate([0,40,0])OUT_container2();

module OUT_bolt_cone(){
    r=1.7;
    difference(){
        cylinder(2, r1=r+1 , r2=r);
        cylinder(3, r=r);
    }
}

module OUT_bearing_spacer(){
    h=(belt_w+2*t+clearance-bearing_h)/2+1;
    r=1.7;
    difference(){
        union(){
            cylinder(h-1.5, r=r+1);
            up(h-1.5)cylinder(2, r1=r+1 , r2=r);
        }
        cylinder(large, r=r);
    }
}
translate([0,10,0])OUT_bearing_spacer();