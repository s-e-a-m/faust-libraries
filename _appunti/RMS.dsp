import("stdfaust.lib");
// Root Mean Square of n consecutive samples
RMS(n) = square : mean(n) : sqrt;

// Square of a signal
square(x) = x * x;

// Mean of n consecutive samples of a signal (uses fixpoint to avoid the 
// accumulation of rounding errors) 
mean(n) = float2fix : integrate(n) : fix2float : /(n); 

// Sliding sum of n consecutive samples
integrate(n,x) = x - x@n : +~_;

// Convertion between float and fix point
float2fix(x) = int(x*(1<<20));      
fix2float(x) = float(x)/(1<<20);    

// Root Mean Square of 1000 consecutive samples
process = no.noise <: vbargraph("normal", 0, 1), (RMS(1000) : vbargraph("rms", 0, 1));