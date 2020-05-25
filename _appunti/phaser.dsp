import("stdfaust.lib");

al_g(x) = hgroup("allpass",x);
//gain = al_g(vslider("G[style:knob]", 0.5, 0, 1, 0.01):si.smoo);
fb = al_g(vslider("feedback[style:knob]", 0.0, 0, 1, 0.01):si.smoo);
freq = vslider("LFO[scale:exp][style:knob]", 0.001, 0, 30, 0.001) : si.smoo;

//alseq = seq(i,4,fi.allpassn(1,lfo));

alseq = seq(i,4,crap(lfo))
with{
  crap(g) = (+ <: _,*(-g))~*(g):+;    
};


lfo = sin(phasor*2*ma.PI)
with{
  step = (freq/ma.SR);
  phasor = step : (+:ma.decimal)~_;
};

process = _<: _,(+:alseq)~*(fb):>_<:_,_;