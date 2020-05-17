import("stdfaust.lib");

iid(f,r) = 1.0+(pow((f/1000),0.8)*sin(r));

deg2rad = *(ma.PI/180);

f = hslider("freq[scale:exp]", 1000,1,22000,1);
r = hslider("deg", 0,-90,90,1) : deg2rad : si.smoo;

iidlin = iid(f,r) : ba.log2LinGain;

//process = no.noise:fi.lowpass(4,f):fi.highpass(4,f)<:_*(ba.db2linear(-iid(f,r))),_*(ba.db2linear(iid(f,r))) : *(0.25),*(0.25);

itd(r) = 0.09*((r+sin(r)))/344 : ba.sec2samp;

itdpan(r) = _ <: de.fdelay3(256,itd(r)),de.fdelay3(256,(-itd(r)));

process = no.noise:fi.lowpass(4,f):fi.highpass(4,f) : itdpan(r) : _*(ba.db2linear(-iid(f,r))),_*(ba.db2linear(iid(f,r)));
