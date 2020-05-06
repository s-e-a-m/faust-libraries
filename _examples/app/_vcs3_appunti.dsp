import("stdfaust.lib");

osc1_g(x) = hgroup("[001]OSCILLATOR 1", x);
osc1_lev_g(x) = osc1_g(hgroup("[003]LEVEL", x));
freq  = osc1_g(vslider("[001]FREQUENCY[style:knob][scale:exp]", 100,1,10000,0.01) : si.smoo);
shape = osc1_g(vslider("[002]SHAPE[style:knob]", 5,0,10,0.1)/10 : si.smoo);
slev = osc1_lev_g(vslider("[001]SINE[style:knob]", 0,0,10,0.1)/10 : si.smoo);
plev = osc1_lev_g(vslider("[002]SAW[style:knob]", 0,0,10,0.01)/10 : si.smoo);

vcs3osc1(freq,shape,slev,plev) = ((wsin+sine)*slev)+(saw*plev)
  with{
    step = freq/ma.SR;
    phasor(step) = +(step)~ ma.decimal : -(step);
    sine = sin(phasor(step)*2*ma.PI) : *(0.5*sin(shape*(ma.PI)));
    wsin = sin(phasor(step)*(-1)*ma.PI) : +(0.5) : *(cos(shape*(ma.PI)));
    pshape = cos(shape*(ma.PI))*(-1);
    saw = phasor(step)-(0.5);
};

process = vcs3osc1(freq,shape,slev,plev) : fi.lowpass(1,16000);
