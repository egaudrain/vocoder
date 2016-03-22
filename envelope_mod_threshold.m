function Env = envelope_mod_threshold(Env, fs, p, thr)

% Applies a threshold to the envelope. By default the threshold is 1% of
% the maximal value in the whole envelope matrix.
% 
% If a negative value is used, the threshold is taken as an absolute value.
% But remember that while the envelope is not normalized, the output is, so
% your threshold might be difficult to define properly.
%
% See also VOCODE

% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2014-02-14
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

if nargin<4
    thr = 0.01;
end

if thr>0
    thr = thr * max(Env(:));
else
    thr = abs(thr);
end

for i=1:size(Env,2)
    Env(:,i) = max(Env(:,i), thr)-thr;
end

