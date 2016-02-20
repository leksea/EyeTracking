function [dotsLE,dotsRE] = stimulus_make_left_right_dots(scr,stm,condition)
%
% make a single frame of dots for a given condition
switch condition
    
    case 'SingleDot'        % just one dot per eye in center
        
        dotsLE = [0 0]';
        dotsRE = [0 0]';
        
    case 'IOVD'         % for IOVD, two eyes are uncorrelated
        
        [dotsLE] = stimulus_make_random_dots(stm.xmax,stm.ymax,stm.numDots);
        [dotsRE] = stimulus_make_random_dots(stm.xmax,stm.ymax,stm.numDots);
        
    case {'Mixed','MixedCons','MixedIncons'}  % for Mixed, first 1/2 are correlated, 2nd half uncorrelated
        
        [dots1]     = stimulus_make_random_dots(stm.xmax,stm.ymax,round(stm.numDots/2));
        
        [dotsLE2]   = stimulus_make_random_dots(stm.xmax,stm.ymax,round(stm.numDots/2));
        [dotsRE2]   = stimulus_make_random_dots(stm.xmax,stm.ymax,round(stm.numDots/2));
        
        dotsLE      = [dots1 dotsLE2];
        dotsRE      = [dots1 dotsRE2];
        
    case {'CDOT','FullCue'}           % otherwise, same dots in both eyes
        
        [dots] = stimulus_make_random_dots(stm.xmax,stm.ymax,stm.numDots);
        
        dotsLE = dots;
        dotsRE = dots;
        
    otherwise
        
        error('invalid stimulus cues');
        
end

dotsRE(1,:) = scr.signRight.*dotsRE(1,:); % deal with mirror reversal
