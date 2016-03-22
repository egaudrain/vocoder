function frq = mm2frq(mm)
% FRQ = MM2FRQ(MM)
% 	Applies Greenwood's function for mapping place to frequency.
%   
%   See Greenwood D.D. (1990) JASA 87, 6:2592-2605. doi:10.1121/1.399052.
%
%   See also FRQ2MM.

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

a= .06; % appropriate for measuring basilar membrane length in mm
k= 165.4;

frq = 165.4 * (10.^(a * mm)- 1);




