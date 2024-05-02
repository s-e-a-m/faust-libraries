import("../../../src/seam.lib");
tau(t60,g) = (-20*log10(abs(g))*t60)/60;
gain(t60,t) = 10^((60*t)/(-20*t60));
process = sms.t60(11,1/sqrt(2)),tau(1,1/sqrt(2)),gain(1,11);