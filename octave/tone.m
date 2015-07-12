function y = tone (len,f)

more off;

fs = 96E3;
srate = 1/fs;

A = 1;
#f = 20;

t = 0:srate:len;


y = A*sin(2*pi*f*t);
#plot(y)
