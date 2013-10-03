% test_gen_lownoise

f1 = 1000;
f2 = 2000;
fs = 44100;
n  = fs*2;
random_seed = 1;
f0 = 1;

tic
nz = get_pshc(n, fs, f1, f2, f0, random_seed);
toc

plot(nz)

