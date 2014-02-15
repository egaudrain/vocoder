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

Use the function `filter_bands()` or the function `estfilt_shift()` to generate filter bank structures like this one:

	fb.filterA 
	  .filterB
	  .center
	  .lower
	  .upper
	  .fs
	  .type
	  .order
	  .filter_type

`filterA` and `filterB` are cell arrays containing A and B coefficients of IIR filters for each frequency-band. These are later used in the `filtfilt()` Matlab function. The i-th channel, `filterB{i}` can also contain a cell array itself. The filters there are then applied sequentially.

`center`, `lower` and `upper` are vectors listing the center, lower and upper frequencies of each band.

`type` is the type of spacing function that was used (log-frequency, linear, or Greenwood).

`filter_type` is a string giving the name of the type of filter used (Butterworth; Bingabr et al. 2008...).

