function [b, a] = filter_bingabr_2008(s, w, fs)

%[B, A] = FILTER_BINGABR_2008(S, W)
%   Returns filter coefficients for a filter simulating current spread of a
%   slope S in band W. Note that the band cutoffs are only used to
%   calculate the center frequency. W is provided in normalized frequency.

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2014-02-13
% University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2014
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

fc = w*fs/2;
cp = mean(frq2mm(fc));

s = abs(s); % In dB/mm
lambda = (20*log10(exp(1)))/s; % In the exponential

p = linspace(frq2mm(0), frq2mm(fs/2), 2048*2); % Place along the cochlea
I = exp(-abs(p-cp)/lambda); % Current spread

% Based on power law, acoustic loudness is proportional to
% ~ (Pa^2)^0.25
% Electrical loudness is proportional to I^2.23 (I in mA)
% 2.23 comes from Cohen, 2009, Hear. Res. 247:87-99
% doi:10.1016/j.heares.2008.11.003

Pa = I.^(2*2.23);
Pa = Pa/max(Pa);

f = mm2frq(p);

% plot(f, 20*log10(Pa), '-b')

n = 1024;
b = fir2(n, f*2/fs, Pa, blackmanharris(n+1));
a = 1;

% [h,w] = freqz(b,a,2048*8);
% hold on
% plot(w/pi*fs/2, 20*log10(abs(h)), '-r')
% hold off
