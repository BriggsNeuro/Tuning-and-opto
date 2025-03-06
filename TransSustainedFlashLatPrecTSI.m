%calculating average first spike per event time (latency), and first spike jitter
%(spike timing precision), and transient/sustained index for TransSust and Flash data files

[datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
load(datafile);

%cheat for if this is flash versus T/S file
if length(data(1).gratcyclets) > 200
    dur = 150;
else
    dur = 450;
end

%% if you have good units, make  GoodUnits matrix with the WITH LED structure listed first
if exist('GoodUnits') == 1 && length(data) > 1
    r = GoodUnits(:,1);
    unit = GoodUnits(:,2); 
    AorB = GoodUnits(:,3);
    OnOff = GoodUnits(:,4);
    precdataOutput(:,1) = r;
    precdataOutput(:,2) = unit + (AorB/10);
    
    for i = 1:length(r)
        gratts=[]; psth = []; trialspx = []; timevec = []; spktm = []; rastmat=[]; spknumOnset=[]; spknumSust=[];
        gratts = data(r(i)).gratcyclets;
        switch AorB(i)
            case 1
                [psth trialspx] = mpsth(data(r(i)).unitAts(:,unit(i)),gratts,'pre',0,'post',80,'chart',2);
            case 2
                [psth trialspx] = mpsth(data(r(i)).unitBts(:,unit(i)),gratts,'pre',0,'post',80,'chart',2);
            case 3
                [psth trialspx] = mpsth(data(r(i)).unitCts(:,unit(i)),gratts,'pre',0,'post',80,'chart',2);
        end
        [rastmat timevec] = mraster(trialspx,0,100);
        
        if data(r(i)).YesLED == 1
            name = 'Enter conservative event start time';
            prompt = {'event start (msec)'};
            defaultparams = {'[50]'};
            numlines = 1;
            params = inputdlg(prompt,name,numlines,defaultparams);
            evtsrt = str2num(params{1});
        end
        
        for b = 1:(length(rastmat(:,1))-1)
            c = []; d=[]; f=[];
            c = find(rastmat(b,:) == 1);
            if isempty(c) == 1
                spktm(b) = NaN;
                spknumOnset(b) = 0;
                spknumSust(b) = 0;
            else
                d = find(c > evtsrt & c < evtsrt + 20);
                if isempty(d)==1
                    spktm(b) = NaN;
                else
                    spktm(b) = c(d(1));
                end
                f = find(c >= (evtsrt + 20) & c < dur);
                spknumOnset(b) = length(d);
                spknumSust(b) = length(f);
            end
        end
        M = []; I = []; halfmax = []; HMt = []; lat=[];
        PSTH = sum(rastmat(:,:),1);
        [M I] = max(PSTH(evtsrt:evtsrt+20));
        [halfmax HMt] = find(PSTH(evtsrt:evtsrt+I) > M/2);
        switch OnOff(i)
            case 0
                lat = HMt(1) + evtsrt-1; % OFF
            case 1
                lat = HMt(1) + (evtsrt-1) - 30; %ON
        end
        precdataOutput(i,3) = lat;
        precdataOutput(i,4) = nanmean(spknumOnset)/0.02;
        precdataOutput(i,5) = nanstd(spknumOnset)^2/0.02;
        precdataOutput(i,6) = nanstd(spktm);
    end
    precdataOutput(:,3)
elseif exist('GoodUnits') == 1 && length(data) == 1 % For example, GoodUnits=[1 3 1]
    close all
    r = GoodUnits(:,1);
    unit = GoodUnits(:,2);
    AorB = GoodUnits(:,3);
%     precdataOutput(:,1) = r;
%     precdataOutput(:,2) = unit + (AorB/10);
    for i = 1:length(r)
        gratts=[]; psth = []; trialspx = []; timevec = []; spktm = []; rastmat=[]; spknumOnset=[]; spknumSust=[];
        gratts = data(r(i)).gratcyclets;
        switch AorB(i)
            case 1
                [psth trialspx] = mpsth(data(r(i)).unitAts(:,unit(i)),gratts,'pre',0,'post',400,'chart',2);
            case 2
                [psth trialspx] = mpsth(data(r(i)).unitBts(:,unit(i)),gratts,'pre',0,'post',400,'chart',2);
            case 3
                [psth trialspx] = mpsth(data(r(i)).unitCts(:,unit(i)),gratts,'pre',0,'post',400,'chart',2);
        end
      
        [rastmat timevec] = mraster(trialspx,0,100);
        pause
        name = 'Enter conservative event start time and ON/OFF';
        prompt = {'event start (msec)','event end','second event start','second event end','ON(1) or OFF(0)'};
        defaultparams = {'30','100','150','300','0'};
        numlines = 1;
        params = inputdlg(prompt,name,numlines,defaultparams);
        evtsrt = str2num(params{1});
        evtend = str2num(params{2});
        sevtsrt = str2num(params{3});
        sevtend = str2num(params{4});
        OnOff  = str2num(params{5});
        M = []; I = []; halfmax = []; HMt = []; lat=[];
        PSTH = sum(rastmat(:,:),1);
        [M I] = max(PSTH(evtsrt:evtend)); % M is maximum value, I is index of M, [M I] corresponds to the index of the maximum FR
        [halfmax HMt] = find(PSTH(evtsrt:evtsrt+I) > M/2);
%         [D R] = max(PSTH(evtend:399));
%         [Shalfmax SHMt] = find(PSTH(evtend:evtend+R) > D/2);
        secondFR=sum(psth(sevtsrt:sevtend,2))/length(sevtsrt:sevtend); % FR in the second event bins
        baselineFR=sum(psth(1:30,2))/length(1:30); %FR in the baseline
        switch OnOff(i)
            case 0 % OFF
                lat = HMt(1) + evtsrt-1;
            case 1 % ON
                lat = HMt(1) + (evtsrt-1) - 30; 
        end

        for b = 1:(length(rastmat(:,1))-1)
            c = []; d=[]; f=[];
            c = find(rastmat(b,:) == 1);
            if isempty(c) == 1
                spktm(b) = NaN;
                spknumOnset(b) = 0;
                spknumSust(b) = 0;
            else
                d = find(c > (evtsrt + I - 5) & c < (evtsrt + I + 5));
                if isempty(d)==1
                    spktm(b) = NaN;
                else
                    spktm(b) = c(d(1));
                end
                f = find(c >= (evtsrt + I + 10) & c < (evtsrt+ I + 40));
                spknumOnset(b) = length(d);
                spknumSust(b) = length(f);
            end
        end
        precdataOutput(i,1) = evtsrt;
        precdataOutput(i,2) = evtend;
        precdataOutput(i,3) = lat;
        precdataOutput(i,4) = mean(spknumOnset,'omitnan')/0.01;
        precdataOutput(i,5) = std(spknumOnset,'omitnan')^2/0.01;
        precdataOutput(i,6) = std(spktm,'omitnan');
        precdataOutput(i,7) = mean(spknumSust,'omitnan')/0.03;  
        precdataOutput(i,8) = std(spknumSust,'omitnan')^2/0.03;  
        %precdataOutput(i,9) = SHMt(1)+evtend-1; % event start of delayed response, JY, 07/10/23
        precdataOutput(i,9) = sevtsrt;
        precdataOutput(i,10)= sevtend;
        precdataOutput(i,11)= secondFR/baselineFR;
    end
else
    name2 = 'Enter Recording sessions and units';
    prompt2 = {'Recording Session (w/NOled first or only)','Unit','A=1,B=2'};
    numlines = 1;
    defaultparams2 = {'[1 2]','[1 2 3 5 6 7 1 3 5 1 3]','[1 1 1 1 1 1 2 2 2 3 3]'};
    params2 = inputdlg(prompt2,name2,numlines,defaultparams2);
    r = str2num(params2{1});
    unit = str2num(params2{2});
    AorB = str2num(params2{3});
    
    for i = 1:length(r)
        gratts = []; precdata=[];
        gratts = data(r(i)).gratcyclets;
        for j = 1:length(unit)
            psth = []; trialspx = []; timevec = []; spktm = []; rastmat=[]; spknumOnset=[]; spknumSust=[];
            switch AorB(j)
                case 1
                    [psth trialspx] = mpsth(data(r(i)).unitAts(:,unit(j)),gratts,'pre',0,'post',500,'chart',2);
                case 2
                    [psth trialspx] = mpsth(data(r(i)).unitBts(:,unit(j)),gratts,'pre',0,'post',500,'chart',2);
                case 3
                    [psth trialspx] = mpsth(data(r(i)).unitCts(:,unit(j)),gratts,'pre',0,'post',500,'chart',2);
            end
            [rastmat timevec] = mraster(trialspx,0,100);
            
            for b = 1:(length(rastmat(:,1))-1)
                c = []; d=[]; f=[];
                c = find(rastmat(b,:) == 1);
                if isempty(c) == 1
                    spktm(b) = NaN;
                    spknumOnset(b) = 0;
                    spknumSust(b) = 0;
                else
                    d = find(c > 20 & c < 70);
                    if isempty(d)==1
                        spktm(b) = NaN;
                    else
                        spktm(b) = c(d(1));
                    end
                    f = find(c >= 70 & c < dur);
                    spknumOnset(b) = length(d);
                    spknumSust(b) = length(f);
                end
            end
            precdata(1,j) = unit(j) + (AorB(j)/10);
            precdata(2,j) = data(r(i)).YesLED;
            precdata(3,j) = nanstd(spktm);
            precdata(4,j) = nanmean(spknumOnset)/0.05;
            precdata(5,j) = nanstd(spknumOnset)^2/0.05;
            precdata(6,j) = nanmean(spknumSust)/((dur-70)/1000);
            precdata(7,j) = nanstd(spknumSust)^2/((dur-70)/1000);
            precdata(8,j) = precdata(4,j) / precdata(6,j);
            M = []; I = []; halfmax = []; HMt = [];
            PSTH = sum(rastmat(:,:),1);
            [M I] = max(PSTH);
            [halfmax HMt] = find(PSTH(1:I) > M/2);
            lat = HMt(1);
            precdata(9,j) = lat;
        end
        data(r(i)).PrecTSILat = precdata;
    end
end
%if exist('GoodUnits') == 1
  % save([path datafile],'data','channels','GoodUnits','precdataOutput','-mat','-append')
%else
   % save([path datafile],'data','channels','-mat','-append')