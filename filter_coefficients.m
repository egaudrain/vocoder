function filter_struct = filter_coefficients(f, fs, filter_options)

%FILTER_STRUCT = FILTER_COEFFICIENTS(F, FS, [FILTER_OPTIONS])
%   Creates a filter structure based on cutoff (and center) frequencies F.

% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2021-01-18
% CNRS UMR5292, Lyon, FR
% KNO, University Medical Center Groningen, NL
%-----------------------------
% 2021-01-26: Added the possibility to use second order sections instead of
%   [B,A] coefficient forms.
%-----------------------------


%---------
% This file is part of
% vocoder: a versatile Matlab vocoder for research purposes
% Copyright (C) 2021 Etienne Gaudrain
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

if size(f,1)~=3
    error('vocode:filter_freq_mismatch', 'The matrix defining the filter cutoffs and centers must be 3 x nChannels (%d x %d given)', size(f,1), size(f,2));
end

nChannels = size(f,2);

lowerl = f(1,:);
center = f(2,:);
upperl = f(3,:);

if isnumeric(filter_options)
    filter_options = {'butter', filter_options, 'sos'};
end
filter_type = filter_options{1};
order = filter_options{2};
if length(filter_options)<3
    switch filter_type
        case 'bingabr_2008'
            coef_type = 'ba';
        otherwise
            coef_type = 'sos';
    end
else
    coef_type = filter_options{3};
end


FS=fs/2;
%nOrd=order*2;

if fs/2<max(upperl)
    error('vocode:fs_too_low', 'The sampling rate %d is too low for the upper frequency %d', fs, max(upperl));
end

% Handle filter type
switch filter_type
    case 'butter'
        switch coef_type
            case 'ba'
                filter_func = @butter;
            case 'sos'
                filter_func = @butter_sos;
        end       
    case 'bingabr_2008'
        filter_func = @(n,w) filter_bingabr_2008(n,w,fs);
        if ~strcmp(coef_type, 'ba')
            warning('coef_type will be "ba" for filters "bingabr_2008". We fixed it for this time.');
            coef_type = 'ba';
        end
    otherwise
        if isa(filter_type, 'function_handle')
            filter_func = @(n,w) filter_type(n,w,fs);
        else
            error('Filter type "%s" is unknown.', filter_type);
        end
end

%filterA=zeros(nChannels,nOrd+1);
%filterB=zeros(nChannels,nOrd+1);

switch coef_type
    case 'ba'
        filterA = cell(nChannels,1);
        filterB = cell(nChannels,1);
    case 'sos'
        filterSOS = cell(nChannels,1);
        filterG = cell(nChannels,1);
end

for i=1:nChannels
    w=[lowerl(i)/FS, upperl(i)/FS];
    
    % Butter is a special case because we can get orders in half
    if ischar(filter_type) && strcmp(filter_type, 'butter') && mod(order,1)~=0
        if mod(order,1)==.5 % We have half filters => use low/high pass
            switch coef_type
                case 'ba'
                    [b1,a1] = butter(order*2, w(1), 'high');
                    [b2,a2] = butter(order*2, w(2), 'low');
                    b = {b1, b2};
                    a = {a1, a2};
                case 'sos'
                    [z1,p1,k1] = butter(order*2, w(1), 'high');
                    [z2,p2,k2] = butter(order*2, w(2), 'low');
                    [sos1,g1] = zp2sos(z1,p1,k1);
                    [sos2,g2] = zp2sos(z2,p2,k2);
                    sos = {sos1, sos2};
                    g = {g1, g2};
            end
        else
            error('2*ORDER has to be an integer (provided ORDER=%f).', order);
        end
    else
        switch coef_type
            case 'ba'
                [b, a] = filter_func(order, w);
            case 'sos'
                [sos, g] = filter_func(order, w);
        end
    end
    switch coef_type
        case 'ba'
            filterB{i} = b;
            filterA{i} = a;
        case 'sos'
            filterSOS{i} = sos;
            filterG{i} = g;
    end
end

filter_struct = struct();
filter_struct.coef_type = coef_type;
switch coef_type
    case 'ba'
        filter_struct.filterA = filterA;
        filter_struct.filterB = filterB;
    case 'sos'
        filter_struct.filterSOS = filterSOS;
        filter_struct.filterG = filterG;
end
filter_struct.center  = center;
filter_struct.lower   = lowerl;
filter_struct.upper   = upperl;
filter_struct.fs      = fs;
filter_struct.type    = 'custom';
filter_struct.order   = repmat(order, 1, nChannels);
filter_struct.filter_type = filter_type;


function [sos, g] = butter_sos(n, w)

[z,p,k] = butter(n, w);
[sos, g] = zp2sos(z,p,k);
