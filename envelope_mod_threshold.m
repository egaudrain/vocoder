function Env = envelope_mod_threshold(Env, fs, p, thr)

% Applies a threshold to the envelope. By default the threshold is 1% of
% the maximal value in the whole envelope matrix.
% 
% If a negative value is used, the threshold is taken as an absolute value.
% But remember that while the envelope is not normalized, the output is, so
% your threshold might be difficult to define properly.
%
% See also VOCODE

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2014-02-14
% KNO, University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2014
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

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

