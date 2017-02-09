// Import Arduino library
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;

import oscP5.*;
import netP5.*;
OscP5 oscP5;
OscP5 oscP5Receiver;
NetAddress sending;
Arduino arduino;

// Led serial
int ledPin = 13;

// number of faces found
int found;

// pose
float poseScale;
PVector posePosition = new PVector();
PVector poseOrientation = new PVector();

// gesture
float mouthHeight;
float mouthWidth;
float eyeLeft;
float eyeRight;
float eyebrowLeft;
float eyebrowRight;
float jaw;
float nostrils;

// Creation of a variable which define the message we send to Wekinator (default : "/wek/inputs")
String inputMessage = "/wek/inputs";

// Make mySmile accessible from everywhere 
float mySmile;
float red = 255;

void setup() {
	
  size(640, 480);
  frameRate(30);
  
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(ledPin, Arduino.OUTPUT);
 
/* instantiating oscP5, listening to OSC messages *coming* from port 8338, default port on FaceOSC */
  oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "poseScale", "/pose/scale");
  oscP5.plug(this, "posePosition", "/pose/position");
  oscP5.plug(this, "poseOrientation", "/pose/orientation");
  oscP5.plug(this, "mouthWidthReceived", "/gesture/mouth/width");
  oscP5.plug(this, "mouthHeightReceived", "/gesture/mouth/height");
  oscP5.plug(this, "eyeLeftReceived", "/gesture/eye/left");
  oscP5.plug(this, "eyeRightReceived", "/gesture/eye/right");
  oscP5.plug(this, "eyebrowLeftReceived", "/gesture/eyebrow/left");
  oscP5.plug(this, "eyebrowRightReceived", "/gesture/eyebrow/right");
  oscP5.plug(this, "jawReceived", "/gesture/jaw");
  oscP5.plug(this, "nostrilsReceived", "/gesture/nostrils");
// Parameter #1 = your local IP adress (kinda like the postal adress of your computer) by default --> "127.0.0.1"
// Parameter #2 = the port we *send* the message on (kinda like a specific mailbox at your postal adress)
  sending = new NetAddress("127.0.0.1", 6448);
  
  oscP5Receiver = new OscP5(this, 12000);
  
}

void draw() {
  
  if(mySmile >= 150) {
   red = 0;
   arduino.digitalWrite(ledPin, Arduino.HIGH);
  } else {
   arduino.digitalWrite(ledPin, Arduino.LOW);
   red = 255;
   }
   
  background(red, mySmile, 0);
  sendOsc();
}

// Sending OSC messages function
void sendOsc() {

// On instancie un objet OscMessage, l'argument String "/wek/inputs" est le nom du message (par défaut sur Wekinator)
  OscMessage msg = new OscMessage(inputMessage);

// On ajoute une ou plusieurs valeurs (inputs) au message OSC avec la fonction .add()
// Ici : inputs envoyés à wekinator (port 6448) avec le message /wek/inputs
// Wekinator reçoit et lit les messages dans l'ORDRE
  msg.add((float)found); 
  msg.add((float)poseScale);
  msg.add((float)posePosition.x); 
  msg.add((float)poseOrientation.x);
  msg.add((float)mouthWidth); 
  msg.add((float)mouthHeight);
  msg.add((float)eyeLeft); 
  msg.add((float)eyeRight);
  msg.add((float)eyebrowLeft);
  msg.add((float)eyebrowRight);
  msg.add((float)jaw);
  msg.add((float)nostrils);
  
  oscP5.send(msg, sending);
}

void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("f")) { // looking for 1 float (type = "f") control value
        float smile = theOscMessage.get(0).floatValue();
        mySmile = map(smile, 0, 1, 0, 255);
     } else {
       mySmile = 0;
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }
}