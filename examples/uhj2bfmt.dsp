import("stdfaust.lib");

uhj2bfmt(L,R,T,Q) = W,X,Y,Z
  with{
    // biquad(x,a0,a1,a2,b1,b2) = x : + ~ ((-1)*conv2(b1, b2)) : conv3(a0, a1, a2)
    //   with {
    //     conv2(c0,c1,x) = c0*x+c1*x';
    //     conv3(c0,c1,c2,x) = c0*x+c1*x'+c2*x'';
    //   };

    j = fi.pospass(128, 300) : !, *(2);
    //j = mx.biquad(1.94632, -0.94657, 0.94657, -1.94632, 1) :
    //    mx.biquad(0.83774, -0.06338, 0.06338, -0.83774, 1);

    S = 0.5 * (L + R);
    D = 0.5 * (L - R);

    W = 0.982 * S + j(0.197 * (0.828 * D + 0.768 * T));
    X = 0.419 * S - j(0.828 * D + 0.768 * T);
    Y = 0.796 * D - 0.676 * T + j(0.187 * S);
    Z = 1.023 * Q;
  };

  process = uhj2bfmt;
