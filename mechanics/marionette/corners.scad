// (C) 2023 Dmytry Lavrov.
use <../../common/common.scad>
include <dimensions.scad>
$fa=3;
$fs=0.2;
t=2;

large=1000;

extra_r=5;

grab_w=5;
grab_l=40;

mid_winch_l=2*t+glass_t;

lip=1;
lip_h=2;
cable_clearance=1;

bearing_lip=0.5;

lower_winch_l=winch_turns*cable_r + lip+cable_clearance;
upper_winch_l=winch_l-lower_winch_l-mid_winch_l;
winching_height=upper_winch_l-t-glass_t/2;

echo("Winching height:", winching_height);
echo("Downforce:", 4*cable_tension*winching_height/norm([glass_w-movement_margin*2, glass_h-movement_margin*2]));


module at_motor_corners(i=0){
    if(i==0||i==1)translate([-motor_hole_gap/2, -motor_hole_gap/2, 0])children();
    if(i==0||i==2)translate([-motor_hole_gap/2, motor_hole_gap/2, 0])children();
    if(i==0||i==3)translate([motor_hole_gap/2, -motor_hole_gap/2, 0])children();
}


//translate([-50,0,0])motor_shaft();


module OUT_winch_bad_break_your_motor(){
    a=5;
    difference(){
        
        union(){
            cylinder(winch_l, r=winch_r);
            cylinder(lip, r=winch_r+lip_h);
            up(winch_l-lip)cylinder(lip, r=winch_r+lip_h);
        }
        motor_shaft();
        x_mirror(){
            up(upper_winch_l+1+sin(a)*winch_r){
                translate([motor_shaft_r+1,0,0])rotate([90-a,0,0])cylinder(large, r=0.5, center=true);
            }        
            up(winch_l-(lower_winch_l+1+sin(a)*winch_r)){
                translate([motor_shaft_r+1,0,0])rotate([90-a,0,0])cylinder(large, r=0.5, center=true);
            }
        }
    }
}

module OUT_winch(){
    a=5;
    hole_expand=0.15;
    extra_bevel=0.1;
    extra_bevel_l=2;
    
    difference(){
        union(){
        
            /*
            cylinder(lower_winch_l, r=lower_winch_r);
            up(lower_winch_l)cylinder(mid_winch_l, r=winch_r+1);
            up(lower_winch_l+mid_winch_l)cylinder(upper_winch_l, r=upper_winch_r);
            
            cylinder(lip, r=winch_r+lip_h);
            up(winch_l-lip)cylinder(lip, r=winch_r+lip_h);*/
            rotate_extrude(){
                polygon([
                [steel_shaft_r+hole_expand, extra_bevel_l],
                [steel_shaft_r+hole_expand+extra_bevel, 0],
                [lower_winch_r+lip, 0],
                [lower_winch_r, lip],
                [lower_winch_r, lower_winch_l],
                [lower_winch_r+1, lower_winch_l+1],
                [upper_winch_r+1, lower_winch_l+mid_winch_l-1],
                [upper_winch_r, lower_winch_l+mid_winch_l],
                [upper_winch_r, lower_winch_l+mid_winch_l+upper_winch_l-lip],
                [upper_winch_r+lip, lower_winch_l+mid_winch_l+upper_winch_l],
                [steel_shaft_r+hole_expand+extra_bevel, lower_winch_l+mid_winch_l+upper_winch_l],                
                
                [steel_shaft_r+hole_expand, lower_winch_l+mid_winch_l+upper_winch_l - extra_bevel_l],                
                ]);
            }
        }
        //cylinder(large, r=steel_shaft_r, center=true);
        
        x_mirror(){
            up(lower_winch_l+1+sin(a)*winch_r){
                translate([steel_shaft_r+1,0,0])rotate([90-a,0,0])cylinder(large, r=1, center=true);
            }        
            up(winch_l-(upper_winch_l+1+sin(a)*winch_r)){
                translate([steel_shaft_r+1,0,0])rotate([90-a,0,0])cylinder(large, r=1, center=true);
            }
        }
        /*hull(){
            translate([lower_winch_r+0.5, 0, lower_winch_l])sphere(0.5);
            translate([winch_r+1, 0, lower_winch_l+0.5*mid_winch_l])sphere(0.5);
        }*/
    }
}

/*
module OUT_corner(){
    motor_h=glass_t + t + upper_winch_l + motor_bump_h;
    
    translate([-winch_offset, -winch_offset, 0])up(motor_h-motor_bump_h)OUT_winch();//%cylinder(winch_l, r=winch_r);
    
    difference(){
        union(){
            hull(){
                translate([-winch_offset, -winch_offset, -t])at_motor_corners()cylinder(glass_t+2*t, r=extra_r);
                
                box([-t,-t,-t], [grab_l, grab_l, glass_t+t]);
            }
            
            translate([-winch_offset, -winch_offset, 0])sequential_hull(){
                translate([-motor_hole_gap/2, motor_hole_gap/2, 0])cylinder(motor_h, r=extra_r);
                translate([-motor_hole_gap/2, -motor_hole_gap/2, 0])cylinder(motor_h, r=extra_r);
                translate([motor_hole_gap/2, -motor_hole_gap/2, 0])cylinder(motor_h, r=extra_r);
            }
        }
        box([grab_w, grab_w, -large], [large, large, large]);
    
        #box([0,0,0], [glass_w, glass_h, glass_t]);
        // improves registration
        #cylinder(glass_t, r=2);
        
        translate([-winch_offset, -winch_offset, -t]){
            cylinder(large, r=winch_r+winch_clearance, center=true);
            at_motor_corners(){
                cylinder(large, r=motor_hole_r);
                up(motor_h+motor_hole_depth-motor_screw_l)mirror([0,0,1])cylinder(large, r=motor_screw_head_r);
            }
        }
    }
}*/

module OUT_corner_bearings(){
    motor_h=glass_t + t + upper_winch_l + motor_bump_h;
    
    cl=0.5;
    
    %translate([-winch_offset, -winch_offset, 0])up(-lower_winch_l-t)OUT_winch();//%cylinder(winch_l, r=winch_r);
    
    module bearing_support(){
        h=he_bearing_h+bearing_lip;
        difference(){
            hull(){
                    translate([-motor_hole_gap/2, motor_hole_gap/2, 0])cylinder(h, r=extra_r);
                    translate([-motor_hole_gap/2, -motor_hole_gap/2, 0])cylinder(h, r=extra_r);
                    translate([motor_hole_gap/2, -motor_hole_gap/2, 0])cylinder(h, r=extra_r);
                    cylinder(h, r=he_bearing_or+3);
            }
            up(bearing_lip)cylinder(h-bearing_lip, r=he_bearing_or);
            cylinder(h+100, r=he_bearing_or-bearing_lip);
        }
    }
    
    difference(){
        union(){
            hull(){
                translate([-winch_offset, -winch_offset, -t])at_motor_corners()cylinder(glass_t+2*t, r=extra_r);
                
                box([-t,-t,-t], [grab_l, grab_l, glass_t+t]);
            }

            support_h=winch_l+2*cl+2*(he_bearing_h+bearing_lip);
            translate([-winch_offset, -winch_offset, - t - lower_winch_l - cl - he_bearing_h - bearing_lip]){
                sequential_hull(){
                    translate([-motor_hole_gap/2, motor_hole_gap/2, 0])cylinder(support_h, r=extra_r);
                    translate([-motor_hole_gap/2, -motor_hole_gap/2, 0])cylinder(support_h, r=extra_r);
                    translate([motor_hole_gap/2, -motor_hole_gap/2, 0])cylinder(support_h, r=extra_r);
                }
                bearing_support();
                up(support_h)mirror([0,0,1])bearing_support();
            }
            
            
        }
        box([grab_w, grab_w, -large], [large, large, large]);
    
        box([0,0,0], [glass_w, glass_h, glass_t]);
        // improves registration
        cylinder(glass_t, r=2);
        
        translate([-winch_offset, -winch_offset, -t-1]){
        
            hull(){
                cylinder(2*t+glass_t+2, r=winch_r+winch_clearance);
                translate([4, 4, 0])cylinder(2*t+glass_t+2, r=winch_r+winch_clearance);
            }
            
            
            at_motor_corners(){
                cylinder(large, r=2, center=true);
                //up(motor_h+motor_hole_depth-motor_screw_l)mirror([0,0,1])cylinder(large, r=motor_screw_head_r);
            }
        }
    }
}

//OUT_corner();
OUT_corner_bearings();

//translate([50,0,0])intersection(){OUT_corner_bearings(); box([grab_l-10, -large, -large], [large, large, large]);}

translate([0,-50,0])OUT_winch();

module OUT_side_grabber(){
    difference(){
        union(){
            hull(){
                cylinder(2*t+glass_t, r=idler_r);
                box([idler_screw_r+0.5, -grab_l/2, 0], [idler_screw_r+0.5+grab_w+t, grab_l/2, 2*t+glass_t]);
            }
            up(2*t+glass_t)cylinder(lower_winch_l/2 - idler_h/2, r1=idler_screw_r+1+lower_winch_l/2 - idler_h/2, r2=idler_screw_r+1);
        }
        cylinder(large, r=idler_screw_r, center=true);
        
        y_mirror(){
            translate([idler_screw_r+t-1, 3-grab_l/2, 0])cylinder(large, r=0.9, center=true);
            translate([idler_screw_r+t-1, 6-grab_l/2, 0])cylinder(large, r=0.9, center=true);
        }
        
        box([idler_screw_r+0.5+t, -large, t], [large, large, t+glass_t]);
    }
}

translate([0,70,0])OUT_side_grabber();

cone_alpha=30;
slider_bottom_r=3+upper_winch_l*tan(cone_alpha);

module OUT_test_slider(){
    difference(){
        
        cylinder(upper_winch_l, r1=slider_bottom_r, r2=3);
        for(i=[0:90:359]){
            up(upper_winch_l)rotate([0,0,i])rotate([45,0,0])cylinder(large, r=1, center=true);
            up(upper_winch_l-20)rotate([0,0,i])rotate([90-cone_alpha,0,0])cylinder(large, r=1);
        }
    }
    
}

translate([0,150,0])OUT_test_slider();

module OUT_align_jig(){
    jig_w=2;
    t=3;
    cl=0.2;
    difference(){
        union(){
            box([-glass_w/2-t, -jig_w, 0], [glass_w/2+t, jig_w, t]);
            box([-jig_w, -glass_h/2-t, 0], [jig_w, glass_h/2+t, t]);
            x_mirror(){
                box([-glass_w/2-t, -jig_w, 0], [-glass_w/2, jig_w, t+glass_t]);
            }
            y_mirror(){
                box([-jig_w, -glass_h/2-t, 0], [jig_w, -glass_h/2, t+glass_t]);
            }
            cylinder(t, r=slider_bottom_r+3);
        }
        cylinder(t*3, r=slider_bottom_r+cl, center=true);
    }
    
}

translate([-150,-150,0])OUT_align_jig();
