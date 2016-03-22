function x = hanngate(x, fs, t)
%X = HANNGATE(X, FS, T)
%   Applies Hann ramping of T seconds to X.

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

if length(t)==1
    t = [t, t];
end

w = hann(floor(2*t(1)*fs));
w = w(1:floor(end/2));

if size(x, 1) == 1
    w = w';
end

x(1:length(w)) = w .* x(1:length(w));


w = hann(floor(2*t(2)*fs));
w = w(ceil(end/2):end);

if size(x, 1) == 1
    w = w';
end

x(end-length(w)+1:end) = w .* x(end-length(w)+1:end);