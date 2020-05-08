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

sqPI = 3.141592653589793238462643383279502797479068098137295573004504331874296718662975536062731407582759857177734375;

vcs3osc1(f,s,sl,pl) = shaped(f,s,sl), saw(f,pl)
  with{
    phasor(f) = os.lf_sawpos(f);
    sine(f,s) = sin(phasor(f)*2*ma.PI) : *(0.5*sin(s*(ma.PI)));
    wsine(f,s) = sin(phasor(f)*(-1)*ma.PI) : +(2/sqPI) : *(cos(s*(ma.PI)));
    shaped(f,s,sl) = (sine(f,s)+wsine(f,s))*sl;
    saw(f,pl) = (phasor(f)-(0.5))*pl;
};

//process = vcs3osc1(freq,shape,samp,pamp) : fi.lowpass(2,10000), fi.lowpass(2,10000) : fi.lowpass6e(20000), fi.lowpass6e(20000) : fi.dcblocker, fi.dcblocker;
process = vcs3osc1(freq,shape,samp,pamp) : fi.lowpass6e(24000), fi.lowpass6e(24000);
