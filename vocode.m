function [xOut, fsOut, p] = vocode(xIn, fsIn, params)

% [Xout, FSout] = VOCODE(Xin, FSin, PARAMS)
%   Band-vocode Xin using details provided in PARAMS
%
%   PARAMS must contain a field 'analysis_filters' of the form:
%       analysis_filters.filterA
%       analysis_filters.filterB
%       analysis_filters.center
%       analysis_filters.lower
%       analysis_filters.upper
%   Such structure can be produced by FILTER_BANDS. The elements filterA
%   and filterB are cell arrays containing the filter coefficients for each
%   channel. If, for a given channel, a cell array is provided, the filters
%   will be applied sequentially. Filters are applied with the FILTFILT
%   function.
%
%   PARAMS can also contain a field 'synthesis_filters' of the same form.
%   If no such field is provided, the content of 'analysis_filters' will be
%   used. If provided, its elements must of the same length as those of
%   'analysis_filters'.
%
%   The field 'envelope' contains a structure describing how the envelope
%   should be calculated with the following fields:
%       method = 'low-pass' (default) or 'hilbert'
%   If method is 'low-pass', the following fields should be also provided:
%       rectify = 'half-wave' (default) or 'full-wave'
%       fc      = cuttof frequency in Hz (250 Hz default)
%       order   = the order of the filter, the actual order will be
%                 multiplied by 4 (default is 2, hence filters of effective
%                 order 8)
%   The sub-field 'modifiers' contains a list (cell-array) of
%   function names (or handles) modifying the envelope. A cell array can
%   also be provided to give arguments to the function. Possible values
%   are:
%       - 'threshold' (equivalent to {'threshold', 0.01}). This should
%         always be applied first.
%       - 'n-of-m' (equivalent to {'n-of-m', 8}, number of maxima)
%       - or a function handle that takes in the envelope matrix, the
%         sampling frequency, and extra arguments:
%         FNC(M, FS, PARAMS, A, B, ...) should be called as {@FNC, A, B, ...}    
%
%   The field 'synth' describes how the resynthesis should be performed:
%       carrier = 'noise' (default), 'sin', 'low-noise' or 'pshc'
%   For the noise carrier, the bands of noise can be filtered before
%   modulation by the envelope by specifying:
%       filter_before = true (default is false)
%   For all carriers, the modulated carrier can be refiltered in the band
%   to suppress sidebands by specifying:
%       filter_after  = true (default)
%   For 'pshc', the field 'f0' must also be provided (no default).
%
%   For 'noise', 'low-noise' and 'pshc' carriers, the random stream will be
%   initialized using the field PARAMS.random_seed. By default this field
%   contains sum(100*clock).
%
%   See also FILTER_BANDS, GET_LOWNOISE, GET_PSHC, FILTFILT
 

% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> - 2010-02-17
% MRC Cognition and Brain Sciences Unit, Cambridge, UK

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-09-11
% KNO, University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2013
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

p = default_parameters(params);

fs = fsIn;

%--------------------- Compute de output RMS
% We filter between the lower and upper freqs of the analysis filters so
% the RMS of the output corresponds to the RMS of this portion of the
% spectrum of the input.

[b, a] = butter(ceil(min(p.analysis_filters.order([1, end]))), [p.analysis_filters.lower(1), p.analysis_filters.upper(end)]*2/fs);
rmsOut = rms(filtfilt(b, a, xIn));

%--------------------- Prepare the band filters
AF = p.analysis_filters;
SF = p.synthesis_filters;

if length(AF.center)~=length(SF.center)
    error('Vocode:analysis_synthesis_mismatch', 'There should be as many analysis filters as synthesis filters.')
else
    nCh = length(AF.center);
end

%--------------------- Prepare the envelope filters
switch p.envelope.method
    case {'low-pass', 'lp', 'low'}
        if length(p.envelope.fc)==1
            p.envelope.fc = ones(nCh,1)*p.envelope.fc(1);
        end
        if length(p.envelope.fc)~=nCh
            error('Vocode:n_envelope_fc', 'params.envelope.fc [%d] must be of length the number of channels [%d]', length(p.envelope.fc), nCh);
        end
        
        if length(p.envelope.order)==1
            p.envelope.order = ones(nCh,1)*p.envelope.order(1);
        end
        if length(p.envelope.order)~=nCh
            error('Vocode:n_envelope_fc', 'params.envelope.order [%d] must be of length the number of channels [%d]', length(p.envelope.order), nCh);
        end
        
        for i=1:nCh
            [blo,alo] = butter(p.envelope.order(i), p.envelope.fc(i)*2/fs, 'low');
            p.envelope.filter(i).b = blo;
            p.envelope.filter(i).a = alo;
        end
            
    case 'hilbert'
    otherwise
        error('Vocode:envelope_method_unknown', 'Method "%s" is unknown for the envelope parameter', p.envelope.method);
end

%--------------------- Some initialisation

nSmp = length(xIn);
ModC = zeros(nSmp, nCh);
Env  = zeros(nSmp, nCh);
%{
y    = zeros(nSmp, 1);
env  = zeros(nSmp, 1);
nz   = zeros(nSmp, 1);
%}
%cmpl = zeros(nSmp, 1);

% RMS levels of original filter-bank outputs are stored in the vector 'levels'
levels = zeros(nCh, 1);

%--------------------- Synthesize each channel

for i=1:nCh

    y = apply_filter(AF, i, xIn);
    levels(i) = rms(y);
    
    switch p.envelope.method
        case 'hilbert'
            env = abs(hilbert(y));
            
        case {'low-pass', 'lp', 'low'}
            
            switch p.envelope.rectify
                case {'half', 'half-wave'}
                    env = max(y, 0);
                case {'full', 'full-wave'}
                    env = abs(y);
                otherwise
                    error('Vocode:envelope_rectify_unknown', 'Rectification "%s" is unknown.', p.envelope.rectify);
            end
            
            env = max(filtfilt(p.envelope.filter(i).b, p.envelope.filter(i).a, env), 0);
  
    end
    
    if isempty(p.envelope.modifiers) % We only do this if the envelope was unmodified
        Env(:,i) = env / max(env);
    else
        Env(:,i) = env;
    end
end

for km = 1:length(p.envelope.modifiers)
    md = p.envelope.modifiers{km};
    if iscell(md)
        md_name = md{1};
        md_args = md(2:end);
    else
        md_name = md;
        md_args = {};
    end
    switch md_name
        case 'threshold'
            md_f = @envelope_mod_threshold;
        case 'n-of-m'
            md_f = @envelope_mod_nofm;
        otherwise
            if isa(md_name, 'function_handle')
                md_f = md_name;
            else
                error('Envelope modifier "%s" is unknown.', md_name);
            end
    end
    Env = md_f(Env, fs, p, md_args{:});
end

for i=1:nCh
    switch p.synth.carrier
        case 'noise'
            %-- Excite with noise
            rng(p.random_seed);
            nz = sign(rand(nSmp,1)-0.5);
            if p.synth.filter_before
                nz = apply_filter(SF, i, nz);
            end
            
        case {'sine', 'sin'}
            %-- Sinewave
            nz = sin(SF.center(i)*2.0*pi*(0:(nSmp-1))'/fs);
            
        case {'low-noise', 'low-noise-noise', 'lnn'}
            %-- Low-noise-noise
            nz = get_lownoise(nSmp, fs, SF.lower(i), SF.upper(i), p.random_seed);
            
        case {'pshc'}
            nz = get_pshc(nSmp, fs, SF.lower(i), SF.upper(i), p.synth.f0, p.random_seed);
        
    end
    
    ModC(:,i) = Env(:,i) .* nz;
    
    if p.synth.filter_after
        ModC(:,i) = apply_filter(SF, i, ModC(:,i));
    end
    
    % Restore the RMS of the channel
    if isempty(p.envelope.modifiers) % We only do this if the envelope was unmodified
        ModC(:,i) = ModC(:,i) / rms(ModC(:,i)) * levels(i);
    end
end

%--------------------- Reconstruct

xOut = sum(ModC, 2);
xOut = xOut / rms(xOut) * rmsOut;

% CAREFUL: the output is not scaled to avoid clipping
%{
max_sample = max(abs(xOut));
if max_sample > (2^15-2)/2^15
    % figure out degree of attenuation necessary
    ratio = 1.0/max_sample;
    wave=wave * ratio;
    warning(sprintf('Sound scaled by %f = %f dB\n', ratio, 20*log10(ratio)));
end

xOut = wave';
%}

fsOut = fsIn;

%==========================================================================
function p = default_parameters(params)
% Fill the structure with default parameters, merges with the provided
% params, and check them

p = struct();

%-- Envelope extraction
p.envelope = struct();
p.envelope.method = 'low-pass';
p.envelope.rectify = 'half-wave';
p.envelope.fc = 250;
p.envelope.order = 2;
p.envelope.modifiers = {};

%-- Synthesis
p.synth = struct();
p.synth.carrier = 'noise';
p.synth.filter_before = false; % Filter the carrier before modulation
p.synth.filter_after  = true;  % Filter the carrier after modulation
p.synth.f0 = .3;

%-- Other params
p.display = false;
p.random_seed = sum(100*clock);

%----------

p = merge_structs(p, params);

if ~isfield(p, 'analysis_filters')
    error('Vocode:analysis_filters', 'The field "analysis_filters" is mandatory and was not provided in the parameters.');
end

if ~isfield(p, 'synthesis_filters')
    p.synthesis_filters = p.analysis_filters;
    warning('Vocode:synthesis_filters', 'The analysis filters will be used for synthesis.');
end

%==========================================================================
function c = merge_structs(a, b)
% A is the default, and we update with the values of B

c = a;

keys = fieldnames(b);

for k = 1:length(keys)
    
    key = keys{k};
    
    if isstruct(b.(key)) && isfield(a, key)
        c.(key) = merge_structs(a.(key), b.(key));
    else
        c.(key) = b.(key);
    end
    
end


%==========================================================================
function y = apply_filter(filter_struct, i, x)
% Filters X in channel I of FILTER_STRUCT

if iscell(filter_struct.filterB{i})
    % filterB/A is a collection of filters that need to be run after each
    % other.
    y = x;
    b = filter_struct.filterB{i};
    a = filter_struct.filterA{i};
    for k=1:length(b)
        y = filtfilt(b{k}, a{k}, y);
    end
else
    y = filtfilt(filter_struct.filterB{i}, filter_struct.filterA{i}, x);
end
