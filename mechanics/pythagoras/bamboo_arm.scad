// (C) 2023 Dmytry Lavrov.
$fa=3;
$fs=0.2;

include <../BOSL2/std.scad>
include <../BOSL2/transforms.scad>
use <../common/common.scad>

$tags_shown="ALL";
/*
bolt_r_loose=1.2;
bolt_r=1.1;
thread_hole_r=1;
nut_r=4.4/2 + 0.2;
nut_h=1.5;*/

bamboo_rod_r=2.1;


t=1;

large=1000;
alpha=atan(0.5);
bearing_side_r=10;
bearing_side_h=70;

// bamboo section size
h=100;
l=200;
mid_w=100;

clearance=2;

hole_depth=10;

hinge_bolt_hole_r=2.4;

module copy_up(h=h){
    children();
    up(h)rotate([180,0,0])children();
}
module copy_side(){
    children();
    translate([l, 0, 0])rotate([0,0,180])children();
}

module bamboo_rod(p1, p2, r=bamboo_rod_r, l1=0, l2=0){
    translate(p1)rot(from=[0,0,1], to=p2-p1)up(l1){
        _h=norm(p2-p1)-l1-l2;
        echo("Bamboo rod: ", _h);
        cylinder(_h, r=r);
        //%up(_h/2)linear_extrude(1)text(str(_h));
    }
}

module bamboo_rod_outer(p1, p2, r=bamboo_rod_r, l1=0){
    translate(p1)rot(from=[0,0,1], to=p2-p1)up(l1){
        cylinder(hole_depth, r=r+t);
    }
}

// how far to back off one of the rods to avoid an intersection
function angle_backoff(v1, v2, r=bamboo_rod_r) = r/tan(0.5*atan2(norm(cross(v1,v2)), v1*v2));



module all_rods(){
    up(t+bamboo_rod_r){
        copy_side()copy_up(h){            
            bamboo_rod([0,0,0], [l/2, 0, h/2], bamboo_rod_r, angle_backoff([l, 0, 0], [l/2, 0, h/2]), angle_backoff([l/2, 0, h/2], [l/2, 0, -h/2]));        
            bo1=angle_backoff([l/2, 0, h/2], [l/2, mid_w/2, h/2]);
            bo2=angle_backoff([l/2, mid_w/2, h/2], [l/2, mid_w/2, -h/2]);
            bamboo_rod([0,0,0], [l/2, mid_w/2, h/2], bamboo_rod_r, bo1, bo2);
            bamboo_rod([0,0,0], [l/2, -mid_w/2, h/2], bamboo_rod_r, bo1, bo2);
        }
        copy_up(h)bamboo_rod([0,0,0], [l, 0, 0], bamboo_rod_r, 5);
        
        // up(t+bamboo_rod_r*2)cylinder(h, r=bamboo_rod_r);
        bamboo_rod([l,0,0], [l, 0, h], bamboo_rod_r, bamboo_rod_r, bamboo_rod_r);
        
        bamboo_rod([l/2, mid_w/2, h/2], [l/2, -mid_w/2, h/2]);
        copy_up(h)bamboo_rod([l/2, 0, 0], [l/2, 0, h/2], bamboo_rod_r, bamboo_rod_r, bamboo_rod_r);
        
    }
}

translate([0,-100,0])%all_rods();

// rod measurements, note: may not be up to date.
// 98.7 x4
// 107.9 x8
// 195 x2
// 95.8 x1
// 100 x1
// 45 x2
// 192.203 x2
// 192.703 - wtf.
// 83.9 x1


module OUT_shoulder(){
    difference(){
        union(){
            // An old kludge
            /*
            hull(){
                cylinder(bearing_side_h, r=bearing_side_r);
                translate([-(bearing_side_r*2+clearance),0,0])cylinder(bearing_side_h, r=bearing_side_r);
            }*/
            cylinder(h+2*t+2*bamboo_rod_r, r=bearing_side_r);
            
            up(t+bamboo_rod_r)copy_up(h){
            hull(){
                bamboo_rod_outer([0,0,0], [l, 0, 0], bamboo_rod_r, 5);
                bamboo_rod_outer([0,0,0], [l/2, 0, h/2], bamboo_rod_r, angle_backoff([l, 0, 0], [l/2, 0, h/2]));        
                bo1=angle_backoff([l/2, 0, h/2], [l/2, mid_w/2, h/2]);
                bamboo_rod_outer([0,0,0], [l/2, mid_w/2, h/2], bamboo_rod_r, bo1);
                bamboo_rod_outer([0,0,0], [l/2, -mid_w/2, h/2], bamboo_rod_r, bo1);
                cylinder(20, r=bamboo_rod_r+t);
            }
        }
        }
        #all_rods();
        
        up(-1)cylinder(large, r=hinge_bolt_hole_r);
    }
}

OUT_shoulder();

module mirror_copy(v){
    children();
    mirror(v)children();
}

module all_way_mirror(){
    mirror_copy([1,0,0])mirror_copy([0,1,0])mirror_copy([0,0,1])children();
}

module v_mirror(h=0){
    children();
    up(h)mirror([0,0,1])children();
}

module OUT_spider(){
    difference(){
        up(t+bamboo_rod_r){            

            hull()copy_up()copy_side()
            {
                translate([l/2, 0, h/2]){
                    bamboo_rod_outer([0,0,0], [l/2, 0, h/2], bamboo_rod_r,  angle_backoff([l/2, 0, h/2], [l/2, 0, -h/2]));
                    down(hole_depth)cylinder(hole_depth*2, r=bamboo_rod_r+t);
                    // commented out to improve printability
                    //rotate([90,0,0])down(hole_depth/2)cylinder(hole_depth, r=bamboo_rod_r+t);
                }                
            }

            hull(){
                translate([l/2, -mid_w/2, h/2])mirror_copy([1,0,0])mirror_copy([0,0,1]){
                    bo2=angle_backoff([l/2, mid_w/2, h/2], [l/2, mid_w/2, -h/2]);
                    bamboo_rod_outer([0,0,0], [l/2, mid_w/2, h/2], bamboo_rod_r,  bo2);                    
                    //rotate([90,0,0])cylinder(-hole_depth, r=bamboo_rod_r+t);
                }
            }
            hull(){
                translate([l/2, 0, 0]){
                    up(bamboo_rod_r)cylinder(hole_depth, r=bamboo_rod_r+t);
                    rotate([0,90,0])up(-hole_depth)cylinder(hole_depth*2, r=bamboo_rod_r+t);
                    //rotate([90,0,0])cylinder(-hole_depth, r=bamboo_rod_r+t);
                }
            }
        }
        all_rods();
    }
}

OUT_spider();


bearing_r=3.5+0.1;
bearing_h=3;
bearing_lip=2;
bearing_housing_r=5;
elbow_r=5;
// m3 bolt for the elbow bearing
small_bolt_r=1.45;
small_bolt_l=10;
//bearing centring washer height =2;

module OUT_elbow(){    
        
    elbow_d=elbow_r+bearing_housing_r;
    
    difference(){
        union(){
            //cylinder(h+2*t+2*bamboo_rod_r, r=elbow_r);
            v_mirror(h+2*t+2*bamboo_rod_r){
                hull(){ 
                    cylinder(bearing_h+bearing_lip, r=elbow_r);
                    l=elbow_r+bearing_housing_r;
                    translate([-elbow_d/sqrt(2), -elbow_d/sqrt(2), 0])cylinder(bearing_h+bearing_lip, r=bearing_housing_r);
                }
            }
            
            
            up(t+bamboo_rod_r)copy_up(h){
                hull(){
                    bamboo_rod_outer([0,0,0], [l, 0, 0]);
                    bamboo_rod_outer([0,0,0], [l/2, 0, h/2], bamboo_rod_r, angle_backoff([l, 0, 0], [l/2, 0, h/2]));        
                    bo1=angle_backoff([l/2, 0, h/2], [l/2, mid_w/2, h/2]);
                    bamboo_rod_outer([0,0,0], [l/2, mid_w/2, h/2], bamboo_rod_r, bo1);
                    bamboo_rod_outer([0,0,0], [l/2, -mid_w/2, h/2], bamboo_rod_r, bo1);
                    cylinder(hole_depth+t+bamboo_rod_r*2, r=elbow_r);
                }
            }
        }
        all_rods();
        up(t+bamboo_rod_r*2)cylinder(h, r=bamboo_rod_r);
        // Aux holes?
        /*A practical 10 Cents Ceramic tube hotend
        up(t+bamboo_rod_r)copy_up(h){
            for(j=[10:10:h/2])
            up(j){
                for(i=[0:45:180])rotate([0,0,i])rotate([90,0,0])up(-100)cylinder(200, r=1);
            }
        }*/        
        translate([-(bearing_side_r*2+clearance),0,0])cylinder(large, r=hinge_bolt_hole_r);
        
        v_mirror(h+2*t+2*bamboo_rod_r)translate([-elbow_d/sqrt(2), -elbow_d/sqrt(2), 0]){
            cylinder(bearing_h, r=bearing_r);
            cylinder(large, r=bearing_r-0.5);
        }
    }
}

translate([l,0,0])rotate([0,0,180])OUT_elbow();


h2=h-2*(bearing_h+bearing_lip+2);// +2*(bamboo_rod_r+t)
//lower_arm_drop=25;
lower_arm_drop=-h2/2;

module all_lower_arm_rods(){
    bamboo_rod([0,0,0], [l, 0, -lower_arm_drop], bamboo_rod_r, bamboo_rod_r, angle_backoff([l,0,-lower_arm_drop], [l, 0, -h2-lower_arm_drop]));
    bamboo_rod([0,0,0], [0, 0, h2], bamboo_rod_r, bamboo_rod_r);
    bamboo_rod([0,0,h2], [l, 0, -lower_arm_drop], bamboo_rod_r, angle_backoff([l, 0, -h2-lower_arm_drop], [0,0,-h2]), angle_backoff([l,0,-lower_arm_drop], [l, 0, -h2-lower_arm_drop]));
}

tip_rod_r=2;

module multi(list){
    for(a = list){
        translate(a)children();
    }
}

function move_towards(v1, v2, l) = v1+(v2-v1)*(l/norm(v2-v1));

module OUT_lower_arm(){
    echo("h2: ", h2);
    s=bamboo_rod_r+small_bolt_r+2;
    bolt_hole_depth=5;
    
    module stays_hole(){
        rotate([90,0,0])up(-large/2)cylinder(large, r=1);
    }
  
    up(t+bamboo_rod_r)
    difference(){        
        union(){
            hull(){
                bamboo_rod_outer([0,0,0], [l, 0, -lower_arm_drop], bamboo_rod_r, bamboo_rod_r);
                bamboo_rod_outer([0,0,0], [0, 0, h2], bamboo_rod_r, bamboo_rod_r);
                translate([-s, 0, -t-bamboo_rod_r])cylinder(bolt_hole_depth, r=small_bolt_r+t);
            }
            hull(){
                bamboo_rod_outer([0,0,h2], [0, 0, 0]);
                bamboo_rod_outer([0,0,h2], [l, 0, -lower_arm_drop], bamboo_rod_r, angle_backoff([l, 0, -h2-lower_arm_drop], [0,0,-h2]));
                translate([-s, 0, h2+t+bamboo_rod_r])mirror([0,0,1])cylinder(bolt_hole_depth, r=small_bolt_r+t);
            }
            hull(){
                bamboo_rod_outer([l, 0, -lower_arm_drop], [0,0,h2], bamboo_rod_r, angle_backoff([l,0,-lower_arm_drop], [l, 0, -h2]));
                bamboo_rod_outer([l, 0, -lower_arm_drop], [0,0,0], bamboo_rod_r, angle_backoff([l,0,-lower_arm_drop], [l, 0, -h2]));
                //translate([l, 0, -t-bamboo_rod_r-lower_arm_drop]) cylinder(10, r=tip_rod_r+2);
                translate([l, 0, -lower_arm_drop-5]) cylinder(10, r=tip_rod_r+2);
            }
            
        }
        #all_lower_arm_rods();
        multi([[0,0,0], [0, 0, h2],
        move_towards([l, 0, -lower_arm_drop], [0,0,0], angle_backoff([l,0,-lower_arm_drop], [l, 0, -h2-lower_arm_drop]) - 1.5),
        
        move_towards([l, 0, -lower_arm_drop], [0,0,h2], angle_backoff([l,0,-lower_arm_drop], [l, 0, -h2-lower_arm_drop]) - 1.5)
        
        ])stays_hole();
        
        translate([-s, 0, -t-bamboo_rod_r-5])cylinder(large, r=small_bolt_r);
        //translate([l, 0, -t-bamboo_rod_r-lower_arm_drop])
        translate([l, 0, -lower_arm_drop])
        {
            cylinder(large, r=tip_rod_r, center=true);
            rotate([0,90,0])cylinder(large, r=1);
        }
        
        // Show rods for debugging
        translate([0,10,0])%all_lower_arm_rods();
    }
    
}

module OUT_bolt_cone(){
    r=1.7;
    difference(){
        cylinder(2, r1=r+1 , r2=r);
        cylinder(3, r=r);
    }
}

//translate([0,50,0])OUT_bolt_cone();

//translate([0,100,0])OUT_lower_arm();

module OUT_balance_arm_joint(){
    gap=14;
    s=gap+2*bamboo_rod_r;
    cl=2;
    difference(){
        union(){
            sequential_hull(){
                bamboo_rod_outer([0,0,bamboo_rod_r+t], [50, 0, bamboo_rod_r+t], bamboo_rod_r, cl);
                bamboo_rod_outer([0,0,bamboo_rod_r+t+s/2], [50*cos(120), 50*sin(120), bamboo_rod_r+t+s/2], bamboo_rod_r, cl);            
                bamboo_rod_outer([0,0, bamboo_rod_r+t+s], [50, 0, bamboo_rod_r+t+s], bamboo_rod_r, cl);                
            }            
        }
        
        bamboo_rod([0,0,bamboo_rod_r+t], [50, 0, bamboo_rod_r+t], bamboo_rod_r, cl);
        bamboo_rod([0,0,bamboo_rod_r+t+s/2], [50*cos(120), 50*sin(120), bamboo_rod_r+t+s/2], bamboo_rod_r, cl);            
        bamboo_rod([0,0, bamboo_rod_r+t+s], [50, 0, bamboo_rod_r+t+s], bamboo_rod_r, cl);
        //cylinder(large, r=1, center=true);
        up(bamboo_rod_r+t)rotate([0,0,60])rotate([0,90,0])cylinder(large, r=1, center=true);
        up(bamboo_rod_r+t+s)rotate([0,0,60])rotate([0,90,0])cylinder(large, r=1, center=true);
    }
}
/*
module OUT_balance_arm(){
    hotend_h=55;
    hotend_tip=5;
    hotend_clearance=16;
    bearing_or=11/2;
    bearing_h=4;
    t=2;
    bar_t=3;
    bar_h=hotend_h+bearing_h/2;
    back_l=30;
    difference(){
        union(){
        }
    }
}*/

module OUT_bamboo_drill_jig(){
    difference(){
        cylinder(8, r=bamboo_rod_r+5);
        up(2)cylinder(8, r=bamboo_rod_r+0.1);
        up(4)rotate([90,0,0])cylinder(30, r=1, center=true);
        up(5)rotate([0,90,0])cylinder(30, r=1, center=true);
    }
}

//translate([0,-100,0])OUT_balance_arm_joint();
//translate([0,-120,0])OUT_bamboo_drill_jig();


hotend_clearance=40;


he_bearing_or=11/2;
he_bearing_h=4;

module OUT_bamboo_to_bearing(stick_or=8.5/2){
    slots=false;
    grab_w=10;
    extra_grab=3;
    h=hotend_clearance+extra_grab;
    t2=2;
    bearing_expand=0.0;//0.1;
    difference(){
        union(){
            hull(){
                up(h)rotate([90,0,0])cylinder(he_bearing_h, r=he_bearing_or+t2, center=true);
                intersection(){
                    box([-he_bearing_or-t, -he_bearing_h/2, 0], [he_bearing_or+t, he_bearing_h/2, hotend_clearance]);
                    cylinder(grab_w, r=stick_or+t);
                }
            }
            //box([-he_bearing_or-t, -he_bearing_h/2, 0], [+he_bearing_or+t, +he_bearing_h/2, hotend_clearance]);
            cylinder(grab_w, r=stick_or+t);
            up(grab_w)cylinder((stick_or+t)*2, r1=stick_or+t, r2=0);
            if(slots)hull(){
                x_mirror(){
                    //box([stick_or+t, -3, 0], [stick_or+t+3, 3, 6]);
                    translate([stick_or+t, 0, 0])cylinder(extra_grab, r=4);
                }
            }
        }
        cylinder(grab_w, r=stick_or);
        up(h)rotate([90,0,0])cylinder(he_bearing_h+1, r=he_bearing_or+bearing_expand, center=true);
        #box([-2, -20, h], [2, 20, h+he_bearing_or+bearing_expand]);
        
        // approach 1: rope through a hole
        up(extra_grab)rotate([0,90,0])cylinder(large, r=1, center=true);
        // approach 2: slots for rope
        if(slots)xy_mirror(){
            //up(extra_grab)#box([stick_or+t, -0.5, -10], [20, 0.5, 0]);
            up(extra_grab)rotate([30,0,0])#box([stick_or+t, 0, -10], [20, 1, 0]);
            up(extra_grab)rotate([90,0,0])#box([stick_or+t, 0, -10], [20, 1, 0]);
        }
    }
    
}
/*
translate([0,-140,0])OUT_bamboo_to_bearing();
translate([0,-151,0])OUT_bamboo_to_bearing(7.6/2);
*/
module OUT_flat_bamboo_to_bearing(){
    t2=2;
    bearing_expand=0;
    bar_h=2;
    flexure_t=1;
    flexure_r=2;
    difference(){
        union(){
            cylinder(he_bearing_h, r=he_bearing_or+t2);
            hull(){
                box([0, -(he_bearing_or+t2), 0], [hotend_clearance, he_bearing_or+t2, bar_h]);
                y_mirror(){                    
                    translate([hotend_clearance*2, 2, 0])cylinder(bar_h, r=3);
                }
            }
        }
        up(-1)cylinder(he_bearing_h+2, r=he_bearing_or+bearing_expand);
        y_mirror(){
            translate([hotend_clearance, 2, 0])cylinder(he_bearing_h+2, r=1);
            translate([hotend_clearance*1.333, 2, 0])cylinder(he_bearing_h+2, r=1);
            translate([hotend_clearance*1.666, 2, 0])cylinder(he_bearing_h+2, r=1);
            translate([hotend_clearance*2, 2, 0])cylinder(he_bearing_h+2, r=1);
        }
        v_mirror(bar_h){
            translate([he_bearing_or+t2+flexure_r, 0, (bar_h-flexure_t)/2-flexure_r])rotate([90,0,0])cylinder(large, r=flexure_r, center=true);
        }
    }
}
//translate([0,-170,0])OUT_flat_bamboo_to_bearing();

flat_bamboo_w=7.5;//8.8;
flat_bamboo_t=2.1;

module chevron_one(h, r){    
    a=60;
    extra_l=2.5;    
    rotate([0,0,a/2]){
        hull(){
            translate([extra_l, 0, 0])cylinder(h, r=r);
            translate([flat_bamboo_w+extra_l, 0, 0])cylinder(h, r=r);
        }
    }
}

module chevron(h, r){    
    a=60;
    extra_l=2.5;    
    for(x=[-a/2,a/2])rotate([0,0,x]){
        hull(){
            translate([extra_l, 0, 0])cylinder(h, r=r);
            translate([flat_bamboo_w+extra_l, 0, 0])cylinder(h, r=r);
        }
    }
}

module OUT_flat_bamboo_corner_joint(){
    r=flat_bamboo_t/2+1.5;
    h=5;
    a=60;
    extra_l=2.5;
    difference(){
        chevron(h, r);
        down(1)chevron(h+2, flat_bamboo_t/2);
    }
}

structure_clearance=9;

module OUT_flat_bamboo_to_bearing(){
    t2=2;
    t3=1.5;
    bearing_expand=0;
    bar_h=2;
    flexure_t=1;
    flexure_r=2;
    difference(){
        union(){
            cylinder(he_bearing_h, r=he_bearing_or+t2);
            hull(){
                cylinder(bar_h, r=he_bearing_or+t2);
                //box([hotend_clearance*0.75, -(he_bearing_or+t2)-2, 0], [hotend_clearance, he_bearing_or+t2, bar_h]);
                
                translate([hotend_clearance, 0, 0])rotate([0,0,180])chevron(bar_h, flat_bamboo_t/2+1.5);
                
                translate([hotend_clearance+structure_clearance, 0, 0])rotate([0,0,180])chevron(bar_h, flat_bamboo_t/2+1.5);
                
                y_mirror(){                    
                    translate([hotend_clearance*3, 2, 0])cylinder(bar_h, r=3);
                }
                //translate([hotend_clearance*3, 3-he_bearing_or-t2, 0])cylinder(bar_h, r=3);
            }
            translate([hotend_clearance, 0, 0])rotate([0,0,180])chevron(4, flat_bamboo_t/2+1.5);
            translate([hotend_clearance+structure_clearance, 0, 0])rotate([0,0,180])chevron(4, flat_bamboo_t/2+1.5);
            
            /*
            translate([0, -he_bearing_or-t2-flat_bamboo_t/2, flat_bamboo_t/2+t3])rotate([0,90,0]){
                l=hotend_clearance*3;
                gw=6;
                n=5;
                for(i=[0:n])up(i*(l-0.5*gw)/n - 0.5*gw){               
                    box([0,0,0], [flat_bamboo_t/2+t3, flat_bamboo_t/2+t3, gw]);
                    hull(){
                        cylinder(gw, r=flat_bamboo_t/2+t3);
                        translate([-flat_bamboo_w,0,0])cylinder(gw, r=flat_bamboo_t/2+t3);
                    }
                }
            }*/
        }
        up(-1)cylinder(he_bearing_h+2, r=he_bearing_or+bearing_expand);
        translate([hotend_clearance, 0, -1])rotate([0,0,180])chevron(large, flat_bamboo_t/2);
        
        translate([hotend_clearance+structure_clearance, 0, -1])rotate([0,0,180])chevron(large, flat_bamboo_t/2);
        
        y_mirror(){
            //translate([hotend_clearance+2, 2, 0])cylinder(he_bearing_h+2, r=1);
            for(i=[2, 2.5, 3])translate([hotend_clearance*i, 2, 0])cylinder(he_bearing_h+2, r=1);
        }
        
        // flexure.
        
        v_mirror(bar_h){
            translate([he_bearing_or+t2+flexure_r, 0, (bar_h-flexure_t)/2-flexure_r])rotate([90,0,0])cylinder(large, r=flexure_r, center=true);
        }
        
        // vertical stabiliation bar holds
        /*
        #translate([0, -he_bearing_or-t2-flat_bamboo_t/2, flat_bamboo_t/2+t3])rotate([0,-90,0]){
            hull(){
                cylinder(large, r=flat_bamboo_t/2, center=true);
                translate([flat_bamboo_w,0,0])cylinder(large, r=flat_bamboo_t/2, center=true);
            }
        }*/
    }
}

module OUT_flat_bamboo_to_belt(){
    r=flat_bamboo_t/2+1.5;
    h=5;
    a=60;
    extra_l=2.5;
    difference(){
        hull (){
            chevron(h, r);
            translate([structure_clearance,0,0])chevron(h, r);
        }
        down(1)chevron(h+2, flat_bamboo_t/2);
        translate([structure_clearance,0,0])down(1)chevron(h+2, flat_bamboo_t/2);
    }
}


module OUT_flat_bamboo_to_belt(){
    OUT_flat_bamboo_corner_joint();
    translate([structure_clearance,0,0])OUT_flat_bamboo_corner_joint();
}

module OUT_flat_bamboo_to_bearing_2(){
    t2=2;
    bearing_expand=0;
    bar_h=2;
    flexure_t=1;
    flexure_r=2;
    difference(){
        union(){
            cylinder(he_bearing_h, r=he_bearing_or+t2);
            hull(){
                box([0, -(he_bearing_or+t2), 0], [hotend_clearance/2, he_bearing_or+t2, bar_h]);                
                translate([hotend_clearance, 0, 0])rotate([0,0,180])chevron(bar_h, flat_bamboo_t/2+1.5);
            }
            //translate([hotend_clearance, 0, 0])rotate([0,0,180])chevron(bar_h+3, flat_bamboo_t/2+1.5);
        }
        up(-1)cylinder(he_bearing_h+2, r=he_bearing_or+bearing_expand);
        translate([hotend_clearance, 0, -1])rotate([0,0,180])chevron(bar_h+3, flat_bamboo_t/2);
        v_mirror(bar_h){
            translate([he_bearing_or+t2+flexure_r, 0, (bar_h-flexure_t)/2-flexure_r])rotate([90,0,0])cylinder(large, r=flexure_r, center=true);
        }
    }
}



module OUT_bamboo_to_flat_bamboo(stick_or=8.5/2){
    slots=false;
    grab_w=10;
    extra_grab=3;    
    t2=2;
    bearing_expand=0.0;//0.1;
    flat_bamboo_grab_w=2;
    difference(){
        hull(){
            translate([flat_bamboo_grab_w/2, 0, grab_w])rotate([0,-90,0])chevron_one(flat_bamboo_grab_w, flat_bamboo_t/2+1.5);
            
            /*
            intersection(){
                cylinder(grab_w, r=stick_or+t);
                box([-large, -3, -large], [large, large, large]);
            }
            intersection(){
                cylinder(grab_w, r=stick_or+t);
                box([-large, -large, -large], [large, 3, large]);
            }*/
            cylinder(grab_w, r=stick_or+t);
            
            translate([flat_bamboo_grab_w/2, 0, grab_w])rotate([0,-90,0])mirror([0,1,0])chevron_one(flat_bamboo_grab_w, flat_bamboo_t/2+1.5);            
        }
        cylinder(grab_w, r=stick_or);
        translate([large/2, 0, grab_w])rotate([0,-90,0])chevron(large, flat_bamboo_t/2);
        translate([large/2, 0, grab_w+(flat_bamboo_t/2 + 1.5)/sin(30)])rotate([0,-90,0])linear_extrude(large)polygon([[0,0], [large*cos(30), large*sin(30)], [large*cos(30), -large*sin(30)]]);
    }
    
}

/*

translate([0,-200,0])OUT_flat_bamboo_corner_joint();
translate([0,-170,0])OUT_flat_bamboo_to_bearing();
translate([0,-150,0])OUT_flat_bamboo_to_belt();

translate([0,-220,0])OUT_flat_bamboo_to_bearing_2();

translate([0,-250,0])OUT_bamboo_to_flat_bamboo();
translate([20,-250,0])OUT_bamboo_to_flat_bamboo(9.5/2);
translate([40,-250,0])OUT_bamboo_to_flat_bamboo(7.7/2);
translate([60,-250,0])OUT_bamboo_to_flat_bamboo(8.7/2);
*/



small_bearing_or=16/2;
small_bearing_w=5;
arm_l=250;
arm_w=25;
arm_h=70;

//hinge_r=small_bearing_or+2;

//bearing_lip=1;
//hinge_bolt_hole_r=2.4;


hinged_arm_holder_bh=small_bearing_w+bearing_lip;
hinged_arm_holder_h=(h + 2*t + 2*bamboo_rod_r) + 2*(hinged_arm_holder_bh+2);

hinged_arm_holder_extra_h=50;

hinge_r=10;

support_thickness=0.4;

module m4_bolt_hole(){// for mounting to 2020 extrusion
    up(5-12){
        cylinder(20, r=2.2);
        mirror([0,0,1])cylinder(large, r=3.6);
    }
}

module OUT_shoulder_base(){
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
    
    widen_y=0.1;
    widen_z=0.1;
    
    difference(){    
        box([0,0,0], [40, 40, hinged_arm_holder_h+hinged_arm_holder_extra_h]);
        diag_symmetry(){
            //rail_holes();
            //up(h_over_rail_2-h_over_rail)rail_holes();
        }
        box([-large,  10-widen_y, 10-widen_z], [large, 30+widen_y, 30+widen_z]);
        translate([20, 20, 20]){
            xy_mirror(){
                translate([10, 10, 0])rotate([90,0,0])m4_bolt_hole();
            }
            x_mirror()translate([10, 0, -10]){
                m4_bolt_hole();
            }
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
    
    /*
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
    }*/
    
    
}
translate([-100,0,0])OUT_shoulder_base();