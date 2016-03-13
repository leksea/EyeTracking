function [dat,scr,stm] = stimulus_setup(dat, scr)
%
% define features of experimental stimulus


%  SCREEN  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if dat.dispArcmin < scr.pix2arcmin; 
		warning('disparity requested is less than 1 pixel'); 
	end


%  STIMULUS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.dotUpdateHz     = 60;        % dot update rate
dat.numCycles       = 1;         % total cycles, more than 1 for periodic stim

stm.dispPix             = dat.dispArcmin/scr.pix2arcmin;            % step full disparity in pixels
stm.rampEndDispDeg      = 2*(dat.rampSpeedDegSec*dat.cycleSec);     % end full disparity of ramp in degrees relative to start position
stm.rampEndDispPix      = (60*stm.rampEndDispDeg)/scr.pix2arcmin;   % end full disparity of ramp in pixels relative to start position

stm.stimRadPix      = round((60*dat.stimRadDeg)/scr.pix2arcmin);    % dot field radius in pixels
stm.stimRadSqPix    = stm.stimRadPix^2;                             % square it now to save time later
stm.dotSizePix      = (dat.dotSizeDeg*60)/scr.pix2arcmin;           % dot diameter in pixels

stm.xmax            = 4*max([stm.stimRadPix stm.rampEndDispPix]);   % full x field of dots before circle crop
stm.ymax            = stm.xmax;                                         % fill y field of dots before circle crop

stm.numDots = round( dat.dotDensity*(  stm.xmax*(scr.pix2arcmin/60) * ...  % convert dot density to number of dots for PTB
    stm.ymax*(scr.pix2arcmin/60) ) );


%  TIMING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% note: dot drawing is done frame-by-frame rather than using PTB WaitSecs,
% this seems to provide better precision, although time is still not
% perfect (a few frames tend to be dropped)

stm.dotUpdateSec    = 1/dat.dotUpdateHz;                                % duration to hold dots on screen
stm.dotRepeats		= round(scr.frameRate/dat.dotUpdateHz);             % number of frames to hold dots on screen
dat.dotUpdateHz     = scr.frameRate/stm.dotRepeats;                     % true dot update rate is even multiple of frame rate
stm.numUpdates      = round(dat.dotUpdateHz*dat.cycleSec);              % number of times the stimulus is updated in a rap cycle
stm.preludeUpdates  = round(dat.dotUpdateHz*dat.preludeSec);            % number of times the stimulus is updated in a preclue

stm.dynamics.step       = [ zeros(1,stm.preludeUpdates) repmat(stm.dispPix,1,stm.numUpdates)];   % set up step disparity updates
stm.dynamics.ramp       = [ zeros(1,stm.preludeUpdates) linspace(stm.rampEndDispPix/stm.numUpdates,stm.rampEndDispPix,stm.numUpdates)];       % set up ramp disparity updates
stm.dynamics.stepramp   = [ zeros(1,stm.preludeUpdates) stm.dispPix - linspace(0,stm.rampEndDispPix - (stm.rampEndDispPix/stm.numUpdates),stm.numUpdates)];


% cycle through conditions and make sure they don't exceed calibration area
isTooBigForRamp = 0;
isTooBigForStep = 0;
isTooBigForStepRamp = 0;

for d = 1:length(dat.dynamics)
	
	switch dat.dynamics{d}
		
		case 'ramp'
			
			isTooBigForRamp = max(stm.dynamics.ramp/2) > scr.caliRadiusPixX;
			
		case 'step'
			
			isTooBigForStep = max(stm.dynamics.step/2) > scr.caliRadiusPixX;
			
		case 'stepramp'
			
			isTooBigForStepRamp = max(stm.dynamics.stepramp/2) > scr.caliRadiusPixX;
			
	end
	
end

if(isTooBigForRamp || isTooBigForStep || isTooBigForStepRamp)
	warning('need to increase calibration area in order to run this condition');
end

%  FIXATION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stm.fixationRadiusDeg = 1;
stm.fixationRadiusPix = (60*stm.fixationRadiusDeg)/scr.pix2arcmin;
stm.fixationRadiusSqPix = stm.fixationRadiusPix^2;

stm.fixationDotRadiusDeg = 0.125;
stm.fixationDotRadiusPix = (60*stm.fixationDotRadiusDeg)/scr.pix2arcmin;

if scr.topbottom == 1
    scr.Yscale = 0.5;
else
    scr.Yscale = 1;
end

stm.fixationRadiusYPix = stm.fixationRadiusPix*scr.Yscale;
stm.fixationRadiusXPix = stm.fixationRadiusPix;


%  TRIAL STRUCTURE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dat.trials.condition        = {};
dat.trials.dynamics         = {};
dat.trials.direction        = {};
dat.trials.repeat           = [];

for c = 1:length(dat.conditions)
    
    for d = 1:length(dat.dynamics)
        
        for n = 1:length(dat.directions)
            
            for r = 1:dat.cond_repeats
                
                dat.trials.condition    = [dat.trials.condition ; dat.conditions{c}];
                dat.trials.dynamics     = [dat.trials.dynamics ; dat.dynamics{d}];
                dat.trials.direction    = [dat.trials.direction ; dat.directions{n}];
                dat.trials.repeat       = [dat.trials.repeat ; r];
                
            end
        end
        
    end
    
end

% randomize trial order
dat.trials.trialnum = randperm(length(dat.trials.condition));

% emptry response arrays
dat.trials.resp         = cell(1,length(dat.trials.condition));
dat.trials.respCode     = NaN*ones(1,length(dat.trials.condition));
dat.trials.isCorrect    = NaN*ones(1,length(dat.trials.condition));

% generate random delay period for each trial
dat.trials.delayTimeSec = randi([250 750],1,length(dat.trials.condition))./1000;
dat.trials.delayUpdates = round(dat.dotUpdateHz*dat.trials.delayTimeSec);

%dat.trials.mat = [dat.trials.trialnum' dat.trials.condition dat.trials.dynamics dat.trials.repeat dat.trials.direction];

%% SOUND %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cf = 1000;                  % carrier frequency (Hz)
sf = 22050;                 % sample frequency (Hz)
d = 0.1;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation
stm.sound.s = s;
stm.sound.sf = sf;

cf = 2000;                  % carrier frequency (Hz)
sf = 22050;                 % sample frequency (Hz)
d = 0.1;                    % duration (s)
n = sf * d;                 % number of samples
s = (1:n) / sf;             % sound data preparation
s = sin(2 * pi * cf * s);   % sinusoidal modulation
stm.sound.sFeedback = s;
stm.sound.sfFeedback = sf;



