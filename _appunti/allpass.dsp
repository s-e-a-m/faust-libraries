import("stdfaust.lib");

lsweep = ba.sweep((ma.SR/2)-1,1); //SWEEP

gnallp(D,g) = _ <: ( + : de.delay((ma.SR/2),int(D-1)))~*(g),_ : *(1-(g*g)), *(-g) : +; //

allpass_comb(N,aN) = (+ <: de.delay(ma.SR/2,N-1),*(aN)) ~ *(-aN) : mem,_ : +; // Js faust

cmtap(D,g) = (+ <: de.delay((ma.SR/2),int(D-1)),*(-g)) ~ *(g) : +; // curtis roads

process = allpass_comb(32,0.8);//


//process = cmtap(512,0.5);


gnallp(D,g) = _ <: ( + : de.delay((ma.SR/2),int(D-1)))~*(g),_ : *(1-(g*g)), *(-g) : +;
apnl(a1,a2,x) = nonLinFilter
with {
   condition = _>0;
   nonLinFilter = (x - _ <: _*(condition*a1 + (1-condition)*a2),_')~_ :> +;
};

allpassn(0,sv) = _;
allpassn(n,sv) = _ <: ((+ <: (allpassn(n-1,sv)),*(s))~(*(-s))) : _',_ :+
with { s = ba.take(n,sv); };

allpassnkl(0,sv) = _;
allpassnkl(n,sv) = _ <: *(s),(*(1+s) : (+
                   : allpassnkl(n-1,sv))~(*(-s))) : _, mem*(1-s) : +
with { s = ba.take(n,sv); };

//process = fi.allpassnn(1,0.1);

//process = os.osc(10000) <: cmtap(1024,0.5),gnallp(1024,0.5), allpass_comb(1024,0.5);
//process = os.osc(22000) <: _,cmtap(512,0.5), allpass_comb(512,0.5);
//process = no.noise <: cmtap(512,0.5), allpass_comb(512,0.5);
