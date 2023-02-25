// (C) 2023 Dmytry Lavrov

module box(low, high){
    translate(low){
        cube(high-low);
    }
}

module mirror_duplicate(v){
    children();
    mirror(v=v)children();
}

module x_mirror(){
    mirror_duplicate(v=[1,0,0])children();
}
module y_mirror(){
    mirror_duplicate(v=[0,1,0])children();
}
module xy_mirror(){
    mirror_duplicate(v=[1,0,0])mirror_duplicate(v=[0,1,0])children();
}

module four_corners(low, high){
    translate([low[0], low[1], 0])children();
    translate([high[0], low[1], 0])children();
    translate([high[0], high[1], 0])children();
    translate([low[0], high[1], 0])children();  
}

module cyl_rounded_box(low, high, r){
    h=high[2]-low[2];
    translate([0, 0, low[2]]){
        hull(){
            translate([low[0]+r, low[1]+r, 0])cylinder(h, r=r);
            translate([high[0]-r, low[1]+r, 0])cylinder(h, r=r);
            translate([high[0]-r, high[1]-r, 0])cylinder(h, r=r);
            translate([low[0]+r, high[1]-r, 0])cylinder(h, r=r);
        }
    }
}

module rounded_box(l, h, r){
    hull(){
        translate([l[0]+r, l[1]+r, l[2]+r])sphere(r);        
        translate([l[0]+r, l[1]+r, h[2]-r]) sphere(r);
        translate([l[0]+r, h[1]-r, l[2]+r]) sphere(r);
        translate([l[0]+r, h[1]-r, h[2]-r]) sphere(r);
        
        translate([h[0]-r, l[1]+r, l[2]+r]) sphere(r);
        translate([h[0]-r, l[1]+r, h[2]-r]) sphere(r);
        translate([h[0]-r, h[1]-r, l[2]+r]) sphere(r);
        translate([h[0]-r, h[1]-r, h[2]-r]) sphere(r);
    }
}

module skel_cyl_rounded_box(low, high, ir, or, outer=true, right_side=true){
    h=high[2]-low[2];
    translate([0, 0, low[2]])
    difference(){
        union(){
            translate([low[0], low[1], 0])cylinder(h, r=or);
            translate([high[0], low[1], 0])cylinder(h, r=or);
            translate([high[0], high[1], 0])cylinder(h, r=or);
            translate([low[0], high[1], 0])cylinder(h, r=or);
            // outer shell
            if(outer){
                box([low[0], low[1]-or, 0], [high[0], low[1]-ir, h]);            
                box([low[0], high[1]+ir, 0], [high[0], high[1]+or, h]);
                
                box([low[0]-or, low[1], 0], [low[0]-ir, high[1], h]);
                
                if(right_side)box([high[0]+ir, low[1], 0], [high[0]+or, high[1], h]);
            }

            // inner shell            
            box([low[0], low[1]+ir, 0], [high[0], low[1]+or, h]);            
            box([low[0], high[1]-or, 0], [high[0], high[1]-ir, h]);
            
            box([low[0]+ir, low[1], 0], [low[0]+or, high[1], h]);
            box([high[0]-or, low[1], 0], [high[0]-ir, high[1], h]);
        }
        translate([low[0], low[1], 0])cylinder(h, r=ir);
        translate([high[0], low[1], 0])cylinder(h, r=ir);
        translate([high[0], high[1], 0])cylinder(h, r=ir);
        translate([low[0], high[1], 0])cylinder(h, r=ir);
    }
}

module sequential_hull(){
    if($children<2){
        hull()children();
    }else{
        for (i = [0: $children-2])
            hull(){
                children(i);
                children(i+1);
            }
    }
}

module teardrop(r){// sphere with a hat, purpose: avoid overhangs
    union(){
        sphere(r);
        translate([0,0,r*sqrt(0.5)])cylinder(r*sqrt(0.5), r1=r*sqrt(0.5), r2=0);
    }
}

module up(z){
    translate([0,0,z])children();
}
