function [lower,center,upper]= greenwud(N, low, high, dbg)
% [lower,center,upper] = greenwud(N,low,high)
%
% This function returns the lower, center and upper freqs
% of the filters equally spaced according to Greenwood's equation
% Input: N - number of filters
% 	 low - (left-edge) 3dB frequency of the first filter
%	 high - (right-edge) 3dB frequency of the last filter

% Adapted from Stuart Rosen -- June 1998

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


% Set up equally spaced places on the basilar membrane
places = [0:N]*(frq2mm(high)-frq2mm(low))/N + frq2mm(low);
% Also calculate centre frequencies according to the same mapping
centres = zeros(1,N);
centres = (places(1:N) + places(2:N+1))/2;
% convert these back to frequencies
freqs = mm2frq(places);
center = mm2frq(centres);

if dbg==1
	 f=low:100:high;
	 plot(f, frq2mm(f));
	 grid
	 hold on 
 end

 lower=zeros(1,N); upper=zeros(1,N); 
 lower(1:N)=freqs(1:N);
 upper(1:N)=freqs(2:N+1);

  if dbg==1,  
   plot(center,ones(1,N),'ro');

 end;
