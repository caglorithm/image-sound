import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
  
Minim minim;
AudioInput input;
AudioOutput out;
FFT fft;

PFont font;  

float maxSpec = 10;

long counter = 0;
long newline_counter = 0; 

int countx=0;
int county=0;

boolean GOT_RED=false, GOT_GREEN=false, GOT_BLUE=false;
int RED_BASE=243, GREEN_BASE=695, BLUE_BASE=1000;

float rb=0, gb=0, bb=0;
float r, g, b;
SineWave siner, sineg, sineb;

int maxfreq = 3000;
int maxamp = 80;

float[] band = new float[maxfreq];
//println(fft.specSize());

float specStep; // Breite einer horiz. Linie
float specScale;


PImage img; 
int[][] values;
color[][] colorz; 
int wi;
int hi;

void sleep(long ms){
  int a=1;
  for (long i = 0; i < ms; i++) {a=a*a*a*a*a*a;}
}

void playsound()
{

 minim = new Minim(this);
 // get a line out from Minim, default bufferSize is 1024, default sample rate is 44100, bit depth is 16
 out = minim.getLineOut(Minim.STEREO);

// create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
 siner = new SineWave(440, 0.5, out.sampleRate());
 siner.portamento(200);
 out.addSignal(siner);
 
 sineg = new SineWave(440, 0.5, out.sampleRate());
 sineg.portamento(200);
 out.addSignal(sineg);
 
  sineb = new SineWave(440, 0.5, out.sampleRate());
 sineb.portamento(200);
 out.addSignal(sineb);
 //out.addSignal(sine2);


}


void setup() {
  background(0);
  
    smooth();
  noStroke ();
  
  img = loadImage("wein.jpg");   
   
   println("dimensinos: " + img.width + " " + img.height);
  size(img.width, img.height);
  //size(1200,800);
  
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 1024*4);
  fft = new FFT (input.bufferSize (), 
                 input.sampleRate ());
  fft.logAverages(11, 16);
  fft.forward (input.mix);  
  specScale = (float) width / (fft.specSize () - 1);
  
  wi = img.width;
  hi = img.height;
  
  
  // why is this here?
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
      

}

void draw() {
  
  //background (0);
  noStroke ();

  fill(rb*20, gb*30, bb*20);
  rect(width-30,0,30,30);
  
  // peaks
  get_band();
  draw_pixels();
}


 float[] get_band(){
   
  counter++;
   
  float g = 0;    // GrÃ¼nwert der FÃ¼llfarbe
  float h = 0;    // HÃ¶he von Rechteck und Linie
  float one = 0;

  int peak = 0;
  float lastone=0;
  

  // Zeichnen des detailierten Frequenzspektrums
  noStroke ();
    for (int i = 0; i < maxfreq; i++) {
    //g = map (fft.getBand (i), 0, maxSpec, 50, 255);
    //h = map (fft.getBand (i), 0, maxSpec, 2, height);
    //one = map (fft.getBand (i), 0, maxSpec, 0, 1);
    float freq = fft.getFreq(i);
    println(freq);
    //freq = log(freq)/log(1.2);
    
    g = map(freq,0,maxamp,100,255);
    h = map(freq,0,maxamp,2,height);
    one = map(freq,0,maxamp,0,1);
    
    //fill (0, g, 0);
    //rect (i * specScale, height - h, specScale, h);
        
    if (one>0){
          band[i]=one;
          if (one>0.05 && one > lastone){
            peak = i;
            lastone = one;
          }
    }
 }
 
     // average colors from the band[]
  int bandsize = 256;
  rb=0; gb=0; bb=0;
  for (int f = RED_BASE; f < RED_BASE+bandsize; f++)
    rb +=band[f];
  for (int f = GREEN_BASE; f < GREEN_BASE+bandsize; f++)
    gb +=band[f];
  for (int f = BLUE_BASE; f < BLUE_BASE+bandsize; f++)
    bb +=band[f];  
    
      /// ******** TEXT DRAWING *******
/*  fill (255);  
  font = loadFont("letter20.vlw");
  textFont(font);
*/
  
  // new line signal
  if (peak>1990) draw_new_line();  
    
  return band;
 }

void draw_new_line(){
  // if enough time has passed since the last new-line.
  int newline_threshold=500;
    if (millis()-newline_counter>newline_threshold) {
      countx = 0;
      county += 10;
    }
    if (millis()-newline_counter<newline_threshold) {
      countx = 0;
    }
    newline_counter = millis();
}

void draw_pixels() {
  countx++;
    float dim = input.mix.level () * width;
    //countx += input.mix.level () * 200;
      if (countx > width-10) {
        draw_new_line();
  }
  
  if (county > height - 30) {
    countx = 0;
    county = 0; 
  }
  
      fill(rb*20, gb*30, bb*30);
      //ellipse(countx, county, dim/2, dim/2);
      //ellipse(countx, county, dim*2, dim*2);
      //ellipse(countx, (county*dim)%height, dim*2, dim*2);
      //rect(width-countx, (county*dim)%height/3, dim*5, dim*2);
      rect(countx, county, 10, 10);
  
}

void stop()
{
  minim.stop();
  super.stop();
}


