% test_vocode

range = [100, 8000];
n = 4;
fs = 44100;
type = 'greenwood';
shift = 0;
order = 12;

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

p.analysis_filters = estfilt_shift(n,type,fs,range,{'butter', order, 'sos'});

%-----

sound_path = '~/Sounds/CRM_York/Normalised (RMS Power -21dBFS)';
[x, fs] = audioread(fullfile(sound_path, 'N-CRM-F1-A-B1.wav'));


tic()
[y_sos, fs, psos] = vocode(x, fs, p);
toc()

p.analysis_filters = estfilt_shift(n,type,fs,range,{'butter', order, 'ba'});

tic()
[y_ba, fs, pab] = vocode(x, fs, p);
toc()

