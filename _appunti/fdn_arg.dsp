import("stdfaust.lib");
declare options "[midi:on]";

delays = (4,4,4,4);
freqs = 800,4000;
dur = 2,2,2;
rev = _ <: re.fdnrev0(512, delays, 3,freqs, dur, 0., 0.);

process = rev;