//-------------------------------------------------------------- CHARLIEVERB ---
//-------------------------------------------------------------- CSOUND --------
//-------------------------------------------------------------- PORTING -------
import("stdfaust.lib");

// GLOBAL INTERFACE
parameters(x) = hgroup("CharlieVerb",x);

// INPUT-FILTER
if_g(x) = parameters(vgroup("[01]INPUT FILTERS",x));
ihip = if_g(vslider("[01]HIPASS[style:knob][scale:exp]", 20,20,1000,0.1) : si.smoo);
ilop = if_g(vslider("[02]LOPASS[style:knob][scale:exp]", 20000,1000,20000,0.1) : si.smoo);
input_filters(ihip,ilop) = fi.highpass(2,ihip) : fi.lowpass(2,ilop);

// PRE-DELAY
pdly = if_g(int(vslider("[03]PREDELAY[style:knob]", 1,1,100,0.001)/1000 : ba.sec2samp));
mpdl = ba.sec2samp(0.11) : int;
predelay(mpdl,pdly) = de.delay(mpdl,pdly);

// LIBRARY
// COMPUTER MUSIC TUTORIAL ALLPASS
cmtap(maxdel,D,g) = (+ <: de.delay(maxdel,int(D-1)),*(-g)) ~ *(g) : +;

// CSOUND TONE LOW PASS FILTER
tone(freq) = _*c1 : (+~_ *(c2))
with{
  hp = freq; //freq
  c1 = 1-c2;
  b = 2 - (cos(2*ma.PI*(hp/ma.SR)));
  c2 = b - sqrt((b*b)-1.0);
};

// CSOUND SPECS
ifactor = ma.SR/origSR;
origSR = 44100;
ilog001 = log(0.001);

// fragmentation (to smare pulses) 3x allpass filters
// delay times
itfrag1 = (67/25600)*ifactor;
itfrag2 = (213/25600)*ifactor;
itfrag3 = (647/25600)*ifactor;
// TIME TO SAMPS CONVERSION
itfrag1s = itfrag1 : ba.sec2samp;
itfrag2s = itfrag2 : ba.sec2samp;
itfrag3s = itfrag3 : ba.sec2samp;

ap_g(x) = parameters(vgroup("[02]ALLPASS",x));
dT = ap_g(vslider("[04]AP Decay Time[style:knob]", 6,6,36,0.1) : si.smoo);

apfrag1 = cmtap(ma.SR,(2*itfrag1s),dT*itfrag1);
apfrag2 = cmtap(ma.SR,(2*itfrag2s),dT*itfrag2);
apfrag3 = cmtap(ma.SR,(2*itfrag3s),dT*itfrag3);
fragmentation = apfrag1 : apfrag2 : apfrag3;
//process = _*0.707 : frag * 0.1;
//process = dT*itfrag3; // ktdecayfrag3 = ktattack * itfrag3 => gain > 1 per max 40 clip 36

itdensity = 0.01770 * ifactor : ba.sec2samp ;
kdensity = ap_g(vslider("[04]Density[style:knob]", 0.1,0.1,1,0.01) : si.smoo);
density = cmtap(ma.SR,itdensity,kdensity);
//process = density;

// reverberation 6x comb+alpass filters
// comb delays
itcomb1 = .05004355*ifactor;
itcomb2 = .05607709*ifactor;
itcomb3 = .06106576*ifactor;
itcomb4 = .06800453*ifactor;
itcomb5 = .07131519*ifactor;
itcomb6 = .07839002*ifactor;
//process = itcomb1;
itcomb1s = itcomb1 : ba.sec2samp : int;
itcomb2s = itcomb2 : ba.sec2samp : int;
itcomb3s = itcomb3 : ba.sec2samp : int;
itcomb4s = itcomb4 : ba.sec2samp : int;
itcomb5s = itcomb5 : ba.sec2samp : int;
itcomb6s = itcomb6 : ba.sec2samp : int;
//comb decay feedback coefs
kfeed1 = exp(itcomb1*ilog001/combdt);
kfeed2 = exp(itcomb2*ilog001/combdt);
kfeed3 = exp(itcomb3*ilog001/combdt);
kfeed4 = exp(itcomb4*ilog001/combdt);
kfeed5 = exp(itcomb5*ilog001/combdt);
kfeed6 = exp(itcomb6*ilog001/combdt);
//allpass delays
itdiffuser1 = .00610*ifactor : ba.sec2samp;
itdiffuser2 = .00911*ifactor : ba.sec2samp;
itdiffuser3 = .01118*ifactor : ba.sec2samp;
itdiffuser4 = .01339*ifactor : ba.sec2samp;
itdiffuser5 = .01529*ifactor : ba.sec2samp;
itdiffuser6 = .01731*ifactor : ba.sec2samp;

idifftime = 0.5;
er_g(x) = parameters(vgroup("[03]COMB",x));
comblp = er_g(vslider("[05]TONE[style:knob]", 20000,250,20000,1) : si.smoo);
combdt = er_g(vslider("[06]Decay Time[style:knob]", 0.5,0,1,0.001) : si.smoo);

adel1 = (+ : *(kfeed1) : de.delay(ma.SR,itcomb1s))~(cmtap(ma.SR,itdiffuser1,idifftime) : tone(comblp));
adel2 = (+ : *(kfeed2) : de.delay(ma.SR,itcomb2s))~(cmtap(ma.SR,itdiffuser2,idifftime) : tone(comblp));
adel3 = (+ : *(kfeed3) : de.delay(ma.SR,itcomb3s))~(cmtap(ma.SR,itdiffuser3,idifftime) : tone(comblp));
adel4 = (+ : *(kfeed4) : de.delay(ma.SR,itcomb4s))~(cmtap(ma.SR,itdiffuser4,idifftime) : tone(comblp));
adel5 = (+ : *(kfeed5) : de.delay(ma.SR,itcomb5s))~(cmtap(ma.SR,itdiffuser5,idifftime) : tone(comblp));
adel6 = (+ : *(kfeed6) : de.delay(ma.SR,itcomb6s))~(cmtap(ma.SR,itdiffuser6,idifftime) : tone(comblp));

asumL = (adel1-adel2+adel3-adel4+adel5-adel6)*(0.25); //-12dB
asumR = (adel1+adel2-adel3+adel4-adel5+adel6)*(0.25) ; //-12dB
//process = _ <: asumL, asumR;

// MIXER
om_g(x) = parameters(hgroup("[99]OUTPUT MIXER", x));
inlev = *(om_g(vslider("[01]INPUT LEVEL", 0,0,1,0.01) : si.smoo));
er = *(om_g(vslider("[02]L", 0,0,1,0.01) : si.smoo));
diff = *(om_g(vslider("[03]R", 0,0,1,0.01) : si.smoo));
mixer = (inlev <: _,_) ,er,diff :> _,_;

charlieverb = _*(0.707) <:_, (input_filters(ihip,ilop) : predelay(pdly) : fragmentation : density <: asumL, asumR) : mixer;

process = input_filters(ihip,ilop) : predelay(pdly);