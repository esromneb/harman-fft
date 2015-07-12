
more off;

fs = 96E3;
y = ramp(1, 70, 17E3);
wavwrite(y,fs,'file3.wav')

y = ramp(5, 0, 200);
y = y';
y = [zeros(fs,1);y];
wavwrite(y,fs,'slow-long.wav');


t20 = tone(15,20);
t20 = [zeros(fs,1);t20'];
wavwrite(t20,fs,'20hz.wav');

t15 = tone(15,15);
t15 = [zeros(fs,1);t15'];
wavwrite(t20,fs,'15hz.wav');




y = ramp(15, 10, 600);
y = y';
y = y .* 1000;
y = [zeros(fs,1);y];
y = min(max(y,-1),1);

wavwrite(y,fs,'10-600-square.wav');



y = ramp(15, 12, 80);
y = y';
y = [y; y(end:-1:1); y; y(end:-1:1); y; y(end:-1:1); y; y(end:-1:1);]; 

%plot(y(1:3E4));

wavwrite(y,fs,'12-80-repeat-sin.wav');

y = y .* 1000;
y = min(max(y,-1),1);
wavwrite(y,fs,'12-80-repeat-square.wav');