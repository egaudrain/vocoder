function H = compare_filters(filters, captions, f, fs,  timing)

if nargin<5
    timing = false;
end

H = cell(size(filters));

for i=1:length(filters)
    tic();
    H{i} = transfer_function(filters{i}, f, fs);
    t = toc();
    h(i) = plot(f, 20*log10(H{i}));
    hold on
    if timing
        captions{i} = [captions{i}, ' ', sprintf('[%.2f s]', t)];
    end
end
hold off
legend(h, captions);

set(gca, 'XScale', 'log')
xlim([f(1), f(end)]);
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')
