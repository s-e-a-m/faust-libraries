import("stdfaust.lib");

bfmt2uhj(W,X,Y,Z) = L,R,T,Q
  with{
    // biquad(x,a0,a1,a2,b1,b2) = x : + ~ ((-1)*conv2(b1, b2)) : conv3(a0, a1, a2)
    // 	with {
    // 		conv2(c0,c1,x) = c0*x+c1*x';
    // 		conv3(c0,c1,c2,x) = c0*x+c1*x'+c2*x'';
    // 	};
    //
    // j = biquad(1.94632, -0.94657, 0.94657, -1.94632, 1) :
    //     biquad(0.83774, -0.06338, 0.06338, -0.83774, 1);

    j = fi.pospass(128, 300) : !, *(2);

    S = 0.9396926 * W + 0.1855740 * X;
    D = j((-0.3420201 * W) + (0.5098604 * X)) + (0.6554516 * Y);

    L = 0.5 * (S + D);
    R = 0.5 * (S - D);
    T = j((-0.1432 * W + 0.6512 * X)) - (0.7071 * Y);
    Q = 0.9772 * (Z);
  };

  process = bfmt2uhj;
