function y = fft_filter(x, fs, fp, mp, varargin)

X = fft(x);
f = (0:length(x)-1)/(length(x)-1)*fs;
f(f>fs/2) = fs-f(f>fs/2);

if length(fp)>2
    % A magnitude profile was given
    m = exp(interp1(log(fp), log(mp), log(f(2:end)), 'pchip', 1));
    m = [1, m];
elseif length(fp)==2
    % We have a bandpass filter, mp is the order
    % We create a profile that puts the -3 dB point at the cutoff
    % frequencies
    fc = fp;
    s = mp*6;
    ft1 = 2^(3/s)*fc(1);
    ft2 =  2^(-3/s)*fc(2);
    if ft2<ft1
        ft = sqrt(ft2*ft1);
        ft2 = ft;
        ft1 = ft;
    end
    fi1 = sqrt(fc(1)*f(2));
    fi2 = sqrt(fc(2)*fs/2);
    fp = [f(2), fi1, fc(1), ft1, ft2, fc(2) fi2, fs/2];
    mp = 10.^(([(log2(fp(1:2)/fc(1))*s), 0, 3, 3, 0, (log2(fc(2)./fp(7:8))*s)]-3)/20);
    m = interp1(log(fp), log(mp), log(f(2:end)), 'linear', 1);
    % Smoothing
    w = hann(32);
    w = w/sum(w);
    m = conv2(m(:), w(:), 'same');
    m = [1; exp(m)];
else
    % We have a highpass or lowpass filter, mp is the order and varargin is
    % the slope
end



X = X(:).*m;
y = real(ifft(X));