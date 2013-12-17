function nz = get_pshc(n, fs, f1, f2, f0, random_seed)
%NZ = get_pshc(N, FS, F1, F2, F0 RSEED)
%   Returns N samples of PSHC between F1 and F2 (in Hz).
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
    
    x = GenCarrier2(f0, round(f1/f0), round(f2/f0), fs, 1/f0, 'rep', 1, GenCarrier2_factor(sqrt(f1*f2), f0));
    
    x = .9 * x / max(abs(x));
    
    wavwrite(x, fs, fname);
end

x = repmat(x, N, 1);

rng('shuffle');

i = randi([1, floor((N/f0-d)*fs+1)]);
nz = x(i:i+n-1);

%--------------------------------------------------------------------------
function f = GenCarrier2_factor(fc, f0)

% Polyfit 3rd order on
% Freqs  = [ 250, 500, 1000, 2000, 4000, 6000, 8000];
% ExRate = [   9,  10,   14,   18,   25,   30,   35];

p = [0.0000   -0.0000    0.0069    7.2244];

f = round(polyval(p, fc)/sqrt(f0));
