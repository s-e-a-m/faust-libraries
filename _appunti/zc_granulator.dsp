/* This is an alternative design that implements zero-crossing detection rather than windowing to avoid discontinuities among grains. 

The first two arguments of grains_dl_zc must be known at compile time and they are number of voices and lenght of the delay lines in seconds. The remaining inputs are pitch, grain rate, grain position, input signal. 

The position is determined by the amplitude value of the input signal.

The algorithm waits until the output of the granulator is at a ZC to trigger the next grain, so the grain rate is a desired value which may vary depending on the graunlator output. 

The algorithm is described here: https://tmblr.co/Zhtq9x2i76aPG. */

import("stdfaust.lib");

process(x) =    hslider("pitch", 1, -64, 64, .001),
                hslider("rate", 10, 1, 10000, .001),
                hslider("pos", 1, 0, 1000, .001)*x+hslider("pos_offset", 0, 0, 8, .001),
                x*hslider("gain", 1, 0, 64, .001) : grains_dl_zc(1, 8);

// DL-based ZC granulator
grains_dl_zc(n, s) = par(i, n, grain) :> /(n)
with {
      size = s*ma.SR : round_pow2;
      index = ba.period(size);
      grain(pitch, rate, pos, input) = (input,
                                       (   input,
                                               _,
                                            pitch,
                                            (rate : abs),
                                            pos : read_grain) : dl_pol)
                                       ~ _;
      read_grain(input, fb, pitch, rate, pos) = (  trigger,
                                                   index : ba.sAndH),
                                                (  trigger,
                                                   (   input,
                                                       pos,
                                                       fb : zc_index) : ba.sAndH) : - : +(shift) : wrap(0, size)
      with {
       zc_index(input, position, direction) = ba.if((diff(direction) : >=(0)),
                                                    (  input,
                                                       p : zc_index_up),
                                                    (  input,
                                                       p : zc_index_down)) : +(1)
       with {
           p = position*ma.SR : wrap(0, size);
       };
       trigger =   check
                   ~ _
       with {
           check(ready) =  (fb : zc),
                           (line_reset(rate, ready) : >=(1)) : &;
       };
      shift =  (1,
               (   trigger,
                   pitch : ba.sAndH) : -)*( 1,
                                            (trigger,
                                            rate : ba.sAndH) : div)*ma.SR*line_reset(   (trigger,
                                                                                        rate : ba.sAndH), trigger);
      };
      zc_index_up(input, pos) = (  (input : zc),
                                   (diff(input) : >(0)) : &),
                                index : ba.sAndH,
                                pos : dl;
      zc_index_down(input, pos) =  (   (input : zc),
                                       (diff(input) : <(0)) : &),
                                   index : ba.sAndH,
                                   pos : dl;
      dl_pol(in, del) = de.fdelayltv(4, size, del, in);
      dl(in, del) = in : de.delay(size, del);
};

////////////////////////////////// AUXILIARY FUNCTIONS ////////////////////////

// closest power of 2
round_pow2(x) = 2^(ma.log2(x) : rint);

// wrap around a range
wrap(lower, upper, x) = (x-lower)/(upper-lower) : ma.decimal : *(upper-lower) : +(lower);

// line with reset input
line_reset(rate, reset) =  rate ,
                           ma.SR : / : +
                                       ~ *(1-(reset : !=(0)));

// differentiator
diff(x) = x-x';

// zero-crossing detection
zc(x) = x*x' : <(0);

// NAN-safe divider
div(x1, x2) = ba.if(x2 : ==(0), 0, (x1 ,
                                    x2 : /));


