VOCODER (2013)
==============

The code in this section is used to implement various vocoders, generally used to simulate acoustically what cochlear implant users experience through their device. The code base was originally produced by Stuart Rosen, later modified by Bob Carlyon, and since more or less completely rewritten in a more modern style and with many additions.

The `vocode()` function is supposed to cover a lot of cases, and therefore receives a rather complex set of parameters. The said function is called like this: `[y, fs]=vocode(x,fs,p)`. `x` is a (single channel, i.e. mono) signal. `fs` is the sampling frequency and `p` is a structure with all the parameters. The function returns `y`, the vocoded version of `x`.

This document describes how to setup the parameter structure `p`.

`p` has four main sections:
- `analysis_filters`: describes the filter bank used for analysis purposes.
- `synthesis_filters`: describes the filter bank used for synthesis.
- `envelope`: describes how the envelope is extracted.
- `synth`: describes the type of carrier that'll be used, and how to combine it with the envelope.

Each of these are documented below, in the same order.




Filter banks
------------

The filter banks are described in `p.analysis_filters` and `p.synthesis_filters`. If only the former is provided, the analysis filters are also used for synthesis. If both analysis and synthesis filter banks are provided, they need to have the same number of channels.

_Analysis filters_ are used to partition the input signal into frequency bands. These are typically rather sharp. _Synthesis filters_ are used to shape broadband carriers, or eventually to reshape narrow band carriers once they have been modulated by the envelope.

Use the function `filter_bands()` or the function `estfilt_shift()` (see below) to generate filter bank structures like this one:

```matlab
fb.filterA 
  .filterB
  .center
  .lower
  .upper
  .fs
  .type
  .order
  .filter_type
```

`filterA` and `filterB` are cell arrays containing A and B coefficients of IIR filters for each frequency-band. These are later used in the `filtfilt()` Matlab function. The i-th channel, `filterB{i}` can also contain a cell array itself. The filters there are then applied sequentially.

`center`, `lower` and `upper` are vectors listing the center, lower and upper frequencies of each band.

`type` is the type of spacing function that was used (log-frequency, linear, or Greenwood).

`filter_type` is a string giving the name of the type of filter used (Butterworth; Bingabr et al. 2008...).

### Convenience functions

Two help creating these rather complicated structures, two convenience functions are provided. `filter_bands()` is the easiest, and is actually a wrapper for the second one `estfilt_shift()`.

`filter_bands(range, n, fs, type, order, shift)` returns a filter structure from the following parameters:
- `range`: a two element vector giving the lowest and the highest frequency limit of the vocoder. These will become the lower cutoff frequency of the first band and the upper cutoff frequency of the last frequency band.
- `n`: is the number of channels.
- `fs`: is the sampling frequency. 

These arguments are optional:
- `type`: is the type of spacing function used to partition the range. Possible values are 'greenwood' (default), 'log' and 'linear'. Device names 'ci24' and 'hr90k' can also be used there. This overrides the values of `range` and `n` provided (so they can be left as `[]`).
- `order`: is the order of the filters (default is 3). By default, Butterworth bandpass filters are used, with the `filtfilt()` function. As a result the order passed as an argument here is effectively multiplied by 4. See below for more details on this.
- `shift`: the shift of the frequency range expressed in millimeters along the cochlea (based on Greenwood's function).

By default, Buttherworth filters are used. To use other filters, provide a cell array of the form `{filter_type, filter_parameter}` for `order`. Providing a number for this argument is equivalent to `{'butter', order}`. Other possible values are 'bingabr_2008' (then the order is the slope in dB/mm) or a function  handle of the form:

```matlab
[b, a] = filter_function(order, [low, high], fs)
```

Where 'low' and 'high' are calculated from the range, the number of channels and the type of spacing, and must be in normalized frequency (f/(2*fs)).

If the filter type is 'butter' (including if `order` is simply a number rather than a cell-array)  and a fractional order is used (has to be a multiple of 1/2), separate low-pass and high-pass filters are used instead of a bandpass.



### Examples

To make a structure of eight 12th order Butterworth filters equally spaced on the cochlea from 200 to 7000 Hz:

```matlab
p.analysis_filters = filter_bands([200, 7000], 8, fs, 'greenwood');
```

To create equivalent synthesis filters but 4th order, and shifted by 4 mm towards the apex:

```matlab
p.synthesis_filters = filter_bands([200, 7000], 8, fs, 'greenwood', 1, 4);
```

Remember, the order argument passed to the filter_bands function will be multiplied by 4, so we pass 1 to get 4th order filters. If we wanted 6th order filters, we would pass 1.5. If ommited, the value 3 is used, resulting in 12th order filters.

To create a structure of 12th order Butterworth analysis filter matching the frequencies of Cochlear devices:

```matlab
p.analysis_filters = filter_bands([], [], fs, 'ci24');
```

To create matched filters with the current spread simulation like in Bingabr et al. (2008):

```matlab
p.synthesis_filters = filter_bands(mm2frq(frq2mm(1174)+[0 16]), length(p.analysis_filters.center), fs, ...
									'greenwood', {'bingabr_2008', 2.8}, 0);
```

The `[0 16]` vector is due to the fact that standard electrode arrays are about 16 mm long. The value of 1174 Hz is the average frequency corresponding to the location of the most apical electrode (Skinner et al. 2002).




Envelope
--------

The default envelope structure is as follows:

```matlab
p.envelope.method = 'low-pass';
p.envelope.rectify = 'half-wave';
p.envelope.fc = 250;
p.envelope.order = 2;
p.envelope.modifiers = {};
```

Here is a quick explanation of each of the fields:

- `method`: determines how the envelope is extracted. Possible values are 'hilbert' or 'low-pass'.
- `rectify`: if the method is 'low-pass', then the signal is rectified, either 'half-wave' or 'full-wave', and then low-passed.
- `fc`: if the method is 'low-pass', the rectified signal is low-pass filtered below this cutoff frequency. If a vector is provided, its length must be the number of channels.
- `order`: again if the method is 'low-pass', this specifies the order of the filter. Because the `filtfilt()` function is used, the order is effectively multiplied by 2.
- `modifiers`: a cell-array listing modifiers for the envelope. These are detailed below.

### Envelope modifiers

The field 'modifiers' contains a list (cell-array) of function names (or handles) modifying the envelope in each channel. A cell array can also be provided to give arguments to the function. Possible values are:

- 'threshold': applies a threshold to the envelope (equivalent to `{'threshold', 0.01}`). This is implemented as ``max(env-thr, 0)``. If a positive threshold value is given, the threshold is calculated as a proportion of the maximal envelope value (across time and channels). If a negative threshold is given, it is treated as an absolute value. See `envelope_mod_threshold()` for details of the implementation.

- 'n-of-m': select only the n first maxima (equivalent to `{'n-of-m', 8}`, selecting 8 maxima). This is used to simulate strategies like ACE. In these strategies, the maxima can evaluated on every pulse. We do the same here, using a stimulation rate of 900 Hz. This frequency can also be passed as third argument. If this strategy is used, it is strongly advised to use `p.synth.filter_after=true` to avoid clicks, and a warning will be emitted if this is not the case. See `envelope_mod_nofm()` for details of the implementation.

- a function handle. The function will be passed the envelope matrix, the sampling frequency, and extra arguments and must thus have the following signature: `Env = fnc(Env, fs, p, ...)`. This should be passed as `{@fnc, ...}` (replace the '...' with extra arguments as necessary). The `Env` matrix has n-sample rows and m-channels columns.


The envelope is extracted either by rectification/low-pass or using the Hilbert-transform. If no modifier is provided, the envelope is then normalized in each channel, then multiplied with the carrier, eventually (re)filtered in the band, and the RMS of the resulting signal is then adjusted to that of the original signal filtered in that same band. Once all the bands are summed, the resulting signal's RMS is adjusted to match that of the original signal filtered in the same frequency range.

However, **if modifiers are used, the envelopes are not normalized and RMS adjusted**. Only the signal obtained after summation of the channels is scaled. This is particularly important for the n-of-m modifier, for instance.

### Examples

This defines an envelope with a cutoff of 50 Hz, with selection of 5 maxima.

```matlab
p.envelope.method = 'low-pass';
p.envelope.rectify = 'half-wave';
p.envelope.fc = 50;
p.envelope.order = 2;
p.envelope.modifiers = {{'n-of-m', 5}};
```

Note the use of the double curly-brackets for the modifier list. This is what should be types to add a threshold:

```matlab
p.envelope.modifiers = {{'n-of-m', 5}, {'threshold', 0.02}};
```

And this is how a custom function should be used. First define your function.

```matlab
function Env = envelope_mod_compression(Env, fs, p, alpha)
   Env = Env.^alpha;
end
```

Then add it to the modifiers.

```matlab
p.envelope.modifiers = {{'n-of-m', 5}, {'threshold', 0.02}, {@envelope_mod_compression, .5}};
```


References
----------

+ Bingabr et al. (2008) Hearing Research. doi: 10.1016/j.heares.2008.04.012.
+ Skinner et al. (2002) JARO, doi: 10.1007/s101620020013.


