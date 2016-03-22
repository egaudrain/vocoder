function [b, a] = filter_bingabr_2008(s, w, fs)

%[B, A] = FILTER_BINGABR_2008(S, W)
%   Returns filter coefficients for a filter simulating current spread of a
%   slope S in band W. Note that the band cutoffs are only used to
%   calculate the center frequency. W is provided in normalized frequency.

% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2014-02-13
% CNRS UMR5292, Lyon, FR
% KNO, University Medical Center Groningen, NL

%---------
% This file is part of
% vocoder: a versatile Matlab vocoder for research purposes
% Copyright (C) 2016 Etienne Gaudrain
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%---------
% See README.md for rules on citations.
%---------

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
