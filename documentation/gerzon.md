---
description: A library for the exploration of Michael Gerzon's algorithms
---

<!-- LICENSE: GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 -->

# gerzon.lib

```text
declare name "Michael Gerzon - Library";
declare version "0.2";
declare author "Giuseppe Silvi";
declare author "Davide Tedesco";
declare license "CC3";
```

## MICHAEL GERZON EARLY WORKS

### 1970 - SURROUND SOUND FROM 2-CHANNEL STEREO - SUM-AND-DIFFERENCE LAYOUT

> ... a method of obtaining a genuine surround stereo effect from suitable conventional two-channel stereo recordings

#### Reference

* [Surround sound from 2-channel stereo - Hi-Fi News, August 1970](https://github.com/s-e-a-m/References/blob/master/Gerzon-Michael/1970-GERZON-Surround_sound_from_2-channel_stereo_A4.pdf)
* [A year of surround-sound - Hi-Fi News, August 1971](https://github.com/s-e-a-m/References/blob/master/Gerzon-Michael/1971-GERZON-A_year_of_surround_sound_A4.pdf)

```text
        F
     •  |  •
  •     |     •
L ----- + ----- R
  •     |     •
     •  |  •
        B
```

Where the four outpust are respectively: Left - Right - Front - Back

#### Code

```text
lrfb(L,R) = L,R,F,B
  with{
    F = (1/sqrt(2))*(L+R);
    B = (1/sqrt(2))*(L-R);
};

process = lrfb;
```

### 1970 - SURROUND SOUND FROM 2-CHANNEL STEREO - IDEAL LS ARRANGEMENT

> Another, more obvious, defect of ‘sum-and-difference’ four-speaker reproduction is the highly inconvenient seating arrangements, which are hardly suitable for the cosy domestic enjoyment of music.

#### Reference

* [Surround sound from 2-channel stereo - Hi-Fi News, August 1970](https://github.com/s-e-a-m/References/blob/master/Gerzon-Michael/1970-GERZON-Surround_sound_from_2-channel_stereo_A4.pdf)
* [A year of surround-sound - Hi-Fi News, August 1971](https://github.com/s-e-a-m/References/blob/master/Gerzon-Michael/1971-GERZON-A_year_of_surround_sound_A4.pdf)

```text
 B ---------- C
 |            |
 |            |
 |            |
 |            |
 A ---------- D
```

Where the four outpust are respectively: B,C,A,D

#### Code

```text
lrsurrls(L,R) = B,C,A,D
  with{
    A = L*(0.924) - R*(0.383);
    B = L*(0.924) + R*(0.383);
    C = L*(0.383) + R*(0.924);
    D = L*(-0.383) + R*(0.924);
};

process = lrsurrls;
```

### 1971 - A YEAR OF SURROUND SOUND

> What is the precise effect of the rear spread control? With the few set-ups on which it has so far been tried, as one turns the control away from the pure ‘Hafler’ system, the sound seems to gain a subtle life and depth that the Hafler system lacks.

#### Reference

* [A year of surround-sound - Hi-Fi News, August 1971](https://github.com/s-e-a-m/References/blob/master/Gerzon-Michael/1970-GERZON-A_year_of_surround_sound_A4.pdf)

```text
 L ---------- R
 |            |
 |            |
 |            |
 |            |
 kL -------- kR
```

Where:

 * suffix rs is Rear Spread
 * k is a number between 0.5 and 1.0

#### Code

```text
lrsurrrs(L,R,k) = L,R,kL,kR
  with{
    kc = min(k,1):max(k,0.5);
    kL = (kc*L)-((1-kc)*R);
    kR = (kc*R)-((1-kc)*L);
};

process = lrsurrrs;
```

## A B MODULES

### GENERIC AB MODULE WITHOUT SHELVING

Converts a generic tetrahedral A-Format into Firts Order B-Format

#### Reference

[Ambisonics. Part two: Studio techniques Studio Sound, Vol. 17, pp 24-26, 28, 40 (August 1975)](https://www.michaelgerzonphotos.org.uk/articles/Ambisonics%202.pdf)

#### Code

```text
abmodule(LFU,RFD,RBU,LBD) = W,X,Y,Z
	with{
    W = 0.5 * (LFU + RFD + RBU + LBD);
	  X = 0.5 * (LFU + RFD - RBU - LBD);
	  Y = 0.5 * (LFU - RFD - RBU + LBD);
	  Z = 0.5 * (LFU - RFD + RBU - LBD);
};

process = abmodule;
```

### GENERIC BA MODULE WITHOUT SHELVING

Converts Firts Order B-Format into a generic tetrahedral A-Format

#### Reference

#### Code

```text
bamodule(W,X,Y,Z) = LFU,RFD,RBU,LBD
  with{
	  LFU = 0.5 * (W + X + Y + Z);
	  RFD = 0.5 * (W + X - Y - Z);
	  RBU = 0.5 * (W - X - Y + Z);
    LBD = 0.5 * (W - X - Y - Z);
};

process = bamodule;
```

## ENCODERS

### MONO TO FIRST ORDER B-FORMAT ENCODER

Encode a mono channel into Firts Order B-Format

#### Reference

1975 - Ambisonics. Part two: Studio techniques. Reproduced from Studio Sound, Vol. 17, pp 24-26, 28, 40 (August 1975)

#### Code

```text
m2bfmt(azi,elv) = bfmt
  with{
    W = *(1/sqrt(2));
    X = *cos(d2r(azi))*cos(d2r(elv));
    Y = *sin(d2r(azi))*cos(d2r(elv));
    Z = *sin(d2r(elv));
    bfmt = _ <: W,X,Y,Z;
};

process = m2bfmt(16,23);
```

### LR STEREO TO FIRST ORDER B-FORMAT ENCODER

Converts a Stereo stream into Firts Order B-Format

#### Code

```text
lr2bfmt(a) = 1/sqrt(2)*(m2bfmt(a,0)+m2bfmt(-a,0));

process = lr2bfmt(45);
```

## DECODERS

### PLANAR THREE CHANNEL B-FORMAT TO FOUR LOUDSPEAKER DECODER

Converts planar B-Format to four loudspeaker setup for horizontal studio monitoring

#### Reference

[Ambisonics. Part two: Studio techniques Studio Sound, Vol. 17, pp 24-26, 28, 40 (August 1975)](https://www.michaelgerzonphotos.org.uk/articles/Ambisonics%202.pdf)

#### Code

```text
bdmodule = shelf : bamodule
  with{
    shelf = fi.highshelf(2,1.76,350),
            fi.highshelf(2,-1.25,350),
            fi.highshelf(2,-1.25,350),
            *(0.0);
};

process = bdmodule;
```

### DECODER FOR BMX ENCODED SIGNALS

Converts C-Format Stereo BMX encoded signals to four loudspeaker setup

#### Reference

(Ambisonics. Part two: Studio techniques Studio Sound, Vol. 17, pp 24-26, 28, 40 (August 1975))[https://www.michaelgerzonphotos.org.uk/articles/Ambisonics%202.pdf]

#### Code

```text
bmxmodule(L,R) = (M+S),M,S,0 : bamodule
  with{
    M = 0.5*(L+R) : fi.lowshelf(2,-3.98,350);
    S = 0.5*(L-R) : fi.lowshelf(2,2.04,350);
};

process = bmxmodule;
```

## UHJ UTILITIES

#### Code

```text
lrS = nsum;
lrD = ndif;
j = fi.pospass(128, 35) : *(2), !;
```

## B-FORMAT TO UHJ LRTQ

Ambisonic UHJ format is a development of the Ambisonic surround sound system designed to be compatible with mono and stereo media.

#### Reference

https://en.wikipedia.org/wiki/Ambisonic_UHJ_format

#### Code

```text
bfmt2uhj(W,X,Y,Z) = L,R,T,Q
  with{
    S = 0.9396926 * W + 0.1855740 * X;
    D = j((-0.3420201 * W) + (0.5098604 * X)) + (0.6554516 * Y);
    L = 0.5 * (S + D);
    R = 0.5 * (S - D);
    T = j((-0.1432 * W + 0.6512 * X)) - (0.7071 * Y);
    Q = 0.9772 * (Z);
};

j = fi.pospass(128, 35) : *(2), !;

process = bfmt2uhj;
```

#### Code

```text
bfmt2uhj_LR = bfmt2uhj:_,_,!,!;

process = bfmt2uhj_LR;
```

### FOUR CHANNEL LRTQ UHJ TO B-FORMAT

Ambisonic UHJ format is a development of the Ambisonic surround sound system designed to be compatible with mono and stereo media.

#### Reference

1983-gerzon-ambisonic-in-multichannel-broadcasting-and-video

#### Code

```text
uhj2bfmt(L,R,T,Q) = W,X,Y,Z
  with{
    lrS = nsum;
    lrD = ndif;
    W = (0.982*lrS) + j(0.197*((0.828*lrD)+(0.768*T)));
    X = (0.419*lrS) - j(0.828*(lrD+(0.768*T)));
    Y = j(0.187*lrS) + ((0.796*lrD)-(0.676*T));
    Z = 1.023*Q;
};

j = fi.pospass(128, 35) : *(2), !;

process = bmxmodule;
```

## TOOLS

### FIRST ORDER B-FORMAT ROTATE

Rotate the Firts Order B-Format armonics set

#### Reference

#### Code

```text
brotate(W,X,Y,Z,a,e) = W1,X1,Y1,Z1
  with{
    W1 = W;
    X1 = (X*cos(a))-(Y*sin(e));
    Y1 = (Y*cos(a))-(X*sin(e));
    Z1 = Z;
};

process = brotate(16,23);
```

### THREE CHANNEL STEREO

Three channel pan-pot with low frequency phase correlation

#### Reference

[Studio Sound, June 1990](http://www.audiosignal.co.uk/Resources/Three_channels_A4.pdf)

#### Code

```text
lrcpan(x,pot) = l,r,c
  with{
    plr = (pot) + (0.5);
    l = x*((1 - (plr)) * (pot) * (-2.0));
    c = x*(cos(pot*PIq));
    r = x*((plr) * (pot) * (2.0));
};

pot = hslider("[unit:deg]", 0.0, -45.0, 45.0, 0.1) / (90.0) : si.smoo;

process = lcrpan(pot);
```
