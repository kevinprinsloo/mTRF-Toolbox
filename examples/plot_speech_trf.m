function plot_speech_trf
%PLOT_SPEECH_TRF  Plot example speech TRF.
%   PLOT_SPEECH_TRF loads an example dataset and estimates and plots a
%   speech TRF and the global field power (GFP) from 2 minutes of
%   128-channel EEG data as per Lalor and Foxe (2010).
%
%   Example data is loaded from SPEECH_DATA.MAT and consists of the
%   following variables:
%       'stim'      a vector containing the speech spectrogram, obtained by
%                   band-pass filtering the speech signal into 128
%                   logarithmically spaced frequency bands between 100
%                   and 4000Hz, taking the Hilbert transform at each band
%                   and averaging over every 8 neighbouring bands.
%       'resp'      a matrix containing 2 minutes of 128-channel EEG data
%                   filtered between 0.5 and 15 Hz
%       'fs'        the sample rate of STIM and RESP (128Hz)
%       'factor'    the BioSemi EEG normalization factor for converting the
%                   TRF to microvolts (524.288mV / 2^24bits)
%
%   mTRF-Toolbox https://github.com/mickcrosse/mTRF-Toolbox

%   References:
%      [1] Lalor EC, Foxe JJ (2010) Neural responses to uninterrupted
%          natural speech can be extracted with precise temporal
%          resolution. Eur J Neurosci 31(1):189-193.

%   Authors: Mick Crosse <mickcrosse@gmail.com>
%   Copyright 2014-2020 Lalor Lab, Trinity College Dublin.

% Load data
load('data/speech_data.mat','stim','resp','fs','factor');

% Normalize data to convert TRF to uV
stim = sum(stim,2);
resp = resp*factor;

% Model hyperparameters
dir = 1;
tmin = -100;
tmax = 400;
lambda = 0.05;

% Compute model weights
model = mTRFtrain(stim,resp,fs,dir,tmin,tmax,lambda,'method','Tikhonov',...
    'zeropad',0);

% Get TRF and GFP
trf = squeeze(model.w);
gfp = squeeze(std(model.w,[],3));

% Define ROI
chan = 85; % channel Fz

% Plot TRF
figure, subplot(1,2,1)
plot(model.t,trf(:,chan),'linewidth',3)
xlim([-50,350])
title('Speech TRF (Fz)')
xlabel('Time lag (ms)')
ylabel('Amplitude (\muV)')
axis square, grid on

% Plot GFP
subplot(1,2,2)
area(model.t,gfp,'edgecolor','none');
xlim([-50,350])
title('Global Field Power')
xlabel('Time lag (ms)')
axis square, grid on