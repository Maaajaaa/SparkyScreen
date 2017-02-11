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

pcbColor=[0.11,0.36,0.89];

/* [General Options] */
lcdCube = [165,105,4.5];
patternX=50;
patternY=20;
clearanceDepth=6;
nutHeight=16;
nutMountDepth = 1.5;
//defintions (should stay as they are)
thread="M4";
nutThickness = _get_fam(thread)[_NB_F_NUT_HEIGHT];
echo("<b>MAIN CHIP NEEDS AIRFLOW FOR COOLING</b>");

module lcd(patternX=50, patternY=20, thread = "M4", nutHeight=16, clearanceDepth=6, extentionsOnly=false){
  if(!extentionsOnly)color("SlateGrey")cube(lcdCube);
  if(extentionsOnly)stainless(no="1.4301")for(x = [-1,1], y = [-1,1]){
    translate([lcdCube[0]/2+x*patternX/2,lcdCube[1]/2+y*patternY/2, lcdCube[2]+nutHeight]){
      translate([0,0,3.2])nut(thread);
      translate([0,0,-clearanceDepth])cylinder(d=4.3,clearanceDepth*3);
    }
  }
}

mainPcbSize=[128.7,85.4,3.5];

module mainPcb(holes = "in"){
  //board and MAIN components (reference: winborad IC (U300))
  difference(){
    color(pcbColor)cube(mainPcbSize);
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
  if(holes == "screws")stainless(no="1.4301")for(x = [0,1], y = [0,1]){
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 3.5+4])nut("M3");
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 0.1])rotate([0,180,0])screw("M3x8");
  }

}

module buttonPcb(holes="in"){
  difference() {
    //bare pcb with resistors
    color(pcbColor)cube([15,83,1.7]);
    //holes
    for(y=[17,47.9,79.8]){
      translate([7.5,y,-1])cylinder(d=2.3,4);
  }  }
  //connector
  color("LightGrey")translate([1.5,-0.5,1.7])cube([12,8.1,3.2]);
  //buttons
  for(y=[19,28.4,48.5,58.5,68.5]){
    color("Black")translate([5.6-9,y,-0.001]){
      cube([9,8.3,3.7]);
      translate([-2,2.4,1.15])cube([2,3.5,1.5]);
  }   }
}

module touchDriverPcb(holes = "in"){
  difference(){
    //pcb including space for highest component (quarz)
    color("Green")cube([20,68,5.2]);
    //mounting holes
    translate([3,3,-1])cylinder(d=3,7);
    translate([17,65,-1])cylinder(d=3,7);
  }
}

module microUsbPcb(){
  //PCB
  color("Darkgreen", 1)difference(){
    translate([0,0.6,0])cube([13.4, 15.1, 3.3]);
    translate([2.2,9.5,-.1]) cylinder(5, d=3);
    translate([11.2,9.5,-.1]) cylinder(5, d=3);
  }
  translate([1.6,0,3.3]){
    //space with solder
    translate([0,2.1,0]) cube([10.6,3.5,2.6]);
    translate([1.55,0,0]){
      //solderfree space
      cube([7.5,2.1,2.6]);
      //bened end
      translate([-0.25,0,-0.3])cube([8, .6, 3.2]);
  } }
}

module 3p5mmPcb(){
  difference(){
    //pcb
    cube([10.4,20.7,2.7]);
    //hole
    translate([5.2,15,-1])cylinder(d=3,4);
  }
  //connector
  translate([2,-0.25,2.7])cube([6.4,11.6,5.1]);
  translate([5.2,-2.7,2.5+2.7])rotate([0,90,90])cylinder(d=5,2.7);
}

wallThickness = 2;
lcdFrontMountDepth = 1.5;
//[top,bottom,right,left]
overlap = [1.5,8,3.5,2];
screenCube = [lcdCube[0]-overlap[2]-overlap[3],lcdCube[1]-overlap[0]-overlap[1],lcdCube[2]+1];

module frontBezel(lcdFrontMountDepth=lcdFrontMountDepth,bezelWidth=bezelWidth,instance="notMain"){
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
  cornerCorrection = -[cornerRadius*2+cornerSmoothingRadius*2,cornerRadius*2+cornerSmoothingRadius*2,0];
  finalSize = preFinalSize + bezelCorrection + cornerCorrection;
  if(instance != "main")
  {
    echo([bezelWidth*2,bezelWidth*2,0]-currentBezelWidth);
    if(bezelCorrection[0] < 0 || bezelCorrection[1] < 0)
      echo("<b>ERROR: your choosen bevelSize is too small for the display offset and wall thickness</b>", "minimum is:", max(overlap)+wallThickness);
    finalTranslation = basicBezelTranslation+overlapBezelTranslationCorrection+wallTranslation-bezelCorrection/2-cornerCorrection/2;
    echo(currentBezelWidth);
    translate([overlap[3],overlap[0],0])//difference()
    {
      translate(finalTranslation)
        minkowski(){
          cube(finalSize);
          cylinder(r=cornerRadius, 0.00001,$fn=4);
          cylinder(r=cornerSmoothingRadius,0.00001,$fn=30);
        }
    }
  }
  if(instance == "main"){
    difference() {
      hull(){
        bevelHeight = lcdFrontMountDepth;
        //originalHeight but smaller bezelWidth
        translate([0,0,0])frontBezel(bezelWidth=bezelWidth-bevelHeight*2);
        //lower with right bezel
        translate([0,0,0])frontBezel(lcdFrontMountDepth=0);
      }
      translate([overlap[3],overlap[0],0]){
        color("DarkSlateGrey")translate([0,0,-lcdFrontMountDepth-1])cube(screenCube);
        #color("Gray")translate([-overlap[3],-overlap[0],0])scale([1, 1, 1.1])lcd();
      }
    }
  }
}

//rotate([0,45,-$t*360])  //for animation
  translate([-screenCube[0]/2,-screenCube[1]/2,0])  {
      frontBezel(instance="main")
      #lcd();
      top();

      mainPcbPos = [lcdCube[0]-mainPcbSize[0]-20,6,1.9];
      #lcd(extentionsOnly=true,nutHeight=nutHeight);
      #translate([0,0,lcdCube[2]]){
        translate([-bezelWidth+overlap[3]+5.5,91,3.2])rotate([180,0,0])buttonPcb();
        translate([mainPcbPos[0]+mainPcbSize[0]+2,3.5,2]){
          microUsbPcb();
          translate([0,18+10,-2])touchDriverPcb();
          #translate([20.7,18+9.4,-2+7.9])rotate([0,180,90])3p5mmPcb();
        }
        translate(mainPcbPos)mainPcb(holes="screws");
      }
  }

module top(screwSecuringDiameter=16){
  for(x = [-1,1], y = [-1,1]){
    translate([lcdCube[0]/2+x*patternX/2,lcdCube[1]/2+y*patternY/2, lcdCube[2]+nutHeight-clearanceDepth]){
      cylinder(d=screwSecuringDiameter,clearanceDepth+nutThickness+nutMountDepth,$fn=6);
    }
  }
}
