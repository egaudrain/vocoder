function filter_struct = estfilt_shift(nChannels,type,Srate,range,order)

%  ESTFILT_SHIFT - This function returns the filter coefficients for a
%	filter bank for a given number of channels
%	and with a variety of filter spacings. Also returns
%	the filter centre frequencies.

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-09-11
% University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2013
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

LowFreq = range(1);
UpperFreq = range(2);

if Srate/2<UpperFreq
    error('vocode:fs_too_low', 'The sampling rate %d is too low for the upper frequency %d', Srate, UpperFreq);
end

switch type
    % ------------------ greenwood spacing of filters ---------------------
    case 'greenwood'
        
        FS=Srate/2;
        nOrd=order*2;
        [lowerl,center,upperl]=greenwud(nChannels,LowFreq,UpperFreq,0);
                
        
    % ------------------ linear filter spacing  -------------------------
    case {'lin', 'linear'}
        
        FS=Srate/2;
        
        nOrd=6;
        range=(UpperFreq-LowFreq);
        interval=range/nChannels;
        
        center=zeros(1,nChannels);
        
        for i=1:nChannels  % ----- Figure out the center frequencies for all channels
            upperl(i)=LowFreq + (interval*i);
            lowerl(i)=LowFreq + (interval*(i-1));
            center(i)=0.5*(upperl(i)+lowerl(i));
        end
        %lowerl
        %center
        %upperl
        
        
    % ------------------ logarithmic filter spacing  ----------------------
    case 'log'
        
        FS=Srate/2;
        
        nOrd=6;
        range=log10(UpperFreq/LowFreq);
        interval=range/nChannels;
        
        center=zeros(1,nChannels);
        
        for i=1:nChannels  % ----- Figure out the center frequencies for all channels
            upperl(i)=LowFreq*10^(interval*i);
            lowerl(i)=LowFreq*10^(interval*(i-1));
            center(i)=0.5*(upperl(i)+lowerl(i));
        end
        
 
        
    %------------------- Could add ERB here.
        
    otherwise
        error('Filters must be log, greenwood or linear');
        
end
% ----------------------

filterA=zeros(nChannels,nOrd+1);
filterB=zeros(nChannels,nOrd+1);

for i=1:nChannels
    W1=[lowerl(i)/FS, upperl(i)/FS];
    [b,a]=butter(order,W1);
    filterB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
    filterA(i,1:nOrd+1)=a;   %----->  Save the coefficients 'a'
end


filter_struct.filterA = filterA;
filter_struct.filterB = filterB;
filter_struct.center  = center;
filter_struct.lower   = lowerl;
filter_struct.upper   = upperl;
filter_struct.fs      = Srate;
filter_struct.type    = type;
filter_struct.order   = repmat(order, 1, nChannels);
