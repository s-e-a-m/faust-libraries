import("../../../src/seam.lib");
t602t(t60,g) = (-20*log10(abs(g))*t60)/60;
//process = t602t(2,1/sqrt(2));

t602g(t60,t) = 10^((60*t)/(-20*t60));
//process = t602g(2,0.1);