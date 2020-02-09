import("stdfaust.lib");

lr2bfmt(L,R) = W,X,Y,Z
  with{
    azi = (30.0 * (ma.PI / 180.0));
    elv = (00.0 * (ma.PI / 180.0));

    WL = L * 0.707;
    XL = L * cos(azi) * cos(elv);
    YL = L * sin(azi) * cos(elv);
    ZL = L * sin(elv);

    WR = R * 0.707;
    XR = R * cos(-azi) * cos(elv);
    YR = R * sin(-azi) * cos(elv);
    ZR = R * sin(elv);

    W = 0.707 * (WL + WR);
    X = 0.707 * (XL + XR);
    Y = 0.707 * (YL + YR);
    Z = 0.707 * (ZL + ZR);
};

process = lr2bfmt;
