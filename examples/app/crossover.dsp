import("stdfaust.lib");
crossover(freq) = _ <: low,high
with{
    freqtorad = freq*2*ma.PI/ma.SR;
    fcoeff1 = (sin(freqtorad)-1)/(cos(freqtorad));
    fcoeff2 = (fcoeff1+1)/2;
    block1(x) = loop~_: *(fcoeff1),_: +
    with{
        loop = _ <: *(fcoeff1),_: x-_,_;
    };
    block2(x) = loop~_: !,_
    with{
        loop = _ <: x-_,_ : *(fcoeff2),_ <:_+_,_,! <: +,_,!;
    };
low = block2 : block2;
high = _ <: block1 - low;
};
process = os.osc(ba.sweep((ma.SR/2)-1,1)) : crossover(15000) <: _,_,+;
