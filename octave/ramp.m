function data = ramp (lenS)

  more off;

freq1=20;
freq2=20E3;
fs=96E3;
t=1/fs:1/fs:lenS; %
f=freq1:(freq2-freq1)/length(t):freq2-(freq2-freq1)/length(t); 

data=sin(2*pi*f.*t);

end
