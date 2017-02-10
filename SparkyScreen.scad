use<nutsnbolts/cyl_head_bolt.scad>
use<nutsnbolts/materials.scad>
include<nutsnbolts/data-access.scad> // database lookup functions
include<nutsnbolts/data-metric_cyl_head_bolts.scad>

$fn = 40;
screenCube = [165,105,4.5];
patternX=50;
patternY=20;
clearanceDepth=6;
nutHeight=16;
//defintions (should stay as they are)
thread="M4";
nutThickness = _get_fam(thread)[_NB_F_NUT_HEIGHT];
echo("nutThickness is (from nutThickness variable):",nutThickness, "however it should be", _get_fam(thread)[_NB_F_NUT_HEIGHT]);
//MAIN CHIP NEEDS AIRFLOW FOR COOLING
module screen(patternX=50, patternY=20, thread = "M4", nutHeight=16, clearanceDepth=6, extentionsOnly=false){
  if(!extentionsOnly)color("SlateGrey")cube(screenCube);
  if(extentionsOnly)stainless(no="1.4301")for(x = [-1,1], y = [-1,1]){
    translate([screenCube[0]/2+x*patternX/2,screenCube[1]/2+y*patternY/2, screenCube[2]+nutHeight]){
      translate([0,0,3.2])nut(thread);
      translate([0,0,-clearanceDepth])cylinder(d=4.3,clearanceDepth);
    }
  }
}
function x(x) = x;
//translate([0,0,-screenCube[2]])screen();
//pcb
mainPcbSize=[128.7,85.4,3.5];
module mainPcb(holes = "in"){
  //board and MAIN components (reference: winborad IC (U300))
  difference(){
    color("Blue")cube(mainPcbSize);
    if(holes == "in")for(x = [0,1], y = [0,1])
        translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10),-1])cylinder(5,d=3.2,$fn=20);
  }
  //connectors
  color("LightGrey")translate([-0.001,12,0.001])cube([12.3,22,7]);
  color("LightGrey")translate([-0.001,39,0.001])cube([15,15,4.2]);
  color("Grey")translate([25.5,-3,-0.2])cube([16.4,12.6,7.6]);
  color("LightGrey")translate([46.5,-6,-1.5])cube([38.4,17.5,12.4]);
  color("LightBlue")translate([89,-6,-1.5])cube([32,15.5,15.5]);
  color("LightGrey")translate([35.6,74.5,mainPcbSize[2]])cube([27,11,0.8]);
  //big components like coils and caps
  color("DarkSlateGrey")translate([64,21,3.3])cube([43,56,4.2]);
}

module pcbMount(mode = "side")
{}

wallThickness = 2;
//[top,bottom,left,right]
overlap = [1.5,8,2,3.5];
module base(){
  difference(){
    translate([-wallThickness,-wallThickness,-wallThickness])
      minkowski(){
        cube([screenCube[0]+2*wallThickness,screenCube[1]+2*wallThickness,screenCube[2]+wallThickness-0.001]);
        //cylinder(r=3, 0.001,$fn=6);
      }
    translate([overlap[3],overlap[0],-wallThickness-1])cube([screenCube[0]-overlap[2]-overlap[3],screenCube[1]-overlap[0]-overlap[1],screenCube[2]+1]);
    #screen();
  }
}
color("Green")base();
screen(extentionsOnly=true,nutHeight=nutHeight);
mainPcbPos = [screenCube[0]-mainPcbSize[0]-15,6,screenCube[2]+1.9];
translate(mainPcbPos){
  mainPcb();
  stainless(no="1.4301")for(x = [0,1], y = [0,1]){
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 3.5+4])nut("M3");
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 0.1])rotate([0,180,0])screw("M3x8");
  }
}
top();
module top(screwSecuringDiameter=16){
  for(x = [-1,1], y = [-1,1]){
    translate([screenCube[0]/2+x*patternX/2,screenCube[1]/2+y*patternY/2, screenCube[2]+nutHeight-clearanceDepth]){
      cylinder(d=screwSecuringDiameter,clearanceDepth,$fn=6);
    }
  }
  /*translate([screenCube[0]/2-patternX/2,screenCube[1]/2-patternY/2,screenCube[2]+nutHeight-clearanceDepth])minkowski(){
    cube([patternX,patternY,5]);
    cylinder(d=screwSecuringDiameter,0.001,$fn=6);
  }*/
}
