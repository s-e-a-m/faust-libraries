import("stdfaust.lib");

iid(f,rad) = 1.0+pow((f/1000),0.8)*sin(rad);

deg2rad = *(ma.PI/180);

f = hslider("freq", 1000,1,22000,1);
rad = hslider("deg", 0,-45,45,1) : deg2rad;

iidlin = iid(f,rad) : ba.log2LinGain;

process = no.noise:fi.lowpass(4,f):fi.highpass(4,f)<:_*(ba.db2linear(-iid(f,rad))),_*(ba.db2linear(iid(f,rad))) : *(0.25),*(0.25);
