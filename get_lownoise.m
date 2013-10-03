function nz = get_lownoise(n, fs, f1, f2, random_seed)
%NZ = GET_LOWNOISE(N, FS, F1, F2, RSEED)
%   Returns N samples of low-noise-noise between F1 and F2 (in Hz).
%
%   The low-noise-noise is 1-Hz periodic, so only 1 s is actually generated
%   and the noise is then recycled with a random starting phase.
%
%   When the random seed RSEED is changed, a new noise file is created and
%   stored in the carriers/ subdirectory.

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-09-11
% University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2013
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

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

