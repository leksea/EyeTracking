function drawFixation(w, scr, flipIt)
%
% draws binocular fixation nonius to the screen, if flipIt is 1, then draw
% full nonius and flip, if flipIt is 0, draw only verticals and wait to
% flip until the stimulus is drawn too


% length of diagonal lines
	fixationRadiusXPix2 = sqrt(((scr.fixationRadiusXPix).^2)/2);
	fixationRadiusYPix2 = sqrt(((scr.fixationRadiusYPix).^2)/2);

	% line width in pixels
	line_width  = 2;

	% bg
	Screen('FillRect', w, scr.glevel);

	% central square - same size as dots
	Screen('FillRect', w, scr.LEwhite, ...
		[scr.x_center_pix_left - scr.fixationDotRadiusPix ...
		scr.y_center_pix_left - scr.fixationDotRadiusPix ...
		scr.x_center_pix_left + scr.fixationDotRadiusPix ...
		scr.y_center_pix_left + scr.fixationDotRadiusPix] );

	Screen('FillRect', w, scr.REwhite, ...
		[scr.x_center_pix_right - scr.fixationDotRadiusPix ...
		scr.y_center_pix_right - scr.fixationDotRadiusPix ...
		scr.x_center_pix_right + scr.fixationDotRadiusPix ...
		scr.y_center_pix_right + scr.fixationDotRadiusPix] );


	% nonius lines


	% vertical
	if flipIt
	
		% make verticals the same as all other lines
		vertical_radius = scr.fixationRadiusYPix;
		vertical_width  = line_width;
	
	else
	
		% make verticals the same as all other lines
		vertical_radius = scr.fixationRadiusYPix*2;
		vertical_width  = line_width*3;
	
	end

	% draw vertical lines
	Screen('DrawLine', w, scr.REwhite, scr.x_center_pix_right, ...
		scr.y_center_pix_right  - (vertical_radius), ...
		scr.x_center_pix_right, ...
		scr.y_center_pix_right - (vertical_width) , vertical_width);

	Screen('DrawLine', w, scr.LEwhite, scr.x_center_pix_left, ...
		scr.y_center_pix_left + (vertical_radius), ...
		scr.x_center_pix_left, ...
		scr.y_center_pix_left + (vertical_width), vertical_width);



	% draw other lines and flip
	if flipIt	
	% horizontal
		Screen('DrawLine', w, scr.REwhite, scr.x_center_pix_right - (scr.signRight*stm.fixationRadiusXPix), ...
			scr.y_center_pix_right, ...
			scr.x_center_pix_right - (scr.signRight*stm.fixationDotRadiusPix + line_width), ...
			scr.y_center_pix_right , line_width);
	
		Screen('DrawLine', w, scr.LEwhite, scr.x_center_pix_left + (stm.fixationDotRadiusPix + line_width), ...
			scr.y_center_pix_left, ...
			scr.x_center_pix_left + (stm.fixationRadiusXPix), ...
			scr.y_center_pix_left, line_width);
	
		% diagonal
		Screen('DrawLine', w, scr.REwhite, scr.x_center_pix_right - (scr.signRight*fixationRadiusXPix2), ...
			scr.y_center_pix_right  - (scr.signRight*fixationRadiusYPix2), ...
			scr.x_center_pix_right + (scr.signRight*fixationRadiusXPix2), ...
			scr.y_center_pix_right  + (scr.signRight*fixationRadiusYPix2) , line_width);
	
		Screen('DrawLine', w, scr.REwhite, scr.x_center_pix_right - (scr.signRight*fixationRadiusXPix2), ...
			scr.y_center_pix_right  + (scr.signRight*fixationRadiusYPix2), ...
			scr.x_center_pix_right + (scr.signRight*fixationRadiusXPix2), ...
			scr.y_center_pix_right  - (scr.signRight*fixationRadiusYPix2) , line_width);
	
		Screen('DrawLine', w, scr.LEwhite, scr.x_center_pix_left - (fixationRadiusXPix2), ...
			scr.y_center_pix_left  - (fixationRadiusYPix2), ...
			scr.x_center_pix_left + (fixationRadiusXPix2), ...
			scr.y_center_pix_left  + (fixationRadiusYPix2) , line_width);
	
		Screen('DrawLine', w, scr.LEwhite, scr.x_center_pix_left - (fixationRadiusXPix2), ...
			scr.y_center_pix_left  + (fixationRadiusYPix2), ...
			scr.x_center_pix_left + (fixationRadiusXPix2), ...
			scr.y_center_pix_left  - (fixationRadiusYPix2) , line_width);
	
		Screen('Flip', w);
	end

