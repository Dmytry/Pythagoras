// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
large=1000;

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

module motor_negative(plate=true){
    box([-motor_w/2, -motor_w/2, -large], [motor_w/2, motor_w/2, 0]);
    
    // hack: remove some unnecessary material
    box([-large, -large, -large], [large, large, -12]);

    if(plate){
        box([-motor_w, -motor_w, plate_t], [motor_w, motor_w, large]);
    }
    xy_mirror(){
        translate([motor_hole_gap/2, motor_hole_gap/2, 0]){
            up(-1)cylinder(large, r=motor_hole_r);
            if(!plate){
                up(plate_t)cylinder(large, r=motor_screw_head_r);
            }
        }
    }        
    up(-1E-3)hull(){
        cylinder(plate_t+5, r=motor_bump_r);
        translate([-large, 0, 0])cylinder(plate_t+5, r=motor_bump_r);
    }
}

//translate([0,100,0])motor_mounting_plate();
//translate([100,100,0])%motor_negative();

h=20;
twist_l=60;

// 2D rotation for calculations
function rotated(point, angle)=[point[0]*cos(angle)-point[1]*sin(angle), point[0]*sin(angle) + point[1]*cos(angle) ];


module motor_and_pulley_mount(){
    standoff=0.5;
    one_pulley_h=8.5;
    
    st=3;
    
    rotation_h_over_motor=pulley_centre_height+motor_bump_h;
    
    high_y=0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle);
    
    low_y=-0.5*motor_w*cos(motor_angle)-rotation_h_over_motor*sin(motor_angle);
    
    alpha=-atan2(high_y, twist_l-motor_w/2);
    
    front_y=4;
    
    extra=10;
                
    module motor_hole(plate=true){
        up(h+one_pulley_h+standoff)
        rotate(v=[1,0,0], a=-motor_angle)
        {
            up(-rotation_h_over_motor)motor_negative(plate);
        }
    }
    
    module m4_bolt_hole(){
        up(5-12){
            cylinder(large, r=2.2);
            mirror([0,0,1])cylinder(large, r=3.6);
        }
    }
    
    
    topright=[twist_l+ motor_w/2+st, high_y];
    topright_r=rotated(topright, alpha);
    
    difference(){
        union(){    
            difference(){
                rotate([0,0,alpha])box([twist_l - motor_w/2-st+0.01, low_y, 0], [twist_l+ motor_w/2+st, high_y, h+one_pulley_h+standoff+sin(motor_angle)*motor_w/2 + cos(motor_angle)*(plate_t-rotation_h_over_motor)]);
                
                rotate([0,0,alpha])translate([twist_l,0,0])motor_hole();
                rotate([0,0,alpha])box([twist_l-motor_w/2-st-1, 0, h], [twist_l, high_y, large]);
            }
            
            difference(){
            
                union(){
                    intersection(){
                        box([twist_l-motor_w/2-st, topright_r[1]-10, 0],[topright_r[0], front_y, h]); // z
                        rotate([0,0,alpha])box([-large, low_y, 0], [twist_l+ motor_w/2+st, large, h+one_pulley_h+standoff+sin(motor_angle)*motor_w/2 + cos(motor_angle)*(plate_t-rotation_h_over_motor)]);
                    }
                    box([twist_l, -front_y, 0], [twist_l + motor_w/2+st+h, front_y, h]);
                }
                
                
                //box([-extra, low_y, 0],[twist_l + motor_w/2+st, front_y, h]);
                rotate([0,0,alpha])translate([twist_l, 0, 0])motor_hole(false);
                
                
            }
        }
        // 2 holes
        /*
        translate([twist_l, 0, 0])x_mirror(){
            translate([motor_w/2+st - h/2, front_y, h/2])rotate(a=-90, v=[1,0,0]){
                m4_bolt_hole();
            }
        }*/
        
        // single hole mid motor:
        
        translate([twist_l, front_y, h/2]){
            rotate(a=-90, v=[1,0,0]){
                m4_bolt_hole();
            }
        }
        
        translate([twist_l + motor_w/2+st + h/2, front_y, h/2])rotate([-90,0,0])m4_bolt_hole();
    }
    difference(){
        union(){
            /*
            hull(){
                difference(){
                    box([twist_l - motor_w/2-st, low_y, 0], [twist_l - motor_w/2, high_y, h]);
                    //motor_hole();
                }
                cylinder(h, r=4);
            }*/            
            cylinder(h+standoff, r=front_y);
            box([-extra, -front_y, 0],[twist_l-motor_w/2-st, front_y, h]);
        }
        translate([0, 0, -1])cylinder(large, r=2);
        translate([20, 0, -1])cylinder(large, r=2);
        
        x_mirror()translate([-extra/2, front_y, h/2])rotate([-90,0,0])m4_bolt_hole();
    }
    
    // NOTE: update when moving bolt holes(!)
    echo("Bolt holes: ", -extra/2, extra/2, /* twist_l-(motor_w/2+st - h/2), twist_l+(motor_w/2+st - h/2),*/ twist_l,  twist_l + motor_w/2+st + h/2);
}

motor_and_pulley_mount();

//translate([motor_w+10,0,0])mirror([1,0,0])motor_and_pulley_mount();