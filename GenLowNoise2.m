function [out, noise] = GenLowNoise2(t, flo, fhi, fs)
%out = GenLowNoise(t, flo, fhi, fs)
% generates low-noise noise that repeats itself after 1 second
%
% input:
%   t     = duration of signal (s)
%   flo   = lowest frequency component (Hz)
%   fhi   = highest frequency component (Hz)
%   fs    = sampling rate (Hz)
%
% output:
%   lownoise noise

% Provided by Gaston Hilkhuysen <hilkhuysen@lma.cnrs-mrs.fr>, 2013-09-10

%---------
% This file is part of
% vocoder: a versatile Matlab vocoder for research purposes
% Copyright (C) 2013 LMA CNRS, Olivier Macherey / CRNL CNRS, UMCG, Etienne Gaudrain
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


f0       = 1;    % frequency spacing of noise
hmin     = flo;  
hmax     = fhi;
scalenew = 1;

array_final = GenCarrier2(f0,                  ...
                         hmin,                ...
                         hmax,                ...
                         fs,            ...
                         t,            ...
                         'rand',              ...
                         scalenew);

noise = array_final;
                     
array_final = 0.99*array_final./max(abs(array_final)); % stay within -0.99..0.99 range
% crest_array = max(abs(array_final))/sqrt(mean(array_final.^2));
rms_init    = sqrt(mean(array_final.^2));              % inital level

T    = 1/fs;                % Sample time
L    = round(t*fs);         % Length of signal
t    = (0:L-1)*T;                 % Time vector
NFFT = 2^nextpow2(L);             % Next power of 2 from length of y

% X   = fft(array,NFFT)/L;          % normalize by length
f = fs/2*linspace(0,1,NFFT/2+1); % freq bins
f = [f, f(end:-1:2)];
% AMP = 2*abs(X(1:NFFT/2+1));       % amplitude and compensate mirror

% plot(f,10*log10(AMP.^2/L),'b');   % RMS (two times length normalization?)

array = zeros(NFFT,1);

for i=1:10

    array_final = array_final ./abs(hilbert(array_final)); % flatten envelope
    array_final = array_final *            ...             % compensate energy shift          
                  rms_init ./              ...
                  sqrt(mean(array_final.^2)); 

    array(1:(NFFT-L)/2)           = 0;   % trial and tail with zeros
    array((NFFT-L)/2+1:(NFFT+L)/2)= array_final(:);
    array((NFFT+L)/2+1:NFFT)      = 0;

    X   = fft(array,NFFT)/L;
    % f   = sampfreq/2*linspace(0,1,NFFT/2+1);
    % AMP = 2*abs(X(1:NFFT/2+1));

    %{
    for i=1:length(f),                 % band pass spectrum
        if f (i) < hmin,
            X(i) = 0;
            X(NFFT-i+1)=0;
        elseif f (i) > hmax,
            X(i) = 0;
            X(NFFT-i+1)=0;    
        end
    end
    %}
    
    X((f<hmin) | (f>hmax)) = 0;

    % AMP = 2*abs(X(1:NFFT/2+1));        % amplitudes

    array            = ifft(X,NFFT,'symmetric');        % back to time domain
    array_final(1:L) = array((NFFT-L)/2+1:(NFFT+L)/2);  % signal part
    array_final      = array_final * rms_init     ./ ...
                       sqrt(mean(array_final.^2));      % compensate energy loss
    % crest_array = max(abs(array_final))/sqrt(mean(array_final.*array_final));

end

out            = array_final;
% array(1:(NFFT-L)/2)=0;
% array((NFFT-L)/2+1:(NFFT+L)/2)=array_final(:);
% array((NFFT+L)/2+1:NFFT)=0;
% 
% X = fft(array,NFFT)/L;
% f = sampfreq/2*linspace(0,1,NFFT/2+1);
% AMP = 2*abs(X(1:NFFT/2+1));

