import("stdfaust.lib");

//-------------------------------------------------------------- VOICED UNVOICED
threshold = hslider("[2] Threshold", 0.9, 0, 100.000, 0.001);
insp1 = hbargraph("insp1",0,50);
insp2 = hbargraph("insp2",-5,5);
zerox(x) = (x'<0) & (x>=0);//(x<0) | (x>0);
process = _ <: de.delay(512,500),
               (_<: *(_,_') < (0) : slidingSumN(500,512) : > (threshold) : insp2: * (1.570796) <: cos, sin : si.smoo, si.smoo),
               de.delay(512,500) : *,* ;
//process = zerox : slidingSumN(500,512) : insp1;
//-------------------------------------------------------------- LIBRARY              
take(1, (xs, xxs))  = xs;
take(1, xs)         = xs;
take(nn, (xs, xxs)) = take(nn-1, xxs);

subseq((head, tail), 0, 1) = head;
subseq((head, tail), 0, n) = head, subseq(tail, 0, n-1);
subseq((head, tail), p, n) = subseq(tail, p-1, n);
subseq(head, 0, n)         = head;

slidingReduce(op,N,maxN,disabledVal,x) =
  par(i,maxNrBits,fixedDelayOp(pow2(i),x)@sumOfPrevBlockSizes(N,maxN,i)
    : useVal(i)) : combine(maxNrBits)
with {

    // Apply <op> to the last <N> values of <x>, where <N> is fixed
    fixedDelayOp = case {
      (1,x) => x;
      (N,x) => op(fixedDelayOp(N/2,x), fixedDelayOp(N/2,x)@(N/2));
    };
    
    // The sum of all the sizes of the previous blocks
    sumOfPrevBlockSizes(N,maxN,0) = 0;
    sumOfPrevBlockSizes(N,maxN,i) = (subseq((allBlockSizes(N,maxN)),0,i):>_);
    allBlockSizes(N,maxN) = par(i, maxNrBits, (pow2(i)) * isUsed(i));
    maxNrBits = int2nrOfBits(maxN);
    
    // Apply <op> to <N> parallel input signals
    combine(2) = op;
    combine(N) = op(combine(N-1),_);
    
    // Decide wether or not to use a certain value, based on N
    // Basically only the second <select2> is needed,
    // but this version also works for N == 0
    // 'works' in this case means 'does the same as reduce'
    useVal(i) =
      _ <: select2(
        (i==0) & (N==0),
        select2(isUsed(i), disabledVal,_),
        _
      );
      
    // useVal(i) =
    //     select2(isUsed(i), disabledVal,_);
    isUsed(i) = take(i+1,(int2bin(N,maxN)));
    pow2(i) = 1<<i;
    // same as:
    // pow2(i) = int(pow(2,i));
    // but in the block diagram, it will be displayed as a number, instead of a formula

    // convert N into a list of ones and zeros
    int2bin(N,maxN) = par(j,int2nrOfBits(maxN),int(floor(N/(pow2(j))))%2);
    // calculate how many ones and zeros are needed to represent maxN
    int2nrOfBits(0) = 0;
    int2nrOfBits(maxN) = int(floor(log(maxN)/log(2))+1);
};

slidingSumN(n,maxn) = slidingReduce(+,n,maxn,0);

