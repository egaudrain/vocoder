% test_vocode

range = [100, 8000];
n = 8;
fs = 44100;
type = 'greenwood';
shift = 0;
order = 4;

AF = filter_bands([], [], fs, 'ci24', order, 0);
SF = filter_bands(mm2frq(frq2mm(1174)+0.73*([0, 21])), 22, fs, 'greenwood', {'bingabr_2008', 2.8}, 0);

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

p.analysis_filters = AF;
p.synthesis_filters = SF;

tic
sound_path = '~/Sounds/CRM_York/Normalised (RMS Power -21dBFS)';
[x, fs] = audioread(fullfile(sound_path, 'N-CRM-F1-A-B1.wav'));


[y1, fs, p1] = vocode(x, fs, p);
toc

sound(y1,fs)

%{
p.synth.carrier = 'low-noise';
p.synth.filter_after = false;


tic
[y2, fs, p2] = vocode(x, fs, p);
toc


p.synth.carrier = 'pshc';
p.synth.filter_after = false;


tic
[y3, fs, p3] = vocode(x, fs, p);
toc
%}