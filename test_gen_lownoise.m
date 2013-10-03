% test_gen_lownoise

f1 = 1000;
f2 = 2000;
fs = 44100;
n  = fs*2;
random_seed = 1;

tic
nz = get_lownoise(n, fs, f1, f2, random_seed);
toc

plot(nz)

