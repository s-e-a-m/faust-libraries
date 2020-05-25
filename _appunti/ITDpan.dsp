import("stdfaust.lib");
//      sorgente <:orecchiosx,orecchiodx
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



process = itdpan;