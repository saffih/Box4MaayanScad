
fn = 100/10;
dl=0.2; // layer height
space=0.05;// between cover and walls
w=0.4; // nozzel width I use
d = 3*w; // thick 3 walls
td = 3*w; // top bottom , 6 layers of 0.2 
cd = d*2; // cover height
nd =2*(d+d);//inner margin, on 2 sides  
a=20

;  // coomon edge size for x y h
x=a;//25;
y=a;//40;
r=4; // round corners, 0 for rect
h=a-td; // height

module letter(l, letter_size) {
	text(l, size = letter_size, font = font, halign = "center", valign = "center", $fn = 16);
	
}

module boxAndLidOf(td=td, height=h, scale=1.0, twist=0, offBy=0, fn=fn){
    if (offBy==0){
       aBoxAndLidOf(td=td, height=height, scale=scale, twist=twist, offBy=[x*scale+5, 0 ,0], fn=fn) children();
    } else {
         aBoxAndLidOf(td=td, height=height, scale=scale, twist=twist, offBy=offBy, fn=fn) children() ;
        }
    
}

module aBoxAndLidOf(td=td, height=h, wallWidth=d, scale=1.0, twist=0, offBy=[60,0,0], fn=fn){
    union () {
        dScale = (scale-1)/height;
        heightC = td;    
        heightB = height - td;    
        scaleB = 1+dScale*height;
        dTwist = twist/height;
        twistB = dTwist*heightB;

        translate (offBy) 
        for ( i= [0:1:$children-1]) { 
        boxOf(td=td, height=height, wallWidth=wallWidth, scale=scaleB, twist=twistB, fn=fn) children(i);
        }
        
        translate (-offBy)
       difference()
//        intersection()
        {
            union(){
                for ( i= [0:1:$children-1]) { 
                    coverOf( height=heightC, cd=cd, wallWidth=wallWidth, dScale=dScale, dTwist = dTwist, fn=fn ) scale([scaleB, scaleB, scaleB]) 
                    rotate([0, 180,0])  
                    children(i);
                }
            }
         //#   
          translate([0,0,height+td])          
          rotate(-dTwist*(height))      
          rotate([0, 180, 0]) 
            union() {
                for ( i= [0:1:$children-1]) { 
                    boxOf(td=td, height=height, wallWidth=wallWidth, scale=scaleB, twist=twistB, fn=fn) 
                     children(i);
                }
            }/**/
        }
    }
}

module boxOf(td=td, height=h, wallWidth=d, scale=1.0, twist=0, fn=fn){
    union(){
        addHeightTo(height=td, twist=twist/(height/td), fn=fn)  children();
        wallsOf(height=height, wallWidth=wallWidth, scale=scale, twist=twist, fn=fn) children();
    }
}

/*module blockOf(height=h, scale=1.0, twist=0, fn=fn){
        addHeightTo(height=height, twist=twist, scale=scale, fn=fn)  children();
}
*/

module coverOf( height=td, cd = cd, wallWidth=d,  dScale=0.0, dTwist=0, fn=fn ){
    h = height;
    d = wallWidth;
     union(){
    addHeightTo(height = td, twist = dTwist*td, scale = 1-dScale*td, fn = fn) children();
    addHeightTo(height = height+cd, twist = dTwist*(height+cd), 
               scale= 1-dScale*(height+cd), fn=fn) difference(){
        lineOf(wallWidth+space+wallWidth/2) children();  
        lineOf(wallWidth+space) children();   
       }
      }
}

module afloor(w=50,l=80,r=10){    
    a=[w-2*r,l-2*r];
    offset(r, $fn=fn) square(a, center=true);
}


module wallsOf( height=40, wallWidth=0.2, scale=1.0, twist=0, fn=fn){
                 addHeightTo(height=height, twist=twist, scale=scale, fn=fn) lineOf(wallWidth) children();
}
    

// inside line width
module lineOf(w){
union(){    
          difference() {
              children();
              offset(-w) children();
          }
}}


module addHeightTo( height=1, twist=0, scale=1.0, fn=fn){
    linear_extrude(height = height, twist = twist, slices = h*2, scale=scale ,$fn = fn)children();
      }
      
// star code taken from 
function point(angle) = [ sin(angle), cos(angle) ];
function radius(i, r1, r2) = (i % 2) == 0 ? r1 : r2;
function star(count, r1, r2, i = 0, result = []) = i < count
    ? star(count, r1, r2, i + 1, concat(result, [ radius(i, r1, r2) * point(360 / count * i) ]))
    : result;

module aFloor(side=a, r=0, sides=4, offBy=[0,0,0]){
    alpha=360/sides;
    radius=side*sin(90-alpha/2)/sin(alpha);
    translate(offBy) offset(r=r,$fn=fn) offset(delta=-r) rotate(180/sides) circle(radius, $fn=sides); 
}

module aBaloon(side=a, r=0, sides=4){
    alpha=360/sides;
    radius=side*sin(90-alpha/2)/sin(alpha)-r;
    echo("radius ",radius, "  r:",r);
      offset(r, $fn=fn) rotate(180/sides) circle(radius, $fn=sides); 
}

module diffCover(boxHeight, coverThick=td,groove=0.5){// children base, box 
   difference()
    //intersection()
    {
        children(0);
        #translate([0,0,boxHeight+1*coverThick-1*groove]) mirror([0,0,1])children(1);
    }
}
module coverBase(height=td, ledge=[0.5, td*0.5]){// children base, box 
    union(){   
            addHeightTo(height=ledge[1]) offset(delta=ledge[0]) children(); 
        addHeightTo(height=height) children();    
    }
  }

 
module man(u=10) {
      union() {
           offset(2)  polygon(star(10, u, 2*u));
           translate([0,-u*2.1,0]) circle(u);
            translate([0,-u/10, 0]) afloor(u*1.6,u*2,a/5);
    }
}


// exmaple the engraved gift box engraved
if(0) { 
    sz=20;
    groove=dl*3;
    //translate([+sz*3.5,-sz,0]) coverOf(height=td, cd=cd, wallwidth=d) man(sz);
            
    //translate([-sz*3.5,-sz,0]) boxOf(height=sz, wallWidth=td) man(sz);
    coverThick=td+groove;
    boxHeight=30;
    difference(){
        //*
        diffCover(boxHeight=boxHeight, coverThick=coverThick, groove=groove) {
            union(){
            coverOf(height=coverThick, cd=cd, wallwidth=d) man(sz);
            coverBase(height=2*dl) man(sz);        
            }
           boxOf(height=boxHeight, wallwidth=td) man(sz);
        }/**/
        translate([0,sz/2,0]){
            first = "מזל טוב";
            second = "להולדת";
            third = "בתכם";
            letter_size=sz*5/12;
            line_space = letter_size*1.3;
            letterHeight = 3*dl;
            translate([0,-2*line_space,0])
            # mirror([1,0,0]) rotate(180) addHeightTo(letterHeight) letter(first, letter_size);
            translate([0,-1*line_space,0])
            # mirror([1,0,0]) rotate(180) addHeightTo(letterHeight) letter(second, letter_size);
            translate([0,-0*line_space,0])
            # mirror([1,0,0]) rotate(180) addHeightTo(letterHeight) letter(third, letter_size);
        }
    }
}

// example 2 star ,starhead
if(0){
    translate([0,4*a, 0]) boxAndLidOf(scale=1)man(a/2);
    translate([0,a*5, 0]) boxAndLidOf(scale=1.2, offBy=[a*4,0,0])  offset(2)  polygon(star(10, 10, a), $fn=fn);
}

// example 3 star scaled
if (0) {
    translate([0, +8*a, 0])
    {
    ae=a*1.5;
         boxAndLidOf(scale=1.2, height=ae, offBy=[ae,10,0])  offset(2)  polygon(star(10, ae/2, ae), $fn=fn);
         boxAndLidOf(scale=1, height=20, offBy=[ae*4,10,0]) circle(20, $fn=fn);
    }
}

// example 4 starsqaround
    
if (0) {
    translate([0,100, 0]) boxAndLidOf(scale=1)
      union() {
           offset(2)  polygon(star(10, 10, a));
           translate([0,-25,0]) circle(10);
            translate([0,-4, 0])  
            afloor(x,y,r); 

          //  translate([-50,-50, 0])  
//          afloor(x,y,r);
  
           }
}
       
// examples 5 - twisted pentagram
if(0) {
    translate([0,0, 0]) boxAndLidOf(scale=1.3, twist=-90*1, offBy=[a,0,0]) 
               aFloor(a, r, 5);//1.2
    translate([0,0, 0]) boxAndLidOf(scale=1.2, twist=30*1, offBy=[3*a,0,0]) 
               aFloor(a*1, r, 4);//2
   
}
// example 6 crazy spiral
if(0) {
 translate([200,0,0]) boxOf(td=td,height=90,  scale=1.5, twist=360*2) translate([15,0,0]) circle (a, $fn=12);
}

//
//    translate([200 ,0, 0])  
//addHeightTo(height=td*3,scale=0)  offset(2) polygon(star(12, 12, sz), $fn=fn);

// examples 7 pot
if(0) {
    f=1;
    sz=70*f;
    h=170*f;
    bsz=sz*0.5;//a*3*1.5;
    bh=h*0.5;
    
    union(){
        difference(){
            union() {
                // shape
                boxOf(height=h, td=td, scale=1.4, twist=30*1,fn=fn) 
                offset(r=10*f) offset(delta=-10*f) 
                circle (sz, $fn=6);
            
                translate([0,0,td]) // drain cover
                addHeightTo(height=td/2,scale=0)  
                offset(2) polygon(star(12, 10, sz), $fn=fn);
            }
            addHeightTo(10) circle(10*f, $fn=fn);//hole
            
            addHeightTo(height=td/2,scale=0)  // drain
            offset(2) polygon(star(12, 10, sz), $fn=fn);

         }
        translate([0,0,0]) rotate(-360/6/2)
difference()
         { translate([0,0,h]) mirror([0,0,180])
             boxOf(height=h, scale=1.4, twist=-30*1,fn=fn) 
             offset(r=10*f) offset(delta=-10*f) 
              circle (sz, $fn=6);
             addHeightTo(height=h, scale=1.4, twist=30*1, fn=fn) 
             offset(r=10*f) offset(delta=-10*f) 
              rotate(-360/6/2) circle  (sz, $fn=6);  

        }
     }
   
}

module base(u=10) {
      union() {
           offset(2)  polygon(star(10, u, 2*u));
    }
}
//  engraved start
if(1) { 

    sz=10;
    groove=dl*3;
    //translate([+sz*3.5,-sz,0]) coverOf(height=td, cd=cd, wallwidth=d) man(sz);
            
    //translate([-sz*3.5,-sz,0]) boxOf(height=sz, wallWidth=td) man(sz);
    coverThick=td+groove;
    boxHeight=sz*1.5;
    translate([+sz*3.5,-sz,0])
    difference(){
        //*
        diffCover(boxHeight=boxHeight, coverThick=coverThick, groove=groove) {
            union(){
            coverOf(height=coverThick, cd=cd, wallwidth=d)
                     base(sz);
            coverBase(height=2*dl)
                     base(sz);
            }
           boxOf(height=boxHeight, wallwidth=td)
                     base(sz);
        }/**/
        translate([0,sz/2,0]){
            first = "תופינים";
            second = "Love";
            third = "Hadas";
            letter_size=sz*5/12;
            line_space = letter_size*1.3;
            letterHeight = 3*dl;
            translate([0,-2*line_space,0])
            # mirror([1,0,0]) rotate(180) addHeightTo(letterHeight) letter(first, letter_size);
            translate([0,-1*line_space,0])
            # mirror([1,0,0]) rotate(180) addHeightTo(letterHeight) letter(second, letter_size);
            translate([0,-0*line_space,0])
            # mirror([1,0,0]) rotate(180) addHeightTo(letterHeight) letter(third, letter_size);
        }
    }
    // translate([-sz*3.5,-sz,0])
    addHeightTo(scale=1.2, height=boxHeight)  base(sz/1.2);

}