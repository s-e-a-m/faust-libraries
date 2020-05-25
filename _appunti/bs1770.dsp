import("stdfaust.lib");

pfs1 = fi.high_shelf(4, 1100);
pfs2 = fi.highpass(2, 55);

tg = ba.sec2samp(400);

bs1770 = pfs1 : pfs2 ;

process = no.noise : bs1770;