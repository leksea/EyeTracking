function drawFixation_Stereo(scr, flip)
%
% draws binocular fixation nonius to the screen, if flipIt is 1, then draw
% full nonius and flip, if flipIt is 0, draw only verticals and wait to
% flip until the stimulus is drawn too    
  
    % length of diagonal lines
	fxRadiusX2 = sqrt(((scr.fxRadiusX).^2)/2);
	fxRadiusY2 = sqrt(((scr.fxRadiusY).^2)/2);
 	
    % line width in pixels
	line_width  = 2;    
    
 	vert_R = scr.fxRadiusY;
	vert_W  = line_width;
    
    %% left screen fixation/nonius
    Screen('SelectStereoDrawBuffer', scr.wPtr, 0);
    Screen('FillRect', scr.wPtr, scr.background);	
        
	% draw dot & vert line
	Screen('FillRect', scr.wPtr, scr.lwhite, ...
		[scr.xc_l - scr.fxDotRadius scr.yc_l + scr.fxDotRadius ...
		scr.xc_l + scr.fxDotRadius scr.yc_l + scr.fxDotRadius] );
	
	Screen('DrawLine', scr.wPtr, scr.lwhite, scr.xc_l, scr.yc_l - vert_R, ...
		scr.xc_l, scr.yc_l - vert_W, vert_W);

        % horizontal
    Screen('DrawLine', scr.wPtr, scr.lwhite, scr.xc_l - scr.signRight*scr.fxRadiusX, ...
        scr.yc_l, scr.xc_l - scr.signRight*(scr.fxDotRadius + line_width), ...
		scr.yc_l , line_width);
 
	% diagonal
	Screen('DrawLine', scr.wPtr, scr.lwhite, scr.xc_l - (scr.signRight*fxRadiusX2), ...
        scr.yc_l - (scr.signRight*fxRadiusY2), ...
		scr.xc_l + (scr.signRight*fxRadiusX2), ...
		scr.yc_l  + (scr.signRight*fxRadiusY2) , line_width);

    Screen('DrawLine', scr.wPtr, scr.lwhite, scr.xc_l - (scr.signRight*fxRadiusX2), ...
        scr.yc_l  + (scr.signRight*fxRadiusY2), ...
		scr.xc_l + (scr.signRight*fxRadiusX2), ...
		scr.yc_l  - (scr.signRight*fxRadiusY2) , line_width);
    
    %% right screen fixation/nonius
    Screen('SelectStereoDrawBuffer', scr.wPtr, 1);
    Screen('FillRect', scr.wPtr, scr.background);	
	
    % draw dot & vert line
    Screen('FillRect', scr.wPtr, scr.rwhite, ...
		[scr.xc_r - scr.fxDotRadius scr.yc_r + scr.fxDotRadius ...
		scr.xc_r + scr.fxDotRadius scr.yc_r + scr.fxDotRadius] );
	
	Screen('DrawLine', scr.wPtr, scr.rwhite, scr.xc_r, scr.yc_r + vert_R, ...
		scr.xc_r, scr.yc_r + vert_W, vert_W);
    
    % horizontal

    Screen('DrawLine', scr.wPtr, scr.rwhite, scr.xc_r + scr.signRight*scr.fxRadiusX, ...
        scr.yc_r, scr.xc_r + scr.signRight*scr.fxDotRadius + line_width, ...
		scr.yc_r , line_width);
 
	% diagonal
	Screen('DrawLine', scr.wPtr, scr.rwhite, scr.xc_r - (scr.signRight*fxRadiusX2), ...
		scr.yc_r - (scr.signRight*fxRadiusY2), ...
		scr.xc_r + (scr.signRight*fxRadiusX2), ...
		scr.yc_r  + (scr.signRight*fxRadiusY2) , line_width);
	
	Screen('DrawLine', scr.wPtr, scr.rwhite, scr.xc_r - (scr.signRight*fxRadiusX2), ...
		scr.yc_r  + (scr.signRight*fxRadiusY2), ...
		scr.xc_r + (scr.signRight*fxRadiusX2), ...
		scr.yc_r  - (scr.signRight*fxRadiusY2) , line_width);    
    
    Screen('Flip', scr.wPtr);
end