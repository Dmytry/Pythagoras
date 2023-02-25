// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>
include <../BOSL2/std.scad>
include <../BOSL2/threading.scad>

$fa=3;
$fs=0.2;
large=1000;

difference(){
    cylinder(14,r=7, $fn=6);
    //cylinder(6.5, r=3.5);
    threaded_rod(d=[6.89, 7.324, 7.974], l=15, pitch=1, internal=true);
    up(6.5)cylinder(8, r=4.5);
}