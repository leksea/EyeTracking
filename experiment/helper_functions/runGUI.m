function [myData, myScr] = runGUI(settings, dataPath)

    % load in options
    displays    = getDisplays(etpath.displays);
    conditions  = getConditions;
    dynamics    = getDynamics;
    ipdmat      = getIpds;
    directions  = {'away', 'towards', 'left', 'right'};
    experiments = getExperiments(etpath.experiments);

    % load in experiment settings
    if isempty(settings)
        myData             = defaultSettings;
        myData.exp_name    = 'default';
        myScr			   = displays.data{ismember(displays.names, myData.display)};
	else
        myData             = eval(settings{1});
        myData.exp_name    = settings{1};
        myData.subj        = 'XX';
        myScr			   = displays.data{ismember(displays.names, myData.display)};
        return
    end
    
    % don't start experiment until all settings are selected
    go      = 0;
    subj    = 'XX';
    ipd     = 0;
    exp_mod = 0;
    num_trials = 0; update_num_trials(0);

    f = createGUI(myData, experiments, displays, conditions, dynamics, directions, ipdmat);
    
    
    
    %% Run the GUI

    set(f,'Name','MID Experiment Settings') %GUI title
    movegui(f,'center');             % Move the GUI to the center of the screen
    set(f,'Visible','on');              % Make the GUI visible
    waitfor(f);                         % Exit if Gui is closed
                                                                                                                                    
    %empty function -- AY
    gui_store_ipd(dat, ipds)                  % store initials/IPD pair for this session

    if(~go)
        error('GUI exited without pressing Start');
    end
end

function guiData = createGUI(inData, inExperiments, inDisplays, inConditions, inDynamics, inDirections, inIPD)
    
    %  Create and then hide the GUI as it is being constructed
    sz      = [360, 500, 500, 500];
    marg    = 30;
    guiData.f = figure('Visible', 'off', 'Position', sz);
    guiData.myData = inData;
    guiData.experiments = inExperiments;
    guiData.displays = inDisplays;
    guiData.conditions = inConditions;
    guiData.dynamics = inDynamics;
    guiData.directions = inDirections;
    guiData.ipd = inIPD;
    

    %% list experiments 
    
    etext = uicontrol('Style','text','String','Experiment',...
        'Position',[marg, sz(2) - marg, 60, 25]);
    
    guiData.epopup = uicontrol('Style','popupmenu',...
        'String',{guiData.experiments(:).name},...
        'Position',[marg + 60,sz(2) - marg,200,26],...
        'Callback',{@exp_Callback},...
        'Value',find(strcmp({guiData.experiments(:).name}, guiData.myData.exp_name)));

    guiData.warn_me = uicontrol('Style','text','String','',...
        'Position',[marg + 275,sz(2) - marg,190,25]);

    align([etext, guiData.epopup, guiData.warn_me],'None','Top');


    %% subject initials
    stext = uicontrol('Style','text','String','Subject',...
        'Position',[marg,sz(2) - marg*2,60,25]);
    
    guiData.sbox = uicontrol('Style','edit',...
        'String',subj,...
        'Position',[marg + 60,sz(2) - marg*2,60,26],...
        'Callback',{@subj_Callback});

    %% IPD
    ptext = uicontrol('Style','text','String','IPD (cm)',...
        'Position',[marg + 130,sz(2) - marg*2,60,25]);
    guiData.pbox = uicontrol('Style','edit',...
        'String',guiData.ipd,...
        'Position',[marg + 190,sz(2) - marg*2,60,26],...
        'Callback',{@ipd_Callback});

    align([stext, guiData.sbox, ptext, guiData.pbox],'None','Top');


    %% list displays
    dtext = uicontrol('Style','text','String','Display',...
        'Position',[marg,sz(2) - marg*3,60,25]);
    
    guiData.dpopup = uicontrol('Style','popupmenu',...
        'String',{guiData.displays.names},...
        'Position',[marg + 60,sz(2) - marg*3,200,26],...
        'Callback',{@display_Callback},...
        'Value',guiData.displays.data{ismember(guiData.displays.names, guiData.myData.display)});


    align([dtext,dpopup],'None','Top');

    %% recording options
    rradio = uicontrol('Style', 'radiobutton', ...
        'String',   'record', ...
        'Callback', @recording_Callback, ...
        'Position',[marg + 60,sz(2) - marg*4,200,25],...
        'Value',    guiData.myData.recording);

    %% feedback options
    guiData.fradio = uicontrol('Style', 'radiobutton', ...
        'String',   'provide feedback', ...
        'Callback', @feedback_Callback, ...
        'Position', [marg + 60,sz(2) - marg*5,200,25],...
        'Value',    guiData.myData.training);

    %% start experiment
    guiData.start = uicontrol('Style', 'pushbutton', ...
        'String',   'Start', ...
        'Callback', @start_Callback, ...
        'BackgroundColor',get_color(4), ...
        'Position',[marg + 60,sz(2) - marg*14.5,200,25]);


    %% save as new experiment
    guiData.zbox = uicontrol('Style','edit',...
        'String','NewName',...
        'Position',[marg + 60,marg,200,25],...
        'Callback',{@newName_Callback});

    guiData.store = uicontrol('Style', 'pushbutton', ...
        'String',   'Store Settings', ...
        'Callback', @storeExp_Callback, ...
        'Position',[marg + 275,marg,100,25]);

    align([store, guiData.zbox], 'None', 'Top');


    %% disparity magnitude
    d1text = uicontrol('Style','text','String','Step Disp (am)',...
        'Position',[marg,sz(2) - marg*7,60,30]);
    guiData.d1box = uicontrol('Style','edit',...
        'String',guiData.myData.dispArcmin,...
        'Position',[marg + 60,sz(2) - marg*7,50,31],...
        'BackgroundColor',ColorIt(3), ...
        'Tag','dispArcmin', ...
        'Callback',{@text_Callback});

    align([d1text, guiData.d1box],'None','Center');

    %% ramp velocity
    d8text = uicontrol('Style','text','String','Speed (deg/sec)',...
        'Position',[marg + 150,sz(2) - marg*7,60,30]);
    guiData.d8box = uicontrol('Style','edit',...
        'String',guiData.myData.rampSpeedDegSec,...
        'Position',[marg + 210,sz(2) - marg*7,50,31],...
        'BackgroundColor',ColorIt(3), ...
        'Tag','rampSpeedDegSec', ...
        'Callback',{@text_Callback});

    align([d8text, guiData.d8box],'None','Center');

    %% stimulus radius
    d2text = uicontrol('Style','text','String','Stim Radius (deg)',...
        'Position',[marg + 150,sz(2) - marg*8,60,30]);
    
    guiData.d2box = uicontrol('Style','edit',...
        'String', guiData.myData.stimRadDeg,...
        'Position',[marg + 210,sz(2) - marg*8,50,31],...
        'Tag','stimRadDeg', ...
        'Callback',{@text_Callback});

    align([d2text, guiData.d2box],'None','Center');

    %% dot diameter
    d3text = uicontrol('Style','text','String','Dot Diam (deg)',...
        'Position',[marg,sz(2) - marg*8,60,30]);
    
    guiData.d3box = uicontrol('Style','edit',...
        'String', guiData.myData.dotSizeDeg,...
        'Position',[marg + 60,sz(2) - marg*8,50,31],...
        'Tag','dotSizeDeg', ...
        'Callback',{@text_Callback});

    align([d3text, guiData.d3box],'None','Center');

    % dot density
    d4text = uicontrol('Style','text','String','Density (d/deg2)',...
        'Position',[marg + 150,sz(2) - marg*9,60,30]);
    guiData.d4box = uicontrol('Style','edit',...
        'String', guiData.myData.dotDensity,...
        'Position',[marg + 210,sz(2) - marg*9,50,31],...
        'Tag','dotDensity', ...
        'Callback',{@text_Callback});

    align([d4text, guiData.d4box],'None','Center');

    %% prelude time
    d5text = uicontrol('Style','text','String','Prelude (sec)',...
        'Position',[marg,sz(2) - marg*9,60,30]);
    
    guiData.d5box = uicontrol('Style','edit',...
        'String', guiData.myData.preludeSec,...
        'Position',[marg + 60,sz(2) - marg*9,50,31],...
        'Tag','preludeSec', ...
        'Callback',{@text_Callback});

    align([d5text, guiData.d5box],'None','Center');

    %% stim time
    d6text = uicontrol('Style','text','String','Stim (sec) (one ramp)',...
        'Position',[marg + 150,sz(2) - marg*10,60,30]);
    
    guiData.d6box = uicontrol('Style','edit',...
        'String', guiData.myData.cycleSec,...
        'Position',[marg + 210,sz(2) - marg*10,50,31],...
        'Tag','cycleSec', ...
        'Callback',{@text_Callback});

    align([d6text, guiData.d6box],'None','Center');

    %% condition repeats
    d7text = uicontrol('Style','text','String','Num repeats',...
        'Position',[marg,sz(2) - marg*10,60,30]);
    
    guiData.d7box = uicontrol('Style','edit',...
        'String', guiData.myData.cond_repeats,...
        'Position',[marg + 60,sz(2) - marg*10,50,31],...
        'Tag','cond_repeats', ...
        'Callback',{@text_Callback});

    align([d7text, guiData.d7box],'None','Center');


    numtext = uicontrol('Style','text','String',...
        ['Num Trials: ' num2str(num_trials)],...
        'Position',[marg,sz(2) - marg*12,60,30]);

    guiData.durtext = uicontrol('Style','text','String',...
        ['Duration: ' num2str((num_trials*(5 + guiData.myData.preludeSec + guiData.myData.cycleSec))/60) ' Min'],...
        'Position',[marg,sz(2) - marg*13,60,30]);


    %% condition options

    for c = 1:length(guiData.conditions)
        guiData.cradio(c) = uicontrol('Style', 'radiobutton', ...
            'String',   guiData.conditions{c}, ...
            'Callback', @condition_Callback, ...
            'Position',[sz(1) - marg,sz(2) - marg*(4 + c),200,25],...
            'Value',    ismember(guiData.conditions{c}, guiData.myData.conditions));
    end


    for d = 1:length(guiData.dynamics)
        guiData.dradio(d) = uicontrol('Style', 'radiobutton', ...
            'String',   guiData.dynamics{d}, ...
            'Callback', @dynamics_Callback, ...
            'Position',[sz(1) - marg,sz(2) - marg*(11 + d),200,25],...
            'Value',    ismember(guiData.dynamics{d}, guiData.myData.dynamics));
    end


    for t = 1:length(guiData.directions)
    
        locx = 2;
        if t <= 2; locx = 1; end        
        
        locy = 2;
        if mod(t , 2) == 0; locy = 1;  end
    
        guiData.tradio(t) = uicontrol('Style', 'radiobutton', ...
            'String',   guiData.directions{t}, ...
            'Callback', @directions_Callback, ...
            'Position',[marg + 90*locx, sz(2) - marg*(11 + locy),100,25],...
            'Value',    ismember(guiData.directions{t}, guiData.myData.directions));
        end



    %% draw boxes

    a = axes;
    set(a, 'Visible', 'off');
    %# Stretch the axes over the whole figure.
    set(a, 'Position', [0, 0, 1, 1]);
    %# Switch off autoscaling.
    set(a, 'Xlim', [0, 1], 'YLim', [0, 1]);

    %# Draw!
    hold on;
    text(0.05,0.66,'Stimulus Properties');
    rectangle('Position',[0.05,0.39,0.53,0.25])
    text(0.23,0.345,'Motion Directions');
    rectangle('Position',[0.23,0.22,0.29,0.11])
    text(0.65,0.77,'Cue Properties');
    rectangle('Position',[0.65,0.39,0.2,0.365])
    text(0.65,0.34,'Dynamics');
    rectangle('Position',[0.65,0.15,0.2,0.175])

    hold off

end

function updateCallbacks(guiData)
% 
    set(guiData.pp, 'callback', {@exp_Callback, guiData});  % update the popup callback.    
    set(S.edX, 'callback', {@edX_call, S});  % update the edit callback.
    set(S.edHX, 'callback', {@edHX_call, S});  % update the edit callback.    
    set(S.edY, 'callback', {@edY_call, S});  % update the edit callback.
    set(S.edHY, 'callback', {@edHY_call, S});  % update the edit callback.    
    set(S.pb, 'callback', {@pb_call, S});
end


function exp_Callback(guiData)
        
 
        str = get(source, 'String');
        val = get(source,'Value');
        
        myData = varargin{3};
        myScr = varargin{4};
        
        dat             = eval(str{val});
        dat.subj        = subj;
        dat.ipd         = ipd;
        dat.exp_name    = str{val};
        scr				= dspl(find(strcmp({dspl(:).name},dat.display)));
        
        update_num_trials(1)
        
        set(dpopup,'Value',find(strcmp({dspl(:).name},dat.display)));
        set(rradio,'Value',dat.recording);
        set(fradio,'Value',dat.training);
        
        set(d1box,'String',num2str(dat.dispArcmin));
        set(d8box,'String',num2str(dat.rampSpeedDegSec));
        set(d2box,'String',num2str(dat.stimRadDeg));
        set(d3box,'String',num2str(dat.dotSizeDeg));
        set(d4box,'String',num2str(dat.dotDensity));
        
        set(d5box,'String',num2str(dat.preludeSec));
        set(d6box,'String',num2str(dat.cycleSec));
        set(d7box,'String',num2str(dat.cond_repeats));
        
        for x = 1:length(cradio)
            set(cradio(x),'Value',ismember(get(cradio(x),'String'),dat.conditions));
        end
        
        for y = 1:length(dradio)
            set(dradio(y),'Value',ismember(get(dradio(y),'String'),dat.dynamics));
        end
        
        for z = 1:length(tradio)
            set(tradio(z),'Value',ismember(get(tradio(z),'String'),dat.directions));
        end
        
        
    end


    function subj_Callback(source, eventdata)
        
        str = get(source, 'String');
        subj = str;
        
        if sum(ismember(ipdmat.subj,subj)) > 0
            ipd = ipdmat.ipd(ismember(ipdmat.subj,subj));
            set(pbox,'String',ipd);
        end
    end

    function ipd_Callback(source, eventdata)
        
        str = get(source, 'String');
        ipd = str2num(str);
        
    end


    function display_Callback(source, eventdata)
        str			= get(source, 'String');
        val			= get(source,'Value');
        dat.display = str{val};
        scr			= dspl(find(strcmp({dspl(:).name},dat.display)));
        exp_mod     = 1;
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
    end


    function recording_Callback(source,eventdata)
        
        val = get(source,'Value');
        dat.recording = val;
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
    end


    function feedback_Callback(source,eventdata)
        
        val = get(source,'Value');
        dat.training = val;
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
    end


    function start_Callback(source,eventdata)
        
        go          = 1;
        dat.subj    = subj;
        dat.ipd     = ipd;
        
        if ipd == 0
            set(warn_me,'String','WARNING: IPD cannot be zero','BackgroundColor',ColorIt(1));
            error('cannot run experiment without IPD filled in')
        end
        
        if exp_mod == 1
            set(warn_me,'String','WARNING: Experiment modified and must be renamed','BackgroundColor',ColorIt(1));
            error('cannot run experiment without changing name')
        end
        
        close all;
    end


    function newName_Callback(source,eventdata)
        
        str = get(source, 'String');
        
        if ~isempty(str2num(str(1))) && ~strcmp('i',str(1)) && ~strcmp('j',str(1))
            dat.exp_name = 'tmpfile';
        else
            dat.exp_name = str;
        end
    end


    function storeExp_Callback(source,eventdata)
        
        if strcmp(dat.exp_name,'tmpfile')
            set(warn_me,'String','WARNING: Filename cannot start with a number','BackgroundColor',ColorIt(1));
            error('Filename cannot start with a number');
        else
            gui_create_new_experiment(dat)
            
            exp         = gui_load_experiments;
            set(epopup,'String',{exp(:).name}, ...
                'Value',find(strcmp({exp(:).name},dat.exp_name)));
            set(warn_me,'String','','BackgroundColor',[.94 .94 .94]);
            
            exp_mod     = 0;
        end
        
    end



    function text_Callback(source,eventdata)
        
        str = get(source, 'String');
        dat.(get(source,'tag')) = str2num(str);
        
        if ~strcmp(get(source,'tag'),'cond_repeats')
            exp_mod     = 1;
        else
            update_num_trials(1)
        end
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
        
        
    end


    function condition_Callback(source,eventdata)
        
        val = get(source,'Value');
        
        cname = get(source,'String');
        
        if val && ~ismember(cname,dat.conditions)
            dat.conditions{end+1} = cname;
        elseif ~val && ismember(cname,dat.conditions)
            ind = find(ismember(dat.conditions,cname));
            dat.conditions(ind) = [];
        end
        
        update_num_trials(1)
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
    end



    function dynamics_Callback(source,eventdata)
        
        val = get(source,'Value');
        
        dname = get(source,'String');
        
        if val && ~ismember(dname,dat.dynamics)
            dat.dynamics{end+1} = dname;
        elseif ~val && ismember(dname,dat.dynamics)
            ind = find(ismember(dat.dynamics,dname));
            dat.dynamics(ind) = [];
        end
        
        update_num_trials(1)
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
    end


    function directions_Callback(source,eventdata)
        
        val = get(source,'Value');
        
        tname = get(source,'String');
        
        if val && ~ismember(tname,dat.directions)
            dat.directions{end+1} = tname;
        elseif ~val && ismember(tname,dat.directions)
            ind = find(ismember(dat.directions,tname));
            dat.directions(ind) = [];
        end
        
        update_num_trials(1)
        
        set(warn_me,'String','ALERT: Conditions changed','BackgroundColor',ColorIt(5));
    end

    function  update_num_trials(flag)
        
        num_trials  = (dat.cond_repeats...
            *length(dat.directions)*length(dat.dynamics)...
            *length(dat.conditions));
        
        if(flag)
            set(numtext,'String',['Num Trials: ' num2str(num_trials)]);
            set(durtext,'String',['Duration: ' num2str((num_trials*(5+dat.preludeSec+dat.cycleSec))/60) ' Min']);
        end
        
    end
