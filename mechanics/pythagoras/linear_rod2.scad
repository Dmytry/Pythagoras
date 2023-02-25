// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
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

tensioner();

/* // debug: cross section of tensioner
%translate([0,30,0])intersection(){
    tensioner();
    box([-large, -large, -large], [large, large, pulley_total_h/2]);
}*/


arm_l=250;
arm_w=25;
arm_h=70;

hinge_r=small_bearing_or+2;

bearing_lip=1;
hinge_bolt_hole_r=2.4;

module v_mirror(h=arm_h){
    children();
    up(h)mirror([0,0,1])children();
}

module hinged_arm_1(){
    c=0.5;
    difference(){
        union(){            
            cylinder(arm_h, r=hinge_r);
            hull(){
                //intersection(){
                cylinder(arm_h, r=hinge_r);
                //box([0,c,0], [arm_l, arm_w, arm_h]);
                //}
                translate([arm_l, 0, 0])cylinder(arm_h, r=hinge_r);
            }
        }
        //up(small_bearing_w+bearing_lip)cylinder(arm_h-2*(small_bearing_w+bearing_lip), r=hinge_r+c);
        box([-large, -large, small_bearing_w+bearing_lip], [hinge_r+c, large, arm_h-(small_bearing_w+bearing_lip)]);
        
        up(-1)cylinder(arm_h+2, r=small_bearing_or-0.5);
        v_mirror()cylinder(small_bearing_w, r=small_bearing_or);
        translate([arm_l, 0, 0])cylinder(large, r=hinge_bolt_hole_r);
    }
}


arm_tip_hole_r=1.75;
module hinged_arm_2(){    
    // 2mm clearance;
    h=arm_h-2*(small_bearing_w+bearing_lip)-2;
    tip_h=30;
    c=0.5;
    difference(){
        union(){
            hull(){
                cylinder(h, r=hinge_r);
                translate([0,2*hinge_r,0])cylinder(h, r=hinge_r);               
            }
            hull(){
                cylinder(h, r=hinge_r);
                translate([arm_l,0,0])cylinder(tip_h, r=hinge_r);               
            }
        }
        translate([0,2*hinge_r,-1])cylinder(large, r=hinge_bolt_hole_r);
        translate([arm_l,0,0])cylinder(large, r=arm_tip_hole_r);
        translate([arm_l-40,0,0])cylinder(large, r=arm_tip_hole_r);
        // Mounting holes for hotends and assorted crap
        for(i=[1:5]){
            translate([arm_l-5, large/2, i*5])rotate(a=90, v=[1,0,0])cylinder(large, r=1.45);
            translate([arm_l-5-14, large/2, i*5])rotate(a=90, v=[1,0,0])cylinder(large, r=1.45);
        }
    }
}

module rail_mount_hole(){
    up(5-12){
        cylinder(large, r=2.2);
        mirror([0,0,1])cylinder(large, r=3.6);
    }
}

module hinged_arm_holder(){
    //
    h_over_rail=2*(pulley_total_h+1)-2*(small_bearing_w+bearing_lip+1);
    h_over_rail_2=4*(pulley_total_h+1)-2*(small_bearing_w+bearing_lip+1);
    
    

    bh=small_bearing_w+bearing_lip;
    h=arm_h+2*(bh+2);
    
    extra_h=h_over_rail_2+20;
    module rail_holes(){
        translate([10, 0, 10])rotate(v=[1,0,0], a=90)#rail_mount_hole();
        translate([30, 0, 10])rotate(v=[1,0,0], a=90)#rail_mount_hole();
    }
    
    module diag_symmetry(){
        children();
        mirror([1,-1,0])children();
    }
    
    difference(){    
        box([0,0,0], [40, 40, h+extra_h]);
        diag_symmetry(){
            rail_holes();
            up(h_over_rail_2-h_over_rail)rail_holes();
        }
    }
    up(extra_h)
    v_mirror(h){
        difference(){
            hull(){
                box([0,0,0], [20, 20, bh]);
                translate([-hinge_r-1, -hinge_r-1])cylinder(bh, r=hinge_r);
            }
            translate([-hinge_r-1, -hinge_r-1, -1]){
                cylinder(bh+2, r=small_bearing_or-0.5);
                cylinder(small_bearing_w+1, r=small_bearing_or);
            }
        }
    }
}

translate([-arm_l/2,100,0])hinged_arm_1();
translate([-arm_l/2,200,0])hinged_arm_2();
translate([0,300,0])hinged_arm_holder();


/*

module margin(){
    hull(){
        x_mirror()translate([l/2,0,0])cylinder(margin/2, r1=small_bearing_or+t+margin_t, r2=small_bearing_or+t);
    }
}

module rod1(){
    difference(){
        union(){
            hull(){
                x_mirror()translate([l/2,0,0])cylinder(margin/2+belt_w, r=small_bearing_or+t);
            }
            margin();
            up(margin+belt_w)mirror([0,0,1])margin();
        }
        translate([l/2,0,-1])cylinder(large, r=small_bearing_or-0.5);
        translate([l/2,0, (pulley_w-small_bearing_w)/2])cylinder(large, r=small_bearing_or+print_dilation);
        
        x_mirror(){
            translate([10, 0, pulley_w/2])rotate(v=[1,0,0], a=90)up(-large/2)cylinder(large, r=1.5);
        }
    }
}


rod1();*/