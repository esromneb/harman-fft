function y = ramp (len,f)

more off;

#disp('starting');


fs = 96E3;
srate = 1/fs;

A = 1;
#f = 20;

t = 0:srate:len;


y = A*sin(2*pi*f*t);
#plot(y)
