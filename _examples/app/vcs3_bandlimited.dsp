declare name "EMS VCS3 Eploration";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "EMS VCS3 Eploration";

import("stdfaust.lib");
//import("../../seam.lib");

osc1_g(x) = hgroup("[001]OSCILLATOR 1", x);
freq  = osc1_g(vslider("[001]FREQUENCY[style:knob]", 100,1,10000,0.01) : si.smoo);
shape = osc1_g(vslider("[002]SHAPE[style:knob]", 5,0,10,0.1)/10 : si.smoo);
samp = osc1_g(vslider("[003]SINE[style:knob]",0,0,10,0.001)/10:si.smoo);
pamp = osc1_g(vslider("[004]SAW[style:knob]",0,0,10,00.1)/10:si.smoo);

MAX_SAW_ORDER = 4; MAX_SAW_ORDER_NEXTPOW2 = 8;
vcs3osc1(N,f,s,sl,pl) = (shaped(f,s,sl) : poly(Nc) : D(Nc-1) : gate(Nc-1)), saw(f,pl)
  with{
    phasor(f) = os.lf_sawpos(f);
    sine(f,s) = sin(phasor(f)*2*ma.PI) : *(0.5*sin(s*(ma.PI)));
    wsine(f,s) = sin(phasor(f)*(-1)*ma.PI) : +(0.637) : *(cos(s*(ma.PI)));
    shaped(f,s,sl) = (sine(f,s)+wsine(f,s))*sl;
    saw(f,pl) = (phasor(f)-(0.5))*pl;

    Nc = max(1,min(N,MAX_SAW_ORDER));
  clippedFreq = max(20.0,abs(freq)); // use lf_sawpos(freq) for LFOs (freq < 20 Hz)
  saw1l = 2*lf_sawpos(clippedFreq) - 1; // zero-mean, amplitude +/- 1
  // Also note the availability of lf_sawpos_phase above.
  poly(1,x) = x;
  poly(2,x) = x*x;
  poly(3,x) = x*x*x - x;
  poly(4,x) = x*x*(x*x - 2.0);
  poly(5,x) = x*(7.0/3 + x*x*(-10.0/3.0 + x*x));
  poly(6,x) = x*x*(7.0 + x*x*(-5.0 + x*x));
  p0n = float(ma.SR)/clippedFreq; // period in samples
  diff1(x) = (x - x')/(2.0/p0n);
  diff(N) = seq(n,N,diff1); // N diff1s in series
  factorial(0) = 1;
  factorial(i) = i * factorial(i-1);
  D(0) = _;
  D(i) = diff(i)/factorial(i+1);
  gate(N) = *(1@(N)); // delayed step for blanking startup glitch
};

process = vcs3osc1(3,freq,shape,samp,pamp);
