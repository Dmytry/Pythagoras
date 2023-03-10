// (C) 2023 Dmytry Lavrov.
// Z mechanism, proof of concept (not definite)

use <../common/common.scad>
include <dimensions.scad>
$fa=3;
$fs=0.2;

frame_w=200;
frame_h=200;

large=500;

corner_r=2;

t=4;

rope_and_screw_hole_r=0.9;

module rot_rep(n=2){
    for(i=[0:n-1]){
        rotate([0,0, i*180/n])children();
    }
}

module frame(w, h, z){
    module outer_box(){
        cyl_rounded_box([-w/2, -h/2, 0], [w/2, h/2, z], corner_r);
    }
    
    tight=0.2;
    standoff=0.5;
    anchor_screw_r=0.85;
    
    difference(){    
        union(){
            difference(){
                outer_box();
                box([-w/2+t, -h/2+t, -1], [w/2-t, h/2-t, z+1]);
            }    
            intersection(){
                outer_box();
                union(){
                    rot_rep()box([-t/2, -large, -large], [t/2, large, large]);
                    xy_mirror(){
                        translate([(w/2-t/2)/2, (h/2-t/2)/2, 0]){
                            //cylinder(z, 10);
                            rotate([0,0,atan2(h-t/2, w-t/2)])box([-large, -t/2, -large], [large, t/2, large]);
                            rotate([0,0,-atan2(h-t/2, w-t/2)])box([-large, -t/2, -large], [large, t/2, large]);                                        
                        }
                    }
                }
            }
        }        
        x_mirror()translate([w/2+standoff+1, 0, z/2])rotate([0,-90,0])cylinder(21, r=rope_and_screw_hole_r);
        
        x_mirror()translate([w/2+standoff-t/2-rope_and_screw_hole_r, 0, z])rotate([0,135,0])cylinder(large, r=rope_and_screw_hole_r, center=true);
        
        y_mirror()translate([0, h/2+standoff+1, z/2])rotate([90,0,0])cylinder(21, r=rope_and_screw_hole_r);
        
        y_mirror()translate([0, h/2+standoff-t/2-rope_and_screw_hole_r, z])rotate([-135,0,0])cylinder(large, r=rope_and_screw_hole_r, center=true);
        
        cylinder(large, r=rope_and_screw_hole_r);
        
        translate([w/6, 0, 0])cylinder(large, r=rope_and_screw_hole_r);
    }
}

module top_frame(w, h){
    wo=w+2*(idler_h/2 + 3);
    ho=h+2*(idler_h/2 + 3);
    
    idler_well_h=idler_rr;
    
    z=2*idler_rr+idler_h/2-0.5;
    cl=0.25;
    
    extra_margin=2;
    
    dir=[w, h]/norm([w,h]);
    margin2=6*idler_r;
    
    margin3=motor_hole_gap/2+he_bearing_or+idler_r;//(he_bearing_or + idler_h);
    
    motor_pos=[-w/2+motor_hole_gap/2+4, -h/2+margin3];
    
    cable_pos=[w/2-dir[0]*margin2, h/2-dir[0]*margin2];
    cable_dir=motor_pos-cable_pos;
    
    range=norm(cable_pos-motor_pos);
    
    r=3;    
    turns=range/(2*PI*r);
    shaft_l=turns*cable_r*2;
    echo("winch l:", shaft_l);
    
    //angle=atan2(shaft_l, range); 
    angle=0;
 
    long_screw_l=20;
    
    
    module place_winch(){
        translate([motor_pos[0], motor_pos[1], z-(he_bearing_or+2)*sin(angle)]){
            rotate(v=[-cable_dir[1], cable_dir[0], 0], a=-angle)
            children();
            rotate(v=[-cable_dir[1], cable_dir[0], 0], a=-90)%cylinder(large, r=1);
        }
                
    }
        
    module idler_well(){
        up(idler_well_h){
            box([-idler_r-1, -idler_h/2-cl, -large], [idler_r+1, idler_h/2+cl, large]);            
            rotate([90,0,0])cylinder(40,r=idler_screw_r, center=true);
        }
    }    
    module idler_well_v(){
        up(2*idler_rr-idler_h/2-0.5)difference(){
            cylinder(large, r=idler_r+1);
            cylinder(0.5, r=idler_screw_r+0.5);
        }
        cylinder(large, r=idler_screw_r, center=true);
    }
 
    motor_angle=20;
    
    
    difference(){
        union(){
            cyl_rounded_box([-wo/2, -ho/2, 0], [-wo/2+55, -ho/2+55, z], 1);
            
            frame(wo, ho, z);
            
            xy_mirror()
            {
                translate([w/2-idler_rr-idler_h-extra_margin, h/2, 0])hull(){
                    box([-idler_r-3, -idler_h/2-cl-2, 0], [idler_r+3, idler_h/2+cl+2, z]);            
                    translate([-idler_rr-idler_r-5, -idler_rr])cylinder(z, r=idler_r+3);
                }
            }
            
            y_mirror()
            {
                translate([w/2, h/2-idler_rr-idler_h-extra_margin, 0])rotate([0,0,90])hull(){
                    box([-idler_r-3, -idler_h/2-cl-2, 0], [idler_r+3, idler_h/2+cl+2, z]);
                    translate([-idler_rr-idler_r-5, idler_rr])cylinder(z, r=idler_r+3);
                }
            }
            place_winch()rotate([0,0,motor_angle]){
                xy_mirror()translate([motor_hole_gap/2, motor_hole_gap/2, -z])cylinder(z+shaft_l+motor_bump_h, r=4);
            }
                        
            intersection(){
                box([-wo/2, -ho/2, 0], [wo/2, ho/2, z]);
                place_winch()rotate([0,0,motor_angle]){                    
                    hull()xy_mirror()translate([motor_hole_gap/2, motor_hole_gap/2, -z])cylinder(z, r=6);
                }
            }
            
            translate([w/2-dir[0]*margin2 + idler_rr/sqrt(2), h/2-dir[1]*margin2 - idler_rr/sqrt(2), 0]) cylinder(z, r=idler_r+3);
            box([w/2-dir[0]*margin2 + idler_rr/sqrt(2), h/2-dir[1]*margin2 - idler_rr/sqrt(2)-2, 0], [wo/2, h/2-dir[1]*margin2 - idler_rr/sqrt(2) +2, z]);
            
        }
        xy_mirror()
        {
            translate([w/2-idler_rr-idler_h-extra_margin, h/2, 0]){
                idler_well();
                translate([-idler_rr-idler_r-5, -idler_rr])idler_well_v();
            }
        }
        y_mirror()
        {
            translate([w/2, h/2-idler_rr-idler_h-extra_margin, 0])rotate([0,0,90]){
                idler_well();
                translate([-idler_rr-idler_r-5, idler_rr])idler_well_v();
            }
        }

        translate([w/2-dir[0]*margin2 + idler_rr/sqrt(2), h/2-dir[1]*margin2 - idler_rr/sqrt(2), 0])idler_well_v();        
        
        place_winch(){
            //cylinder(large, r=he_bearing_or, center=true);
            //cylinder(large, r=he_bearing_or+2);
            
            cylinder(large, r=15, center=true);
            
            rotate([0,0,motor_angle]){
                xy_mirror()translate([motor_hole_gap/2, motor_hole_gap/2, 0]){
                    cylinder(large, r=motor_hole_r+0.2, center=true);
                    up(shaft_l+motor_bump_h+motor_hole_depth-long_screw_l)rotate([180,0,0])cylinder(large, r=motor_screw_head_r);
                }
            }
        }
    }
}

frame(frame_w, frame_h, 10);

translate([0, frame_h+50, 0])top_frame(frame_w, frame_h);