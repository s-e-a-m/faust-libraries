import("stdfaust.lib");

//process = os.osc(100)*(0.1), os.osc(1000) : ba.peakholder(150),_;

// t = threshold (peakholder)
overdrive(x,t) = x <: ma.tanh((_*t))+(1-t)*_;

// c = carrier
// m = modulator
// t = envelope follower time sec
choppeRM(t,c,m) = c * overdrive(m,ba.peakholder(ba.sec2samp(t)));

process = os.osc(500), os.osc(0.01) : choppeRM(0.45);
