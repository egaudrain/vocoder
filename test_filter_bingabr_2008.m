
fs = 44100;
s = 2.8;

w = [1000, 2000]*2/fs;

[b, a] = filter_bingabr_2008(s, w, fs);

[h,w] = freqz(b,a,2048*8);
plot(log2(w/pi*fs/2), 20*log10(abs(h)), '-r')

diff(interp1(log2(w(w>0)/pi*fs/2), 20*log10(abs(h(w>0))), log2(1300)+[-2 0]))/2

ylim([-200, 0])

