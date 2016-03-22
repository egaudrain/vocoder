function nz = get_pshc(n, fs, f1, f2, f0, random_seed)
%NZ = get_pshc(N, FS, F1, F2, F0 RSEED)
%   Returns N samples of PSHC between F1 and F2 (in Hz).
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
N = ceil(d*f0)+1;

fname = sprintf('PSHC_%d_%.1f_%.1f-%.1f_%d.wav', fs, f0, f1, f2, random_seed);
pathstr = fileparts(mfilename('fullpath'));
if ~exist(fullfile(pathstr, 'carriers'), 'dir')
    mkdir(fullfile(pathstr, 'carriers'));
end
fname = fullfile(pathstr, 'carriers', fname);

if exist(fname, 'file')
    x = wavread(fname);
else
    rng(random_seed);
    
    x = GenCarrier2(f0, round(f1/f0), round(f2/f0), fs, 1/f0, 'pshc', 1, GenCarrier2_PSHC_Order(sqrt(f1*f2), f0));
    
    x = .9 * x / max(abs(x));
    
    wavwrite(x, fs, fname);
end

x = repmat(x, N, 1);

rng('shuffle');

i = randi([1, floor((N/f0-d)*fs+1)]);
nz = x(i:i+n-1);

%--------------------------------------------------------------------------
function f = GenCarrier2_PSHC_Order(fc, f0)

% Polyfit 3rd order on
% Freqs  = [ 250, 500, 1000, 2000, 4000, 6000, 8000];
% ExRate = [   9,  10,   14,   18,   25,   30,   35];

%p = [0.0000   -0.0000    0.0069    7.2244];
p = [0.0459   -0.7964    6.9097    7.2244];

f = round(polyval(p, fc/1000)/sqrt(f0));
