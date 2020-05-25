import("stdfaust.lib");
order = 128;
freq = 100;
filter1 = fi.lowpass(order,freq) : fi.highpass(order,freq) : *(0.001);
filter2 = fi.lowpass(order,2*(freq)) : fi.highpass(order,2*(freq)) : *(0.001);

process = no.noise <: filter1* filter2;