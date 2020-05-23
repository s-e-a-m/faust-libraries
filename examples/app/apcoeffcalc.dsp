import("stdfaust.lib");
// REFERENCES:
// https://www.dsprelated.com/showcode/182.php

// The following Matlab function generates allpass coefficients for an IIR filter.
// In this design, the magnitude response is unchanged but the phase response is very different.
// This code only supports 1st order or 2nd order variants.

// 1st order allpass filters shift the phase by 180 degrees, while the 2nd order shifts the phase by 360 degrees.
// The "center frequency" of Fc defines where the phase response should be halfway to the max shift.

// For example,
// If order=2 and Fc = 2000Hz, there would be a 180deg shift at 2kHz
// If order=1 and Fc = 5000Hz, there would be a 90deg shift at 5kHz

// Returns allpass filter coefficients.
// Currently only 1st and 2nd orders are supported.
// N is the order of the allpass
// FC is the frequency a the 90deg phase shift point
// FS is the sampling rate
// Q is quality factor describing the slope of phase shift

// Bilinear transform
// g(fc) = tan(ma.PI*(fc/ma.SR));

process = (ap1coeff(freq,qq) : ap1inspec), (ap2coeff(freq,qq) : ap2inspec) :> _ *(0.00001);

ap2coeff(fc,q) = g(fc), b0(fc,q), b1(fc,q), b2, a1(fc,q), a2(fc,q)
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

ap1coeff(fc,q) = g(fc), b0(fc,q), b1, b2, a1(fc,q), a2
with{
 g(fc) = tan(ma.PI*(fc/ma.SR));
 b0(fc,q) = (g(fc)-1)/(g(fc)+1);
 b1 = 1;
 b2 = 0;
 a1 = b0;
 a2 = 0;
};

freq = hslider("[01]Center Frequency", 2000,1,24000,1);
qq = hslider("[02]Q slope", 1,0.01,2,0.001);

graph_g(x) = hgroup("[03]COEFFICIENTS",x);
ap1inspec = graph_g(vgroup("[01]1st ORDER ALLPASS",
            hbargraph("[00]g[style:numerical]", 0,10),
            hbargraph("[01]b0[style:numerical]", -2,2),
            hbargraph("[02]b1[style:numerical]", -2,2),
            hbargraph("[03]b2[style:numerical]", -2,2),
            hbargraph("[04]a1[style:numerical]", -2,2),
            hbargraph("[05]a2[style:numerical]", -2,2)));

ap2inspec = graph_g(vgroup("[02]2nd ORDER ALLPASS",
            hbargraph("[00]g[style:numerical]", 0,10),
            hbargraph("[01]b0[style:numerical]", -2,2),
            hbargraph("[02]b1[style:numerical]", -2,2),
            hbargraph("[03]b2[style:numerical]", -2,2),
            hbargraph("[04]a1[style:numerical]", -2,2),
            hbargraph("[05]a2[style:numerical]", -2,2)));
