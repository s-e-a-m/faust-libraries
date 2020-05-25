import("stdfaust.lib");
freq = vslider("FREQ[scale:exp]", 1,1,10000,0.01);

//filters = fi.lowpass(32,16000), fi.lowpass(32,16000);
osc1(freq) = sine, saw
  with{
    sine = sin(phasor(freq)*2*ma.PI);
    saw = phasor(freq)-(0.5);
    phasor(freq) = +(freq/ma.SR) ~ ma.decimal;
};
process = osc1(freq);