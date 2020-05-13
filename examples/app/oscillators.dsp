import("stdfaust.lib");
//import("../../seam.lib");

f = 10000;

vcs3osc1(f,s,sl,pl) = shaped, saw
  with{
    phasor = os.lf_sawpos(f);
    sine = sin(phasor*2*ma.PI) : *(0.5*sin(s*(ma.PI)));
    wsine = sin(phasor*(-1)*ma.PI) : +(0.5) : *(cos(s*(ma.PI)));
    shaped = (sine+wsine)*sl;
    saw = (phasor-(0.5))*pl;
};

process = os.osc(f),os.osci(f),os.oscrs(f),os.quadosc(f), vcs3osc1(f,0.5,1,1);
