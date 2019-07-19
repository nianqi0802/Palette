

//backgroundcolor
int     BACKGROUND_COLOR           = 0;
//liquid color in line 109

int ends = 0;


int NUM_PARTICLES = 750;


int strokeR = 155;
int strokeG = 40;
int strokeB =10;


float volumn = 0;

int bluepitch = 0;
int redpitch = 0;
int stageone = 1;
int sampleRate= 44100;

float silencebegin;

boolean recordornot = false;

import themidibus.*;
MidiBus myBus;
MidiBus myBus2;
MidiBus myBus3;
MidiBus myBus4;

int track_ini = 1;
int midin = 0;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.geometry.DwCube;
import com.thomasdiewald.pixelflow.java.geometry.DwHalfEdge;
import com.thomasdiewald.pixelflow.java.imageprocessing.filter.DwFilter;

import peasy.PeasyCam;
import processing.core.*;
import processing.opengl.PGraphics3D;

import java.util.ArrayList;

import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.fluid.DwFluidStreamLines2D;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioInput in;
FFT fft;

String note;// name of the note
int n;//int value midi note
color c;//color
float hertz;//frequency in hertz
float midi;//float midi note
int noteNumber;//variable for the midi note
float linetoshow;
int linex =0;



float [] max= new float [sampleRate/2];//array that contains the half of the sampleRate size, because FFT only reads the half of the sampleRate frequency. This array will be filled with amplitude values.
float maximum;//the maximum amplitude of the max array
float frequency;//the frequency in hertz


int channel = 1;
int pitch = 40;
int soundVelocity = 127;

int innerSize=30;
int XPos = mouseX;
float eRadius;
boolean toggle = false;

PFont myFont;
String[] words = {"Hi", "你好", "你好", "Olá", ""};
//int index = int(random(words.length));  // Same as int(random(4))
// Using this variable to decide whether to draw all the stuff
boolean debug = true;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
ArrayList<Vehicle> vehicles;

float R = 1.0f;
float G = 0.0f;
float B = 0.0f;
int colorpanel = 0;

PImage img;

PeasyCam cam;

float radius = 0;
boolean DISPLAY_STROKE = false;

DwPixelFlow context2;

PGraphics3D pg_dst;
PGraphics3D pg_luminance;

DwCube cube;
DwHalfEdge.Mesh mesh;
PShape shp_mesh;

float[] plane_rot = new float[3];

enum RENDER_PASS {
  COLOR, 
    LUMINANCE
}

// Windtunnel, combining most of the other examples.

private class MyFluidData implements DwFluid2D.FluidData {

  @Override
    // this is called during the fluid-simulation update step.
    public void update(DwFluid2D fluid) {

    float px, py, vx, vy, radius, vscale;

    //boolean mouse_input = !cp5.isMouseOver() && mousePressed && !obstacle_painter.isDrawing();
    //here control the fluid coming out
    if (bluepitch >0 || redpitch >0) {

      vscale = 15;
      px     = width/2;
      py     = height/2+200;
      vx     =random(-300, 300);
      vy     = random(-300, 300);

      if (colorpanel == 3) {
        R = random(0.3);
        G = random(0.1);
        B = random(0.9, 1);
      }

      if (colorpanel == 1) {
        R = random(0.8, 1);
        G = random(1);
        B = random(0.2);
      }
      //if (mouseButton == LEFT) {
      radius = 40;
      fluid.addVelocity(px, py, radius, vx, vy);
      //fluid.addDensity (px, py, radius, 1.0f, 0.0f, 0.40f, 1f, 1);
      fluid.addDensity (px, py, radius, R, G, B, 1f, 1);
      //}
    }

    // use the text as input for density
    float mix_density  = fluid.simulation_step == 0 ? 1.0f : 0.05f;
    float mix_velocity = fluid.simulation_step == 0 ? 1.0f : 0.5f;

    addDensityTexture (fluid, pg_density, mix_density);
    addVelocityTexture(fluid, pg_velocity, mix_velocity);
  }


  // custom shader, to add velocity from a texture (PGraphics2D) to the fluid.
  public void addVelocityTexture(DwFluid2D fluid, PGraphics2D pg, float mix) {
    int[] pg_tex_handle = new int[1]; 
    //      pg_tex_handle[0] = pg.getTexture().glName
    context.begin();
    context.getGLTextureHandle(pg, pg_tex_handle);
    context.beginDraw(fluid.tex_velocity.dst);
    DwGLSLProgram shader = context.createShader("data/addVelocity.frag");
    shader.begin();
    shader.uniform2f     ("wh", fluid.fluid_w, fluid.fluid_h);                                                                   
    shader.uniform1i     ("blend_mode", 6);   
    shader.uniform1f     ("mix_value", mix);     
    shader.uniform1f     ("multiplier", 1);     
    shader.uniformTexture("tex_ext", pg_tex_handle[0]);
    shader.uniformTexture("tex_src", fluid.tex_velocity.src);
    shader.drawFullScreenQuad();
    shader.end();
    context.endDraw();
    context.end();
    fluid.tex_velocity.swap();
  }

  // custom shader, to add density from a texture (PGraphics2D) to the fluid.
  public void addDensityTexture(DwFluid2D fluid, PGraphics2D pg, float mix) {
    int[] pg_tex_handle = new int[1]; 
    //      pg_tex_handle[0] = pg.getTexture().glName
    context.begin();
    context.getGLTextureHandle(pg, pg_tex_handle);
    context.beginDraw(fluid.tex_density.dst);
    DwGLSLProgram shader = context.createShader("data/addDensity.frag");
    shader.begin();
    shader.uniform2f     ("wh", fluid.fluid_w, fluid.fluid_h);                                                                   
    shader.uniform1i     ("blend_mode", 2);   
    shader.uniform1f     ("mix_value", mix);     
    shader.uniform1f     ("multiplier", 1);     
    shader.uniformTexture("tex_ext", pg_tex_handle[0]);
    shader.uniformTexture("tex_src", fluid.tex_density.src);
    shader.drawFullScreenQuad();
    shader.end();
    context.endDraw();
    context.end();
    fluid.tex_density.swap();
  }
}


int viewport_w = 1920;
int viewport_h = 1080;
int viewport_x = 0;
int viewport_y = 0;

//int gui_w = 200;
//int gui_x = viewport_w-gui_w;
//int gui_y = 0;

int fluidgrid_scale = 1;

PFont font;

DwPixelFlow context;
DwFluid2D fluid;
DwFluidStreamLines2D streamlines;
MyFluidData cb_fluid_data;

PGraphics2D pg_fluid;             // render target
PGraphics2D pg_density;           // texture-buffer, for adding fluid data
PGraphics2D pg_velocity;          // texture-buffer, for adding fluid data
PGraphics2D pg_obstacles;         // texture-buffer, for adding fluid data
PGraphics2D pg_obstacles_drawing; // texture-buffer, for adding fluid data

ObstaclePainter obstacle_painter;

MorphShape morph; // animated morph shape, used as dynamic obstacle

// some state variables for the GUI/display

boolean UPDATE_FLUID               = true;
boolean DISPLAY_FLUID_TEXTURES     = true;
boolean DISPLAY_FLUID_VECTORS      = false;
int     DISPLAY_fluid_texture_mode = 0;
boolean DISPLAY_STREAMLINES        = false;
int     STREAMLINE_DENSITY         = 10;


int silence_start = 0;
int silence_end = 0;
int silence_duration = 4000;
float volumn_before = 0;

float volumn_wall =300;
int trackcount = 1;


public void settings() {
  fullScreen(P3D);
  size(viewport_w, viewport_h, P2D);
  //viewport_w = width;
  //viewport_h = height;
  smooth(4);
}


void setup() {

  cam = new PeasyCam(this, 600);

  createMesh(5);

  context2 = new DwPixelFlow(this);
  context2.print();
  context2.printGL();

  pg_dst       = (PGraphics3D) createGraphics(width, height-350, P3D);
  pg_luminance = (PGraphics3D) createGraphics(width, height-350, P3D);

  randomSeed(1);
  //frameRate(60);


  flowfield = new FlowField(20);
  vehicles = new ArrayList<Vehicle>();
  // Make a whole bunch of vehicles with random maxspeed and maxforce values
  for (int i = 0; i < 320; i++) {
    vehicles.add(new Vehicle(new PVector(random(width), random(height)), random(3, 5), random(0.1, 0.5), words[int(random(words.length))]));
    println(words[int(random(words.length))]);
  }

  //fullScreen();
  myBus = new MidiBus(this, 0, 1);
  myBus3 = new MidiBus(this, 2, 3);
  myBus2 = new MidiBus(this, 1, 2);
  myBus4 = new MidiBus(this, 3, 4);

  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.MONO, 4096, sampleRate);
  fft = new FFT(in.left.size(), sampleRate);

  surface.setLocation(viewport_x, viewport_y);

  // main library context
  context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  streamlines = new DwFluidStreamLines2D(context);

  // fluid simulation
  fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);

  // some fluid params
  fluid.param.dissipation_density     = 0.99999f;
  fluid.param.dissipation_velocity    = 0.99999f;
  fluid.param.dissipation_temperature = 0.70f;
  fluid.param.vorticity               = 0.00f;

  // interface for adding data to the fluid simulation
  cb_fluid_data = new MyFluidData();
  fluid.addCallback_FluiData(cb_fluid_data);

  // processing font
  font = createFont("../../data/SourceCodePro-Regular.ttf", 48);

  // fluid render target
  pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_fluid.smooth(4);

  // main obstacle texture
  pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_obstacles.noSmooth();
  pg_obstacles.smooth(4);
  pg_obstacles.beginDraw();
  pg_obstacles.clear();
  pg_obstacles.endDraw();


  // second obstacle texture, used for interactive mouse-driven painting
  pg_obstacles_drawing = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_obstacles_drawing.noSmooth();
  pg_obstacles_drawing.smooth(4);
  pg_obstacles_drawing.beginDraw();
  pg_obstacles_drawing.clear();
  pg_obstacles_drawing.blendMode(REPLACE);

  pg_obstacles_drawing.strokeWeight(1);
  if (keyPressed == false) {
    pg_obstacles_drawing.stroke(0);
  } else if (keyPressed == true && key == 'o') {
    pg_obstacles_drawing.noStroke();
  }
  pg_obstacles_drawing.noFill();
  pg_obstacles_drawing.ellipse(width / 2, height / 2, 800, 800);
  //}

  //pg_obstacles_drawing.translate(200, height/2+50);
  pg_obstacles_drawing.rotate(0.3f);
  pg_obstacles_drawing.fill(0, 0, 0);

  pg_obstacles_drawing.endDraw();

  // init the obstacle painter, for mouse interaction
  obstacle_painter = new ObstaclePainter(pg_obstacles_drawing);

  // image/buffer that will be used as density input
  pg_density = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_density.noSmooth();
  pg_density.beginDraw();
  pg_density.clear();
  pg_density.endDraw();

  // image/buffer that will be used as velocity input
  pg_velocity = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_velocity.noSmooth();
  pg_velocity.beginDraw();
  pg_velocity.clear();
  pg_velocity.endDraw();

  // animated morph shape
  morph = new MorphShape(120);

  // createGUI();

  frameRate(60);
}



public void drawObstacles() {

  pg_obstacles.beginDraw();
  pg_obstacles.blendMode(BLEND);
  pg_obstacles.clear();

  // add morph-shape as obstacles
  pg_obstacles.pushMatrix();
  {
    pg_obstacles.noFill();
    pg_obstacles.noStroke();
    //pg_obstacles.strokeWeight(10);
    //pg_obstacles.stroke(64);

    pg_obstacles.translate(width/2, height/2);
    //      morph.drawAnimated(pg_obstacles, 0.975f);
    morph.draw(pg_obstacles, mouseY/(float)height);
  }
  pg_obstacles.popMatrix();
  // add painted obstacles on top of it
  if (keyPressed == false) {
    pg_obstacles.image(pg_obstacles_drawing, 0, 0);
  }
  pg_obstacles.endDraw();
}

public void createMesh(int subdivisions) {
  cube = new DwCube(subdivisions);
  mesh = new DwHalfEdge.Mesh(cube);
  shp_mesh = createShapeMesh();
}

public PShape createShapeMesh() {
  float[][] verts = mesh.ifs.getVerts();
  int  [][] faces = mesh.ifs.getFaces();

  PShape shp = createShape();
  shp.beginShape(QUADS);
  shp.noStroke();
  shp.fill(0);
  for (int i = 0; i < faces.length; i++) {
    int[] face = faces[i];
    // face normal is also the face center
    float[] face_center = {0, 0, 0};
    for (int j = 0; j < 4; j++) {
      float[] vi = verts[face[j]];
      face_center[0] += vi[0] * 0.25;
      face_center[1] += vi[1] * 0.25;
      face_center[2] += vi[2] * 0.25;
    }

    for (int j = 0; j < 4; j++) {
      float[] vi = verts[face[j]];
      float[] vn = face_center;
      shp.normal(vn[0], vn[1], vn[2]);
      shp.vertex(vi[0], vi[1], vi[2]);
    }
  }
  shp.endShape();
  return shp;
}

public void draw() {
  //if(stageone == 0){
  //  background(0);
  //  }
  flowfield.update();

  findNote(); //find note function
  volumn = in.mix.level()*1000;
  //textSize(50); //size of the text
  //text("volumn = "+ volumn, 50, 300);

  if (volumn < volumn_wall && volumn_before>= volumn_wall) {
    silence_start = millis();
  }

  if (volumn >volumn_wall && volumn_before<=volumn_wall) { 
    silence_end = millis();
    getduration();
  }




  //println(volumn);
  if (volumn>volumn_wall) {
    //text (frequency-6+" hz", 50, 80);//display the frequency in hertz
    pushStyle();
    fill(c);
    // text ("note "+note, 50, 150);//display the note name
    //text (midi, 50, 200);//display the midi
    popStyle();

    //myBus.sendNoteOn(channel, int(midi), 20);
    //println("sendmidi"+int(midi));
    //drawfluid();

    // if(!recordornot){
    // myBus2.sendNoteOn(2, 35, 45);  // start recording
    // recordornot =!recordornot;
    // }
    ////different tracks 
    if (silence_duration>2000) {
      println("silence_duration:"+silence_duration);


      //myBus2.sendNoteOn(2, 95, 45);  // playback of sound

      if (trackcount % 3 ==1) {

        if (track_ini != 1) { 
          //myBus2.sendNoteOn(2, 60, 45);
          //myBus2.sendNoteOn(2, 55, 45);  // user three recording off
        }
        //myBus2.sendNoteOn(2, 30, 45); 
        //myBus2.sendNoteOn(2, 25, 45);  // user one record
        silence_duration = 0;
        println("trackone");
        track_ini = 0;
        //colorpanel = 1;
      } 

      if (trackcount % 3 ==2) {
        //myBus2.sendNoteOn(2, 30, 45); 
        //myBus2.sendNoteOn(2, 25, 45);  // user one record off
        //myBus2.sendNoteOn(2, 40, 45); 
        //myBus2.sendNoteOn(2, 45, 45);  // user two recording
        silence_duration = 0;
        println("tracktwo");


        //colorpanel = 2;
      } 
      if (trackcount % 3 == 0) {
        //myBus2.sendNoteOn(2, 40, 45); 
        //myBus2.sendNoteOn(2, 45, 45);  // user two recording off
        //myBus2.sendNoteOn(2, 60, 45); 
        //myBus2.sendNoteOn(2, 55, 45);  // user three recording
        silence_duration = 0;
        println("trackthree");

        //colorpanel = 3;
      } 
      trackcount++;
    }
  }


  volumn_before = volumn;

  if (UPDATE_FLUID) {


    drawObstacles();


    fluid.addObstacles(pg_obstacles);
    fluid.update();
  }


  pg_fluid.beginDraw();


  pg_fluid.background(BACKGROUND_COLOR);


  if (midin>0) {
    radius += 0.4;
  }   
  // main color pass, rendered as usual
  pg_dst.beginDraw();
  displayScene(pg_dst, RENDER_PASS.COLOR);
  pg_dst.endDraw();

  // additional pass where only bloom-relevant stuff is rendered
  pg_luminance.beginDraw();


  if (midin == 70 || midin ==71) {
    displayScene(pg_luminance, RENDER_PASS.LUMINANCE);
  }
  pg_luminance.endDraw();

  // apply bloom
  DwFilter filter = DwFilter.get(context);
  filter.bloom.param.blur_radius = 2;
  filter.bloom.param.mult        = 5;    //map(mouseX, 0, width, 0, 5);
  filter.bloom.param.radius      = 0.5f; //map(mouseY, 0, height, 0, 1);
  filter.bloom.apply(pg_luminance, null, pg_dst);


  // display result
  cam.beginHUD();
  image(pg_dst, 0, 0);
  cam.endHUD();

  // info
  int num_faces = mesh.ifs.getFacesCount();
  int num_verts = mesh.ifs.getVertsCount();
  int num_edges = mesh.edges.length;
  //String txt_fps = String.format(getClass().getName()+ "   [Verts %d]  [Faces %d]  [HalfEdges %d]  [fps %6.2f]", num_verts, num_faces, num_edges, frameRate);
  //surface.setTitle(txt_fps);

  pg_fluid.endDraw();


  if (DISPLAY_FLUID_TEXTURES) {
    fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
  }

  if (DISPLAY_FLUID_VECTORS) {
    fluid.renderFluidVectors(pg_fluid, 10);
  }

  if (DISPLAY_STREAMLINES) {
    streamlines.render(pg_fluid, fluid, STREAMLINE_DENSITY);
  }



  // display
  image(pg_fluid, 0, 0);
  image(pg_obstacles, 0, 0);

  myFont = createFont("hanzi", 5);
  textFont(myFont);

  if (colorpanel >0) {
    for (Vehicle v : vehicles) {
      v.follow(flowfield);
      v.run();
    }
  }
  // draw the brush, when obstacles get removed

  obstacle_painter.displayBrush(this.g);

  // info
  String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
  surface.setTitle(txt_fps);

  //noStroke();
  //fill(100,0,200);
  //if (physics.particles.size() < NUM_PARTICLES) {
  //  addParticle();
  //}
  //physics.update();
  //for (VerletParticle2D p : physics.particles) {
  //  ellipse(p.x, p.y, 5, 5);
  //}

  img = loadImage("cover.png");
  //image(img, 0, 0);
  textSize(10);
  //text(colorpanel, 30, height - 100);

  if (keyPressed == true && key == 'e') {
    ends=1;
  }
  
  if(ends == 1){
  background(0);
  }
  
  
  if (keyPressed == true && key == 's') {
    myBus2.sendNoteOn(4, 55, 45);
  }
}


public class MorphShape {

  ArrayList<float[]> shape1 = new ArrayList<float[]>();
  ArrayList<float[]> shape2 = new ArrayList<float[]>();

  public MorphShape(float size) {
    initAnimator(1, 1);
  }

  float O = 2f;

  public void initAnimator(float morph_mix, int morph_state) {
    if ( morph_mix < 0 ) morph_mix = 0;
    if ( morph_mix > 1 ) morph_mix = 1;
    morph_state &= 1;

    this.morph_mix = morph_mix;
    this.morph_state = morph_state;
  }

  float morph_mix = 1f;
  int   morph_state = 1;

  public void drawAnimated(PGraphics2D pg, float ease) {
    morph_mix *= ease;
    if (morph_mix < 0.0001f) {
      morph_mix = 1f;
      morph_state ^= 1;
    } 

    this.draw(pg, morph_state == 0 ? morph_mix : 1-morph_mix);
  }


  public void draw(PGraphics2D pg, float mix) {
    pg.beginShape();
    for (int i = 0; i < shape1.size(); i++) {
      float[] v1 = shape1.get(i);
      float[] v2 = shape2.get(i);
      float vx = v1[0] * (1.0f - mix) + v2[0] * mix;
      float vy = v1[1] * (1.0f - mix) + v2[1] * mix;
      pg.vertex(vx, vy);
    }
    pg.endShape();
  }
}


public class ObstaclePainter {
  public int draw_mode = 0;
  PGraphics pg;

  float size_paint = 15;
  float size_clear = size_paint * 2.5f;

  float paint_x, paint_y;
  float clear_x, clear_y;

  int shading = 64;

  public ObstaclePainter(PGraphics pg) {
    this.pg = pg;
  }

  public void beginDraw(int mode) {
    paint_x = mouseX;
    paint_y = mouseY;
    this.draw_mode = mode;
    if (mode == 1) {
      pg.beginDraw();
      pg.blendMode(REPLACE);
      pg.noStroke();
      pg.fill(shading);
      pg.ellipse(mouseX, mouseY, size_paint, size_paint);
      pg.endDraw();
    }
    if (mode == 2) {
      clear(mouseX, mouseY);
    }
  }

  public boolean isDrawing() {
    return draw_mode != 0;
  }

  public void draw() {
    paint_x = mouseX;
    paint_y = mouseY;
    if (draw_mode == 1) {
      pg.beginDraw();
      pg.blendMode(REPLACE);
      pg.strokeWeight(size_paint);
      pg.stroke(shading);
      pg.line(mouseX, mouseY, pmouseX, pmouseY);
      pg.endDraw();
    }
    if (draw_mode == 2) {
      clear(mouseX, mouseY);
    }
  }

  public void endDraw() {
    this.draw_mode = 0;
  }

  public void clear(float x, float y) {
    clear_x = x;
    clear_y = y;
    pg.beginDraw();
    pg.blendMode(REPLACE);
    pg.noStroke();
    pg.fill(0, 0);
    pg.ellipse(x, y, size_clear, size_clear);
    pg.endDraw();
  }

  public void displayBrush(PGraphics dst) {
    if (draw_mode == 1) {
      dst.strokeWeight(1);
      dst.stroke(0);
      dst.fill(200, 50);
      dst.ellipse(paint_x, paint_y, size_paint, size_paint);
    }
    if (draw_mode == 2) {
      dst.strokeWeight(1);
      dst.stroke(200);
      dst.fill(200, 100);
      dst.ellipse(clear_x, clear_y, size_clear, size_clear);
    }
  }
}



public void fluid_resizeUp() {
  fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
}
public void fluid_resizeDown() {
  fluid.resize(width, height, ++fluidgrid_scale);
}
public void fluid_reset() {
  fluid.reset();
}
public void fluid_togglePause() {
  UPDATE_FLUID = !UPDATE_FLUID;
}
public void fluid_displayMode(int val) {
  DISPLAY_fluid_texture_mode = val;
  DISPLAY_FLUID_TEXTURES = DISPLAY_fluid_texture_mode != -1;
}
public void fluid_displayVelocityVectors(int val) {
  DISPLAY_FLUID_VECTORS = val != -1;
}

public void streamlines_displayStreamlines(int val) {
  DISPLAY_STREAMLINES = val != -1;
}

void findNote() {
  if (volumn>10) {
    fft.forward(in.left);
    for (int f=0; f<sampleRate/2; f++) { //analyses the amplitude of each frequency analysed, between 0 and 22050 hertz
      max[f]=fft.getFreq(float(f)); //each index is correspondent to a frequency and contains the amplitude value
    }
    maximum=max(max);//get the maximum value of the max array in order to find the peak of volume

    for (int i=0; i<max.length; i++) {// read each frequency in order to compare with the peak of volume
      if (max[i] == maximum) {//if the value is equal to the amplitude of the peak, get the index of the array, which corresponds to the frequency
        frequency= i;
      }
    }


    midi= 69+12*(log((frequency-6)/440));// formula that transform frequency to midi numbers
    n= int (midi);//cast to int
  }
}

void stop() {
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();

  super.stop();
}

void getduration() {
  int pure_duration = silence_end - silence_start; 
  if (pure_duration <0) {
    silence_duration = -pure_duration;
  } else {
    silence_duration = pure_duration;
  }
}




public void displayScene(PGraphics3D canvas, RENDER_PASS pass) {
  cam.getState().apply(canvas);

  if (stageone == 1) {
    canvas.background(0);
  }
  canvas.noLights();

  // for the luminance pass we don't want to fill the colorbuffer, just 
  // the depth-test matters.
  if (RENDER_PASS.LUMINANCE == pass) {
    canvas.pgl.colorMask(false, false, false, false);
  }

  canvas.pushMatrix();
  canvas.scale(radius * 0.99f); // smaller, tot ackel z-fighting
  canvas.shape(shp_mesh);
  canvas.popMatrix();

  if (RENDER_PASS.LUMINANCE == pass) {
    canvas.pgl.colorMask(true, true, true, true);
  }

  canvas.scale(radius);

  float rot_speed = 1f;
  plane_rot[0] += rot_speed * 0.010f;
  plane_rot[1] += rot_speed * 0.001f;
  plane_rot[2] += rot_speed * 0.005f;

  float rx = sin(plane_rot[0]) * PI;
  float ry = cos(plane_rot[1]) * PI;
  float rz = sin(plane_rot[2]) * PI;

  PMatrix3D mat_rot_plane_1 = new PMatrix3D();
  mat_rot_plane_1.rotateX(rx);
  mat_rot_plane_1.rotateY(ry);
  mat_rot_plane_1.rotateZ(rz);

  PMatrix3D mat_rot_plane_2 = new PMatrix3D();
  mat_rot_plane_2.rotateX(rz * 0.5f);
  mat_rot_plane_2.rotateY(rx * 0.2f);
  mat_rot_plane_2.rotateZ(ry * 0.2f);

  float[] plane1 = {mat_rot_plane_1.m02, mat_rot_plane_1.m12, mat_rot_plane_1.m22, 0};
  float[] plane2 = {mat_rot_plane_2.m02, mat_rot_plane_2.m12, mat_rot_plane_2.m22, 0};

  int  [][] faces = mesh.ifs.getFaces();
  float[][] verts = mesh.ifs.getVerts();

  float face_offset = 0.6f;

  //canvas.beginShape(QUADS);
  //canvas.noStroke();
  //for(int i = 0; i < faces.length; i++){
  //  int[] face = faces[i];

  //  // face normal is also the face center
  //  float[] face_center = {0,0,0};
  //  for(int j = 0; j < 4; j++){
  //    float[] vi = verts[face[j]];
  //    face_center[0] += vi[0] * 0.25;
  //    face_center[1] += vi[1] * 0.25;
  //    face_center[2] += vi[2] * 0.25;
  //  }

  //  // normal distances of face-center to planes
  //  float dist1 = abs(dot(face_center, plane1));
  //  float dist2 = abs(dot(face_center, plane2));

  //  dist1 = (float) Math.pow(dist1, 0.1f) * 1.0f; dist1 = (1 - dist1) * 255;
  //  dist2 = (float) Math.pow(dist2, 0.1f) * 1.0f; dist2 = (1 - dist2) * 255;

  //  float rgb_r = dist1;
  //  float rgb_g = max(dist1, dist2) * 0.5f;
  //  float rgb_b = dist2;
  //  float rgb_a = 0;

  //  // generated faces with normal-distance-shading
  //  canvas.fill(rgb_r, rgb_g, rgb_b, rgb_a); 
  //  for(int j = 0; j < 4; j++){
  //    float[] vi = verts[face[j]];

  //    float dx = vi[0] - face_center[0];
  //    float dy = vi[1] - face_center[1];
  //    float dz = vi[2] - face_center[2];

  //    float vx = face_center[0] + dx * face_offset;
  //    float vy = face_center[1] + dy * face_offset;
  //    float vz = face_center[2] + dz * face_offset;
  //    float[] vn = face_center;
  //    canvas.normal(vn[0], vn[1], vn[2]);
  //    canvas.vertex(vx, vy, vz);
  //  }
  //}
  //canvas.endShape();


  // draw planes as circles
  canvas.noFill();
  canvas.strokeWeight(4/radius);

  canvas.pushMatrix();
  canvas.applyMatrix(mat_rot_plane_1);
  canvas.stroke(155, 40, 10);
  if (stageone == 0) {
    canvas.stroke(strokeR, strokeG, strokeB);
    strokeR--;
    strokeG--;
    strokeB--;
  }
  //canvas.fill(155,40,0);
  canvas.ellipse(0, 0, 3f, 3f);
  canvas.popMatrix();


  canvas.pushMatrix();
  canvas.applyMatrix(mat_rot_plane_2);
  canvas.stroke(10, 0, 155);

  // canvas.fill(10,0,255);
  canvas.ellipse(0, 0, 3f, 3f);
  canvas.popMatrix();
}



float dot(float[] va, float[] vb) {
  return va[0] * vb[0] + va[1] * vb[1] + va[2] * vb[2];
}

void noteOn(int channel, int pitch, int velocity) {
  println();
  println("Note On:" + " Channel: "+channel + " Pitch: "+pitch + " Velocity: "+velocity);
  println("--------");
  if (channel == 0) {
    bluepitch = pitch;
    colorpanel = 3;
    stageone =0;
  } else if (channel == 1) {
    redpitch = pitch;
    colorpanel = 1;
  } else if (channel == 2) {
    midin = pitch;
  }
}


void noteOff(int channel, int pitch, int velocity) {
  bluepitch = 0;
  redpitch = 0;
}
