import("stdfaust.lib");

f = hslider("Band Pass & IID Frequency", 1000,1,22000,1) : si.smoo;
r = hslider("Angle", 0,-90,90,1) : deg2rad : si.smoo;
deg2rad = *(ma.PI/180);

iid(f,r) = (pow((f/1000),0.8)*sin(r)); // manca il +1
itd(r) = 0.09*(r+sin(r))/344 : ba.sec2samp;

//itdpan(r) = _ <: de.fdelayltv(16,256,max(itd(r),0)), de.fdelayltv(16,256,(max(-itd(r),0)));

itdpan(r) = _ <: de.delay(256,int(max(itd(r),0))), de.delay(256,int((max(-itd(r),0))));

iidpan(f,r) = _*(ba.db2linear(-iid(f,r))), _*(ba.db2linear(iid(f,r)));

process = no.noise*0.25 : fi.lowpass(4,f) : fi.highpass(4,f) : itdpan(r) : iidpan(f,r)
