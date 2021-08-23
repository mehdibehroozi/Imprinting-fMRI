function readExperimentInfo(subs_dir, dummy_scans, TR)
% extract the timing of experiment.
% subs_dir = struct2table(dir('D:\Data\Chick\analysis\imprinting_August2019\sub*'));

sub_num = subs_dir.name;
analysisDir = subs_dir.folder{1};
sourceB = fullfile(analysisDir, sub_num, 'behavioural');% source of behavioural data
% destinationB = sourceB;% output for MVPA data analysis
for s = 1: length(sourceB)
    FileName = dir(fullfile(sourceB{s},'*.mat'));
    disp(FileName.name)
    mat_in=fullfile(sourceB{s},FileName.name);
    inp=load(mat_in);
    %% create experiment files for imprinting and non imprinting color
    data.imprinted_color=inp.info.Imprinting_Color;
    data.nExp=inp.info.exp_num;
    data.nRun=inp.info.nRUN;% data can be devided to the eight section;
    data.TR=round(inp.results.TR(end));% seconds
    data.initialVol=inp.info.DummyScan;% volume
    data.finalVol=inp.info.finalBlank;% volume
    data.stimDur=inp.info.StimulationDuration;% volume
    data.itiDur=inp.info.ITI_period;% volume
    data.flickeringFreq=inp.info.FlickeringFrequency;% Hz
    data.nTrials=inp.info.Num_Trial;
    data.nTrial=[1:inp.info.Num_Trial]';
    data.stimOnset=(inp.results.time_blocks_Onset-dummy_scans*TR)';% seconds
    data.stimOffset=(inp.results.time_end_CS-dummy_scans*TR)';% seconds
    %%
    %creat label of trials
    f1=find(inp.results.color(:,1)==1);% red color
    f2=find(inp.results.color(:,1)==0);% blue color
    target=string(nan(inp.info.Num_Trial,1));
    trialType=string(nan(inp.info.Num_Trial,1));
    target(f1,:)='red';
    target(f2,:)='blue';
    data.colors=target;
    if isequal(inp.info.Imprinting_Color, 'Red')
        trialType(f1,:)='imprinted';
        trialType(f2,:)='control';
    elseif isequal(inp.info.Imprinting_Color, 'Blue')
        trialType(f1,:)='control';
        trialType(f2,:)='imprinted';
    end
    data.type = trialType;
    save([sourceB{s}, '\res_exp_', sub_num{s}, '.mat'], 'data')
    
    %% save results as a text file for FSL
    trial_iems(:,1)=data.stimOnset;
    trial_iems(:,2)=data.stimOffset-data.stimOnset;
    trial_iems(:,3)=1;
    r=find(data.colors=='red');
    b=find(data.colors=='blue');
    red_time=trial_iems(r,:);
    blue_time=trial_iems(b,:);
    
    if isequal(inp.info.Imprinting_Color, 'Red')
        dlmwrite([sourceB{s},'\imprinted_whole_trials.txt'],red_time,'delimiter','\t');
        dlmwrite([sourceB{s},'\control_whole_trials.txt'],blue_time,'delimiter','\t');
    elseif isequal(inp.info.Imprinting_Color, 'Blue')
        dlmwrite([sourceB{s},'\control_whole_trials.txt'],red_time,'delimiter','\t');
        dlmwrite([sourceB{s},'\imprinted_whole_trials.txt'],blue_time,'delimiter','\t');
    end
    imprinting_color {s} =  inp.info.Imprinting_Color;
    %%
    junk_trials = trial_iems(1:16,:);
    normal_trials = trial_iems(17:end,:);
    Tcolor = data.colors(17:end,:);
    
    r=find(Tcolor=='red');
    b=find(Tcolor=='blue');
    red_time=normal_trials(r,:);
    blue_time=normal_trials(b,:);
    
    if isequal(inp.info.Imprinting_Color, 'Red')
        dlmwrite([sourceB{s},'\imprinted_trials.txt'],red_time,'delimiter','\t');
        dlmwrite([sourceB{s},'\control_trials.txt'],blue_time,'delimiter','\t');
        dlmwrite([sourceB{s},'\junk_trials.txt'],junk_trials,'delimiter','\t');
    elseif isequal(inp.info.Imprinting_Color, 'Blue')
        dlmwrite([sourceB{s},'\control_trials.txt'],red_time,'delimiter','\t');
        dlmwrite([sourceB{s},'\imprinted_trials.txt'],blue_time,'delimiter','\t');
        dlmwrite([sourceB{s},'\junk_trials.txt'],junk_trials,'delimiter','\t');
    end
end
subs_info.sub_num=sub_num;
subs_info.impronting_color = imprinting_color';
subjects_info=struct2table(subs_info);
writetable(subjects_info,'subjects_info.txt','Delimiter','	');
end
