%% README
% *A tutorial and discussion on how to use the _smFISH GUI_*
%
% *Caveat emptor* This code was written for the Lahav Lab, which uses
% specific hardware, specific protocols, and specific cell lines.
% Naturally, this code has been optimized for these specifics and any
% deviations from these specifics may lead to unforeseen dilemmas.
%% *The protocol in brief*
% # Collect smFISH images using the MDA app in Metamorph. Give each stack
% of images collected a unique name, e.g. "p21_48hrs_pos1".
% # Transform the TIFF images into PNG images using
% |importFromMetamorphMDA4smfish.m| (Optional: do flatfield correction).
% # Create a copy of the _smFISH GUI_ in the output directory created by
% |importFromMetamorphMDA4smfish.m|.
%% *Setting up the microscope*
% I have found that the complexity of code rapidly increases when a program
% is made to accommodate many different options, settings, or preferences.
% Perhaps, the most frustrating part of this complexity is that almost all
% of the extra code has nothing to do with the core code that was written
% to solve a particular problem in the first place. This code, hereto
% referred to as bloat code, can mask the true purpose of a code and make
% its interpretation difficult to a programmer trying to read it.
% Additionally, if the bloat code was not written well it can be very
% difficult to modify or extract the core code to have it repurposed.
%
% On the other hand, if an operator's preferences tend to change, perhaps
% due to conditions that vary from experiment to experiment, then having a
% versatile program is useful. Also, if the program is to be distributed to
% a large number of people that together have a wide range of preferences
% then having a program that offers flexibility is essential. When is it
% worth the investment in bloat code? For p53Cinema it was decided that the
% bloat code should be kept to a minimum due to the fact that the desired
% tasks a software should perform are apt to evolve relatively quickly and
% members of the Lahav Lab are all proficient-enough programmers that any
% trivial adjustment can be directly made in the code.
%
% One way to minimize the neccessity of bloat code is to minimize the
% variety of inputs that p53Cinema will handle. Performing experiments with
% a set of standard microscope settings is one way this minimization can be
% accomplished. Standardization can also improve the repeatability of
% experiments and edify new lab members who are learning microscopy for the
% first time. The overall goal of the following settings is to reduce the
% amount of exposure necessary to acquire a good signal. For the most part
% the signal and background is proportional to the length of exposure. This
% means that there is no benefit to using longer exposures, since this can
% lead to bleaching and phototoxicity. 
%
% Another reason to follow the recommended microscope settings is this
% software was written for images collected using these settings. The
% software may not work as intended if other settings or microscope
% equipment is used, so please keep this in mind. Please use the following
% microscope settings when performing time-lapse fluorescence microscopy:
%% Recommended Microscope Settings
% Please use the following settings for time-lapse fluorescence
% microscopy... 
%
% # *Use a binning of _2_* The binning can help in several ways. It can
% reduce the file size (albeit this is not always an improvement, e.g. this
% is a terrible idea if doing smFISH where detection of the PSF is vital).
% Binning can improve signal to noise by reducing the read noise (which is
% typically insignificant if not doing single fluorophore work). It reduces
% the length of exposure necessary to fill the dynamic range of the camera;
% this last point is probably the most significant advantage to binning.
% # *Do not use gain* When a signal is low the gain in a camera can be used
% to increase the dynamic range. In otherwords, the gain can be used to
% amplify a signal so that it stretches over all of the gray levels when
% undergoing analog to digital conversion. The upside is that the full
% dynamic range of the camera is still accessible even when using a very
% low exposure. The downside to using gain is that it introduces shot noise
% into the signal, so the signal to noise ratio is always lowered. Since
% the camera has a 12-bit range there is typically enough contrast in even
% 8-bits to make the image quantitative. Therefore, using gain is not a
% necessity. That said, opinions around the lab differ. Alex Loewer always
% used maximum gain. Jennifer Waters at the NIC does not like gain, because
% to her it seems like a gimmick designed for camera salesmen who go on to
% claim their cameras have better sensitivity. Following an ascetic riff of
% Occam's razor, "When in doubt, go without."
% # *Use a 20x objective* A 20x objective provides a large field of view.
% The human cell lines used in the lab are large enough that the nucleus is
% readily identifiable at 20x, including a binning of 2. A large field of
% view is essential when imaging for more than 24 hours as cells tend to
% move around. Furthermore, the field of view can become very crowed after
% a division or two, so have a larger field view lends itself to plating
% fewer cells; this also means there are more cells to measure per image.
% The disadvantage to 20x is that more out of focus light and
% autofluorescence is measured in the focal volume, which can reduce the
% signal to noise ratio. Keep in mind that 20x is fine for measuring a
% diffuse nuclear signal, but not sub-nuclear structures. For instance,
% when Ketki was measuring the dynamics of p53bp1 foci she had to use 60x
% to get enough spatial resolution to identify individual foci.
% # *A note on exposures* The length of exposure for one microscope does
% not translate to the length of exposure on another microscope.
% Differences in absorbance of the light path and intensity of the light
% source mean that the flux of photons varies between the scopes for any
% given wavelength. Also, the exposure for different colors of light is not
% comparable. This is because the intensity of the light source varies
% across the spectrum and the fluorescent molecules being excited can
% differ in number per target and quantum efficiency. Therefore, the
% exposure must be tuned for each channel on each microscope individually.
% # *Another note about exposure*
%% Converting TIFF images into PNG images
% PNG images are a convenient lossless image format that is more
% standardized than the TIFF format. Metadata is stored in a separate file.
% Part of the conversion process takes a 12-bit image that is created by
% the cameras used in the Lahav lab and _stretches_ it across a 16-bit
% range, which is a common image bit-depth. Please make sure the input
% images are 12-bit otherwise, this may cause loss of information or
% insufficient stretching.
%
% <html> 
% For images collected through the multi-dimensional-aquisition app in
% Metamorph use the function <a
% href="importFromMetamorphMDA.html">importFromMetamorphMDA</a>.
% </html>
%

%% Flat-field and dark-field correction
% Flatfield and darkfield images can be measured directly from the
% microscope. It is highly recommended that these images are collected for
% each experiment to achieve the highest quality of data for
% quantification.
%
% The flat field images can be snapshots created through the
% multi-dimensional-aquisition toolbox. The file names must be of a
% specific pattern. First, they need to be saved as TIFF images; TIFF is
% the default format of metamorph. Second, the names have to be constructed
% as |"name of channel"_"length of exposure in milliseconds".tif|. For
% example |YFP_0.tif| for the darkfield YFP image or |DAPI_200.tif| for a
% DAPI image exposed for 200ms. Four to six images should be collected for
% each fluorescent channel. Do not exceed 2000ms of exposure. I like to
% re-use an empty MatTek dish filled with any old media that has
% phenol-red. No correction is made for phase-contrast images.
%
% The easiest way to collect the dark field image is to direct the light
% path into the eye pieces, which prevents light from reaching the camera.
% Then take an image with an exposure on the order of the exposure to be
% used in the movie. Using 50ms as a standard works well. Despite using a
% measurable length of exposure, which measures signal generated from
% thermal noise, the length of exposure in the name of the file should
% still be |0|, since no light is reaching the camera.
%
% <html> 
% For correcting flat-field and dark-field biases use <a
% href="flatfieldcorrection.html">flatfieldcorrection</a>.
% </html>
%% High Dynamic Range images
% Sometimes the signal under study can vary over several orders of
% magnitude. When this is the case it is difficult to capture the full
% range of the signal with a single exposure setting; either bright objects
% saturate a pixel or dim objects disappear into the background. To
% overcome this limitation exposure bracketing can be used. Intuitively, a
% shorter exposure is used to capture bright objects and a longer exposure
% is used to capture dim objects. The information from both images can be
% combined into a single "image" that has increased dynamic range. This new
% image can retain its quantitative integrity by taking advantage of the
% fact that signal is proportional to exposure. Further, this new image can
% also be transformed via a tone map for visual display onto a montior with
% limited dyanmic range. A rule of thumb to choose the exposures is
% choose the longest exposure you are comfortable with to capture dim
% objects, then determine the shorter exposure by dividing this exposure by
% 8.