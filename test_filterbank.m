
fs = 44100;
ft = estfilt_shift([], 'hr90k', fs, [], 2);

for j=1:length(ft.filterA)
    [h, f] = freqz(ft.filterB{j}, ft.filterA{j}, fs, fs);
    
    plot(f, 20*log10(abs(h)));
    hold on
end

set(gca, 'XScale', 'log');
xlim([150, 12000])
ylim([-60, 10])
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
hold off