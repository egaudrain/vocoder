% test_fft_filter

fs = 44100;
fc = [300, 400];
f  = [fc(1)/4, sqrt(prod(fc)), fc(2)*4];
n  = 4*2;

d = 300e-3;
t = (0:round(d*fs))/fs;

figure(46)
for i=1:length(f)
    x = hanngate(sin(2*pi*f(i)*t), fs, 5e-3);
    y = fft_filter(x, fs, fc, n);
    plot(t, y);
    hold on
end
hold off

