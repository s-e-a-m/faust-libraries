import("stdfaust.lib");

phaser(x,d,g,fb) = x <: _,(+:alseq(d,g))~*(fb):> _
with{
  ap(d,g) = (+ <: de.fdelay((ma.SR/2),d),*(-g)) ~ *(g) : mem,_ : +;
  alseq(d,g) = seq(i,4,ap(d,g));
};

p_g(x) = hgroup("PHASER",x);
freq = p_g(vslider("[01]LF[style:knob]", 0.001, 0, 30, 0.001)) : si.smoo;
fb = p_g(vslider("[02]FBACK[style:knob]", 0.0, 0, 1, 0.001) : si.smoo);
lfo = sin(phasor*2*ma.PI)
with{
  phasor = os.lf_sawpos(freq);
};

oscf = vslider("[01]OSC[style:knob]", 1, 1, 10000, 1) : si.smoo;
del = nentry("[02]DELAY", 0, 0, 10000, 1) : si.smoo;

chopper = min(1) : max(-1);
process = os.osc(oscf)*0.125 : phaser(_del,lfo,fb) : chopper : fi.lowpass(8,10000) : fi.lowpass(64,15000) : *(0.5);
