import("stdfaust.lib");

osc1_g(x) = hgroup("[001]OSCILLATOR 1", x);
osc1_lev_g(x) = osc1_g(hgroup("[003]LEVEL", x));
freq  = osc1_g(vslider("[001]FREQUENCY[style:knob][scale:exp]", 100,1,10000,0.01) : si.smoo);
shape = osc1_g(vslider("[002]SHAPE[style:knob]", 5,0,10,0.1)/10 : si.smoo);
ampo = osc1_lev_g(vslider("[001]SINE[style:knob]", 0,0,10,0.1)/10 : si.smoo);
ampp = osc1_lev_g(vslider("[002]SAW[style:knob]", 0,0,10,0.01)/10 : si.smoo);

vcs3osc1(freq) = sine, saw
  with{
    step = freq/ma.SR;
    phasor(step) = +(step)~ ma.decimal : -(step);
    sine = sin(phasor(step)*2*ma.PI);
    saw = phasor(step)-(0.5);
};

// SINE SHAPE
oshape = sin(shape*(ma.PI)); // 0-1-0
pshape = cos(shape*(ma.PI))*(-1); // 1-0-(-1)
//process = oshape, pshape;

sosc = *(oshape);
oabs = abs : *(pshape) : *(2) : -(pshape);
osc1c(freq) = vcs3osc1(freq) : (_<:sosc+oabs),_ : *(ampo),*(ampp) : +;

matrix(IN,OUT) = (si.bus(2*IN) :> si.bus(IN) : xy(IN,OUT)) ~ (feedback(OUT))
  with{
      //                                       qui ci va lo switch per scegliere su quale uscita reindirizzare il feedback
    feedback(OUT) = si.bus(OUT) <: par(fb, IN, si.bus(OUT)) :> si.bus(OUT);
    switch(IN) = checkbox("IN %3inn") : si.smoo
      with{
        inn = IN+(1);
    };
    outrow(N,row) = hgroup("OUT %3nrow", par(in, N, *(switch(in))) :> _) 
      with{
        nrow = row+(1);
    };
    xy(IN,OUT) = vgroup("Matrix %IN x %OUT", par(in, IN, _) <: par(out, OUT, outrow(IN, out)));
};
process = si.bus(5) : matrix(5,5);
//process = (+,_ : matrix(2,2))~_;
