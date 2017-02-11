use<nutsnbolts/cyl_head_bolt.scad>
use<nutsnbolts/materials.scad>
include<nutsnbolts/data-access.scad> // database lookup functions
include<nutsnbolts/data-metric_cyl_head_bolts.scad>

$fn = 40;

/* [Optical Enhancements] */
//Final width of the bezel
bezelWidth = 12;  // [5:0.1:30]

//cornerRadius of the frontBezel
cornerRadius = 5; // [0:0.1:30]

//radius for smoothing the outer corners
cornerSmoothingRadius = 2; // [0:0.05:5]

/* [General Options] */
lcdCube = [165,105,4.5];
patternX=50;
patternY=20;
clearanceDepth=6;
nutHeight=16;
//defintions (should stay as they are)
thread="M4";
nutThickness = _get_fam(thread)[_NB_F_NUT_HEIGHT];
//MAIN CHIP NEEDS AIRFLOW FOR COOLING
module lcd(patternX=50, patternY=20, thread = "M4", nutHeight=16, clearanceDepth=6, extentionsOnly=false){
  if(!extentionsOnly)color("SlateGrey")cube(lcdCube);
  if(extentionsOnly)stainless(no="1.4301")for(x = [-1,1], y = [-1,1]){
    translate([lcdCube[0]/2+x*patternX/2,lcdCube[1]/2+y*patternY/2, lcdCube[2]+nutHeight]){
      translate([0,0,3.2])nut(thread);
      translate([0,0,-clearanceDepth])cylinder(d=4.3,clearanceDepth);
    }
  }
}
function x(x) = x;
//translate([0,0,-lcdCube[2]])lcd();
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

//[left-right,top-bottom]
wallThickness = 2;
lcdFrontMountDepth = 1.5;
//[top,bottom,right,left]
//correct
overlap = [1.5,8,3.5,2];
screenCube = [lcdCube[0]-overlap[2]-overlap[3],lcdCube[1]-overlap[0]-overlap[1],lcdCube[2]+1];
//swapped
//overlap = [1.5,8,2,3.5];
module frontBezel(){
  //overlap difference of left and right
  overlapCorrectionX = overlap[3]-overlap[2];
  overlapCorrectionY = overlap[0]-overlap[1];
  *echo("overlap(X,Y): ", overlapCorrectionX, overlapCorrectionY);
  //minimum size (only final size when wallThickness=0 and symmetric overlaps)
  basicBezelSize = [lcdCube[0],lcdCube[1],lcdCube[2]+lcdFrontMountDepth-0.001];
  basicBezelTranslation = [-overlap[3], -overlap[0], -lcdFrontMountDepth];
  //correct assymetric top-bottom and left-right realtion
  overlapBezelSizeCorrection = [abs(overlapCorrectionX),abs(overlapCorrectionY),0];
  overlapBezelTranslationCorrection = [overlapCorrectionX,overlapCorrectionY,0];
  //add at the minimalRequiredWalls to all sides
  wallSize = [wallThickness*2,wallThickness*2,0];
  wallTranslation = [-wallThickness,-wallThickness,0];
  //finally add up all correction and make bezels equal
  preFinalSize = basicBezelSize+overlapBezelSizeCorrection+wallSize;
  currentBezelWidth = (preFinalSize-[screenCube[0],screenCube[1],preFinalSize[2]]);
  bezelCorrection = ([bezelWidth*2,bezelWidth*2,0])-currentBezelWidth;
  finalSize = preFinalSize + bezelCorrection;
  echo([bezelWidth*2,bezelWidth*2,0]-currentBezelWidth);
  if(bezelCorrection[0] < 0 || bezelCorrection[1] < 0)
    echo("<b>ERROR: your choosen bevelSize is too small for the display offset and wall thickness</b>", "minimum is:", max(overlap)+wallThickness);
  finalTranslation = basicBezelTranslation+overlapBezelTranslationCorrection+wallTranslation-([bezelWidth*2,bezelWidth*2,0]-currentBezelWidth)/2;
  echo(currentBezelWidth);
  difference()
  {
    translate(finalTranslation)
      minkowski(){
        translate([cornerRadius+cornerSmoothingRadius,cornerRadius+cornerSmoothingRadius,0])
          cube(finalSize-[cornerRadius*2+cornerSmoothingRadius*2,cornerRadius*2+cornerSmoothingRadius*2,0]);
        cylinder(r=cornerRadius, 0.00001,$fn=4);
        cylinder(r=cornerSmoothingRadius,0.00001,$fn=30);
      }

    color("DarkSlateGrey")translate([0,0,-lcdFrontMountDepth-1])cube(screenCube);
    color("Gray")translate([-overlap[3],-overlap[0],0])scale([1, 1, 1.1])lcd();
  }
}

rotate([0,45,-$t*360])
  translate([-screenCube[0]/2,-screenCube[1]/2,0])
    frontBezel();
*lcd(extentionsOnly=true,nutHeight=nutHeight);
mainPcbPos = [lcdCube[0]-mainPcbSize[0]-15,6,lcdCube[2]+1.9];
*translate(mainPcbPos){
  mainPcb();
  stainless(no="1.4301")for(x = [0,1], y = [0,1]){
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 3.5+4])nut("M3");
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 0.1])rotate([0,180,0])screw("M3x8");
  }
}
*top();
module top(screwSecuringDiameter=16){
  for(x = [-1,1], y = [-1,1]){
    translate([lcdCube[0]/2+x*patternX/2,lcdCube[1]/2+y*patternY/2, lcdCube[2]+nutHeight-clearanceDepth]){
      cylinder(d=screwSecuringDiameter,clearanceDepth,$fn=6);
    }
  }
  /*translate([lcdCube[0]/2-patternX/2,lcdCube[1]/2-patternY/2,lcdCube[2]+nutHeight-clearanceDepth])minkowski(){
    cube([patternX,patternY,5]);
    cylinder(d=screwSecuringDiameter,0.001,$fn=6);
  }*/
}

function offset(x,y) = max(x,y)-min(x,y);
