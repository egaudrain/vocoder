function h = transfer_function(fun, f, fs)

%H = TRANSFER_FUNCTION(FUN, F, FS)
%  Returns the *magnitude* transfer function for a filtering function
%  evaluated at frequencies F, assuming a sampling frequency of FS.
%
%  Example:
%   [b,a] = butter(4, [200, 800]*2/fs);
%   fun = @(x) filtfilt(b, a, x);
%   f = exp(linspace(log(30), log(10000), 300));
%   h = transfer_function(fun, f, fs);

h = zeros(size(f));

for i = 1:length(f)
    ff = f(i);
    t = (1:max(round(round(ff)/ff*fs), round(20/ff*fs)))/fs;
    x = sin(2*pi*ff*t);
    h(i) = rms(fun(x))/rms(x);
end