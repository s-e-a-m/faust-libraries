import("stdfaust.lib");

process = +(1)~;

//process = +(0.01)~ma.decimal;
// grid on
// xlim ([0 1000])


// decpart(n) = n - (int(n'));
// process = +(0.001)~decpart;

// import("stdfaust.lib");
// decpart(n) = n - (floor(n));
// step = 0.1;
// process = +(step)~decpart : -(step);
