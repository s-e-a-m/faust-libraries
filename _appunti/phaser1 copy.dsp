import("stdfaust.lib");

//y(n) = C * x(n) + x(n-1) - C * y(n-1)


// kfreq ? C is a coefficient which is calculated from the value of kfreq, using the bilinear z-transform

freq = vslider("Frequency", 0,0,1,0.01);

phaser1(order,C,g) = ( + : seq(i,order,ap(C/4/order)))~*(g)
with{
  ap(C) = _ <: _*(C) + mem : -~*(C);
  clip = min(1) : max(-1);
};

t60(g,d) = 1/((3/(log10(1/g)))*(d)) : ba.sec2samp;
process = t60(0.1,3);

//process = phaser1(8,freq,0.1);
//process = phaser1(4,0.5);
