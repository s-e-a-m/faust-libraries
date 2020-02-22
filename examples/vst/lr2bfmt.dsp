declare name "MICHAEL GERZON STEREO TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON STEREO TO BFORMAT ENCODER";

import("stdfaust.lib");
import("../../seam.lib");

// LS and RS are dead channels to create VST routing consistency
// lr2bfmt(L,R,LR,RS) = W,X,Y,Z
//   with{
//     azi = 45.0 : deg2rad;
//     elv = 00.0 : deg2rad;
//
//     WL = L * 0.707;
//     XL = L * cos(azi) * cos(elv);
//     YL = L * sin(azi) * cos(elv);
//     ZL = L * sin(elv);
//
//     WR = R * 0.707;
//     XR = R * cos(-azi) * cos(elv);
//     YR = R * sin(-azi) * cos(elv);
//     ZR = R * sin(elv);
//
//     W = 0.707 * (WL + WR);
//     X = 0.707 * (XL + XR);
//     Y = 0.707 * (YL + YR);
//     Z = 0.707 * (ZL + ZR);
// };

process = lrms2bfmt;
