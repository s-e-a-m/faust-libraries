import("stdfaust.lib");

p_g(x) = hgroup("PHASER",x);
lff = p_g(vslider("[01]LFO[style:knob]", 0.358, 0, 42, 0.001)) : si.smoo;
fbk = p_g(vslider("[02]FBACK[style:knob]", -0.689, -0.999, 0.999, 0.001) : si.smoo);
del = p_g(nentry("[03]DELAY[style:knob]", 1, 0, 100, 1));

phaser(N,x,d,g,fb) = x <: _,(+:alseq(N,d,g))~*(fb):> _
with{
  ap(d,g) = (+ <: de.fdelay((ma.SR/2),d),*(-g)) ~ *(g) : mem,_ : +;
  alseq(N,d,g) = seq(i,N,ap(d,g));
};

oscf = hslider("[01]SAWTOOTH", 16, 1, 1000, 1) : si.smoo;
lfo = os.osc(lff);

chopper = min(0.707) : max(-0.707);

process = os.sawtooth(oscf)*(0.25) : fi.lowpass(8,10000) : phaser(16,_,del,lfo,fbk) : chopper : fi.lowpass(8,15000) : chopper : fi.lowpass6e(20000) <:_,_;
