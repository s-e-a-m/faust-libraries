import("stdfaust.lib");
// INFERNAL MACHINE MINIMUM DELAY TIME 40 microsecond
del = hslider("del", 0.04, 0.04, 1, 0.001);
immdl = (del/1000) * ma.SR;
process = os.saw3(1000)*0.25<:@(2),_;