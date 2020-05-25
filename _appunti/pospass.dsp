import("stdfaust.lib");
hilbert = fi.pospass6e(150) : !,*(1);

process = os.osc(1000) : hilbert;
