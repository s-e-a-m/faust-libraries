import("stdfaust.lib");
// %Sampling Rate
// Fs = 48000;
//
// %Analog A-weighting filter according to IEC/CD 1672.
f1 = 20.598997;
f2 = 107.65265;
f3 = 737.86223;
f4 = 12194.217;
A1000 = 1.9997;
// pi = 3.14159265358979;
// NUM = [ (2*pi*f4)^2*(10^(A1000/20)) 0 0 0 0 ];
// DEN = conv([1 +4*pi*f4 (2*pi*f4)^2],[1 +4*pi*f1 (2*pi*f1)^2]);
// DEN = conv(conv(DEN,[1 2*pi*f3]),[1 2*pi*f2]);
//
// %Bilinear transformation of analog design to get the digital filter.
// [b,a] = bilinear(NUM,DEN,Fs);

// _ : tf2s(b2,b1,b0,a1,a0,w1) : _
b0 = pow(2*ma.PI*f4,2)*pow(10,(A1000/20));
b1 = 0;
b2 = 0;
w1 = ma.PI*ma.SR/2;

//process = b0;
process = fi.tf2s(b2,b1,b0,a1,a0,w1);
