%this opens up the data structure for each session (made with
%CreateDataStructure) and analyzes tuning data which are then saved to the
%'data' structure within each session variable.   

name = 'Enter Number of sessions to analyze';  %Opens GUI which allows you to specifiy number of sessions to be analyzed
prompt = {'Number of Sessions'};
numlines = 1;
defaultparams = {'1'};
params = inputdlg(prompt,name,numlines,defaultparams);
numRep = str2double(params{1});

for i = 1:numRep %loops through sessions depending on value of numRep
    [datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');  %opens GUI which allows you to choose which datafile to analyze
    load(datafile);
    SimpleCells = ones(1,length(data));
    
    for r = 1:length(data) %cycles through each file in 'data'. Each file is from a session where one tuning parameter was varied, both without LED and with LED
        smTunA = []; smTunB = []; smTunC = []; histAs = []; histBs = []; histCs = []; % clears these variables each loop
        itt = 0.2 + str2num(char(data(r).results1(5,2))); %defines intertrial time
        gratdur = str2num(char(data(r).results1(4,2))); % duration of grating presentation on single trial
        numrepeats = round(str2num(char(data(r).results1(3,2)))); %number of repeats within each session (i.e. did we step through the tuning 2 or 3 times)
        tuntype = str2num(char(data(r).results1(1,2))); %defines the type of tuning (1. ori, 2. contrast, etc.). Specified during recording
        tf = str2num(char(data(r).results2(6,2))); %temporal frequency of grating. Specified during recording
        cycldur = round(1000 / tf); %duration of one cycle of sine wave underlying grating.
        cyclct = gratdur * tf; %number of cycles per grating presentation
        lessct = cyclct - 1;
        edge = (0:0.001:gratdur); % specifies boundaries of bins used for analysis (1ms bins for the duration of one stimulus presentation)
        time = (0:0.001:(cycldur/1000-0.001))'; % time in seconds grating was on screen
        C = ones(cycldur,3);
        C(:,2) = sin(2*pi*4*time);
        C(:,3) = cos(2*pi*4*time);
        
        if isempty(data(r).trialstartts) ~=1
        numtrials = length(data(r).trialstartts); %defines number of trials as the length of the trial start time stamp matrix found in the data structure
        trialgth = round(numtrials/numrepeats); % length of a given trial
        
        for q = 1:numtrials  
            z = [];
          z = find(data(r).gratcyclets > data(r).trialstartts(q)); %finds grating cycle times that occured during a trial
          gratts(q) = data(r).gratcyclets(z(1));
        end
        elseif isempty(data(r).trialstartts) == 1
            data(r).evtLED(find(data(r).evtLED == 0)) = [];
            numtrials = length(data(r).evtLED);
            trialgth = round(numtrials/numrepeats); % length of a given trial
            data(r).trialstartts = data(r).evtLED;
            data(r).trialendts = data(r).evtLED + ((itt-0.2)*2);
            gratts = data(r).evtLED + (itt-0.2);
        end
        
        if length(data(r).unitAts(:,1)) > 1 % If there are Unit A spike times...
            for x = 1:numtrials %find spike times that occured during the trial and while the grating was present
                for y = 1:length(data(r).unitAts(1,:))
                    histtempA = []; ffttempA = []; XFA = []; sponttempA = []; aA = []; uA = [];
                    aA = find(data(r).unitAts(:,y) > gratts(x) & data(r).unitAts(:,y) < data(r).trialendts(x));
                    uA = data(r).unitAts(aA,y);
                    uA = uA - gratts(x);
                    smTunA(x,y) = length(uA);
                    if smTunA(x,y) > 1
                        smTunA(x,y) = length(uA) / gratdur;
                        histtempA = histc(uA, edge);
                        ffttempA = histtempA(1:cycldur);
                        for z = 1:(cyclct-1)
                            ffttempA = ffttempA + histtempA((z*cycldur+1):(cycldur*(z+1)));
                        end
                        XFA = C\ffttempA;
                        aveA(x,y) = XFA(1) * tf;
                        f1A(x,y) = sqrt(sum(XFA(2:3,:).^2,1)) * 2 * tf;
                    else
                        smTunA(x,y) = length(uA);
                        aveA(x,y) =  0;
                        f1A(x,y) = 0;
                        histtempA = zeros(1,length(edge));
                    end
                    sponttempA = find(data(r).unitAts(:,y) > (data(r).trialstartts(x) + 0.4) & data(r).unitAts(:,y) < (data(r).trialstartts(x) + itt));
                    spontA(x,y) = length(sponttempA) / (itt-0.4);
                    histAs(y,:,x) = histtempA;
                end
            end
            tempAsm=[]; tempAav=[]; tempAf1=[]; tempAsp=[];
            for a = 1:numrepeats
                tempAsm(:,:,a) = smTunA(((a-1)*trialgth + 1):(trialgth*a),:);
                tempAav(:,:,a) = aveA(((a-1)*trialgth + 1):(trialgth*a),:);
                tempAf1(:,:,a) = f1A(((a-1)*trialgth + 1):(trialgth*a),:);
                tempAsp(:,:,a) = spontA(((a-1)*trialgth + 1):(trialgth*a),:);
            end
            smTunA = mean(tempAsm,3);
            aveA = mean(tempAav,3);
            f1A = mean(tempAf1,3);
            spontA = mean(tempAsp,3);
            SterrspkA = std(tempAsm,0,3)./sqrt(numrepeats);
            histAs = sum(histAs,3);
            switch tuntype
                case 1 %ori
                    data(r).aveOri = aveA;
                    data(r).f1Ori = f1A;
                    data(r).spontOri = spontA;
                    data(r).sumOri = smTunA;
                    data(r).oriHist = histAs;
                    data(r).oriSterr = SterrspkA;
                case 2 %contrast
                    data(r).aveContrast = aveA;
                    data(r).f1Contrast = f1A;
                    data(r).spontContrast = spontA;
                    data(r).sumContrast = smTunA;
                    data(r).conHist = histAs;
                    data(r).conSterr = SterrspkA;
                case 3 %SF
                    data(r).aveSF = aveA;
                    data(r).f1SF = f1A;
                    data(r).spontSF = spontA;
                    data(r).sumSF = smTunA;
                    data(r).SFHist = histAs;
                    data(r).SFSterr = SterrspkA;
                case 4 %TF
                    data(r).aveTF = aveA;
                    data(r).f1TF = f1A;
                    data(r).spontTF = spontA;
                    data(r).sumTF = smTunA;
                    data(r).TFHist = histAs;
                    data(r).TFSterr = SterrspkA;
                case 5
                    data(r).aveSize = aveA;
                    data(r).f1Size = f1A;
                    data(r).spontSize = spontA;
                    data(r).sumSize = smTunA;
                    data(r).sizeHist = histAs;
                    data(r).sizeSterr = SterrspkA;
            end
            
        else
            data(r).aveTuningA = [0 0];
            data(r).f1TuningA = [0 0];
            data(r).spontTuningA = [0 0];
            data(r).sumTuningA = [0 0];
            data(r).sumMeanA = [0 0];
            data(r).sumSterrA = [0 0];
        end
        
        if length(data(r).unitBts(:,1)) > 1 %same as previous loop, only for Unit Bs
            for x = 1:numtrials
                for y = 1:length(data(r).unitBts(1,:))
                    histtempB = []; ffttempB = []; XFB = []; sponttempB = []; aB = []; uB = [];
                    aB = find(data(r).unitBts(:,y) > gratts(x) & data(r).unitBts(:,y) < data(r).trialendts(x));
                    uB = data(r).unitBts(aB,y);
                    uB = uB - gratts(x);
                    smTunB(x,y) = length(uB);
                    if smTunB(x,y) > 1
                        smTunB(x,y) = length(uB) / gratdur;
                        histtempB = histc(uB, edge);
                        ffttempB = histtempB(1:cycldur);
                        for z = 1:(cyclct-1)
                            ffttempB = ffttempB + histtempB((z*cycldur+1):(cycldur*(z+1)));
                        end
                        XFB = C\ffttempB;
                        aveB(x,y) = XFB(1) * tf;
                        f1B(x,y) = sqrt(sum(XFB(2:3,:).^2,1)) * 2 * tf;
                    else
                        smTunB(x,y) = length(uB);
                        aveB(x,y) =  0;
                        f1B(x,y) = 0;
                        histtempB = zeros(1,length(edge));
                    end
                    sponttempB = find(data(r).unitBts(:,y) > (data(r).trialstartts(x) + 0.4) & data(r).unitBts(:,y) < data(r).trialstartts(x) + itt);
                    spontB(x,y) = length(sponttempB) / (itt-0.4);
                    histBs(y,:,x) = histtempB;
                end
            end
             tempBsm=[]; tempBav=[]; tempBf1=[]; tempBsp=[];
            for a = 1:numrepeats
                tempBsm(:,:,a) = smTunB(((a-1)*trialgth + 1):(trialgth*a),:);
                tempBav(:,:,a) = aveB(((a-1)*trialgth + 1):(trialgth*a),:);
                tempBf1(:,:,a) = f1B(((a-1)*trialgth + 1):(trialgth*a),:);
                tempBsp(:,:,a) = spontB(((a-1)*trialgth + 1):(trialgth*a),:);
            end
            smTunB = mean(tempBsm,3);
            aveB = mean(tempBav,3);
            f1B = mean(tempBf1,3);
            spontB = mean(tempBsp,3);
            SterrspkB = std(tempBsm,0,3)./sqrt(numrepeats);
            histBs = sum(histBs,3);
            switch tuntype
                case 1 %ori
                    data(r).aveOri = cat(2,data(r).aveOri,aveB);
                    data(r).f1Ori = cat(2,data(r).f1Ori,f1B);
                    data(r).spontOri = cat(2,data(r).spontOri,spontB);
                    data(r).sumOri = cat(2,data(r).sumOri,smTunB);
                    data(r).oriHist = cat(1,data(r).oriHist,histBs);
                    data(r).oriSterr = cat(2,data(r).oriSterr,SterrspkB);
                case 2 %contrast
                    data(r).aveContrast = cat(2,data(r).aveContrast,aveB);
                    data(r).f1Contrast = cat(2,data(r).f1Contrast,f1B);
                    data(r).spontContrast = cat(2,data(r).spontContrast,spontB);
                    data(r).sumContrast = cat(2,data(r).sumContrast,smTunB);
                    data(r).conHist = cat(1,data(r).conHist,histBs);
                    data(r).conSterr = cat(2,data(r).conSterr,SterrspkB);
                case 3 %SF
                    data(r).aveSF = cat(2,data(r).aveSF,aveB);
                    data(r).f1SF = cat(2,data(r).f1SF,f1B);
                    data(r).spontSF = cat(2,data(r).spontSF,spontB);
                    data(r).sumSF = cat(2,data(r).sumSF,smTunB);
                    data(r).SFHist = cat(1,data(r).SFHist,histBs);
                    data(r).SFSterr = cat(2,data(r).SFSterr,SterrspkB);
                case 4 %TF
                    data(r).aveTF = cat(2,data(r).aveTF,aveB);
                    data(r).f1TF = cat(2,data(r).f1TF,f1B);
                    data(r).spontTF = cat(2,data(r).spontTF,spontB);
                    data(r).sumTF = cat(2,data(r).sumTF,smTunB);
                    data(r).TFHist = cat(1,data(r).TFHist,histBs);
                    data(r).TFSterr = cat(2,data(r).TFSterr,SterrspkB);
                case 5 %size
                    data(r).aveSize = cat(2,data(r).aveSize,aveB);
                    data(r).f1Size = cat(2,data(r).f1Size,f1B);
                    data(r).spontSize = cat(2,data(r).spontSize,spontB);
                    data(r).sumSize = cat(2,data(r).sumSize,smTunB);
                    data(r).sizeHist = cat(1,data(r).sizeHist,histBs);
                    data(r).sizeSterr = cat(2,data(r).sizeSterr,SterrspkB);
            end
        end
        if length(data(r).unitCts(:,1)) > 1 % Same as previous loops, only for Unit Cs
            for x = 1:numtrials
                for y = 1:length(data(r).unitCts(1,:))
                    histtempC = []; ffttempC = []; XFC = []; sponttempC = []; aC = []; uC = [];
                    aC = find(data(r).unitCts(:,y) > gratts(x) & data(r).unitCts(:,y) < data(r).trialendts(x));
                    uC = data(r).unitCts(aC,y);
                    uC = uC - gratts(x);
                    smTunC(x,y) = length(uC);
                    if smTunC(x,y) > 1
                        smTunC(x,y) = length(uC) / gratdur;
                        histtempC = histc(uC, edge);
                        ffttempC = histtempC(1:cycldur);
                        for z = 1:(cyclct-1)
                            ffttempC = ffttempC + histtempC((z*cycldur+1):(cycldur*(z+1)));
                        end
                        XFC = C\ffttempC;
                        aveC(x,y) = XFC(1) * tf;
                        f1C(x,y) = sqrt(sum(XFC(2:3,:).^2,1)) * 2 * tf;
                    else
                        smTunC(x,y) = length(uC);
                        aveC(x,y) =  0;
                        f1C(x,y) = 0;
                        histtempC = zeros(1,length(edge));
                    end
                    sponttempC = find(data(r).unitCts(:,y) > (data(r).trialstartts(x) + 0.4) & data(r).unitCts(:,y) < data(r).trialstartts(x) + itt);
                    spontC(x,y) = length(sponttempC) / (itt-0.4);
                    histCs(y,:,x) = histtempC;
                end
            end
             tempCsm=[]; tempCav=[]; tempCf1=[]; tempCsp=[];
            for a = 1:numrepeats
                tempCsm(:,:,a) = smTunC(((a-1)*trialgth + 1):(trialgth*a),:);
                tempCav(:,:,a) = aveC(((a-1)*trialgth + 1):(trialgth*a),:);
                tempCf1(:,:,a) = f1C(((a-1)*trialgth + 1):(trialgth*a),:);
                tempCsp(:,:,a) = spontC(((a-1)*trialgth + 1):(trialgth*a),:);
            end
            smTunC = mean(tempCsm,3);
            aveC = mean(tempCav,3);
            f1C = mean(tempCf1,3);
            spontC = mean(tempCsp,3);
            SterrspkC = std(tempCsm,0,3)./sqrt(numrepeats);
            histCs = sum(histCs,3);
            switch tuntype
                case 1 %ori
                    data(r).aveOri = cat(2,data(r).aveOri,aveC);
                    data(r).f1Ori = cat(2,data(r).f1Ori,f1C);
                    data(r).sumOri = cat(2,data(r).sumOri,smTunC);
                    data(r).spontOri = cat(2,data(r).spontOri,spontC);
                    data(r).oriHist = cat(1,data(r).oriHist,histCs);
                case 2 %contrast
                    data(r).aveContrast = cat(2,data(r).aveContrast,aveC);
                    data(r).f1Contrast = cat(2,data(r).f1Contrast,f1C);
                    data(r).sumContrast = cat(2,data(r).sumContrast,smTunC);
                    data(r).spontContrast = cat(2,data(r).spontContrast,spontC);
                    data(r).conHist = cat(1,data(r).conHist,histCs);
                case 3 %SF
                    data(r).aveSF = cat(2,data(r).aveSF,aveC);
                    data(r).f1SF = cat(2,data(r).f1SF,f1C);
                    data(r).sumSF = cat(2,data(r).sumSF,smTunC);
                    data(r).spontSF = cat(2,data(r).spontSF,spontC);
                    data(r).SFHist = cat(1,data(r).SFHist,histCs);
                case 4 %TF
                    data(r).aveTF = cat(2,data(r).aveTF,aveC);
                    data(r).f1TF = cat(2,data(r).f1TF,f1C);
                    data(r).sumTF = cat(2,data(r).sumTF,smTunC);
                    data(r).spontTF = cat(2,data(r).spontTF,spontC);
                    data(r).TFHist = cat(1,data(r).TFHist,histCs);
                case 5 %size
                    data(r).aveSize = cat(2,data(r).aveSize,aveC);
                    data(r).f1Size = cat(2,data(r).f1Size,f1C);
                    data(r).sumSize = cat(2,data(r).sumSize,smTunC);
                    data(r).spontSize = cat(2,data(r).spontSize,spontC);
                    data(r).sizeHist = cat(1,data(r).sizeHist,histCs);
            end
        end
    end
    save([path datafile],'data','filelist','channels','-mat') %'OriYLED','OriNLED','ConYLED','ConNLED','SFYLED','SFNLED','TFYLED','TFNLED','-mat')
    clear Results Results2 units
end




