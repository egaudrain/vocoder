fs = 44100;

%% Test 1: comparing butter bandpass with butter with low+high pass

f = exp(linspace(log(30), log(10000), 300));

figure(1)

% Wide
subplot(2,1,1)

fc = [200, 800];
n  = 3;
[b,a] = butter(n, fc*2/fs);
fun1 = @(x) filtfilt(b, a, x);

[b1,a1] = butter(n*2, fc(1)*2/fs, 'high');
[b2,a2] = butter(n*2, fc(2)*2/fs, 'low');
fun2 = @(x) filtfilt(b2, a2, filtfilt(b1, a1, x));

compare_filters({fun1, fun2}, {'Bandpass', 'Low+High pass'}, f, fs, true);

title(sprintf('Butter Wide range = [%d, %d]', fc(1), fc(2)));

% Narrow
subplot(2,1,2)

fc = [200, 300];
n  = 3;
[b,a] = butter(n, fc*2/fs);
fun1 = @(x) filtfilt(b, a, x);

[b1,a1] = butter(n*2, fc(1)*2/fs, 'high');
[b2,a2] = butter(n*2, fc(2)*2/fs, 'low');
fun2 = @(x) filtfilt(b2, a2, filtfilt(b1, a1, x));

compare_filters({fun1, fun2}, {'Bandpass', 'Low+High pass'}, f, fs, true);

title(sprintf('Butter Narrow range = [%d, %d]', fc(1), fc(2)));

drawnow()

%% Test 2: comparing butter zpk->sos vs. tf

f = exp(linspace(log(30), log(10000), 300));

figure(2)
fc = [200, 800];

% Low order
subplot(2,1,1)

n  = 2;
[b,a] = butter(n, fc*2/fs);
fun1 = @(x) filtfilt(b, a, x);

[z,p,k] = butter(n, fc*2/fs);
[sos, g] = zp2sos(z,p,k);
fun2 = @(x) filtfilt(sos, g, x)*1.1;

compare_filters({fun1, fun2}, {'BA', 'ZPK>SOS'}, f, fs, true);

title(sprintf('Butter order = %d', n));

% High order
subplot(2,1,2)

n  = 6;
[b,a] = butter(n, fc*2/fs);
fun1 = @(x) filtfilt(b, a, x);

[z,p,k] = butter(n, fc*2/fs);
[sos, g] = zp2sos(z,p,k);
fun2 = @(x) filtfilt(sos, g, x)*2; % Adding a small offset to make sure we see the curve if they overlap

H = compare_filters({fun1, fun2}, {'BA', 'ZPK>SOS'}, f, fs, true);

title(sprintf('Butter order = %d', n));

drawnow()

%% Test 3: comparing butter vs. elliptic

f = exp(linspace(log(30), log(10000), 300));

figure(3)

% Butter
subplot(2,1,1)

fc = [200, 300];
n  = 3;
[b, a] = butter(n, fc*2/fs);
fun1 = @(x) filtfilt(b, a, x);

fc = [200, 800];
[b, a] = butter(n, fc*2/fs);
fun2 = @(x) filtfilt(b, a, x);

compare_filters({fun1, fun2}, {'Narrow', 'Wide'}, f, fs, true);

title('Butterworth');

% Ellip
subplot(2,1,2)

Rp = 1.5;
Rs = 80;

fc = [200, 300];
[b, a] = ellip(n, Rp, Rs, fc*2/fs, 'bandpass');
fun1 = @(x) filtfilt(b, a, x);

fc = [200, 800];
[b, a] = ellip(n, Rp, Rs, fc*2/fs, 'bandpass');
fun2 = @(x) filtfilt(b, a, x);

compare_filters({fun1, fun2}, {'Narrow', 'Wide'}, f, fs, true);

title('Elliptic');

drawnow()


%% Test 4: Characterizing width effect in Butter

f = exp(linspace(log(30), log(10000), 300));

figure(4)

captions = {};
fun = {};

for w = exp(linspace(log(100), log(8000), 10))
    fc = [0, w]+200;
    n  = 3;
    [b, a] = butter(n, fc*2/fs);
    fun{end+1} = @(x) filtfilt(b, a, x);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);

%% Test 5: Repeated filtering vs. order

figure(5)

subplot(2,1,1)
captions = {};
fun = {};
for w = [100, 600]
    fc = [0, w]+200;
    n  = 2;
    [b, a] = butter(n, fc*2/fs);
    fun{end+1} = @(x) filtfilt(b, a, x);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
title('Butter, order 8 (n=2)');

subplot(2,1,2)
captions = {};
fun = {};
for w = [100, 600]
    fc = [0, w]+200;
    n  = 1;
    [b, a] = butter(n, fc*2/fs);
    fun{end+1} = @(x) filtfilt(b, a, filtfilt(b, a, x));
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
title('2 x Butter, order 4 (n=1)');


%% Test 6: Same as Test 1, but plotted differently

figure(6)

subplot(2,1,1)
captions = {};
fun = {};
n  = 1;
for w = [100, 600]
    fc = [0, w]+200;
    [b, a] = butter(n, fc*2/fs);
    fun{end+1} = @(x) filtfilt(b, a, x);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
title('Bandpass');

subplot(2,1,2)
captions = {};
fun = {};
n  = 2*n;
for w = [100, 600]
    fc = [0, w]+200;
    [b1,a1] = butter(n*2, fc(1)*2/fs, 'high');
    [b2,a2] = butter(n*2, fc(2)*2/fs, 'low');
    fun{end+1} = @(x) filtfilt(b2, a2, filtfilt(b1, a1, x));
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
title('Lowpass + Highpass');


%% Test 7: Arbmagfir

figure(7)

subplot(2,1,1)
captions = {};
fun = {};
n  = 2;
for w = [100, 600]
    fc = [0, w]+200;
    [b, a] = butter(n, fc*2/fs);
    fun{end+1} = @(x) filtfilt(b, a, x);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
title('Bandpass');

subplot(2,1,2)
captions = {};
fun = {};
n  = 2*n;
for w = [100, 600]
    fc = [0, w]+200;
    designfilt('arbmagfir', 'FilterOrder', n, 'NumBands', 3, 'BandFrequencies1', [fc(1)/2, fc(1)/1.0001], 'BandFrequencies2', [fc(1), fc(2)], 'BandFrequencies3', [fc(2)*1.0001, fc(2)*2],...
        'BandAmplitudes1', [0, 1], 'BandAmplitudes2', [1, 1], 'BandAmplitudes3', [1, 0], 'DesignMethod', 'ls', 'SampleRate', fs);
    fun{end+1} = @(x) filtfilt(b, a, x);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
title('arbmagfir');

%% Test 8: FFT

figure(8)

subplot(2,1,1)
captions = {};
fun = {};
n  = 4;
for w = [100, 600]
    fc = [0, w]+200;
    [b, a] = butter(n, fc*2/fs);
    fun{end+1} = @(x) filtfilt(b, a, x);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
ylim([-80, 1])
title('Bandpass');

subplot(2,1,2)
captions = {};
fun = {};
n  = n*4;
%slope = n*6; % dB/oct
for w = [100, 600]
    fc = [0, w]+200;
    %fp = [1, fc(1)/2^3, fc, fc(2)*2^3, fs/2];
    %mp = 10.^([log2(fp(1)/fp(3))*slope, log2(fp(2)/fp(3))*slope, 0, 0, log2(fp(4)/fp(5))*slope, log2(fp(4)/fp(6))*slope]/20);
    fun{end+1} = @(x) fft_filter(x, fs, fc, n);
    captions{end+1} = sprintf('Width = %.1f oct', log2(fc(2)/fc(1)));
end

compare_filters(fun, captions, f, fs, true);
ylim([-80, 1])
title('FFT');


