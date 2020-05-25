import("stdfaust.lib");

osc1_g(x) = hgroup("[001]OSCILLATOR 1", x);
freq  = osc1_g(vslider("[001]FREQUENCY[style:knob][scale:exp]", 100,1,10000,0.01) : si.smoo);

decimali(n) = n - floor(n);
step = (0.01);
phasor = +(step)~ ma.decimal : -(step);
//process = phasor;

// libreria
vcs3osc1(f,s,sl,pl) = sine+wsine, saw
  with{
    step = f/ma.SR;
    phasor(step) = step : (+ : ma.decimal)~_;
    sine = sin(phasor(step)*2*ma.PI) : *(0.5*sin(s*(ma.PI)));
    wsine = sin(phasor(step)*(-1)*ma.PI) : +(0.5) : *(cos(s*(ma.PI)));
    saw = phasor(step)-(0.5);
};

process = vcs3osc1;