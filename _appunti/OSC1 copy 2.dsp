import("stdfaust.lib");

osc1_g(x) = hgroup("[001]OSCILLATOR 1", x);
osc1_lev_g(x) = osc1_g(hgroup("[003]LEVEL", x));
freq  = osc1_g(vslider("[001]FREQUENCY[style:knob][scale:exp]", 100,1,10000,0.01) : si.smoo);
shape = osc1_g(vslider("[002]SHAPE[style:knob]", 5,0,10,0.1)/10 : si.smoo);
ampo = osc1_lev_g(vslider("[001]SINE[style:knob]", 0,0,10,0.1)/10 : si.smoo);
ampp = osc1_lev_g(vslider("[002]SAW[style:knob]", 0,0,10,0.01)/10 : si.smoo);

osc1(freq) = sine, saw
  with{
    sine = sin(phasor(freq)*2*ma.PI);
    saw = phasor(freq)-(0.5);
    phasor(freq) = +(freq/ma.SR) ~ ma.decimal;
};

// SINE SHAPE
oshape = sin(shape*(ma.PI)); // 0-1-0
pshape = cos(shape*(ma.PI))*(-1); // 1-0-(-1)
//process = oshape, pshape;

sosc = *(oshape);
oabs = abs : *(pshape) : *(2) : -(pshape);
osc1c = osc1(freq) : (_<:sosc+oabs),_ : *(ampo),*(ampp) : +;
 
process = osc1c *(0.5);
