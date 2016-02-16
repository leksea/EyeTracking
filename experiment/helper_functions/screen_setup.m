function [scr, w, winRect] = screen_setup(scr)
%
% open and set up PTB screen window

scr.screenNumber = max(Screen('Screens'));      % Use max screen number
PsychImaging('PrepareConfiguration');       % Prepare pipeline for configuration.

if scr.skipSync
    Screen('Preference', 'SkipSyncTests', 1);
else
    Screen('Preference', 'SkipSyncTests', 0);
end


[w, winRect] = PsychImaging('OpenWindow', scr.screenNumber, ...
                                        0, [], [], [], [], 4);      % Open PTB graphics window
Screen(w,'BlendFunction',GL_ONE, GL_ONE);                      % Enable alpha blending - these are the settings that are needed for Planar

%scr.calicolor = [52 52 52];                                         % bg color during calbration - not black so that itapprox matches mean screen luminance during stim
%scr.calicolor = [0 0 0];

%fill screen
Screen('FillRect', w, [0 0 0], InsetRect(Screen('Rect', w), -1, -1));
Screen('Flip', w);

scr.frameRate   = Screen('NominalFrameRate',w);

if scr.frameRate < 1
    scr.frameRate = 60; % ### Workaround by Holly G. Jan. 7 2016, so that iMac display (which returns 0 for the framerate) will work
    fprintf('\n\nWARNING!!! screen frame rate has been set to 60 Hz and was reported near 0!!!\n\n')
end

% PTB can't seem to get the frame rate of this display
if strcmp(scr.name, 'CinemaDisplayRB');
    scr.frameRate = 60;
    warning('Note: CinemaDisplay true frame rate is 59.95 Hz but is being set as 60.');
end

scr.width_pix   = RectWidth(Screen('Rect', scr.screenNumber));
scr.height_pix  = RectHeight(Screen('Rect', scr.screenNumber));

% Disable key output to Matlab window:
ListenChar(2);

% if using planar, must be in native resolution for accurate eyetracking
if strcmp(scr.name,'planar')
    res = Screen('Resolution', scr.screenNumber)
    
    if res.width ~= 1600 || res.height ~= 1200 || res.pixelSize ~= 32 || res.hz ~= 60
        %error('Planar not in native resolution'); % HG 1/8/2016 commented
        %to test
        fprintf('Planar not in native resolution');
    end
end