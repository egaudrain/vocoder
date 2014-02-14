function Env = envelope_mod_nofm(Env, fs, p, n, fc)

% Applies maxima selection to the vocoder.

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2014-02-14
% KNO, University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2014
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

if nargin<4
    n = 8;
end

if nargin<5
    % Resample envelope at 900 Hz
    fc = 900;
end

t  = (0:size(Env,1)-1)'/fs;

figure(42)
plot(t, Env'*10+repmat((1:size(Env,2))', 1, size(Env,1)), '-k')

for i=1:size(Env,2)
    envR = resample(Env(:,i), fc, fs);
    if i==1
        EnvR = zeros(length(envR), size(Env,2));
    end
    EnvR(:,i) = envR;
end

for j=1:size(EnvR,1)
    [~, idx] = sort(EnvR(j,:), 2);
    EnvR(j, idx(1:end-n)) = 0;
end

N = size(Env,1);


tR = linspace(t(1), t(end), size(EnvR,1))';

for i=1:size(EnvR,2)
    %Env(:,i) = fix_length(resample(EnvR(:,i), fs, fc), N);
    Env(:,i) = interp1(tR, EnvR(:,i), t, 'linear', 0);
end

if ~p.synth .filter_after
    warning('If using the n-of-m envelope modifier it is very highly recommended to add the "filter_after" option to avoid clicks and strange behaviour.');
end

hold on
plot(t, Env'*10+repmat((1:size(Env,2))', 1, size(Env,1)), '-r')
hold off
xlim([t(1), t(end)])
ylim([0, size(Env,2)+1])

%-------------------------
function y = fix_length(x, n)

if length(x)>n
    y = x(1:n);
    y(end-127:end) = y(end-127:end) .* linspace(1,0,128)';
elseif length(x)<n
    y = [x; zeros(n-length(x),1)];
end