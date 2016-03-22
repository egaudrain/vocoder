function nz = get_lownoise(n, fs, f1, f2, random_seed)
%NZ = GET_LOWNOISE(N, FS, F1, F2, RSEED)
%   Returns N samples of low-noise-noise between F1 and F2 (in Hz).
%
%   The low-noise-noise is 1-Hz periodic, so only 1 s is actually generated
%   and the noise is then recycled with a random starting phase.
%
%   When the random seed RSEED is changed, a new noise file is created and
%   stored in the carriers/ subdirectory.

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

d = n/fs;
N = ceil(d)+1;

fname = sprintf('LNN_%d_%.1f-%.1f_%d.wav', fs, f1, f2, random_seed);
pathstr = fileparts(mfilename('fullpath'));
if ~exist(fullfile(pathstr, 'carriers'), 'dir')
    mkdir(fullfile(pathstr, 'carriers'));
end
fname = fullfile(pathstr, 'carriers', fname);

if exist(fname, 'file')
    x = wavread(fname);
else
    rng(random_seed);
    x = GenLowNoise2(1, f1, f2, fs);
    wavwrite(x, fs, fname);
end

x = repmat(x, N, 1);

rng('shuffle');

i = randi([1, floor((N-d)*fs+1)]);
nz = x(i:i+n-1);

