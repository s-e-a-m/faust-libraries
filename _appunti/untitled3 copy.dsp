import("stdfaust.lib");

ortf(x,rad) = left,right;

    x = _;
    d = 0.17;
    rad = 2;
    quad(k) = k*k;
    del = pm.l2s(delta);
    itdl = x : de.fdelay3(1024, max(del(d,rad), 0) + 1);
    itdr = x : de.fdelay3(1014, max(-del(d,rad), 0) + 1);
    delta(d,rad) = sqrt(1-(d*cos(rad))+quad(d)/4)-sqrt(1+(d*cos(rad))+quad(d)/4);
    
    left =  ((1*itdl)+(0.5*(itdl*(cos(rad))))+(0.866*(itdl*(sin(-rad)))))/2;
    right = ((1*itdr)+(0.5*(itdr*(cos(rad))))+(0.866*(itdr*(sin(rad)))))/2;

process = left;