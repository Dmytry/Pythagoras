// (C) 2023 Dmytry Lavrov.
// Tensioning assembly, balanced version

use <../common/common.scad>
include <dimensions.scad>
$fa=3;
$fs=0.2;

supports=true;

support_t=0.2;

module support_cone(h, r1, r2){
    difference(){
        cylinder(h, r1=r1, r2=r2);
        cylinder(h, r1=r1-support_t, r2=r2-support_t);
    }
}

w=(glass_w+2*winch_offset)/(2*winch_ratio);
h=(glass_h+2*winch_offset)/(2*winch_ratio);

t=2;

large=1000;

module rep_180(){
    children();
    rotate([0,0,180])children();
}

arm_step=4;
arm_midline_h=arm_step*5;

frame_h=10;

module frame(w_=w, h_=h){
    cl=0.5;
    x_mirror(){
        box([w_/2-t, -h_/2, 0], [w_/2+t, h_/2, frame_h-cl]);
        hull(){
            translate([w_/2, h_/2, 0])cylinder(frame_h-5, r=t);
            translate([-w_/2, -h_/2, 0])cylinder(frame_h-5, r=t);
        }
    }
    y_mirror(){
        box([-w_/2, h_/2-t, 0], [w_/2, h_/2+t, frame_h-cl]);
    }

}

total_height=2*frame_h+10*arm_step;

idler_pedestal_h=arm_midline_h-idler_rr-idler_h/2;

module combined_base(){
    cl=0.4;
    
    height=idler_pedestal_h+frame_h;
   
    rope_and_screw_hole_r=0.9;
    
    module corner_holder(){
        difference(){
            union(){
                up(height+idler_h){
                    up(cl)cylinder((idler_rr*2-idler_h/2)-cl, r1=idler_r, r2=idler_rr);
                    up((idler_rr*2-idler_h/2))cylinder((idler_rr*2-idler_h/2), r1=idler_rr, r2=idler_r);
                    up((idler_rr*2-idler_h/2)*2)cylinder(total_height-(height+idler_h + (idler_rr*2-idler_h/2)*2), r=idler_r);
                }                
                box([-idler_rr, 0, 0], [idler_rr, idler_r*2, total_height/* height+idler_h+1+(idler_rr*2-idler_h/2)*2 */ ]);
            }
            up(height-cl){
                cylinder(idler_h+cl*2, r=idler_r+1);
            }
            translate([0, idler_r*1.5, height+idler_h+(idler_rr*2-idler_h/2)])rotate([0,90,0])cylinder(large, r=rope_and_screw_hole_r, center=true);
            translate([0, idler_r*1, height+idler_h+(idler_rr*2-idler_h/2)])rotate([0,90,0])cylinder(large, r=rope_and_screw_hole_r, center=true);
            //up(30)cylinder(large, r=idler_screw_head_r);
        }
        /*
        up(height-cl){
            support_cone(idler_h+1+cl, idler_screw_r+support_t, idler_r);
            support_cone(idler_h+1+cl, idler_screw_r+support_t, idler_screw_r+support_t);
        }*/
    }
    
    
    
    difference(){
        union(){
            rep_180(){
                translate([w/2, -h/2, 0])corner_holder();
                translate([w/2, h/2, 0])rotate([0,0,90])corner_holder();
            }
            
            xy_mirror(){
                translate([w/2, h/2, 0]){
                    cylinder(height, r=idler_screw_r+1);
                    cylinder(height-cl, r=idler_rr);
                    up(height+idler_h)cylinder(height, r=idler_screw_r+1);
                }
            }
            frame();
            up(2*frame_h+10*arm_step)mirror([0,0,1])frame();
            //box([-w/2, -h/2, 0], [w/2, h/2, t]);
        }
        
        // holes for idler screws
        xy_mirror()translate([w/2, h/2, 0]){
            cylinder(large, r=idler_screw_r);
            up(height+idler_h+10)cylinder(large, r=idler_screw_head_r);
        }
        
        // Centring hole
        
        cylinder(large, r=1, center=true);
        
    }
}

base_split_h=idler_pedestal_h+frame_h+idler_h-0.01;

module OUT_lower_base(){
    intersection(){
        combined_base();
        box([-large, -large, -large], [large, large, base_split_h]);
    }
}

module OUT_upper_base(){
    rotate([180,0,0])up(-total_height){
        difference(){
            intersection(){
                combined_base();
                box([-large, -large, base_split_h], [large, large, large]);
            }
            xy_mirror(){
                translate([w/2, h/2, 0]){
                    cylinder(large, r=idler_screw_r+0.2, center=true);
                }
            }
        }
    }
}


joint_or=9;//3.2;
bar_t=joint_or;

module one_arm(n){
    step=arm_step;
    arm_l=norm([w, h])+2*idler_r-joint_or;
    joint_ir=2.2;

    
    clear=10;
    
    cl=0.75;
    
    catch_h=2.5;
    catch_or=joint_or;
    
    wheel_side_r=idler_screw_r+1.5;
    
    straight_x=joint_or+3*bar_t;
    
    module cutout(h){
        up(-cl/2)cylinder(h+cl, r=joint_or+cl);
        rotate([0,0,50])box([-large, -large, -cl/2], [cl/2 +bar_t, large, h+cl/2]);
        
        rotate([0,0,-50])box([-large, -large, -cl/2], [cl/2+bar_t, large, h+cl/2]);
    }
    
    module joint(){
        union(){
            cylinder(step, r=joint_or); 
            box([0, -bar_t, 0], [straight_x, 0, step]);
        }
    }
    
    //mirror([0,1,0])
    translate([0,0,bar_t])rotate([90,0,0])
    {    
        difference(){        
            union(){
                //up(n*step)cylinder(5*step, r=joint_or);
                
                up((-n-1)*step){
                    joint();
                    if(n==4){
                        up(-catch_h)cylinder(step+catch_h, r=catch_or);
                    }
                }
                up(n*step){
                    joint();
                    if(n==4){
                        cylinder(step+catch_h, r=catch_or);
                    }
                }
                
                sequential_hull(){
                    box([0, -bar_t, (-1-n)*step], [straight_x, 0, (-n)*step]);
                    translate([arm_l, 0, 0])rotate([90,0,0]){
                        cylinder(joint_or, r=wheel_side_r);
                    }
                    
                    box([0, -bar_t, (n)*step], [straight_x, 0, (n+1)*step]);
                }
                box([0, -bar_t, (-1-n)*step], [straight_x, 0, (n+1)*step]);
                
                translate([arm_l, 0, 0])rotate([90,0,0]){
                    up(-0.2)cylinder(joint_or, r=idler_screw_r+0.5);
                }
            }
            
            if(n==4){
                cylinder(3*h, r=joint_ir, center=true);                
            }else{
                cylinder(3*h, r=he_bearing_or, center=true);
            }
            
            /*
            up((n+2)*step)translate([20,0,0])rotate([90,0,0])up(-1)mirror([1,0,0])linear_extrude(1.5)text(text=str(n), valign="center", halign="right");
            */
            

            //if(n>0)up((n-3)*step)cutout();
            
            if(n>0)up((-n)*step)cutout(n*2*step);
            
            //up((n+5)*step)cutout();
            
            /*    
            box([-2*joint_or, -2*joint_or, -1], [clear, 2*joint_or, n*step]);
            #up(step*(n+1))box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, step*3]);
            
            up(step*(n+1)+arm_h/2)box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, arm_h]);        
            //up(arm_h/2)box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, n*step]);
            */
            
            
            translate([arm_l, 0, 0])rotate([90,0,0]){
                cylinder(large, r=idler_screw_r, center=true);
                //cylinder(1, r=idler_r);
            }
        }
    }
}

module OUT_lock_jig(){
    bh=4;
    cl=0.2;
    difference(){
        cylinder(frame_h+bh, r=joint_or+t);
        box([-t-cl, -large, bh], [t+cl, large, large]);
        box([-large, -t-cl, bh], [large, t+cl, large]);
        up(frame_h+bh-5)cylinder(large, r=joint_or+cl);
    }
}

OUT_lower_base();

translate([-w-50, 0, 0])OUT_upper_base();

//for(i=[0:3])translate([w/2+20, i*35, 0])OUT_arm(i);

module OUT_arm_1(){
    one_arm(1);
}
module OUT_arm_2(){
    one_arm(2);
}
module OUT_arm_3(){
    one_arm(3);
}
module OUT_arm_4(){
    one_arm(4);
}

for(i=[1:4])translate([w/2+20, i*50, 0])one_arm(i);

translate([0, h/2+50, 0])OUT_lock_jig();

//translate([w/2+20,h/2+100,0])for(i=[1:4])rotate([0,0,i*45])OUT_arm(i);


/*
Issues/todo:
Motor mounts.
Balancing arms vertically.

Spring tensioning needs to be done on the counter-cables of the driven winches

mid-edge pulleys (with spring tensioned options).

Maybe: scale down 3x with pulleys rather than 2x

*/