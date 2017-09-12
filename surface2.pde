import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

ControlIO control;

ControlDevice device1;
ControlDevice device2;

ControlButton d1buttonL;
ControlButton d1buttonR;
ControlButton d2buttonL;
ControlButton d2buttonR;
ControlSlider slider;
ControlButton button2;
ControlSlider slider2;

boolean center = true, phaseI = true, PickedFocus=false, animating = false, showPts = false; 
float t=0, s=0, tt = 0;
float degree1 = 70.0, degree2 = PI/2 + 40.0;
int f=0, maxf=5, counter = 0; //(4)
pt P = new pt();
pt Q = new pt();
pt X = new pt();
pt Y = new pt();
pts left = new pts();
pts right = new pts();
pts R1 = new pts();
pts R2 = new pts();
pts R = new pts();

static public void main(String args[]) {
   PApplet.main(new String[] { "surface2" });
}


int mice = ManyMouse.Init();
ManyMouseEvent event = new ManyMouseEvent();

void setup() {
  thread("main");
  size(900, 900, P3D);
  control = ControlIO.getInstance(this);
  println(control.deviceListToText("")); 
  device1 = control.getDevice("USB Receiver");
  device2 = control.getDevice("USB OPTICAL MOUSE");
  left.declare(); right.declare(); R.declare();R1.declare(); R2.declare();
  //right.loadPts("data/pts");
  right.addPt(new pt(156.23712,120.41205,0));
  left.addPt(new pt(right.G[0].x-400, right.G[0].y, right.G[0].z));
  Q = right.G[0];
  P = left.G[0];
  X = P(Q, P); R.addPt(X);
  R1.addPt(P(Q, X));
  R2.addPt(P(X, P));
  d1buttonL = device1.getButton(0);
  d2buttonR = device2.getButton(1);
}

void draw() {
  background(255);
  noStroke();
  lights();
  pushMatrix();
  setView();
  showFloor();
  sphere(left.G[0], 10);
  sphere(right.G[0],10);
  if(phaseI && !animating) {
    rightControl(right.G[0]);
    leftControl(left.G[0]);
  }
  if(animating) {
    
    phaseI = false;
    f++; if (f>=maxf) {animating=true; f=0; counter++;}
    if(f%5 == 0) {
      if(d1buttonL.pressed()) {
        rightControl(Q);
        right.addPt(Q);
        print("hhhhha");
        if(d2buttonR.pressed()) {
          leftControl(P);
        }
        left.addPt(P);
        Q = new pt(Q.x, Q.y, Q.z+5.0);
        P = new pt(P.x, P.y, P.z+5.0);
        pt X = biArcCenter(Q, P, degree1, degree2)[0];
        R1.addPt(X);
        pt Y = biArcCenter(Q, P, degree1, degree2)[1];
        R2.addPt(Y);
        pt U = biArcCenter(Q, P, degree1, degree2)[2];
        R.addPt(U);
      } else {
        if(d2buttonR.pressed()) {
          leftControl(P);
          right.addPt(Q);
          left.addPt(P);
          Q = new pt(Q.x, Q.y, Q.z+5.0);
          P = new pt(P.x, P.y, P.z+5.0);        
          pt X = biArcCenter(Q, P, degree1, degree2)[0];
          R1.addPt(X);
          pt Y = biArcCenter(Q, P, degree1, degree2)[1];
          R2.addPt(Y);
          pt U = biArcCenter(Q, P, degree1, degree2)[2];
          R.addPt(U);
        }
      }
    }
   };
   
   if(showPts) {
     for(int i = 1; i < right.nv; i++) {
       fill(blue);
       sphere(right.G[i], 2);
       sphere(left.G[i], 2);
       fill(green);
       sphere(R.G[i], 2);
       fill(orange);
       showArcPt(left.G[i], R1.G[i], R.G[i]);
       showArcPt(right.G[i], R2.G[i], R.G[i]);
     }
   }
  popMatrix();
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////                                        ////////////////////////////////////////////
////////////////////////////////////            HELPER FUNCTIONS            ////////////////////////////////////////////
////////////////////////////////////                                        ////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void rightControl(pt Q) {
  Q.x += device1.getSlider(0).getValue();
  Q.y += device1.getSlider(1).getValue();
}

void leftControl(pt P) {
    P.x += device2.getSlider(0).getValue();
    P.y += device2.getSlider(1).getValue();
}


void showArcPt(pt Q, pt X, pt P) {
  showSpiralPattern(Q, X, P, X);

}

pt center(pt Q, pt P, float degree) {
  float beta = PI/2 - degree;
  //beta = PI - (PI/2 - beta)*2;
  float d = sqrt(pow((Q.x - P.x), 2) + pow((Q.y - P.y), 2));
  float h = (d/2.0) * tan(PI/2 - beta);
  if(beta < 0 ) h = (d/2.0) * tan(-PI/2 - beta);
  print("beta is : ");
  println(beta);
  pt mid = P(Q, P);
  pt center = new pt(mid.x, mid.y+h, mid.z);
  return center;
}

pt[] biArcCenter(pt Q, pt P, float alpha, float beta) {
  //float d = sqrt(pow((Q.x - P.x), 2) + pow((Q.y - P.y), 2));
  float d = d(Q, P);
  //println(d);
   float a = d/(2.0*cos(alpha) + 2.0*cos(PI - beta));
   //println(a);
   pt J = P(P, V(2*cos(alpha)*a, U(P,Q)));
   pt mid1 = P(P, J);
   pt I1 = P(P, V(a, U(R(J, 2*PI - alpha, P), P)));
   pt O1 = P(mid1, V(tan(PI/2.0 - alpha)*d(P, J)/2.0, U(mid1, R(I1, PI, mid1))));
   pt mid2 = P(Q, J);
   pt I2 = P(Q, V(a, U(R(J, PI + beta, Q), Q)));
   pt O2 = P(mid2, V(tan(beta - PI/2.0)*d(Q, J)/2.0, U(mid2, R(I2, PI, mid2))));
   pt []arr = {O1, O2, J};
   return arr;
}

void showFloor() {
    fill(255); 
    pushMatrix(); 
      translate(0,0,-1.5); 
      float d=100;
      int n=20;
      pushMatrix();
        translate(0,-d*n/2,0);
          for(int j=0; j<n; j++)
            {
            pushMatrix();
              translate(-d*n/2,0,0);
              for(int i=0; i<n; i++)
                {
                fill(200); box(d,d,1);  pushMatrix(); translate(d,d,0);  box(d,d,1); popMatrix();
                fill(255); pushMatrix(); translate(d,0,0); box(d,d,1); translate(-d,d,0); box(d,d,1); popMatrix();
                translate(2*d,0,0);
                }
            popMatrix();
            translate(0,2*d,0);
            }
      popMatrix(); // draws floor as thin plate
    popMatrix(); // draws floor as thin plate
    }


void main()
    {
    //int mice = ManyMouse.Init();
    //ManyMouseEvent event = new ManyMouseEvent();
    int temp = 0;
    //if (mice > 0)  // report events until process is killed.
    //{
          println("ManyMouse.Init() reported " + mice + ".");
    for (int i = 0; i < mice; i++) {
      println("Mouse #" + i + ": " + ManyMouse.DeviceName(i));
    }
      if (!ManyMouse.PollEvent(event))
        try { Thread.sleep(1); } catch (InterruptedException e) {}
       else {
         print("Mouse #");
         print(ManyMouse.DeviceName(event.device));
         print(" ");
         
////////////////////////////////////CHANGE NAMES HERE////////////////////////////////////
         if(ManyMouse.DeviceName(event.device).equals("USB OPTICAL MOUSE")) {temp = 1;}
         if(ManyMouse.DeviceName(event.device).equals("USB Receiver")) { temp = 2;}
/////////////////////////////////////////////////////////////////////////////////////////
          switch (event.type){
            case ManyMouseEvent.SCROLL:
              print("scroll wheel ");
              if (event.item == 0){
                if(temp == 1) {
                  degree1 += event.value * PI * (5.0/180.0);
                  print(event.value);
                } if(temp == 2) {
                  degree2 += event.value * PI * (5.0/180.0);
                  print(event.value);
                }
              }
               break;

             case ManyMouseEvent.DISCONNECT:
               print("disconnect");
               mice--;
               break;
             } // switch
             println();
           } // if
        //}
        ManyMouse.Quit();
    } // Main