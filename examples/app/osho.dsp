/*BIQUAD FILTER*/
/* y[n]=b0x[n]+b1x[n−1]+b2x[n−2]−a1y[n−1]−a2y[n−2]
Note that a and b parameters are inverted */
import("stdfaust.lib");
biquad(a0c,a1c,a2c,b1c,b2c) =  a(a0c,a1c,a2c) : ma.sub~(b(b1c,b2c))
with{
    a0(a0c) = *(a0c);
    a1(a1c) = @(1) : *(a1c);
    a2(a2c) = @(2) : *(a2c);
    b1(b1c) = *(b1c);
    b2(b2c) = @(1) : *(b2c);
    //Blocco FIR
    a(a0c,a1c,a2c) = _ <: a0(a0c),a1(a1c),a2(a2c) :> _ ;
    //Blocco IIR
    b(b1c, b2c) = _ <:  b1(b1c), b2(b2c):> _;
};
//Coefficenti Max
//a = a0(0.9), a1(0.1), a2(0.1);
//b = b1(0.2), b2(0.2);
osco = os.impulse : biquad(1,0,0,-1.95128373,1)*0.1;
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
ptrack(a) = fi.dcblockerat(80) : (fi.lowpass(1) : upt(a)) ~ max(100);
process =  osco <: _,(ptrack(10) : hbargraph("[01]freq[style:numerical]", 1000,5000));
