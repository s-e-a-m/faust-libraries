import("stdfaust.lib");

iid(f,r) = 1.0+(pow((f/1000),0.8)*sin(r));

deg2rad = *(ma.PI/180);

f = hslider("freq", 1000,1,22000,1);
r = hslider("deg", 0,-45,45,1) : deg2rad;

iidlin = iid(f,r) : ba.log2LinGain;

process = os.osc(f)<:_*(ba.db2linear(-iid(f,r))),_*(ba.db2linear(iid(f,r))) : *(0.25),*(0.25);
