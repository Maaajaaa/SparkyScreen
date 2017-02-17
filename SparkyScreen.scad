use<nutsnbolts/cyl_head_bolt.scad>
use<nutsnbolts/materials.scad>
include<nutsnbolts/data-access.scad> // database lookup functions
include<nutsnbolts/data-metric_cyl_head_bolts.scad>

$fn = 40;

/* [Front Bezel] */
//Final width of the bezel
bezelWidth = 12;  // [5:0.1:30]

//cornerRadius of the frontBezel
cornerRadius = 3.8; // [0:0.1:30]

//radius for smoothing the outer corners
cornerSmoothingRadius = 1.4; // [0:0.05:5]

//inner cornerRadius of the frontBezel
innerCornerRadius = 2; // [0:0.1:30]

//radius for smoothing the inner corners
innerCornerSmoothingRadius = 0.65; // [0:0.05:5]

//position of the screws that should connect the front and backPlate
cornerOffset = 5.7; // [0:0.05:20]


/* [Backside] */
//height of the first backPlate
1stBackPlateHeight = 5.4;// [0.1:0.1:10]

//scale of the backplate
2ndBackPlateScale = 0.2;// [-5:0.01:1]

//height of the 2nd backPlate
2ndBackPlateHeight = 10;// [2:0.1:15]

//show cable
showCables = true;

/* [General Options] */
lcdCube = [165,105,4.5];
patternX=50;
patternY=20;
clearanceDepth=6;
nutHeight=16;
nutMountDepth = 1.5;

/* [Hidden] */
//defintions (should stay as they are)
pcbColor=[0.11,0.36,0.89];
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
//withComponents on pcb
//mainPcbSize=[128.7,85.4,3.5];
//without them
mainPcbSize=[128.7,85.4,1.4];

module mainPcb(holes = "in",showCables=showCables){
  //board and MAIN components (reference: winborad IC (U300))
  difference(){
    color(pcbColor)cube(mainPcbSize);
    if(holes == "in")for(x = [0,1], y = [0,1])
        translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10),-1])cylinder(5,d=3.2,$fn=20);
  }
  //connectors
  color("LightGrey")translate([-0.001,12,-0.001])cube([12.3,22,7]);
  color("LightGrey")translate([-0.001,39,-0.001])cube([15,15,4.2]);
  //HDMI port and cable
  color("Grey")translate([25.5,-3,-0.2])cube([16.4,12.6,7.6]);
  if(showCables)color("SkyBlue")translate([25.5-3.2,-42.99,-0.2-3.2])cube([22,40,14]);
  //DVI port and cable
  color("LightGrey")translate([46.5,-6,-1.5])cube([38.4,17.5,12.4]);
  if(showCables)color("SkyBlue")translate([46.7,-45.99,-1.5-3.6/2])cube([38,40,16]);
  //VGA port and cable
  color("Blue")translate([89,-6,-1.5])cube([32,15.5,15.5]);
  if(showCables)color("SkyBlue")translate([87.75,-45.99,-1.5])cube([34.5,40,15.5]);

  color("LightGrey")translate([35.6,74.5,mainPcbSize[2]])cube([27,11,0.8]);
  //big components like coils and caps
  color("DarkSlateGrey")translate([64,21,mainPcbSize[2]])cube([43,56,4.2]);
  if(holes == "screws")stainless(no="1.4301")for(x = [0,1], y = [0,1]){
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 1.4+4])nut("M3");
    translate([4.6+x*(mainPcbSize[0]-9.2), 5.3+y*(mainPcbSize[1]-10), 0.1])rotate([0,180,0])screw("M3x6");
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
    translate([17,3,-1])cylinder(d=3,7);
    translate([3,65,-1])cylinder(d=3,7);
  }
}

module microUsbPcb(showCables=showCables){
  //PCB
  color("Darkgreen", 1)difference(){
    translate([0,0.6,0])cube([13.4, 15.1, 3.3]);
    translate([2.2,9.5,-.1]) cylinder(5, d=3);
    translate([11.2,9.5,-.1]) cylinder(5, d=3);
  }
  translate([1.6,0,3.3]){
    //space with solder
    translate([0,2.1-00.1,0]) cube([10.6,3.5,2.6]);
    translate([1.55,-0.001,0]){
      //solderfree space
      cube([7.5,2.1+0.002,2.6]);
      //bened end
      translate([-0.25,-0.001,-0.3])cube([8, .6, 3.2]);
   if(showCables)translate([-0.25-3,-30,-0.3-3.4])cube([14,30,10]);

   }
   }
}

module 3p5mmPcb(showCables=showCables){
  difference(){
    //pcb
    cube([10.4,20.7,2.7]);
    //hole
    translate([5.2,15,-1])cylinder(d=3,4);
  }
  //connector
  translate([2,-0.25,2.7])cube([6.4,11.6,5.1]);
  translate([5.2,-2.7,2.5+2.7])rotate([0,90,90])cylinder(d=5,2.7);
  if(showCables)translate([5.2,-2.5-20,2.5+2.7])rotate([0,30,0])rotate([0,90,90])cylinder(d=14,20,$fn=6);
}

module dCPowerPlug(showCables=showCables,topCut=false){
  cube([11.5,3.8,9.3]);
  translate([0,3.799,0])cube([6.5,12,9.3]);
  translate([11.5-9.3/2,3.799+12,9.3/2])rotate([90,0,0])cylinder(d=9.3,12);
  if(showCables)translate([11.5-9.3/2,0,9.3/2])rotate([90,0,0])cylinder(d=15,30);
  if(topCut)translate([11.5-9.3/2,3.799,9.3/2])cube([9.3/2,12,9.3/2]);
  //space for soldered cables
  translate([-3,6,2.5])cube([3.1,10.5,6.6]);
}

wallThickness = 2;
lcdFrontMountDepth = 1.5;
//[back,bottom,right,left]
overlap = [1.5,8,3.5,2];
screenCube = [lcdCube[0]-overlap[2]-overlap[3],lcdCube[1]-overlap[0]-overlap[1],lcdFrontMountDepth];
totalSize = screenCube + [bezelWidth*2,bezelWidth*2,0];

module frontBezel(lcdFrontMountDepth=lcdFrontMountDepth,bezelWidth=bezelWidth,instance="notMain",lcdCube=lcdCube,cornerRadius=cornerRadius){
  //overlap difference of left and right
  overlapCorrectionX = overlap[3]-overlap[2];
  overlapCorrectionY = overlap[0]-overlap[1];
  *echo("overlap(X,Y): ", overlapCorrectionX, overlapCorrectionY);
  //minimum size (only final size when wallThickness=0 and symmetric overlaps)
  basicBezelSize = [lcdCube[0],lcdCube[1],lcdCube[2]+lcdFrontMountDepth-0.001];
  basicBezelTranslation = [-overlap[3], -overlap[0], -lcdFrontMountDepth];
  //correct assymetric back-bottom and left-right realtion
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
      lcbBevelWidth = 2;
      bevelHeight = lcdFrontMountDepth;
      *hull(){
        //originalHeight but smaller bezelWidth
        translate([0,0,0])frontBezel(bezelWidth=bezelWidth-bevelHeight*2,cornerRadius=cornerRadius*0.75);
        //lower with right bezel
        translate([0,0,0])frontBezel(lcdFrontMountDepth=0);
      }
      *translate([overlap[3],overlap[0],0]){
        //beveled hole for the display
        hull(){
          color("DarkSlateGrey")translate([0,0,-lcdFrontMountDepth+0.001])cube(screenCube);
          color("DarkSlateGrey")translate([-lcbBevelWidth,-lcbBevelWidth,-lcdFrontMountDepth-screenCube[2]])
            resize([screenCube[0]+2*lcbBevelWidth,screenCube[1]+2*lcbBevelWidth,0])screenSpace();
        }
        color("Gray")translate([-overlap[3],-overlap[0],-0.001])scale([1, 1, 1.1])lcd();
      }
      *translate([overlap[3]-bezelWidth,overlap[0]-bezelWidth,-lcdFrontMountDepth])
        for(x=[0,1], y=[0,1]){
          //cornerOffset = bezelWidth/2+bevelHeight+lcbBevelWidth/2-0.5;
          baseTranslation = [cornerOffset,cornerOffset,2.9];
          translate(baseTranslation+[x*(totalSize[0]-2*cornerOffset),y*(totalSize[1]-2*cornerOffset),0])rotate([0,180,0])screw("M3x8",makeKeySlot=false);
        }
    }
    translate([overlap[3]-bezelWidth,overlap[0]-bezelWidth,-lcdFrontMountDepth])
      for(x=[0,1], y=[0,1]){
        //cornerOffset = bezelWidth/2+bevelHeight+lcbBevelWidth/2-0.5;
        baseTranslation = [cornerOffset,cornerOffset,2.9];
        stainless(no="1.4301")translate(baseTranslation+[x*(totalSize[0]-2*cornerOffset),y*(totalSize[1]-2*cornerOffset),0])rotate([0,180,0])screw("M3x8");
      }
  }
}

module screenSpace(){
  correction = innerCornerRadius+innerCornerSmoothingRadius;
  translate([correction,correction,0])minkowski(){
    cube(screenCube-[correction,correction,0]);
    cylinder(r=innerCornerRadius, 0.00001,$fn=4);
    cylinder(r=innerCornerSmoothingRadius,0.00001,$fn=30);
  }
}

buttonRotation = 0;
buttonPcbTranslation = [4,0,2.7];
//back();
//rotate([0,-45,-$t*360])  //only for animation
  //translate([-screenCube[0]/2,-screenCube[1],0])
  translate(){
      mainPcbPos = [lcdCube[0]-mainPcbSize[0]-20,-3,1.9];
      /*difference()
      {
        union(){
          *frontBezel(instance="main");
          back(instance="main");
        }

      }*/
      frontBezel(instance="main");
      difference(){
        back(instance="main");
        lcd(extentionsOnly=true,nutHeight=nutHeight);
        translate([0,0,lcdCube[2]]){
          translate(mainPcbPos)mainPcb(holes="screws",showCables=true);
          translate([-bezelWidth+overlap[3]+5.8,91,3.2]+buttonPcbTranslation)rotate([0,-buttonRotation,0])rotate([180,0,0])buttonPcb();
          translate([12,-9,9.298])rotate([0,180,0])dCPowerPlug(showCables=true,topCut=true);
          translate([mainPcbPos[0]+mainPcbSize[0]+0.5,3.5,2]){
            translate([3,-12,0])microUsbPcb(showCables=true);
            translate([0,18+10,-2-0.001])touchDriverPcb();
            translate([20.7,5,-2])rotate([0,0,90])3p5mmPcb(showCables=true);
          }
        }
      }
      #lcd(extentionsOnly=true,nutHeight=nutHeight);
      #translate([0,0,lcdCube[2]]){
        translate(mainPcbPos)mainPcb(holes="screws",showCables=false);
        translate([12,-9,9.3])rotate([0,180,0])dCPowerPlug(showCables=false);
        translate([-bezelWidth+overlap[3]+5.8,91,3.2]+buttonPcbTranslation)rotate([0,-buttonRotation,0])rotate([180,0,0])buttonPcb();
        translate([mainPcbPos[0]+mainPcbSize[0]+0.5,3.5,2]){
          translate([3,-12,0])microUsbPcb(showCables=false);
          translate([0,18+10,-2-0.001])touchDriverPcb();
          translate([20.7,5,-2])rotate([0,0,90])3p5mmPcb(showCables=false);
        }
      }
}

module back(screwSecuringDiameter=16,instance="notMain", shellThickness = [8,8,2], mounts=true){
  if(instance != "main"){
    if(mounts)for(x = [-1,1], y = [-1,1]){
      translate([lcdCube[0]/2+x*patternX/2,lcdCube[1]/2+y*patternY/2, lcdCube[2]+nutHeight-clearanceDepth]){
        cylinder(d=screwSecuringDiameter,clearanceDepth+nutThickness+nutMountDepth,$fn=6);
    }  }
    bevelWidth = 5;
    translate([0,0,lcdCube[2]])
    difference(){
      hull(){
        frontBezelbackShape(h=1stBackPlateHeight);
        translate([0,0,2ndBackPlateHeight])
        //scale([2ndBackPlateScale,2ndBackPlateScale,1])
        frontBezelbackShape(bezel=bezelWidth*2ndBackPlateScale,cornerRad=cornerRadius*2ndBackPlateScale);
        }
      cutoutRadius=8;
      translate([-bezelWidth+0.75,screenCube[1]/2,0])hull(){
        translate([0,0,0])rotate([0,20,180])hexoid(r=cutoutRadius,l=60,h=0.001);
        translate([0,0,2ndBackPlateHeight+0.1])rotate([0,20,180])hexoid(r=cutoutRadius*1.5,l=60*1.1,h=0.001);
      }
      /*hull(){
        translate([0,0,-0.001])cube(screenCube);
        #translate([0,0,2ndBackPlateHeight+3])
          cube(screenCube-[2ndBackPlateScale*2,2ndBackPlateScale*2,0]);
      }*/
    }
  }else{
    translate([screenCube[0]/2+overlap[3],screenCube[1]/2+overlap[0],0])difference()
    {
      backSize = [(screenCube[0]+bezelWidth*2),(screenCube[1]+bezelWidth*2),2ndBackPlateHeight];
      translate([-backSize[0]/2,-backSize[1]/2,0])translate([bezelWidth-overlap[3],bezelWidth-overlap[0]])back();
      translate([0,0,-0])
      resize(backSize-[2*shellThickness[0],2*shellThickness[1],shellThickness[2]])
      translate([-backSize[0]/2,-backSize[1]/2,0])translate([bezelWidth-overlap[3],bezelWidth-overlap[0]])back(mounts=false);
    }
  }
}
//frontBezelbackShape();

module frontBezelbackShape(h=0.01,bezel=bezelWidth,cornerRad=cornerRadius){
  frontBezel(lcdFrontMountDepth=0,lcdCube=[lcdCube[0],lcdCube[1],h],bezelWidth=bezel,cornerRadius=cornerRad);
}
//translate([0,0,50])rotate([0,0,180])hexoid(5,20,5);
module hexoid(r,l,h){
  hull(){
    translate([0,-l/2,0])rotate([0,0,30])cylinder(r=r,h,$fn=6);
    translate([0,l/2,0])rotate([0,0,30])cylinder(r=r,h,$fn=6);
    translate([0,-l/2-r,0])cube([l,l+2*r,h]);
  }
}
