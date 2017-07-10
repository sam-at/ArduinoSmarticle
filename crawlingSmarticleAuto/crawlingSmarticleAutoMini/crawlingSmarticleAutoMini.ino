#include <SoftwareSerial.h> 
#include "Servo.h"

/* Pin Definitions */
#define servo1 5 //new: 10
#define servo2 6 //new: 11
#define led 13
SoftwareSerial AS(9,10);
/* Instance Data & Declarations */
Servo S1;
Servo S2;
const int SERVONUM = 3;
uint16_t const del = 400;
static int p1 = 1500; static int p2 = 1500;
uint8_t minn = 0; uint8_t maxx = 180; uint8_t midd = 90;
uint8_t gaitRadius = 20; //between 0 and 90 degrees
uint8_t radiusChange;
void deactivateSmarticle();
void activateForward();
void activateBackward();
void stopLoop();
int dir = 1;
int v=0;//run nums
int maxV=10;
void setup() {
   AS.begin(9600);
  S1.attach(servo1,600,2400);
  S2.attach(servo2,600,2400);
  pinMode(led,OUTPUT);
//  radiusChange = 90 - gaitRadius;
//  minn = minn + radiusChange;
//  maxx = maxx - radiusChange;
  deactivate();
  delay(5000);
}

void loop()
{
  activateForward();
  if(AS.available()>0)
  {
    dir=AS.read();
    v=v+1;
    if(v>maxV)
    {
      v=1;
      gaitRadius=gaitRadius+5;
      if(gaitRadius>90)
      {
        AS.println("end");
        stopLoop();
      }
    }
    String message = String(dir)+"_"+String(gaitRadius)+"_"+String(v);
    AS.println(message); 
  }
}

/* Moves the arms parallel to the Smarticle's body */
void stopLoop()
{
  while(1);
}
void deactivate() {
  S1.writeMicroseconds(p1=1500);
  S2.writeMicroseconds(p2=1500);
  delay(del);
}

/* Moves the Smarticle forward (convention: switch on left side) */
void activateForward() {
  if(dir==1)
  {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(300);
  }
  else
  {
  activateBackward();
  /*S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del); 
   S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=minn * 10 + 600);
  delay(del);
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(del);
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=maxx * 10 + 600);
  delay(300);*/
  }
}

/* Moves the Smarticle backward (convention: switch on left side) */
void activateBackward() {
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=(180-minn) * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=maxx * 10 + 600);
  S2.writeMicroseconds(p2=(180-maxx) * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=(180-maxx) * 10 + 600);
  delay(del);   
  S1.writeMicroseconds(p1=minn * 10 + 600);
  S2.writeMicroseconds(p2=(180-minn) * 10 + 600);
  delay(300);
}

