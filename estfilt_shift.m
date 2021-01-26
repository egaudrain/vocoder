function filter_struct = estfilt_shift(nChannels,type,fs,range,filter_options)

%  ESTFILT_SHIFT - This function returns the filter coefficients for a
%	filter bank for a given number of channels
%	and with a variety of filter spacings. Also returns
%	the filter centre frequencies.

% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2013-09-11
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

%------------
% Cutoffs from actual devices
freq_maps.ci24 = [188,313,438,563,688,813,938,1063,1188,1313,1563,1813,2063,2313,2688,3063,3563,4063,4688,5313,6063,6938,7938];
freq_maps.hr90k = [250,416,494,587,697,828,983,1168,1387,1648,1958,2326,2762,3281,3898,4630,8700];

%------------

% if isnumeric(filter_options)
%     filter_options = {'butter', filter_options};
% end
% filter_type = filter_options{1};
% order = filter_options{2};    


% FS=fs/2;
% nOrd=order*2;

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
        
        bf = linspace(LowFreq, UpperFreq, nChannels+1);
        lowerl = bf(1:end-1);
        upperl = bf(2:end);
        center = (lowerl+upperl)/2;        
        
    % ------------------ logarithmic filter spacing  ----------------------
    case 'log'
        
        LowFreq = range(1);
        UpperFreq = range(2);
        
        bf = exp(linspace(log(LowFreq), log(UpperFreq), nChannels+1));
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

filter_struct = filter_coefficients([lowerl; center; upperl], fs, filter_options);
filter_struct.type = type;

% if fs/2<max(upperl)
%     error('vocode:fs_too_low', 'The sampling rate %d is too low for the upper frequency %d', fs, max(upperl));
% end
% 
% % Handle filter type
% switch filter_type
%     case 'butter'
%         filter_func = @butter;
%     case 'bingabr_2008'
%         filter_func = @(n,w) filter_bingabr_2008(n,w,fs);
%     otherwise
%         if isa(filter_type, 'function_handle')
%             filter_func = @(n,w) filter_type(n,w,fs);
%         else
%             error('Filter type "%s" is unknown.', filter_type);
%         end
% end
% 
% %filterA=zeros(nChannels,nOrd+1);
% %filterB=zeros(nChannels,nOrd+1);
% 
% filterA = cell(nChannels,1);
% filterB = cell(nChannels,1);
% 
% for i=1:nChannels
%     w=[lowerl(i)/FS, upperl(i)/FS];
%     
%     % Butter is a special case because we can get orders in half
%     if ischar(filter_type) && strcmp(filter_type, 'butter') && mod(order,1)~=0
%         if mod(order,1)==.5 % We have half filters => use low/high pass 
%             [b1,a1] = butter(order*2, w(1), 'high');
%             [b2,a2] = butter(order*2, w(2), 'low');
%             b = {b1, b2};
%             a = {a1, a2};
%         else
%             error('2*ORDER has to be an integer (provided ORDER=%f).', order);
%         end
%     else
%         [b, a] = filter_func(order, w);
%     end
%     filterB{i} = b;
%     filterA{i} = a;
% end
% 
% 
% filter_struct.filterA = filterA;
% filter_struct.filterB = filterB;
% filter_struct.center  = center;
% filter_struct.lower   = lowerl;
% filter_struct.upper   = upperl;
% filter_struct.fs      = fs;
% filter_struct.type    = type;
% filter_struct.order   = repmat(order, 1, nChannels);
% filter_struct.filter_type = filter_type;

