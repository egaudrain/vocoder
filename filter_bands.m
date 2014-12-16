function filter_struct = filter_bands(range, n, fs, type, order, shift)
%FILTER_STRUCT = FILTER_BANDS(RANGE, N, FS, TYPE, ORDER, SHIFT)
%   Creates a filter structure. The function is just a convenience function
%   for ESTFILT_SHIFT.
%
%   RANGE is a two element vector containing the lower and upper cutoff
%   frequencies. 
%   N is the number of channels. 
%   FS is the sampling frequency.
%   TYPE defines how the frequency bands will be spaced. The possible
%   values are 'greenwood', 'linear', 'log'. If omitted, 'greenwood' is
%   selected. 
%   ORDER is the order of the filters (remember that this will be
%   multiplied by 4 in the actual vocoder). Default is 3. 
%   SHIFT is the shift in mm towards the base of the cochlea. If omitted, 
%   no shift is applied.
%
%   By default, Buttherworth filters are used. To use other filters,
%   provide a cell array in place of the ORDER argument, of the form 
%   {FILTER_TYPE, ORDER}. Providing a number is equivalent to
%   {'butter', ORDER}. Other possible values are 'bingabr_2008' (then the
%   order is the slope in dB/mm) or a function handle of the form:
%       [B, A] = FILTER_FUNCTION(ORDER, [LOW, HIGH])
%   The B and A coefficients will be passed to the FILTFILT function.
%
%   If the type is 'butter' and a fractional order is provided, separate
%   low-pass and high-pass are used instead of a bandpass.
%
%FILTER_STRUCT = FILTER_BANDS([], [], FS, DEVICE, ORDER, SHIFT)
%   Creates a filter structure based on the standard filters used in real
%   devices. Possible values for DEVICE are 'ci24' (Cochlear) and 'hr90k'
%   (AB).
%
%   See also VOCODE, ESTFILT_SHIFT

% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-09-11
% University Medical Center Groningen, NL

% Copyright UMCG, Etienne Gaudrain, 2013
% This is code is distributed with no warranty under GNU General Public
% License v3.0. See http://www.gnu.org/licenses/gpl-3.0.txt for the full
% text.

if nargin<4
    type = 'greenwood';
end

if nargin<5
    order = 3;
end

if nargin<6
    shift = 0;
end

mm = frq2mm(range);
range = mm2frq(mm+shift);

filter_struct = estfilt_shift(n,type,fs,range,order);
