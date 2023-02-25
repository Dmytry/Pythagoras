// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
large=1000;

//supports=true;
support_thickness=0.4;

belt_w=6;

belt_gap=2;

belt_pitch=2;
pulley_teeth=20;

pulley_r=pulley_teeth*belt_pitch/(2*PI);

echo("gt2*20 Pulley radius", pulley_r);

// sin(a)*2*pulley_r=belt_w+belt_gap
// a=asin((belt_w+belt_gap)/(2*pulley_r))

motor_angle=asin((belt_w+belt_gap)/(2*pulley_r));

echo("Motor angle:", motor_angle);

motor_hole_gap=31;
motor_hole_r=1.65;
motor_screw_head_r=3.5;

motor_hole_depth=3.5;

motor_margin=3;
motor_w=42+2*motor_margin;

motor_bump_r=11.5;
motor_bump_h=2;

screw_l=10;
plate_t=screw_l-motor_hole_depth;

pulley_centre_height=5;

// Mount for the rail
rail_carriage_w=44;
rail_carriage_h=51;
// Four m5x16 bolts.
rail_carriage_bolt_h_spacing=32;
rail_carriage_bolt_v_spacing=36;
rail_carriage_hole_depth=5;
rail_carriage_bolt_r=2.6;
rail_carriage_bolt_head_r=4.5;
rail_carriage_bolt_l=16;

// For the arm holder
pulley_w=6.5;
flange=1;
pulley_total_h=pulley_w+2*flange;//8.5
small_bearing_or=16/2;
small_bearing_w=5;
arm_l=250;
arm_w=25;
arm_h=70;

hinge_r=small_bearing_or+2;

bearing_lip=1;
hinge_bolt_hole_r=2.4;


module motor_mounting_plate(){
    difference(){
        box([-motor_w/2, -motor_w/2, 0], [motor_w/2, motor_w/2, plate_t]);
        xy_mirror(){
            translate([motor_hole_gap/2, motor_hole_gap/2, -1])cylinder(large, r=motor_hole_r);
        }
        
        up(-1)hull(){
            cylinder(plate_t+5, r=motor_bump_r);
            translate([-motor_w, 0, 0])cylinder(plate_t+5, r=motor_bump_r);
        }
    }
}

module motor_negative(plate=true, cutout=true){
    box([-motor_w/2, -motor_w/2, -large], [motor_w/2, motor_w/2, 0]);

    if(plate){
        box([-motor_w, -motor_w, plate_t], [motor_w, motor_w, large]);
    }
    xy_mirror(){
        translate([motor_hole_gap/2, motor_hole_gap/2, 0]){
            up(-1)cylinder(plate_t*2+5, r=motor_hole_r);
            if(!plate){
                up(plate_t)cylinder(plate_t+30, r=motor_screw_head_r);
            }
        }
    }
    if(cutout){
        up(-1E-3)hull(){
            cylinder(plate_t+50, r=motor_bump_r);
            translate([-large, 0, 0])cylinder(plate_t+50, r=motor_bump_r);
        }
    }
}

//translate([0,100,0])motor_mounting_plate();
//translate([100,100,0])%motor_negative();

h=20;
twist_l=60;

standoff=0.5;
one_pulley_h=8.5;

rotation_h_over_motor=pulley_centre_height+motor_bump_h;

module motor_hole(plate=true, cutout=true){
    up(h+one_pulley_h+standoff)
    rotate(v=[1,0,0], a=-motor_angle)
    {
        up(-rotation_h_over_motor)motor_negative(plate, cutout);
    }
}

st=2.5;

module motor_and_pulley_mount(){

    
    st=2.5;
    
    
    
    high_y=0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle)+5;
    low_y=-0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle);
                
    
    
    difference(){
        union(){    
            difference(){
                box([-motor_w/2-st, low_y, 0],[motor_w/2+st, high_y, h+one_pulley_h+standoff+sin(motor_angle)*motor_w/2 + cos(motor_angle)*(plate_t-rotation_h_over_motor)]);
                motor_hole(true);
                box([-motor_w/2-st-1, 0, h],[0, high_y, large]);
            }
            // Extra box shape
             
            difference(){
                box([-motor_w/2-st, low_y, 0],[motor_w/2+st, high_y, h]);
                motor_hole(false);
            }
        }
        
        /*
        // rail mount holes
        x_mirror(){
            translate([motor_w/2+st - h/2, high_y, h/2])rotate(a=-90, v=[1,0,0]){
                up(5-12){
                    cylinder(large, r=2.2);
                    mirror([0,0,1])cylinder(large, r=3.6);
                }
            }
            
            translate([motor_w/2+st - h/2, high_y-h/2, 0]){
                up(12-5){
                    mirror([0,0,1])cylinder(large, r=2.2);
                    cylinder(large, r=3.6);
                }
            }
        } */
    }
    difference(){
        union(){
            hull(){
                difference(){
                    box([-motor_w/2-st, low_y, 0],[-motor_w/2, high_y, h]);
                    //motor_hole();
                }
                translate([-twist_l, 0, 0])cylinder(h, r=4);
            }
            translate([-twist_l, 0, 0])cylinder(h+standoff, r=4);
        }
        translate([-twist_l, 0, -1])cylinder(large, r=2);
        translate([-twist_l+20, 0, -1])cylinder(large, r=2);
    }
}

module motor_and_pulley_mount_side_plate(a, b){
    standoff=0.5;
    one_pulley_h=8.5;
    
    
    
    rotation_h_over_motor=pulley_centre_height+motor_bump_h;
    
    high_y=0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle)+5;
    low_y=-0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle);
    
    module motor_hole(plate=true){
        up(h+one_pulley_h+standoff)
        rotate(v=[1,0,0], a=-motor_angle)
        {
            up(-rotation_h_over_motor)motor_negative(plate);
        }
    }
    
    if(a){
        difference(){
            box([motor_w/2, low_y, 0],[motor_w/2+st, high_y, h+one_pulley_h+standoff+sin(motor_angle)*motor_w/2 + cos(motor_angle)*(plate_t-rotation_h_over_motor)]);
            motor_hole();
            
        }
    }
    if(b){
        box([motor_w/2, low_y, 0],[motor_w/2+st, high_y, h]);
    }
}

/*
hull(){
    x_mirror()translate([-twist_l-motor_w/2-20,0,0]){
        rotate(v=[0,0,1], a=-17)translate([twist_l,0,0])motor_and_pulley_mount_side_plate();
    }
}*/

//pulley_dist=2*twist_l+motor_w+40;

module v_mirror(h=arm_h){
    children();
    up(h)mirror([0,0,1])children();
}


hinged_arm_holder_h_over_rail=2*(pulley_total_h+1)-2*(small_bearing_w+bearing_lip+1);
    
hinged_arm_holder_h_over_rail_2=hinged_arm_holder_h_over_rail+15;//4*(pulley_total_h+1)-2*(small_bearing_w+bearing_lip+1);      

hinged_arm_holder_bh=small_bearing_w+bearing_lip;
hinged_arm_holder_h=arm_h+2*(hinged_arm_holder_bh+2);
    
hinged_arm_holder_extra_h=hinged_arm_holder_h_over_rail_2+20;

module hinged_arm_holder(){
    //
    
    /*
    module rail_holes(){
        translate([10, 0, 10])rotate(v=[1,0,0], a=90)#rail_mount_hole();
        translate([30, 0, 10])rotate(v=[1,0,0], a=90)#rail_mount_hole();
    }*/
    
    module diag_symmetry(){
        children();
        mirror([1,-1,0])children();
    }
    
    difference(){    
        box([0,0,0], [rail_carriage_w, 40, hinged_arm_holder_h+hinged_arm_holder_extra_h]);
        diag_symmetry(){
            //rail_holes();
            //up(h_over_rail_2-h_over_rail)rail_holes();
        }
    }
    up(hinged_arm_holder_extra_h)
    v_mirror(hinged_arm_holder_h){
        difference(){
            hull(){
                box([0,0,0], [20, 20, hinged_arm_holder_bh]);
                translate([-hinge_r-1, -hinge_r-1, 0])cylinder(hinged_arm_holder_bh, r=hinge_r);
            }
            translate([-hinge_r-1, -hinge_r-1, -1]){
                cylinder(hinged_arm_holder_bh+2, r=small_bearing_or-0.5);
                cylinder(small_bearing_w+1, r=small_bearing_or);
            }
        }        
    }
    
    
}

   


module hinged_arm_holder_supports(){

    h_over_rail=2*(pulley_total_h+1)-2*(small_bearing_w+bearing_lip+1);    
    h_over_rail_2=h_over_rail+15;//4*(pulley_total_h+1)-2*(small_bearing_w+bearing_lip+1);      

    bh=small_bearing_w+bearing_lip;
    h=arm_h+2*(bh+2);
    
    extra_h=h_over_rail_2+20;
    taper=(hinge_r-small_bearing_or);
    
    if(support_thickness>0){
        translate([-hinge_r-1, -hinge_r-1, 0]){
            up(h+extra_h-bh-taper)difference(){
                cylinder(taper, r1=small_bearing_or, r2=hinge_r);
                cylinder(taper,  r1=small_bearing_or-support_thickness, r2=hinge_r-support_thickness);
            }
            up(extra_h-taper)difference(){
                cylinder(taper, r1=small_bearing_or, r2=hinge_r);
                cylinder(taper,  r1=small_bearing_or-support_thickness, r2=hinge_r-support_thickness);
            }
            difference(){
                cylinder(h+extra_h, r=small_bearing_or+support_thickness);
                cylinder(h+extra_h, r=small_bearing_or);
            }

        }
    }
}



pulley_dist=200;

carriage_y=-47;
a1=-24;
a2=29;

echo("Distance between pulleys: ", pulley_dist);

module lead_screw_nut_hole(){
    screw_nut_hole_h=45;
    cylinder(screw_nut_hole_h, r=11.5);
    cylinder(large, r=6);
    // Holes for mounting the lead screw nut
    rotate(v=[0,0,1], a=45)xy_mirror()translate([sqrt(0.5)*8, sqrt(0.5)*8,-1])cylinder(screw_nut_hole_h+12, r=1.5);
}

module carriage_mount_plate(){
    box([-rail_carriage_w/2-1, carriage_y, 0], [rail_carriage_w/2+1, carriage_y + rail_carriage_bolt_l-rail_carriage_hole_depth, rail_carriage_h]);
}

module carriage_mount_holes(){
    translate([0, carriage_y, rail_carriage_h/2]) rotate(v=[1,0,0], a=-90){            
            xy_mirror()
            translate([rail_carriage_bolt_h_spacing/2, 
            rail_carriage_bolt_v_spacing/2,
            rail_carriage_bolt_l-rail_carriage_hole_depth])
            {
                cylinder(large, r=rail_carriage_bolt_head_r);
                mirror([0,0,1])cylinder(large, r=rail_carriage_bolt_r);
            }           
     }
}

module OUT_combined(){

    difference(){
        union(){
        
                       
            sequential_hull(){
                translate([-pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=a1)translate([twist_l,0,0])motor_and_pulley_mount_side_plate(true, false);
                }
                carriage_mount_plate();
                translate([+pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=180+a2)translate([twist_l,0,0])motor_and_pulley_mount_side_plate(true, false);
                }
                //
            }
            
            // eliminate awkward corner
            hull(){
                // TODO: refactor
                rotation_h_over_motor=pulley_centre_height+motor_bump_h;                
                high_y=0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle)+5;
                low_y=-0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle);
                translate([-pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=a1)translate([twist_l,0,0])
                    #box([-motor_w/2-st, low_y, 0],[motor_w/2+st, high_y, h]);
                }
                #box([-rail_carriage_w/2, carriage_y, 0], [0.01-rail_carriage_w/2, carriage_y+40, 20]);
                
            }
            
            hull(){
                translate([-pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=a1)translate([twist_l,0,0])motor_and_pulley_mount_side_plate(false, true);
                }
                carriage_mount_plate();
                translate([+pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=180+a2)translate([twist_l,0,0])motor_and_pulley_mount_side_plate(false, true);
                }
            }
            
            /*
            sequential_hull(){                
                translate([-pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=a1)translate([twist_l,0,0])motor_and_pulley_mount_side_plate(false, true);
                }
                carriage_mount_plate();
                translate([+pulley_dist/2,0,0]){
                    rotate(v=[0,0,1], a=180+a2)translate([twist_l,0,0])motor_and_pulley_mount_side_plate(false, true);
                }sitting on eggs
            }*/
            
            translate([-pulley_dist/2,0,0]){
                rotate(v=[0,0,1], a=a1)translate([twist_l,0,0])motor_and_pulley_mount();
            }
            translate([+pulley_dist/2,0,0]){
                rotate(v=[0,0,1], a=180+a2)translate([twist_l,0,0])motor_and_pulley_mount();
            }
            
            carriage_mount_plate();
            
            translate([0, 20+carriage_y, 0])rotate(v=[0,0,1], a=180)translate([-rail_carriage_w/2, -20, 0])hinged_arm_holder();
            
            
        }
        box([-rail_carriage_w/2-1, -large, -large], [rail_carriage_w/2+1, carriage_y, large]);
        up(10)carriage_mount_holes();
        
        
        translate([-pulley_dist/2,0,0]){
            rotate(v=[0,0,1], a=a1)translate([twist_l,0,0]){
                intersection(){
                    box([-motor_w/2, -large, 0],[motor_w/2, large, large]);
                    motor_hole(false, true);
                }
            }
        }
        
        translate([+pulley_dist/2,0,0]){
            rotate(v=[0,0,1], a=180+a2)translate([twist_l,0,0])motor_hole(false, false);
        }
        
        // Hole for the lead screw.
        translate([0, 20+carriage_y, 0])
        {
            v_mirror(hinged_arm_holder_h+hinged_arm_holder_extra_h)lead_screw_nut_hole();
        }
        
    }
    translate([0, 20+carriage_y, 0])rotate(v=[0,0,1], a=180)translate([-rail_carriage_w/2, -20, 0])hinged_arm_holder_supports();
}

module m4_bolt_hole(){// for mounting to 2020 extrusion
    up(5-12){
        cylinder(large, r=2.2);
        mirror([0,0,1])cylinder(large, r=3.6);
    }
}

module OUT_rail_to_2020(){

    difference(){
        union(){        
            //carriage_mount_plate();
            box([-rail_carriage_w/2, carriage_y, 0], [rail_carriage_w/2, carriage_y + 40, rail_carriage_h]);
            
            hull(){
                box([-rail_carriage_w/2-10, carriage_y + 25-7, 0], [rail_carriage_w/2+10, carriage_y + 25, rail_carriage_h/2+10]);
                box([-rail_carriage_w/2, carriage_y, 0], [rail_carriage_w/2, carriage_y + 25, rail_carriage_h/2+10]);
            }
         
//           translate([0, 20+carriage_y, 0])rotate(v=[0,0,1], a=180)translate([-rail_carriage_w/2, -20, 0])hinged_arm_holder();
            
            
        }
        //box([-rail_carriage_w/2-1, -large, -large], [rail_carriage_w/2+1, carriage_y, large]);
        carriage_mount_holes();
        
        
        // Hole for the lead screw.
        translate([0, 20+carriage_y, 0])
        {
            //v_mirror(hinged_arm_holder_h+hinged_arm_holder_extra_h)lead_screw_nut_hole();
            cylinder(large, r=5);
            
            
            screw_nut_hole_h=45;
            up(rail_carriage_h)cylinder(screw_nut_hole_h, r=11.5);
            up(rail_carriage_h-3)cylinder(large, r=6);
            // Holes for mounting the lead screw nut
            rotate(v=[0,0,1], a=45)xy_mirror()translate([sqrt(0.5)*8, sqrt(0.5)*8,-1])cylinder(screw_nut_hole_h+12, r=1.5);
        }
        
        // cut out for 20x20 extrusion
        box([-large, carriage_y+20+5, rail_carriage_h/2-10.2], [large, large, rail_carriage_h/2+10.2]);
        
        x_mirror(){
            translate([rail_carriage_w/2+5, carriage_y+25, rail_carriage_h/2])rotate([-90,0,0])m4_bolt_hole();
        }
        
        
        
    }
    //translate([0, 20+carriage_y, 0])rotate(v=[0,0,1], a=180)translate([-rail_carriage_w/2, -20, 0])hinged_arm_holder_supports();
}

//OUT_combined();
OUT_rail_to_2020();



screw_height_over_rail_bottom=20+30;
pillow_block_height=15;
pillow_block_w=55;
pillow_block_to_motor=46;
pillow_block_hole_d=42;
pillow_block_t=13;
tight_m5_hole_r=2.2;//2.35;

rail_w=20;
rail_h=18;
rail_hole_spacing=60;

module OUT_z_axis_motor_holder(){
    
    h=rail_hole_spacing+(5+2)*2;
    t=5;
    rail_h=18;
    cl=0.1;
    difference(){
        union(){
            hull(){
                box([-pillow_block_w/2, -t, 0], [pillow_block_w/2, screw_height_over_rail_bottom-pillow_block_height, pillow_block_to_motor+pillow_block_t/2]);
                box([-rail_w/2-t, -t, 0], [rail_w/2+t, rail_h+t, h]);
            }
            
            //translate([0,screw_height_over_rail_bottom,0])motor_mounting_plate();
            box([-pillow_block_w/2, -t, 0], [pillow_block_w/2, screw_height_over_rail_bottom+motor_w/2, plate_t]);
            x_mirror()hull(){
                box([-pillow_block_w/2, -t, 0], [-motor_w/2, screw_height_over_rail_bottom-pillow_block_height, pillow_block_to_motor - pillow_block_t/2-1]);
                box([-pillow_block_w/2, -t, 0], [-motor_w/2, screw_height_over_rail_bottom+motor_w/2, plate_t]);            
            }
        }
        box([-rail_w/2-cl, -cl, -1], [rail_w/2+cl, rail_h+cl, h+1]);
        up(h/2 - rail_hole_spacing/2)rotate(v=[1,0,0], a=90){
            cylinder(large, r=2.5);
            mirror([0,0,1])cylinder(screw_height_over_rail_bottom, r=5);
        }
        up(h/2 + rail_hole_spacing/2)rotate(v=[1,0,0], a=90){
            cylinder(large, r=tight_m5_hole_r);
            mirror([0,0,1])cylinder(large, r=5);
        }
        x_mirror()translate([pillow_block_hole_d/2, -20, pillow_block_to_motor])rotate(v=[1,0,0], a=-90){
            cylinder(large, r=tight_m5_hole_r);
        }
        translate([0, screw_height_over_rail_bottom, 0]){
            cylinder(plate_t+5, r=motor_bump_r);
            xy_mirror(){
                translate([motor_hole_gap/2, motor_hole_gap/2, 0]){
                    cylinder(plate_t+30, r=motor_hole_r);
                    up(plate_t)cylinder(35, r=3.5);
                }
            }
        }
        
        
    }
}

//translate([0, 50, 0])OUT_z_axis_motor_holder();

module OUT_rail_stand(){
    t=5;
    h=rail_hole_spacing+20;
    cl=0.1;
    
    //x=rail_w/2+h-t;
    //y=rail_h/2+h-t;
    x=100;
    y=100;
    
    r=8;
    module base_hole(){
        cylinder(large, r=5.1);
            mirror([0,0,1])cylinder(large, r=2.5);
    }
    difference(){
        union(){
            /*
            hull(){
                box([-x, -y, 0], [x, y, t]);
                box([-rail_w/2-t, -rail_h/2-t, 0], [rail_w/2+t, rail_h/2+t, h]);
            }*/
            box([-rail_w/2-t, -rail_h/2-t, 0], [rail_w/2+t, rail_h/2+t, h]);
            hull(){
                box([-rail_w/2-t, -rail_h/2-t, 0], [rail_w/2+t, rail_h/2+t, h]);
                box([-x/2, -y/2, 0], [x/2, y/2, t]);
            }
            hull(){
                box([-x/2, -y/2, 0], [x/2, y/2, t]);
                xy_mirror()translate([x, y]){
                    cylinder(t, r=r);
                }
            }
            xy_mirror(){
                
                hull(){
                    
                    translate([10, 10]){
                        cylinder(h, r=r);
                    }
                    //box([rail_w/2+t-r, rail_h/2+t-r, 0], [rail_w/2+t, rail_h/2+t, h]);                    
                    /*translate([x-10, y-10]){
                        cylinder(t, r=r);
                    }*/
                    translate([x, y]){
                        cylinder(t, r=r);
                    }
                }
            }
        }
        box([-rail_w/2-cl, -rail_h/2-cl, -1], [rail_w/2+cl, rail_h/2+cl, large]);
        up(h/2 - rail_hole_spacing/2)rotate(v=[1,0,0], a=90){
            cylinder(large, r=2.5);
            mirror([0,0,1])cylinder(large, r=5);
        }
        up(h/2 + rail_hole_spacing/2)rotate(v=[1,0,0], a=90){
            cylinder(large, r=tight_m5_hole_r);
            mirror([0,0,1])cylinder(large, r=5);
        }
        xy_mirror(){
            //translate([x,y,t])base_hole();
            for(i=[0:20:40])translate([x-i,y-i,t])base_hole();
        }
    }
}
//translate([300, 0, 0])OUT_rail_stand();

//translate([motor_w+10,0,0])mirror([1,0,0])motor_and_pulley_mount();