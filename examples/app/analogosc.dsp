import("stdfaust.lib");
//import("../../seam.lib");

f = 1000;
a = 21000;

analsaw(f,a) = saw(f,a)
with{
    p(f) = os.lf_sawpos(f);
    t(f) = abs(p(f) *(2) - (1)) -(0.5);
    q(x) = x*x;
    d(x) = x-x';
    saw(f,a) = q(t(f)) <: q-_ : d : /(f/2) : *(a);
};

analtri(f,a) = tri(f,a)
with{
    p(f) = os.lf_sawpos(f);
    t(f) = abs(p(f) *(2) - (1)) -(0.5);
    q(x) = x*x;
    d(x) = x-x';
    tri(f,a) = (t(f)) <: _-(abs*_) : d : /(f) : *(a);
};

analsquare(f,a) = square(f,a)
with{
    p(f) = os.lf_sawpos(f);
    t(f) = abs(p(f) *(2) - (1)) -(0.5);
    q(x) = x*x;
    d(x) = x-x';
    square(f,a) = (t(f)) <: _-(abs*_) : /(f) : *(a) : d : /(f) : *(5000) : d : /(f) : *(4000) ;
};

process = analsaw(f,a), analtri(f,a), analsquare(f,a);
