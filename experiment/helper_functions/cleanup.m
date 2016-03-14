% Cleanup routine:
function cleanup(early, stm)
	if stm.recording
		Eyelink('Shutdown');    % Shutdown Eyelink:
	end
	sca;                    % Close window:
	ListenChar(0);          % Restore keyboard output to Matlab:
	if(early)
		store_results(stm);
		warning('Exited experiment before completion');
		clear all;
	end
	commandwindow;
end