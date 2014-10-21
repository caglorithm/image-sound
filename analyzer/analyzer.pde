import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
  
Minim minim;
AudioInput input;
AudioOutput out;
FFT fft;

int RED_BASE=243, GREEN_BASE=695, BLUE_BASE=1000;

float maxSpec = 10;


int countx=0;
int county=0;

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


void setup() {
  
    smooth();
  noStroke ();
  
  size(800, 300);
  minim = new Minim (this);
  input = minim.getLineIn (Minim.STEREO, 1024*4);
  fft = new FFT (input.bufferSize (), 
                 input.sampleRate ());
  fft.logAverages(11, 16);

  wi = width;
  hi = height;
  values = new int[wi][hi];
  colorz = new color[wi][hi];

      
}

void draw() {

  background (0);
   
  PFont font;  
  // The font must be located in the sketch's 
  // "data" directory to load successfully 
   
  float g = 0;    // GrÃ¼nwert der FÃ¼llfarbe
  float h = 0;    // HÃ¶he von Rechteck und Linie
  float one = 0;
  int maxfreq = 3000;
  int maxamp = 80;
  int peak = 0;
  float lastone=0;
  
  float[] band = new float[maxfreq];
  //println(fft.specSize());
  
  float specStep; // Breite einer horiz. Linie
  float specScale = (float) width / (fft.specSize () - 1);
   
  // Erzeugen der 'Frequenz-Gruppen' (16 Bereich)
  // mÃ¶gliche Schritte: 2-4-8-16-32-64-128
  float[] group = getGroup (32);
  
   
   
  // Zeichnen des detailierten Frequenzspektrums
  noStroke ();
  //for (int i = 0; i < fft.specSize (); i++) {
    for (int i = 0; i < maxfreq; i++) {
    //g = map (fft.getBand (i), 0, maxSpec, 50, 255);
    //h = map (fft.getBand (i), 0, maxSpec, 2, height);
    //one = map (fft.getBand (i), 0, maxSpec, 0, 1);
    float freq = fft.getFreq(i);
    //freq = log(freq)/log(1.2);
    
    g = map(freq,0,maxamp,100,255);
    h = map(freq,0,maxamp,2,height);
    one = map(freq,0,maxamp,0,1);
    
    fill (0, g, 0);
    rect (i * specScale, height - h, specScale, h);
        
    if (one>0){
          band[i]=one;
          if (one>0.1 && one > lastone){
            peak = i;
            lastone = one;
          }
    }

    // mark peaks      
     if (peak > 1 && lastone == one){
      //stroke(255,0,0,200);
      fill(255,0,0);
      ellipse(i * specScale, height - h, 10, 10);
     }
    
    
    // DRAW THE GRID
    if ((i%100)==0) {
      fill (200);
      rect (i * specScale, 0, specScale*1, height);
    }

  }
  
    // average colors from the band[]
  int bandsize = 256;
  float rb=0, gb=0, bb=0;
  for (int f = RED_BASE; f < RED_BASE+255; f++)
    rb +=band[f];
  for (int f = GREEN_BASE; f < GREEN_BASE+255; f++)
    gb +=band[f];
  for (int f = BLUE_BASE; f < BLUE_BASE+255; f++)
    bb +=band[f];  


  // CREATE COLOR
  fill(rb*40, gb*10, bb*10);
  rect(400,100,30,30);
  
  
   
  // Zeichnen der Gruppen (Linien)
  stroke (255, 255, 0, 200);
  specStep = width / group.length;
  for (int i=0; i < group.length; i++) {
    h = height - map (group[i], 0, maxSpec, 0, height);
    line (i * specStep, h, (i+1) * specStep, h);
      
  }
  
  
  /// ******** TEXT DRAWING *******
  fill (255);  
  font = loadFont("letter20.vlw");
  textFont(font, 14); 
  float ease_peak = 0;
  ease_peak = ease(ease_peak, peak, 0.5);
  text("peak: "+ ease_peak, 4,  50); 
  text("dim: "+ input.mix.level(), 4,  65); 
}

void stop()
{
  minim.stop();
  super.stop();
}


float[] getGroup (int theGroupNum) {
  fft.forward (input.mix);
   
  // Leeres Array fÃ¼r die Gruppen erstellen
  float[] group  = new float[theGroupNum];
  // Das FFT-Spekturm hat eine Stelle mehr 
  // als beim Input definiert. (256->257).
  // Diese wird ignoriert.
  int specLimit  = fft.specSize () - 1;
  // Anzahl der FrequenzbÃ¤nder pro Gruppe
  int groupSize = specLimit / theGroupNum;
   
  // Alle Gruppen mit einem Startwert fÃ¼llen
  for (int i=0; i < group.length; i++) {
    group[i] = 0;
  }
   
  // FÃ¼r jedes FFT-Frequenz-Band
  for (int i=0; i < specLimit; i++) {
    // Maximum?
    if (fft.getBand (i) > maxSpec) {
      //maxSpec = fft.getBand (i);
    }
    // Jedes Band einer Gruppe zuweisen
    int index = (int) Math.floor (i / groupSize);
    group[index] += fft.getBand (i);
  }
   
  // Der Wert jeder Gruppe durch die Anzahl
  // der enthaltenen BÃ¤nder Teilen - >Mittelwert
  for (int i=0; i < group.length; i++) {
    group[i] /= groupSize;
  }
  // Gruppe zurÃ¼ck geben.
  return group;
}


float ease(float value, float target, float easingVal) {
        float d = target - value;
        if (abs(d)>0.001) value+= d*easingVal;
        return value;
}
