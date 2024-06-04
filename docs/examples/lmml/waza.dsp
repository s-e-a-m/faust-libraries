import("../../../src/seam.lib");
// WA&ZA INTERFACE
wgroup(x) = vgroup("[01] WA", x);
waf = wgroup(hslider("[01] WAFB", 0.,0.,0.9,0.01)) : si.smoo;
wag = wgroup(hslider("[02] WAG", 0.,0.,1.0,0.01)) : si.smoo;
zgroup(x) = vgroup("[02] ZA", x);
zaf = zgroup(hslider("[01] ZAFB", 0.,0.,0.9,0.01)) : si.smoo;
zag = zgroup(hslider("[02] ZAG ", 0.,0.,1.0,0.01)) : si.smoo;

process = sml.waza(wag,waf,zag,zaf);
