// Universal Pitch Tracker

import("stdfaust.lib");

a = hslider("win", 100, 1, 100, 1);

ptrack(a,x) = tng(x)
with{
  xcr = (x' < 0) & (x >= 0);
  xcnt = +(xcr)~ %(int(a));
  wnd = xcr & (xcnt == a);
  cnt = (+(1) : *(1 - wnd)) ~ _;
  SH(trig,x) = (*(1 - trig) + x * trig) ~ _;
  nvl = SH(cnt == 0, cnt' + 1);
  tng(x) = a*ma.SR/max(nvl,1) - a*ma.SR*(nvl==0);
};

fptrack(a) = fi.dcblocker : (fi.lowpass(1) : ptrack(a))~ max(100);
process = os.lf_saw(freq) : fptrack(a);

freq  = vslider("[001]FREQUENCY[style:knob][scale:exp]", 100,1,10000,0.01);


//process = SH(0,0.3);
//SH(trig,x) = (*(1 - trig) + x * trig) ~ _;

//x = _;
//process = os.osc(10000) <: cnt;
//xcr = (x' < 0) & (x >= 0);
//cnt = +(xcr)~ %(int(a));
//wnd = xcr & (cnt == a);