function data = ramp (lenS, freq1, freq2)


#freq1=10;
#freq2=100;
fs=96E3;
t=1/fs:1/fs:lenS; %
f=freq1:(freq2-freq1)/length(t):freq2-(freq2-freq1)/length(t); 

data=sin(2*pi*f.*t);

end
