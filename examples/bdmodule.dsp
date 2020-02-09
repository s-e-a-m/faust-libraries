declare name "MICHAEL GERZON BFORMAT TO PLANAR QUADRAPHONIC";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON BFORMAT TO PLANAR QUADRAPHONIC";

import("stdfaust.lib");
import("../seam.lib");

bdmodule = shelf : bamodule
  with{
    shelf = fi.highshelf(2,1.76,350), fi.highshelf(2,-1.25,350), fi.highshelf(2,-1.25,350), *(0.0);
};

process = bdmodule;
