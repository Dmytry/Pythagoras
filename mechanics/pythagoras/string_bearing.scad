// (C) 2023 Dmytry Lavrov.
$fa=3;
$fs=0.2;


include <../BOSL2/std.scad>
include <../BOSL2/constants.scad>
include <../BOSL2/comparisons.scad>
include <../BOSL2/threading.scad>

use <../gears-master/gears.scad>
//use <../BOSL2/involute_gears.scad>

use <../common/common.scad>

large=1000;


mm_per_tooth=3;
gear_modul=mm_per_tooth/PI;
helix=45;
gear_pressure_angle=20;

gear_h=30;
gear_teeth=20;

gear_r=gear_teeth*gear_modul/2;

rope_ditch_depth=3;
rope_angle=5;
cut_angle=45;

module v_mirror(h=arm_h){
    children();
    up(h)mirror([0,0,1])children();
}

module make_spiral(){
}
/*
intersection(){

    herringbone_gear(modul=gear_modul, tooth_number=gear_teeth, 
                            width=gear_h, bore=0.1, pressure_angle=gear_pressure_angle, 
                            helix_angle=-helix, optimized=false);
// kevlar thread cut outs

    
    
}
*/
//up(gear_h)cylinder(10, r=gear_r);

inner_r=gear_r-rope_ditch_depth;
gear_outer_r=gear_r+gear_modul;

pitch=tan(rope_angle)*inner_r * 2 * PI;
echo(pitch);
outer_r=inner_r+(pitch/2)/tan(cut_angle/2);
free_rope_l=2*sqrt(gear_r*gear_r-inner_r*inner_r);

/*
module rope_cutout(){
    h=pitch*2;
    difference(){
        box([-large, -large, 0], [large, large, h]);
        up(h/2)trapezoidal_threaded_rod(d=outer_r*2, l=h, pitch=pitch, thread_depth=outer_r-inner_r, thread_angle=cut_angle-0.1);
        box([0, -large, -large], [large, 0, pitch]);
        box([-large, -large, -large], [0, large, pitch/2]);
    }
}*/


module simple_rope_cutout(r=inner_r, h=3){
    sl=gear_outer_r-inner_r;
    eh=h+2*sl;
    difference(){
        box([-large, -large, 0], [large, large, eh]);
        cylinder(sl, r1=gear_outer_r, r2=inner_r);
        cylinder(sl + h, r=inner_r);
        up(sl + h)cylinder(sl, r1=inner_r, r2=gear_outer_r);
        
    }
    up(sl)rotate(a=-90, v=[0,1,0])cylinder(large, r=1);
    up(eh-sl)rotate(a=-90, v=[0,1,0])cylinder(large, r=1);
}


module bearing(t=0){
    difference(){
        rotate(v=[0,0,1], a=t*180/gear_teeth)herringbone_gear(modul=gear_modul, tooth_number=gear_teeth, 
                                width=gear_h, bore=0.1, pressure_angle=gear_pressure_angle, 
                                helix_angle=-helix, optimized=false);
        up(-1)cylinder(large, r=inner_r-2);
        v_mirror(gear_h){
            up(3)simple_rope_cutout();
        }
    }
}
bearing();
translate([gear_outer_r*2+2, 0, 0])mirror([1,0,0])bearing(1);