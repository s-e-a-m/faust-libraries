import("stdfaust.lib");

// Universal Pitch Tracker
// From faust documentation
a = hslider("n cycles", 1, 1, 100, 1);
upt(a,x) = a*ma.SR / max(M,1) - a * ma.SR * (M == 0)
with{
  // positive zero crossing
  xcr = (x' < 0) & (x >= 0);
  // counts of crossing
  xcnt = +(xcr)~ %(int(a));
  // windows of counts
  wnd = xcr & (xcnt == a);
  // counting samples inside windows
  N = (+(1) : *(1 - wnd)) ~ _;
  // sample and hold the number of cycles
  M = ba.sAndH(N == 0, N' + 1);
};

ptrack(x,a) = x : fi.dcblockerat(80) : (fi.lowpass(1) : upt(a)) ~ max(100);
process = ptrack;
