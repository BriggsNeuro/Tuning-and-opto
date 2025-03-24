These codes require data be formatted into a structure that includes a parameter of spike time stamps per recording channel and a separate parameter of stimulus on/off and/or cycling time stamps.

LGNtunanal.m will take spike times and sort them by stimulus time stamps to generate tuning curve data that are then saved per unit in separate matrices within the parent data structure. Tuning data saved include:
Contrast
Spatial frequency
Temporal frequency
Size

SFCurves0523 will plot curve fits to all of the tuning data generated in LGNtunanal using specified fit types (e.g. difference of gaussians, Naka-Rushton, etc)

LEDPSTHs analyzes similar data structures as noted above, but for trials in which the LED flashed and no stimuli are present - this plots PSTHs per unit that enables hunting for onto-tagged neurons

MseqAnal and mseqplotwork require spike time stamps and time stamps for the start of each repeat of the m-sequence stimulus. This creates kernels that represent each STA. The plot function enables opening existing kernels to plot STAs and temporal response curves for each type of m-sequence stimulus (black/white and cone-modulating). RFsizeNHPold analyzes the peak STA created from the above codes and computes the size of the receptive field within that STA.

Jitter and TransSustainedFlashLatPrecTSI codes calculate PSTHs from spike times and flash spot stimulus time stamps and then calculate metrics that describe the temporal dynamics of these responses. Plotjitter creates PSTHs for identified units.

The DoGFigure is python code for generating Figure 5 of Mai et al NCOMMS submission.
