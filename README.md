# Simple MUA Detection and Plexon Offline Sorter Tools
MATLAB script to detect spikes in high-pass filtered ephys data (Plexon PL2 format) using adaptive amplitude thresholding

## Spike Detection
Use the function `extractMUA` to extract spike waveforms from Plexon "SPKC" data using adaptive amplitude thresholding. 

### Adaptive Thresholding and Alignment
Spike waveforms often change amplitude over time, primarily due to slow (or sudden) shifts between the electrode and brain tissue. This is a common issue that has yet to be sufficiently addressed by modern spike sorting methods. To allieviate this issue, this spike detector determines the amplitude threshold for spikes adaptively based on 250 second long windows. This window length was empirically chosen - it is short enough to capture gradual changes in spike amplitude but long enough that there are enough spikes to generate a stable estimate of the mean waveform under typical conditions. Spike waveforms are aligned to their minimum point after threshold crossing. 

### Exclusion of Putative Axonal Waveforms
Electrodes can pick up strong signals from nearby axons. These waveforms tend to be triphasic or have the shape peak-then-trough rather than trough-then-peak. These signals can dominate the spike signal and interfere with dimensionality reduction methods (e.g. PCA) on waveform shape during spike sorting. This is particularly frustrating when analyzing data from deep brain structures like the thalamus, which contain many passing fibers within and surrounding the structure. Neither the destination nor the origin of these axons is typically known, so putative axonal waveforms are best excluded from analysis.

### Visualization
To verify the spike detection algorithm, a .png file is created for each channel with plots of:
- individual spike waveforms
- spike thresholds per adaptive window
- number of spikes per adaptive window
- mean waveform per window
- principal component 1 vs principal component 2 of waveform shapes, with putative axons labeled
- principal component 1 vs timestamp, with putative axons labeled
- mean waveform, with and without putative axons

### Output
A Matlab file is created with the extracted waveform voltages and timestamps. These spikes are considered multi-unit activity (MUA). A logical variable indicating whether each waveform is a putative axon is also output.

## Plexon Offline Sorter Tools
The function `tools/createOfflineSorterInput` reads the Matlab output files generated above associated with the selected channels and combines them into Matlab files (16 channels per file) for importing into Plexon's Offline Sorter spike sorting program.

The function `tools/compileOfflineSorterOutputToInput` reads the Matlab output files (sorted waveforms per channel) exported from Offline Sorter and combines them into Matlab files (16 channels per file) for importing into Plexon's Offline Sorter spike sorting program.

The function `tools/findAllEventCodesPL2` reads the Plexon PL2 file, which contains event trigger times across event channels, and returns the consolidated event times and event codes. 

## Setup 

Run `setProjectPath` to set the project path for the scripts in this repo.

## Contact

Email rly -at- princeton.edu if you have any questions about this code.



