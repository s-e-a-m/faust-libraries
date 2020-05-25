import("stdfaust.lib");
sweep = ceil(+(0.010)~_ : *(1000)) /(100); // : *(ma.PI/180);
process = sweep;//sin(sweep*ma.PI);
