
more off;

fs = 96E3;
y = ramp(1, 70, 17E3);
wavwrite(y,fs,'file3.wav')

y = ramp(5, 0, 200);
y = y';
y = [zeros(fs,1);y];
wavwrite(y,fs,'slow-long.wav');


t20 = tone(5,20);
t20 = [zeros(fs,1);t20'];
wavwrite(t20,fs,'20hz.wav');

t15 = tone(5,15);
t15 = [zeros(fs,1);t15'];
wavwrite(t20,fs,'15hz.wav');
