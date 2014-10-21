import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
  
Minim minim;
AudioInput input;
AudioOutput out;
FFT fft;


int countx=0;
int county=0;

boolean GOT_RED=false, GOT_GREEN=false, GOT_BLUE=false;
int RED_BASE=250, GREEN_BASE=700, BLUE_BASE=1000;
float NEW_LINE=3000;


float r, g, b;
SineWave siner, sineg, sineb;


PImage img; 
int[][] values;
color[][] colorz; 
int wi;
int hi;

void sleep(long ms){
  int a=1;
  for (long i = 0; i < ms; i++) {a=a*a*a*a*a*a;}
}

void init_red() {
 siner = new SineWave(RED_BASE, 0.5, out.sampleRate());
 siner.portamento(200);
 out.addSignal(siner);
 float mil = millis();
 while (millis()-mil<3000) {}
 siner.setAmp(0);
}

void init_green() {
 sineg = new SineWave(GREEN_BASE, 0.5, out.sampleRate());
 sineg.portamento(200);
 out.addSignal(sineg);
 float mil = millis();
 while (millis()-mil<3000) {}
 sineg.setAmp(0);
}

void init_blue() {
 sineb = new SineWave(BLUE_BASE, 0.5, out.sampleRate());
 sineb.portamento(200);
 out.addSignal(sineb);
 float mil = millis();
 while (millis()-mil<3000) {}
 sineb.setAmp(0);
}

void send_newline(){
  SineWave sine_newline;
  sine_newline = new SineWave(NEW_LINE, 0.8, out.sampleRate());
  sine_newline.portamento(200);
  out.addSignal(sine_newline);
   float mil = millis();
   while (millis()-mil<200) {}
   sine_newline.setAmp(0);  
}

void playsound()
{



// create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
 siner = new SineWave(RED_BASE, 0.5, out.sampleRate());
 siner.portamento(100);
 out.addSignal(siner);
 
 sineg = new SineWave(GREEN_BASE, 0.5, out.sampleRate());
 sineg.portamento(100);
 out.addSignal(sineg);
 
  sineb = new SineWave(BLUE_BASE, 0.5, out.sampleRate());
 sineb.portamento(100);
 out.addSignal(sineb);



}


void setup() {
  img = loadImage("wein.jpg");   
   size(img.width, img.height, OPENGL);
   println(img.width + " " + img.height);
  //frameRate(24);
  noStroke ();
  
 
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 256);
  out = minim.getLineOut(Minim.STEREO);
  fft = new FFT (input.bufferSize (), 
                 input.sampleRate ());
  
  wi = img.width;
  hi = img.height;
  img.loadPixels();
  values = new int[wi][hi];
  colorz = new color[wi][hi];

        for (int y = 0; y < hi; y++) {
        for (int x = 0; x < wi; x++) {
          color pixel = img.get(x, y);
          values[x][y] = int(brightness(pixel));
          //values[x][y] = constrain(values[x][y],10,256);
          colorz[x][y] = pixel;
        }
      }
      
      
      //init_red();
      //init_green();
      //init_blue();
      
      
       playsound();
      
}

void draw() {

  
  countx++;
   float dim = input.mix.level () * width;
    //countx += input.mix.level () * 200;
      if (countx > width-10) {
    countx = 0;
    county += 10;
    send_newline();
  }
  
      fill(colorz[countx][county]);
      rect(countx, county, 10, 10);
      
      r = red(colorz[countx][county]);
      g = green(colorz[countx][county]);
      b = blue(colorz[countx][county]);

      
      /*if (r==0)
        siner.setAmp(0);
      else
        siner.setAmp(0.5);
        
      if (g==0)
        sineg.setAmp(0);
      else
        sineg.setAmp(0.5);
      if (b==0)
        sineb.setAmp(0);
      else
        sineb.setAmp(0.5); */
      
      // send pure colors for calibration
      
      siner.setFreq(RED_BASE+r*4);
      
      sineg.setFreq(GREEN_BASE+g*4);
      
      sineb.setFreq(BLUE_BASE+b*4);
      
      println ("send (R)"+r+" (G)"+g+" (B)"+ b); 
      //sine.setFreq(freq);
      //sleep(100);

  

} 
void stop()
{
  out.close();
  minim.stop();
  
  super.stop();
}
