function result=eyelink_do_cali_steps(el, sendkey)

% USAGE: result=EyelinkDoTrackerSetup(el [, sendkey])
%
%		el: Eyelink default values
%		sendkey: set to go directly into a particular mode
% 				'v', start validation
% 				'c', start calibration
% 				'd', start driftcorrection
% 				13, or el.ENTER_KEY, show 'eye' setup image

%
% 02-06-01	fwc removed use of global el, as suggest by John Palmer.
%				el is now passed as a variable, we also initialize Tracker state bit
%				and Eyelink key values in 'initeyelinkdefaults.m'
% 15-10-02	fwc	added sendkey variable that allows to go directly into a particular mode
% 22-06-06	fwc OSX-ed
% 15-06-10	fwc added code for new callback version
%
% Emily renamed and cleaned up this PTB code


result = -1;
if nargin < 1
	error( 'USAGE: result=EyelinkDoTrackerSetup(el [,sendkey])' );
end


Eyelink( 'StartSetup' );                                    % start setup mode
Eyelink( 'WaitForModeReady', el.waitformodereadytime );     % time for mode change
EyelinkClearCalDisplay(el);                                 % setup_cal_display()


key = 1;
while key ~= 0
	key = eyelink_get_key(el);                              % dump old keys
end


if nargin == 2                                              % go directly into a particular mode if given
	
    if el.allowlocalcontrol == 1
		
        switch lower(sendkey)
			case{ 'c', 'v', 'd', el.ENTER_KEY}
				forcedkey = double(sendkey(1,1));
				Eyelink('SendKeyButton', forcedkey, 0, el.KB_PRESS );
        end
        
    end
    
end

tstart  = GetSecs;
stop    = 0;

while stop == 0 && bitand(Eyelink( 'CurrentMode'), el.IN_SETUP_MODE)

	i = Eyelink( 'CurrentMode');
	if ~Eyelink( 'IsConnected' ); stop=1; break; end;

	if bitand(i, el.IN_TARGET_MODE)			% calibrate, validate, etc: show targets

		eyelink_target_mode_display(el);	
        
	elseif bitand(i, el.IN_IMAGE_MODE)		% display image until we're back
% 		
	  	if Eyelink ('ImageModeDisplay')==el.TERMINATE_KEY 
			result=el.TERMINATE_KEY;
	    	return;                         % breakout key pressed
	  	else
			EyelinkClearCalDisplay(el);     % setup_cal_display()
		end	
	end

	[key, el]=eyelink_get_key(el);		% getkey() HANDLE LOCAL KEY PRESS
    if 1 && key~=0 && key~=el.JUNK_KEY    % print pressed key codes and chars
        fprintf('%d\t%s\n', key, char(key) );
    end
    
	switch key	
		case el.TERMINATE_KEY,				% breakout key code
			result=el.TERMINATE_KEY;
			return;
		case { 0, el.JUNK_KEY }          % No or uninterpretable key
		case el.ESC_KEY,
			if Eyelink('IsConnected') == el.dummyconnected
				stop=1; % instead of 'goto exit'
			end
		    if el.allowlocalcontrol==1
	       		Eyelink('SendKeyButton', key, 0, el.KB_PRESS );
			end
		otherwise, 		% Echo to tracker for remote control
		    if el.allowlocalcontrol==1
	       		Eyelink('SendKeyButton', double(key), 0, el.KB_PRESS );
			end
	end
	
	WaitSecs(0.1);
	
end % while IN_SETUP_MODE

% exit:
EyelinkClearCalDisplay(el);	% exit_cal_display()
result=0;
return;	
