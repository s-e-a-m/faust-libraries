import("stdfaust.lib");

phasor(f) = loop ~ _ : ! , _
with {
    loop(fb) = fb + f/ma.SR : ma.decimal , fb;
};

//process = phasor(50);

freq = 50;
step = (freq/ma.SR);
process = (+(step) ~ ma.decimal) - step;