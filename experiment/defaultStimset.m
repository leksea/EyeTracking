function dat = defaultStimset

	% set up properties
	dat.exp_name        = 'testingNewScripts';
	dat.nonius          = 0;      % nonius on during trial (1) or not(0)

	% dot field properties
	dat.stimRadDeg      = 20;      % stimulus field radius
	dat.dispArcmin      = 240;      % disparity magnitude
	dat.rampSpeedDegSec = [1, 2];      % ramp speed in degrees per second
	dat.dotSizeDeg      = [0.25, 0.5];      % diameter of each dot
	dat.dotDensity      = 2;      % dots per degree2

	% timing
	dat.preludeSec      = 0.25;      % delay before motion onset
	dat.cycleSec        = 2;      % duration of stimulus after prelude
	dat.cond_repeats    = 1;      % number of repeats per condition
	
	dat.amplitudeDeg    = 0.2;
	dat.freqHz          = 0.5;
	% dot update params
	dat.dotUpdateHz     = 60;        
	dat.numCycles       = 1;         
end
