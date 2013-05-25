
final String infile = "topo-rotated.png"; // Source image filename.
final String outfile = "test.lua"; // Output PhrasesPd Lua Table filename.
final int xchunks = 8; // Image X chunks. Corresponds to Monome X buttons.
final int ychunks = 8; // Image Y chunks. Corresponds to Monome Y buttons.
final int pixheight = 187; // Filter window height (pixels). Corresponds to number of semitones.
final int pathlen = 32; // Filter path length (pixels). Corresponds to number of phrase ticks.

ChanLimiter instruments[] = {
  new ChanLimiter(7, 36, 64, 150), // chan 7: Meeblip
  new ChanLimiter(10, 36, 96, 300), // chan 10: mGB Pulse1
  new ChanLimiter(11, 36, 96, 300), // chan 11: mGB Pulse2
  new ChanLimiter(12, 36, 96, 300), // chan 12: mGB Wav
  new ChanLimiter(13, 36, 96, 500), // chan 13: mGB Noise
  new ChanLimiter(6, 0, 15, 500), // chan 6: Modded Alesis HR-16
  new ChanLimiter(4, 0, 11, 500), // chan 4: Alesis SR-16
  new ChanLimiter(14, 36, 96, 100) // chan 14: mGB Poly
};

color[] pixarea = new color[pixheight];
int[] pixvals = new int[pixheight];

ArrayList phrases = new ArrayList();
//int[][][] phrase = new int[xchunks * ychunks][0][3];
int[] blanknote = {-1, -1, -1};

PImage img;

PrintWriter output;

void setup() {
  img = loadImage(infile);
  output = createWriter(outfile);
  size(img.width, img.height);
}

void draw() {
  
  img.loadPixels();
  set(0, 0, img);
  loadPixels();
  
  for (int x = 0; x < xchunks; x++) { // Traverse chunk columns
    
    for (int y = 0; y < ychunks; y++) { // Traverse chunk rows
    
      int pt = (xchunks * y) + x;
      
      int[] note = {0, 0, 0};
      int[] prevnote = {-99, -99, -99};
      
      ArrayList seq = new ArrayList();
      
      // Traverse pixel columns, which correspond to sequence ticks
      for (int filterx = 0; filterx < pathlen; filterx++) {
        
        int darkpos = 0;
        int darkest = 256;
        int lightest = -1;
        
        // Traverse pixels, which correspond to potential semitones, and grab the relevant values
        for (int filtery = 0; filtery < pixheight; filtery++) {
          int locval = (img.width * ((y * pixheight) + ((pixheight - 1) - filtery))) + (x * pathlen) + filterx;
          pixarea[filtery] = img.pixels[locval];
          pixvals[filtery] = int(round(brightness(pixarea[filtery])));
          // Discern darkest pixel position, and darkest/lightest values
          if (pixvals[filtery] <= darkest) {
            darkest = pixvals[filtery];
            darkpos = filtery;
          }
          if (pixvals[filtery] > lightest) {
            lightest = pixvals[filtery];
          }
        }
        
        note = instruments[x].getBoundedNote(darkpos, pixheight, darkest, lightest);
        
        if (note[0] != -99) {
          if (prevnote[0] != -99) {
            int[] tempoff = new int[3];
            arrayCopy(prevnote, tempoff);
            seq.add(tempoff);
          }
          int[] tempon = new int[3];
          arrayCopy(note, tempon);
          seq.add(tempon);
          arrayCopy(note, prevnote);
          prevnote[0] -= 16;
        }

        seq.add(blanknote);
        
      }
      
      // Insert a note-off at the phrasedata's beginning that matches the note-on at its end
      int notefind = -99;
      for (int npoint = 0; npoint < seq.size(); npoint++) {
        int[] nvals = (int[]) seq.get(npoint);
        if (notefind == -99) {
          if (nvals[0] != -1) {
            notefind = npoint;
          }
        }
      }
      if (notefind != -99) {
        seq.add(notefind, prevnote);
      }
      
      phrases.add(seq);
      
    }
    
  }
  
  output.println("return");
  output.println("");
  output.println("{");
  output.println("");
  
    output.println("\t[\"bpm\"] = 120,");
    output.println("\t[\"tpb\"] = 4,");
    output.println("\t[\"gate\"] = 16,");
    output.println("");
    
    output.println("\t[\"adc\"] = {");
      output.println("");
      output.println("\t\t[1] = {");
        output.println("\t\t\t[\"channel\"] = 0,");
        output.println("\t\t\t[\"target\"] = 3,");
        output.println("\t\t\t[\"style\"] = \"absolute\",");
        output.println("\t\t\t[\"magnitude\"] = 127,");
        output.println("\t\t\t[\"val\"] = 0,");
      output.println("\t\t},");
      output.println("");
      output.println("\t\t[2] = {");
        output.println("\t\t\t[\"channel\"] = 1,");
        output.println("\t\t\t[\"target\"] = 3,");
        output.println("\t\t\t[\"style\"] = \"absolute\",");
        output.println("\t\t\t[\"magnitude\"] = 127,");
        output.println("\t\t\t[\"val\"] = 0,");
      output.println("\t\t},");
      output.println("");
      output.println("\t\t[3] = {");
        output.println("\t\t\t[\"channel\"] = 2,");
        output.println("\t\t\t[\"target\"] = 3,");
        output.println("\t\t\t[\"style\"] = \"absolute\",");
        output.println("\t\t\t[\"magnitude\"] = 127,");
        output.println("\t\t\t[\"val\"] = 0,");
      output.println("\t\t},");
      output.println("");
      output.println("\t\t[4] = {");
        output.println("\t\t\t[\"channel\"] = 3,");
        output.println("\t\t\t[\"target\"] = 3,");
        output.println("\t\t\t[\"style\"] = \"absolute\",");
        output.println("\t\t\t[\"magnitude\"] = 127,");
        output.println("\t\t\t[\"val\"] = 0,");
      output.println("\t\t},");
      output.println("");
    output.println("\t},");
    output.println("");
    
    output.println("\t[\"phrase\"] = {");
    output.println("");
    
      // Traverse phrase data, sending it to the output buffer as you go.
      for (int pnum = 0; pnum < phrases.size(); pnum++) {
        
        ArrayList outseq = (ArrayList) phrases.get(pnum);
        
        output.println("\t\t[" + str(pnum + 1) + "] = {");
          output.println("\t\t\t[\"transfer\"] = {0, 0, 0, 0, 1, 0, 0, 0, 0, 1},");
          output.println("\t\t\t[\"notes\"] = {");
          // Send out note data in the proper format
          for (int pseq = 0; pseq < outseq.size(); pseq++) {
            int[] cval = (int[]) outseq.get(pseq);
            if (cval[0] == -1) {
              output.println("\t\t\t\t{-1},");
            } else {
              output.println("\t\t\t\t{" + str(cval[0]) + ", " + str(cval[1]) + ", " + str(cval[2]) + "},");
            }
          }
          output.println("\t\t\t}");
        output.println("\t\t},");
        output.println("");
      }

    output.println("\t}");
    
  output.println("}");
  
  output.flush();
  output.close();
  
  exit();
  
}
