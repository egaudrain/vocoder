% test_vocode

range = [100, 8000];
n = 4;
fs = 44100;
type = 'greenwood';
shift = 0;
order = 3;

filter_struct = filter_bands(range, n, fs, type, order, shift);

p = struct();
p.envelope = struct();
p.envelope.method = 'low-pass';
p.envelope.rectify = 'half-wave';
p.envelope.fc = 250;
p.envelope.order = 2;

%-- Synthesis
p.synth = struct();
p.synth.carrier = 'noise';
p.synth.filter_before = false; % Filter the carrier before modulation
p.synth.filter_after  = true;  % Filter the carrier after modulation
p.synth.f0 = 1;

%-- Other params
p.display = false;
p.random_seed = 1;

p.analysis_filters = filter_struct;

p.envelope.fc = min(p.analysis_filters.lower, (p.analysis_filters.upper - p.analysis_filters.lower)/2);
%p.envelope.fc = p.analysis_filters.lower;


sound_path = '~/Sounds/CRM_York/Normalised (RMS Power -21dBFS)';
[x, fs] = wavread(fullfile(sound_path, 'N-CRM-F1-A-B1.wav'));

tic
[y1, fs, p1] = vocode(x, fs, p);
toc


p.synth.carrier = 'sin';
p.synth.filter_after = false;


tic
[y2, fs, p2] = vocode(x, fs, p);
toc


p.synth.carrier = 'low-noise';
p.synth.filter_after = false;


tic
[y31, fs, p3] = vocode(x, fs, p);
toc

p.synth.carrier = 'pshc';
p.synth.filter_after = false;


tic
[y41, fs, p4] = vocode(x, fs, p);
toc