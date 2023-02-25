// (C) 2023 Dmytry Lavrov.
use <../../common/common.scad>
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

module OUT_base(){
    height=15;
    cl=0.4;
    module corner_holder(){
        difference(){
            union(){
                up(height+idler_h+1){
                    cylinder((idler_rr*2-idler_h/2), r1=idler_r, r2=idler_rr);
                    up((idler_rr*2-idler_h/2))cylinder((idler_rr*2-idler_h/2), r1=idler_rr, r2=idler_r);
                }                
                box([-idler_rr, 0, 0], [idler_rr, idler_r*2, height+idler_h+1+(idler_rr*2-idler_h/2)*2]);
            }
            up(height-cl){
                cylinder(idler_h+1+cl, r=idler_r+1);
            }
            translate([0, idler_r*1.5, height+idler_h+1+(idler_rr*2-idler_h/2)])rotate([0,90,0])cylinder(large, r=1, center=true);
            translate([0, idler_r*1, height+idler_h+1+(idler_rr*2-idler_h/2)])rotate([0,90,0])cylinder(large, r=1, center=true);
            up(30)cylinder(large, r=idler_screw_head_r);
        }
        up(height-cl){
            support_cone(idler_h+1+cl, idler_screw_r+support_t, idler_r);
            support_cone(idler_h+1+cl, idler_screw_r+support_t, idler_screw_r+support_t);
        }
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
                }
            }
            x_mirror(){
                box([w/2-t, -h/2, 0], [w/2+t, h/2, height-cl]);
                hull(){
                    translate([w/2, h/2, 0])cylinder(height-5, r=t);
                    translate([-w/2, -h/2, 0])cylinder(height-5, r=t);
                }
            }
            y_mirror(){
                box([-w/2, h/2-t, 0], [w/2, h/2+t, height-cl]);
            }
            box([-w/2, -h/2, 0], [w/2, h/2, t]);
        }
        
        // holes for idler screws
        xy_mirror()translate([w/2, h/2, 0])cylinder(large, r=idler_screw_r, center=true);
        
        // Centring hole
        
        cylinder(large, r=1, center=true);
        
    }
}

joint_or=7;//3.2;
bar_t=joint_or;

module OUT_arm(n){
    arm_h=32;
    step=arm_h/8;
    arm_l=norm([w, h])+2*idler_r;
    joint_ir=2.2;

    
    clear=10;
    
    cl=0.5;
    
    catch_h=5;
    
    module cutout(){
        up(-cl/2)cylinder(step*3+cl, r=joint_or+cl);
        rotate([0,0,50])box([-large, -large, -cl/2], [cl/2, large, step*3+cl/2]);
        
        rotate([0,0,-50])box([-large, -large, -cl/2], [cl/2+bar_t, large, step*3+cl/2]);
    }
    
    module joint(){
        union(){
            if(n>0){
                cylinder(step, r=joint_or);
            }else{
                up(-catch_h)cylinder(step+catch_h, r=joint_or);
            }
            box([0, -bar_t, 0], [arm_l/2, 0, step]);
        }
    }
    
    //mirror([0,1,0])
    translate([0,0,bar_t])rotate([90,0,0])
    {    
        difference(){        
            union(){
                //up(n*step)cylinder(5*step, r=joint_or);
                up(n*step)joint();
                up((n+4)*step)joint();
                hull(){
                    box([0, -bar_t, n*step], [arm_l/2, 0, (n+5)*step]);
                    translate([arm_l, 0, idler_r])rotate([90,0,0]){
                        cylinder(joint_or, r=idler_r);
                    }
                }
                
                translate([arm_l, 0, idler_r])rotate([90,0,0]){
                    up(-0.2)cylinder(joint_or, r=idler_screw_r+0.5);
                }
            }
            cylinder(3*h, r=joint_ir, center=true);
            
            up((n+2)*step)translate([20,0,0])rotate([90,0,0])up(-1)mirror([1,0,0])linear_extrude(1.5)text(text=str(n), valign="center", halign="right");
            

            if(n>0)up((n-3)*step)cutout();
            
            up((n+1)*step)cutout();
            up((n+5)*step)cutout();
            /*    
            box([-2*joint_or, -2*joint_or, -1], [clear, 2*joint_or, n*step]);
            #up(step*(n+1))box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, step*3]);
            
            up(step*(n+1)+arm_h/2)box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, arm_h]);        
            //up(arm_h/2)box([-2*joint_or, -2*joint_or, 0], [clear, 2*joint_or, n*step]);
            */
            
            
            translate([arm_l, 0, idler_r])rotate([90,0,0]){
                cylinder(large, r=idler_screw_r, center=true);
                //cylinder(1, r=idler_r);
            }
        }
    }
}

 OUT_base();

for(i=[0:3])translate([w/2+20, i*35, 0])OUT_arm(i);

//translate([w/2+20,h/2+20,0])for(i=[0:3])rotate([0,0,i*45])OUT_arm(i);


/*
Issues/todo:
Motor mounts.
Balancing arms vertically.

Spring tensioning needs to be done on the counter-cables of the driven winches

mid-edge pulleys (with spring tensioned options).

Maybe: scale down 3x with pulleys rather than 2x

*/