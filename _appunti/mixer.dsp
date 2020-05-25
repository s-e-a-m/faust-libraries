import("stdfaust.lib");
noise = no.pink_noise;
sine = os.osc (440);
saw = os.lf_saw (1092);

revpol = checkbox("[01] revpol")*(-2)+(1);

pot = vslider ("[02] panpot[style:knob]",0.5,0,1,0.01) : si.smoo;

pan = _ <: _*(1-pot),_*(pot);
panq = _ <: _*sqrt(1-pot), _ *sqrt(pot);//commento
pansemiq = _<:_*((( 1-pot ) + sqrt(1-pot))/(2)) , _*(((pot) + sqrt(pot))/(2));
itdpan = _<:de.fdelay3(64,max(del(radius,eardistance,alpha),0)+1),de.fdelay3(64,max(-del(radius,eardistance,alpha),0)+1)
with{
eardistance = nentry("ears distance[unit:cm]", 17, 15, 20, 0.1)/100; // metri
radius = nentry("radius[unit:cm]", 100, 50, 500, 1)/100; 
alpha = vslider("angle[unit:deg][style:knob]", 90, 0, 180, 0.1)*ma.PI/180;
quad(x) = x*x;
delta(radius,eardistance,alpha) = sqrt(quad(radius) - eardistance * radius *cos(alpha) + quad(eardistance)/4) -
                                  sqrt(quad(radius) + eardistance * radius *cos(alpha) + quad(eardistance)/4) ;
del(radius,eardistance,alpha) = delta(radius,eardistance,alpha)/344 * ma.SR;                                   
};

fader = vslider("[03]volume",0,0,1,0.01) : si.smoo;//si.smoo intepolatore
channel(n) = vgroup("ch %n", *(revpol) : pan : *(fader),*(fader));
process = noise, sine, saw : hgroup("mixer", channel(1), channel(2), channel(3)) :> _,_;
//compiti: fare in modo che itdpan riceva i valori da panpot al posto di alpha, fare tasto mute,
//TO DO LIST: Meter, Master, selettore di PAN