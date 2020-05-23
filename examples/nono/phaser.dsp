import("stdfaust.lib");
import("../../seam.lib");

p_g(x) = hgroup("PHASER",x);
freq = p_g(vslider("[01]LFO[scale:exp][style:knob]", 0.001, 0, 30, 0.001)) : si.smoo;
fb = p_g(vslider("[02]FBACK[style:knob]", 0.0, 0, 1, 0.01) : si.smoo);

alseq(D,g) = seq(i,4,ap(D,g))
with{
  ap(D,g) = (+ <: de.fdelay((ma.SR/2),D),*(-g)) ~ *(g) : mem,_ : +;
};

lfo = sin(phasor*2*ma.PI)
with{
  phasor = os.lf_sawpos(freq);
};

process = phaser(_,1,lfo);
