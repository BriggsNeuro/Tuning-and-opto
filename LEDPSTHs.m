%analyze latency and precision of high versus low contrast grating stimuli
%(no LED)

name1 = 'Enter Number of cells to analyze';
prompt1 = {'Number of cells'};
numlines = 1;
defaultparams1 = {'1'};
params1 = inputdlg(prompt1,name1,numlines,defaultparams1);
numRep = str2double(params1{1});

for i = 1:numRep
%     [datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
%     load(datafile);
    
    name = 'Enter info for cell to analyze';
    prompt = {'matlab num','AorB (1 or 2)','Structure num','bin size'};
    defaultparams = {'24','1','2','10'};
    params = inputdlg(prompt,name,numlines,defaultparams);
    unit = str2double(params{1});
    AorB = str2double(params{2});
    r = str2double(params{3});
    binsize = str2double(params{4});
    
    if AorB == 1
        spikes = data(r).unitAts(:,unit);
    elseif AorB == 2
        spikes = data(r).unitBts(:,unit);
    end
    
   trialstart = [];
        numsteps = str2num(char(data(r).results(1,2)));
        numrepeats = str2num(char(data(r).results(2,2)));
        numtrials = numsteps * numrepeats;
        if numtrials > length(data(r).trialstartts) && numtrials > length(data(r).trialendts)
            if length(data(r).trialendts) > length(data(r).trialstartts)
                numtrials = length(data(r).trialendts);
                for s = 1:numtrials
                    a = [];
                    a = find(data(r).gratcyclets < data(r).trialendts(s));
                    trialstart(s) = data(r).gratcyclets(a(end));
                end
            else numtrials = length(data(r).trialstartts);
                for s = 1:numtrials
                    a = [];
                    a = find(data(r).gratcyclets > data(r).trialstartts(s));
                    trialstart(s) = data(r).gratcyclets(a(1));
                end
            end
        else
            for s = 1:numtrials
                a = [];
                a = find(data(r).gratcyclets > data(r).trialstartts(s));
                trialstart(s) = data(r).gratcyclets(a(1));
            end
        end
    
    [psth{i} trialspx{i}] = mpsth(spikes,trialstart,'pre',400,'post',1000,'binsz',binsize,'chart',2);
 
    clear spikes AorB r data channels filelist GoodUnits unit trialstart
end