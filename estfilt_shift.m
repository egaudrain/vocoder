function filter_struct = estfilt_shift(nChannels,type,fs,range,filter_options)

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

%------------
% Cutoffs from actual devices
freq_maps.ci24 = [188,313,438,563,688,813,938,1063,1188,1313,1563,1813,2063,2313,2688,3063,3563,4063,4688,5313,6063,6938,7938];
freq_maps.hr90k = [250,416,494,587,697,828,983,1168,1387,1648,1958,2326,2762,3281,3898,4630,8700];

%------------

if isnumeric(filter_options)
    filter_options = {'butter', filter_options};
end
filter_type = filter_options{1};
order = filter_options{2};    


FS=fs/2;
nOrd=order*2;

switch type
    % ------------------ greenwood spacing of filters ---------------------
    case 'greenwood'
        
        LowFreq = range(1);
        UpperFreq = range(2);
        
        [lowerl,center,upperl]=greenwud(nChannels,LowFreq,UpperFreq,0);        
        
    % ------------------ linear filter spacing  -------------------------
    case {'lin', 'linear'}
        
        LowFreq = range(1);
        UpperFreq = range(2);
        
        bf = linspace(LowFreq, UpperFred, nChannels+1);
        lowerl = bf(1:end-1);
        upperl = bf(2:end);
        center = (lowerl+upperl)/2;        
        
    % ------------------ logarithmic filter spacing  ----------------------
    case 'log'
        
        LowFreq = range(1);
        UpperFreq = range(2);
        
        bf = 10.^linspace(log(LowFreq), log(UpperFred), nChannels+1);
        lowerl = bf(1:end-1);
        upperl = bf(2:end);
        center = sqrt(lowerl.*upperl);
 
    case {'ci24', 'hr90k'}
        
        bf = freq_maps.(type);
        lowerl = bf(1:end-1);
        upperl = bf(2:end);
        center = sqrt(lowerl.*upperl);
        nChannels = length(center);
        
    %------------------- TODO: Could add ERB here.
        
    otherwise
        error('TYPE must be ''log'', ''greenwood'', ''linear'', ''ci24'' or ''hr90k''.');
        
end
% ----------------------

if fs/2<max(upperl)
    error('vocode:fs_too_low', 'The sampling rate %d is too low for the upper frequency %d', fs, max(upperl));
end

% Handle filter type
switch filter_type
    case 'butter'
        filter_func = @butter;
    case 'bingabr_2008'
        filter_func = @(n,w) filter_bingabr_2008(n,w,fs);
end

%filterA=zeros(nChannels,nOrd+1);
%filterB=zeros(nChannels,nOrd+1);

filterA = cell(nChannels,1);
filterB = cell(nChannels,1);

for i=1:nChannels
    w=[lowerl(i)/FS, upperl(i)/FS];
    
    % Butter is a special case because we can get orders in half
    if strcmp(filter_type, 'butter') && mod(order,1)~=0
        if mod(order,1)==.5 % We have half filters => use low/high pass 
            [b1,a1] = butter(order*2, w(1), 'high');
            [b2,a2] = butter(order*2, w(2), 'low');
            b = {b1, b2};
            a = {a1, a2};
        else
            error('2*ORDER has to be an integer (provided ORDER=%f).', order);
        end
    else
        [b, a] = filter_func(order, w);
    end
    filterB{i} = b;
    filterA{i} = a;
end


filter_struct.filterA = filterA;
filter_struct.filterB = filterB;
filter_struct.center  = center;
filter_struct.lower   = lowerl;
filter_struct.upper   = upperl;
filter_struct.fs      = fs;
filter_struct.type    = type;
filter_struct.order   = repmat(order, 1, nChannels);
filter_struct.filter_type = filter_type;

