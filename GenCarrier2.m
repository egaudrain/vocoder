function [array_final,time_final]=GenCarrier2(f0, hmin, hmax, fs, duration, phases, scalenew, factor)
%[array,time]=GenCarrier2(f0, hmin, hmax, fs, duration, phases, scalenew, factor)
%
%Generates a harmonic complex with consecutive harmonic number hmin to hmax
%and also choice of phases. Shaped by digital 8th order Butterworth.
%
%input:
%       f0 = fundamental frequency (Hz)
%     hmin = minimum harmonic number
%     hmax = maximum harmonic number
%       fs = sampling frequency (Hz)
% duration = duration in seconds
%   phases =
%       0, 'sin', 'sine'              => sin phase
%       1, 'cos', 'cosine'            => cos phase
%       2, 'alt'                      => alternating, odd: cos, even: sin
%       3, 'rand', 'random'           => random
%       4, 'rep', 'expanding'         => rate expanding phase
%       5, 'sch', 'sch+', 'schroeder' => positive Schroeder
%       6, 'sch-', 'schroeder-'       => negative Schroeder
% scalenew = scaling
%   factor = only used for rate-expanding phase. Gives an effective rate
%            equal to F0 * factor^2
%
%output:
%    array (values)
%    time (in seconds)

% Copyright LMA CNRS, Olivier Macherey, 2013 / UMCG, Etienne Gaudrain, 2013
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

%modified from HARMCOMP to input (software) filter cutoffs & slopes
%based on Bob Carlyon's Fortran harmcomp3.for
%dragged into 21st century by CJL (Fri, May 17 2002, 14:20:28 ; 137/366)
%then modified by Bob to output real array with values between -1.0 and +1.0
%th eresulting HRMCOMPREAL modified here to HRMCOMPDIG to do all filtering 
%digitally

% modified from hrmcompdig_filttimes.m to start the stimulus in between 2 periods (so that every pulses
% are identical).

% Modified on 23/11/2011 by Olivier Macherey to allow custom phase
% relationships that expand the rate.

% Modified on 09/09/2013 by Etienne Gaudrain to change argument handling,
% phase generation (outside the loop), ...

%rand('state',sum(100*clock)) %set random number state in case we use random phases
% tic
global clip
clip=0;
%global itrace;
%itrace=0;

halfpi=pi*0.5;
%rlog2=log(2.0); %could be done more directly using log2

halfperiod_samples=round(fs/f0/4);
% add half a pulse train period at the beginning and at the end of the pulse train
nopts=round(duration*fs)+2*halfperiod_samples; %*[ ] round equiv to fortran's nint?

temparray=zeros(nopts,1);
%value=temparay;
%array=temparay;

n=1:nopts;
time=(n./fs)';

% = 0 => sine
% = 1 => cos
% = 2 => ALT: odd=cos even=sin
% = 3 => random
% = 4 => rate expanding phase
% = 5 => schroeder

hn = hmin:hmax;
freq = f0*hn;

switch phases
    case {0, 'sine', 'sin'}
        phase = zeros(size(freq));

    case {1, 'cos', 'cosine'}
        phase = ones(size(freq))*halfpi;

    case {2, 'alt'}
        phase = ones(size(freq))*halfpi;
        phase(mod((hmin:hmax),2)==0) = 0;

    case {3, 'rand', 'random'}
        phase=rand(size(freq))*2*pi;

    case {4, 'expanding', 'rep'}
        
        if nargin<8
            error('FACTOR must be provided for rate-expanding phase');
        end
        
        u=randperm(factor)-1;
        v=rand(1,factor);
        
        phase = zeros(size(freq));
        for j = 0:1:factor-1
            s = mod((hn+j)/factor,1)==0;
            phase(s) = 2*u(j+1)*pi*hn(s)/factor^2+v(j+1)*2*pi;
        end

    case {5, 'schroeder', 'sch+', 'sch'}
        phase=pi*hn.*(hn+1)/round(((hmax-hmin)/f0)+1);
    
    case {5, 'schroeder-', 'sch-'}
        phase=-pi*hn.*(hn+1)/round(((hmax-hmin)/f0)+1);

    otherwise
        error('Invalid value for PHASES');
end

for i=1:length(hn)
    temparray = temparray + sin((2.*pi*time*freq(i))+phase(i));
end

numcomps=hmax-hmin+1;
scale=scalenew./numcomps;
array=temparray*scale;

if(any(abs(array)>1.0))
    warning('Clipping!');
    clip=1;
    return;  %*[ ] equiv performance in matlab and fortran?
end

%now apply "filtorder"  order Butterworth filter. 

%Now do it in 2 stages - lowpass then highpass
% Wn=[cutlo]/(0.5*fs);
% [b,a]=butter(8,Wn,'high');
% array=filter(b,a,array);
% Wn=[cuthi]/(0.5*fs);
% [b,a]=butter(8,Wn);
% array=filter(b,a,array);

%fvtool(b,a);

% Extract the desired duration of the pulse by removing half a period at
% the beginning and half a period at the end
nopts_final=1:round(duration*fs);
%nosamples=length(nopts_final);
time_final=nopts_final./fs;

%array_final(1:length(time_final))=array(halfperiod_samples+1:1:length(array)-halfperiod_samples);
array_final = array(halfperiod_samples+1:1:end-halfperiod_samples);

% toc