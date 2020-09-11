declare name "CURTIS ROADS ALLPASS FILTER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "CURTIS ROADS ALLPASS FILTER";

import("stdfaust.lib");
import("../../../seam.lib");

// ap1 = fi.tf2(1.94632, -0.94657, 0.94657, -1.94632, 1);
// ap2 = fi.tf2(0.83774, -006338, 0.06338, -0.83774, 1);
// ap1b = biquad(1.94632, -0.94657, 0.94657, -1.94632, 1);
// ap2b = biquad(0.83774, -006338, 0.06338, -0.83774, 1);
// ap1c = biquad(0.87747, -1.86141, 1, -1.86141, 0.87747);
// ap2c = biquad(0.77083, -1.71048, 1, -1.71048, 0.77083);

process = os.osc(zsweep(ma.SR/2)) <: _+(apbiquad(1250,0.01):apbiquad(4500,2)) : *(0.25);
//process = os.osc(lsweep(2)) <: _+(fi.pospass(8,1000):*(2),!);

biquad(a0c,a1c,a2c,b1c,b2c) = a(a0c,a1c,a2c) : ma.sub~(b(b1c,b2c))
with{
a0(a0c) = *(a0c);
a1(a1c) = @(1) : *(a1c);
a2(a2c) = @(2) : *(a2c);
a(a0c,a1c,a2c) = _ <: a0(a0c), a1(a1c), a2(a2c) :> _;
b1(b1c) = *(b1c);
b2(b2c) = @(1) : *(b2c);
b(b1c,b2c) = _ <: b1(b1c),b2(b2c) :> _ ;
};

apbiquad(fc,q) = biquad(b0(fc,q), b1(fc,q), b2, a1(fc,q), a2(fc,q))
with{
  g(fc) = tan(ma.PI*(fc/ma.SR));
  d(q)  = 1/q;
  k(fc,q)  = 1/(1 + (d(q)*g(fc)) + (g(fc)*g(fc)));
  b0(fc,q) = (1 - (g(fc)*d(q)) + (g(fc)*g(fc))) * k(fc,q);
  b1(fc,q) = 2 * ((g(fc)*g(fc)) - 1) * k(fc,q);
  b2 = 1;
  a1 = b1;
  a2 = b0;
};
