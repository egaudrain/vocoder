function x = hanngate(x, fs, t)
%X = HANNGATE(X, FS, T)
%   Applies Hann ramping of T seconds to X.

% Copyright UMCG, Etienne Gaudrain, 2013
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

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