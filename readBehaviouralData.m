clear all
close all
subs_dir = struct2table(dir('D:\Data\Chick\Imprinting\analysis\sub*'));
%subs_dir =subs_dir(1:end,:);
dummy_scans = 10;%volumes
TR = 4;%sec
%%
readExperimentInfo(subs_dir, dummy_scans, TR)

%readExperimentInfo_single_trials(subs_dir, dummy_scans, TR)
