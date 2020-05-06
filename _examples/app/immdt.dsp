import("stdfaust.lib");
// INFERNAL MACHINE MINIMUM DELAY TIME 40 MICROSECOND
// WHEN SAMPLE RATE MAKE SENSE
immdt = (0.04/1000)*ma.SR:int;
process = no.pink_noise*0.25<:_,(@(immdt)+_),(@(immdt)-_);
