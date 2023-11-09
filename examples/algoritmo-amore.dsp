import("../seam.lib");

se = +;

amare(x,gx) = +(x*(1-gx))~*(gx);
essere_amati(y,gy) = +(y*(1-gy))~*(gy);
sentirsi_amati(z,gz) = +(z*(1-gz))~*(gz);

persona(x,gx,y,gy,z,gz) = amare(x,gx),
          essere_amati(y,gy),
          sentirsi_amati(z,gz);

process = amare, essere_amati, sentirsi_amati;
