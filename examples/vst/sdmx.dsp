declare name "SUM AND DIFFERENCE MATRIX";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "SUM AND DIFFERENCE MATRIX";

import("stdfaust.lib");
//import("../../seam.lib");

nsum = 0.707*(_+_);
ndif = 0.707*(_-_);
sdmx = _,_ <: nsum, ndif;

process = sdmx;
