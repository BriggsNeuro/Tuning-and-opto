%this opens up variable containing a data structure for each session (made with
%CreateDataStructureMseq) and analyzes msequences which are then saved to the
%'data' structure within each session variable.


[datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
load(datafile);
FPT = 2; %may want to import this from data(r).results - flip time?

for k = 1:length(data)
    lgts(k) = length(data(k).gratcyclets);
end
goodlgts = find(lgts > 2);
if ~isempty(goodlgts)
totaldur = data(goodlgts(1)).gratcyclets(3) - data(goodlgts(1)).gratcyclets(2);
else
    totaldur = data(k).gratcyclets(2) - data(k).gratcyclets(1);
end
% totaldur = 327.8872
%%
% <<<<<<< .mine
% monitorRefreshRateHz = 16383 / totaldur * FPT;
%  termLengthMs = 10.00755;
% % termLengthMs = 10 - 1.85*1e-3; %this is Dan Butt's correction 12/09/2021, based on trial and error approach starting from an estimate like what is on the next line
% % termLengthMs = 1000 / monitorRefreshRateHz; %this is only different from Dan's above by 0.0001msec, and yet you don't get nice RFs with this error. So we can start with this number (1000/monitorRefreshRateHz) and then make
% %smal changes to termLengthMs until we optimize the same of our STAs. It could be that we just need to add 0.0001??
% ||||||| .r491
% monitorRefreshRateHz = 16383 / totaldur * FPT;
% termLengthMs = 10.00755;
% %termLengthMs = 10 - 1.85*1e-3; %this is Dan Butt's correction 12/09/2021, based on trial and error approach starting from an estimate like what is on the next line
% % termLengthMs = 1000 / monitorRefreshRateHz; %this is only different from Dan's above by 0.0001msec, and yet you don't get nice RFs with this error. So we can start with this number (1000/monitorRefreshRateHz) and then make
% %smal changes to termLengthMs until we optimize the same of our STAs. It could be that we just need to add 0.0001??
% =======
monitorRefreshRateHz = round(16383 / totaldur * FPT, 4);
%termLengthMs = 1000 / monitorRefreshRateHz;
%termLengthMs=10-1.85e-3;
switch monitorRefreshRateHz
    case 100.1342
        termLengthMs=9.9873;
    case 99.9307
        termLengthMs= 10.00755;
    case 100.0195
        termLengthMs=9.9987;
    case 99.9308
        termLengthMs=10.0074;
    case 100.1343
        termLengthMs=9.98705;
    case 99.9306
        termLengthMs=10.0077;
    otherwise
        termLengthMs=1000/monitorRefreshRateHz;
        disp(['Refresh rate ', num2str(monitorRefreshRateHz), 'is not optimized. Using estimated RR. Please optimize and add to code.'])
end 
        
%termLengthMs= 10.00755; %9.987; %9.9873;
 %10.00755;

%%
for r = 1:length(data)
    displaynum = [];
    starttemp = find(data(r).gratcyclets >= totaldur & data(r).gratcyclets < totaldur*2);
    if isempty(starttemp) == 0
        tstart = data(r).gratcyclets(starttemp) - totaldur;
        tend = data(r).trialendts(end);
        if isempty(tend) == 1
            tend = data(r).unitAts(end);
        end
        StartEndTimes = [tstart tend];
        subtractkernel = MseqProgSubKern(StartEndTimes,FPT,termLengthMs,displaynum);
        
        for y = 1:length(channels)
            h = []; spikes = [];
            h = find(data(r).unitAts(:,y) > tstart & data(r).unitAts(:,y) < tend);
            spikes = data(r).unitAts(h,y) - tstart;
            if length(spikes) > 200
                channel = channels(y);
                AorB = 1;
                StructNum = r;
                data(r).kernelAs(:,:,y) = MseqProg(spikes,StartEndTimes,FPT,subtractkernel,termLengthMs,displaynum,StructNum,channel,AorB);
            %MseqProg(spikes,StartEndTimes,FPT,subtractkernel,termLengthMs,displaynum,StructNum,channel,AorB);
            end
        end
        if sum(data(r).unitBts(1,:)) > 0
            for y = 1:length(channels)
                h2 = []; spikes2 = [];
                h2 = find(data(r).unitBts(:,y) > tstart & data(r).unitBts(:,y) < tend);
                spikes2 = data(r).unitBts(h2,y) - tstart;
                if length(spikes2) >200
                    channel = channels(y);
                    AorB = 2;
                    StructNum = r;
                    %data(r).kernelBs(:,:,y) = MseqProg(spikes2,StartEndTimes,FPT,subtractkernel,termLengthMs,displaynum,StructNum,channel,AorB);
                 %MseqProg(spikes2,StartEndTimes,FPT,subtractkernel,termLengthMs,displaynum,StructNum,channel,AorB);
                end
            end
        end
        if sum(data(r).unitCts(1,:)) > 0
            for y = 1:length(channels)
                h3 = []; spikes3 = [];
                h3 = find(data(r).unitCts(:,y) > tstart & data(r).unitCts(:,y) < tend);
                spikes3 = data(r).unitCts(h3,y) - tstart;
                if length(spikes3) > 1000
                    channel = channels(y);
                    AorB = 3;
                    StructNum = r;
                    %data(r).kernelCs(:,:,y) = MseqProg(spikes3,StartEndTimes,FPT,subtractkernel,termLengthMs,displaynum,StructNum,channel,AorB);
                    %MseqProg(spikes3,StartEndTimes,FPT,subtractkernel,termLengthMs,displaynum,StructNum,channel,AorB);
                end
            end
        end
    end
end
save([path datafile],'data','filelist','channels','-mat')