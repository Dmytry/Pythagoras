use <../common/common.scad>
include <dimensions.scad>
$fa=3;
$fs=0.2;
large=100;

hose_ir=4;
inlet_wall_t=1.2;

restrictor_t=0.6;

module OUT_infill(){
}

module OUT_air_bearing(){
    s=movement_margin;
    base_t=4;
    t=2;
    
 
    difference(){
        union(){
            cyl_rounded_box([-s, -s, 0], [s, s, base_t], 5);
            up(base_t)cylinder(10, r=hose_ir);            
        }
        cyl_rounded_box([-s+t, -s+t, 0], [s-t, s-t, base_t-t], 5-t);
        up(base_t-t+restrictor_t)cylinder(large, r=hose_ir-inlet_wall_t);
    }
    intersection(){
        cyl_rounded_box([-s, -s, 0], [s, s, base_t], 5);
        for(i=[0:7])rotate([0,0,i*45]){
            box([-0.2, -large, -large], [0.2, large, large]);
        }
    }
    
}
OUT_air_bearing();