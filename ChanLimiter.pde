class ChanLimiter {
  
  int channel, note, velocity, notelow, notehigh, threshold;
  int tval = 0;
  int[] outnote = {0, 0, 0};
  int[] falsenote = {-99, -99, -99};
  
  ChanLimiter(int chan, int low, int high, int thresh) {
    channel = chan;
    notelow = low;
    notehigh = high;
    threshold = thresh;
  }
  
  int[] getBoundedNote(int darkpos, int pixrange, int darkest, int lightest) {
    int gapsize = lightest - darkest;
    tval += gapsize;
    if (tval >= threshold) {
      tval = 0;
      outnote[0] = channel + 144;
      outnote[1] = int(round(map(darkpos, 0, pixrange, notelow, notehigh)));
      outnote[2] = int(round(map(gapsize, 0, 255, 1, 127)));
      return outnote;
    } else {
      return falsenote;
    }
  }
  
}
