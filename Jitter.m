%calculating average first spike per event time (latency), and first spike jitter
%(spike timing precision), and transient/sustained index for TransSust and Flash data files

% [datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
% load(datafile);

%cheat for if this is flash versus T/S file
if length(data(1).gratcyclets) > 200
    dur = 150;
else
    dur = 450;
end
spktmwin = 9;
combos = dec2bin(0:800,1) - '0';
nix = find(sum(combos,2) > 3);
combos(nix,:) = [];
singles = find(sum(combos,2) == 1);
%nuldist = ones(length(combos(:,1)));

name1 = 'Unit info';
prompt1 = {'struct #s','unit','AorBorC'};
defaultparams1 = {'[2 1]','1','1'};
numlines = 1;
params1 = inputdlg(prompt1,name1,numlines,defaultparams1);
r = str2num(params1{1});
unit = str2num(params1{2});
AorB = str2num(params1{3});
Output(:,1) = r;
Output(1,2) = unit + (AorB/10);

for i = 1:length(r)
    gratts=[]; psth = []; trialspx = []; timevec = []; rastmat=[]; jit=[]; spkwin=[]; spkdist=[];
    gratts = data(r(i)).gratcyclets;
    switch AorB
        case 1
            [psth trialspx] = mpsth(data(r(i)).unitAts(:,unit),gratts,'pre',0,'post',100,'chart',2);
        case 2
            [psth trialspx] = mpsth(data(r(i)).unitBts(:,unit),gratts,'pre',0,'post',100,'chart',2);
        case 3
            [psth trialspx] = mpsth(data(r(i)).unitCts(:,unit),gratts,'pre',0,'post',100,'chart',2);
    end
    [rastmat timevec] = mraster(trialspx,0,100);
    if data(r(i)).YesLED == 1
        pause
        name = 'Pick peak bin LED';
        prompt = {'peak bin (msec)','window (msec)'};
        defaultparams = {'[71]','2'};
        params = inputdlg(prompt,name,numlines,defaultparams);
        pkbin = str2num(params{1});
        jitwin = str2num(params{2});
    end
    Output(i,3) = psth(pkbin,2) / length(gratts); %reliability = probability of spike in bin across trials
    
    jit = psth(pkbin-jitwin:pkbin+jitwin,2);
    ft = fit((pkbin-jitwin:pkbin+jitwin)',jit,'gauss1');
    Output(i,4) = ft.c1*2; %jitter as STD of distribution of spikes around peak bin

    [a,b] = max(psth(pkbin:pkbin+10,2));
    pkbin2 = pkbin + b - 2;
    spkwin = rastmat(:,pkbin2:pkbin2+spktmwin);
    for y = 1:length(spkwin(:,1))
        for x = 1:length(combos(:,1))
        spkdist(y,x) = isequal(spkwin(y,:),combos(x,:));
        end
    end
    sumprob(i,:) = sum(spkdist,1);
end
tempprob = sumprob;
tempprob(:,singles) = [];
tempprob2 = sumprob(:,singles);
Output(:,5) = sum(tempprob(:,2:end),2)./800;
Output(:,6) = sum(tempprob2,2)./800;

figure
bar(tempprob(2,2:end),'k')
hold on
bar(tempprob(1,2:end),'b')
figure
bar(tempprob2(2,2:end),'k')
hold on
bar(tempprob2(1,2:end),'b')

% for b = 1:(length(rastmat(:,1)))
%             c = []; d=[]; f=[];
%             c = find(rastmat(b,:) == 1);
%             if isempty(c) == 1
%                 spktm(b) = NaN;
%                 spknumOnset(b) = 0;
%                 spknumSust(b) = 0;
%             else
%                 d = find(c > pkbin & c < pkbin + 20);
%                 if isempty(d)==1
%                     spktm(b) = NaN;
%                 else
%                     spktm(b) = c(d(1));
%                 end
%                 f = find(c >= (pkbin + 20) & c < dur);
%                 spknumOnset(b) = length(d);
%                 spknumSust(b) = length(f);
%             end
%         end
%         M = []; I = []; halfmax = []; HMt = []; lat=[];
%         PSTH = sum(rastmat(:,:),1);
%         [M I] = max(PSTH(pkbin:pkbin+20));
%         [halfmax HMt] = find(PSTH(pkbin:pkbin+I) > M/2);
%         switch OnOff
%             case 0
%                 lat = HMt(1) + pkbin-1;
%             case 1
%                 lat = HMt(1) + (pkbin-1) - 30;
%         end
%         Output(i,3) = lat;
%         Output(i,4) = nanmean(spknumOnset)/0.02;
%         Output(i,5) = nanstd(spknumOnset)^2/0.02;
%         Output(i,6) = nanstd(spktm);
