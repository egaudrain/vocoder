
fs = 44100;
[b1, a1] = butter(3, [200, 300]*2/fs);
[b2, a2] = butter(3, [200, 800]*2/fs);
[b3, a3] = butter(2, [200, 300]*2/fs);

[h1, f1] = freqz(b1, a1, fs, fs);
    
plot(f1, 20*log10(abs(h1))*2);
hold on

[h2, f2] = freqz(b2, a2, fs, fs);
plot(f2, 20*log10(abs(h2))*2);

% [h3, f3] = freqz(b3, a3, fs, fs);
% plot(f3, 20*log10(abs(h3))*2);

[b4, a4] = butter(6, 200*2/fs, 'high');
[b5, a5] = butter(6, 800*2/fs, 'low');

[b6, a6] = butter(6, 300*2/fs, 'low');

[h4, f4] = freqz(b4, a4, fs, fs);
plot(f4, 20*log10(abs(h4))*2);
[h5, f5] = freqz(b5, a5, fs, fs);
plot(f5, 20*log10(abs(h5))*2);

[h6, f6] = freqz(b6, a6, fs, fs);
plot(f6, 20*log10(abs(h6))*2);

set(gca, 'XScale', 'log');
xlim([200/4, 800*4])
ylim([-100, 10])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
hold off