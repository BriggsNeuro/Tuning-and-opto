%mseq and impulse response calculation for good units

RF = []; hipix = []; hival = []; lopix = []; loval = []; hiRF = []; loRF = [];

%[datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
%load(datafile);

name2 = 'Enter Recording sessions and unit';
prompt2 = {'Unit','A=1,B=2','conetype?(Magno=0;L=1;M=2;S=3'};
numlines = 1;
defaultparams2 = {'1','1','0'};
params2 = inputdlg(prompt2,name2,numlines,defaultparams2);
for  r = 1:2  
    unit = str2num(params2{1});
    AorB = str2num(params2{2});
    Cone = str2num(params2{3});

    FPT = str2double(data(r).results{4,2}) / 10;
    switch Cone
        case 0
            switch AorB
                case 1
                    kA = data(r).kernelAs(:,:,unit);
                case 2
                    kA = data(r).kernelBs(:,:,unit);
            end
        case 1
            switch AorB
                case 1
                    kA = data(r).kernelAs_R(:,:,unit);
                case 2
                    kA = data(r).kernelBs_R(:,:,unit);
            end
        case 2
            switch AorB
                case 1
                    kA = data(r).kernelAs_G(:,:,unit);
                case 2
                    kA = data(r).kernelBs_G(:,:,unit);
            end
        case 3
            switch AorB
                case 1
                    kA = data(r).kernelAs_B(:,:,unit);
                case 2
                    kA = data(r).kernelBs_B(:,:,unit);
                
            end
    end


    KernelS.Mseq0 = interp2(reshape(kA(:,2),16,16),2);
    KernelS.Mseq1 = interp2(reshape(kA(:,3),16,16),2);
    KernelS.Mseq2 = interp2(reshape(kA(:,4),16,16),2);
    KernelS.Mseq3 = interp2(reshape(kA(:,5),16,16),2);

    scrsz = get(groot,'ScreenSize');
    figure('OuterPosition',[1 scrsz(4)/3 scrsz(3)/1.25 scrsz(4)/3])
    subplot(1,4,4), imagesc(KernelS.Mseq0)
    hold on
    subplot(1,4,3), imagesc(KernelS.Mseq1)
    hold on
    subplot(1,4,2), imagesc(KernelS.Mseq2)
    hold on
    subplot(1,4,1), imagesc(KernelS.Mseq3)

    name3 = 'Enter peak frame and ON or OFF';
    prompt3 = {'Peak frame','ON(1) or OFF(0)'};
    defaultparams3 = {'3','1'};
    params3 = inputdlg(prompt3,name3,numlines,defaultparams3);
    peakFrame = str2num(params3{1});
    OnOff = str2double(params3{2});

    scrsz = get(groot,'ScreenSize');
    figure('OuterPosition',[1 scrsz(4)/3 scrsz(3)/1.25 scrsz(4)/3])
    switch peakFrame
        case 1
            subplot(1,5,1)
            imagesc(KernelS.Mseq3)
            v = caxis;
            hold on
            subplot(1,5,2), imagesc(KernelS.Mseq2)
            caxis(v);
            hold on
            subplot(1,5,3), imagesc(KernelS.Mseq1)
            caxis(v);
            hold on
            subplot(1,5,4), imagesc(KernelS.Mseq0)
            caxis(v);
            hold on
        case 2
            subplot(1,5,2)
            imagesc(KernelS.Mseq2)
            v = caxis;
            hold on
            subplot(1,5,1), imagesc(KernelS.Mseq3)
            caxis(v);
            hold on
            subplot(1,5,3), imagesc(KernelS.Mseq1)
            caxis(v);
            hold on
            subplot(1,5,4), imagesc(KernelS.Mseq0)
            caxis(v);
            hold on
        case 3
            subplot(1,5,3)
            imagesc(KernelS.Mseq1)
            v = caxis;
            hold on
            subplot(1,5,1), imagesc(KernelS.Mseq3)
            caxis(v);
            hold on
            subplot(1,5,2), imagesc(KernelS.Mseq2)
            caxis(v);
            hold on
            subplot(1,5,4), imagesc(KernelS.Mseq0)
            caxis(v);
            hold on
        case 4
            subplot(1,5,4)
            imagesc(KernelS.Mseq0)
            v = caxis;
            hold on
            subplot(1,5,1), imagesc(KernelS.Mseq3)
            caxis(v);
            hold on
            subplot(1,5,2), imagesc(KernelS.Mseq2)
            caxis(v);
            hold on
            subplot(1,5,3), imagesc(KernelS.Mseq1)
            caxis(v);
            hold on
    end

    switch peakFrame
        case 1
            if OnOff == 1
                [f,z] = max(max(KernelS.Mseq3));
                [c,d] = max(KernelS.Mseq3(:,z));
                Cntrpix = [z,d];
            end
            if OnOff == 0
                [i,j] = min(min(KernelS.Mseq3));
                [k,l] = min(KernelS.Mseq3(:,j));
                Cntrpix = [j,l];
            end

            if min(Cntrpix) < 16
                dist1 = min(Cntrpix);
                dist2 = max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            elseif max(Cntrpix) > 44
                dist1 = 61 - min(Cntrpix);
                dist2 = 61 - max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            else adval = 15;
            end
            RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
            RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%              if adval >= 7
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) < 16
%                 RFpixY = (1:1:adval*2+1);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) > 44
%                 RFpixY = (61-adval*2:1:61);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(2) < 16
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (1:1:adval*2+1);
%             elseif adval < 7 && Cntrpix(2) > 44
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (61-adval*2:1:61);
%             end
            RF = KernelS.Mseq3(RFpixX,RFpixY);
            backgrnd = mean(mean(KernelS.Mseq3));

        case 2
            if OnOff == 1
                [f,z] = max(max(KernelS.Mseq2));
                [c,d] = max(KernelS.Mseq2(:,z));
                Cntrpix = [z,d];
            end
            if OnOff == 0
                [i,j] = min(min(KernelS.Mseq2));
                [k,l] = min(KernelS.Mseq2(:,j));
                Cntrpix = [j,l];
            end

            if min(Cntrpix) < 16
                dist1 = min(Cntrpix);
                dist2 = max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            elseif max(Cntrpix) > 44
                dist1 = 61 - min(Cntrpix);
                dist2 = 61 - max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            else adval = 15;
            end
             RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
            RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             if adval >= 7
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) < 16
%                 RFpixY = (1:1:adval*2+1);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) > 44
%                 RFpixY = (61-adval*2:1:61);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(2) < 16
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (1:1:adval*2+1);
%             elseif adval < 7 && Cntrpix(2) > 44
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (61-adval*2:1:61);
%             end
            RF = KernelS.Mseq2(RFpixX,RFpixY);
            backgrnd = mean(mean(KernelS.Mseq2));

        case 3
            if OnOff == 1
                [f,z] = max(max(KernelS.Mseq1));
                [c,d] = max(KernelS.Mseq1(:,z));
                Cntrpix = [z,d];
            end
            if OnOff == 0
                [i,j] = min(min(KernelS.Mseq1));
                [k,l] = min(KernelS.Mseq1(:,j));
                Cntrpix = [j,l];
            end

            if min(Cntrpix) < 16
                dist1 = min(Cntrpix);
                dist2 = max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            elseif max(Cntrpix) > 44
                dist1 = 61 - min(Cntrpix);
                dist2 = 61 - max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            else adval = 15;
            end
             RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
            RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             if adval >= 7
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) < 16
%                 RFpixY = (1:1:adval*2+1);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) > 44
%                 RFpixY = (61-adval*2:1:61);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(2) < 16
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (1:1:adval*2+1);
%             elseif adval < 7 && Cntrpix(2) > 44
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (61-adval*2:1:61);
%             end
            RF = KernelS.Mseq1(RFpixX,RFpixY);
            backgrnd = mean(mean(KernelS.Mseq1));

        case 4
            if OnOff == 1
                [f,z] = max(max(KernelS.Mseq0));
                [c,d] = max(KernelS.Mseq0(:,z));
                Cntrpix = [z,d];
            end
            if OnOff == 0
                [i,j] = min(min(KernelS.Mseq0));
                [k,l] = min(KernelS.Mseq0(:,j));
                Cntrpix = [j,l];
            end

            if min(Cntrpix) < 16
                dist1 = min(Cntrpix);
                dist2 = max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            elseif max(Cntrpix) > 44
                dist1 = 61 - min(Cntrpix);
                dist2 = 61 - max(Cntrpix);
                dist = min([dist1 dist2]);
                adval = dist - 1;
            else adval = 15;
            end
             RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
            RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%              if adval >= 7
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) < 16
%                 RFpixY = (1:1:adval*2+1);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(1) > 44
%                 RFpixY = (61-adval*2:1:61);
%                 RFpixX = (Cntrpix(2)-adval:1:Cntrpix(2)+adval);
%             elseif adval < 7 && Cntrpix(2) < 16
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (1:1:adval*2+1);
%             elseif adval < 7 && Cntrpix(2) > 44
%                 RFpixY = (Cntrpix(1)-adval:1:Cntrpix(1)+adval);
%                 RFpixX = (61-adval*2:1:61);
%             end
            RF = KernelS.Mseq0(RFpixX,RFpixY);
            backgrnd = mean(mean(KernelS.Mseq0));
    end

    mnRF = mean(mean(RF));
    stdRF = std(std(RF));
    hicut = mnRF + (4*stdRF);
    locut = mnRF - (4*stdRF);
    hipix = find(RF > hicut);
    hival = RF(hipix);
    lopix = find(RF < locut);
    loval = RF(lopix);

    hiRF = mnRF * ones(size(RF));
    loRF = mnRF * ones(size(RF));
    hiRF(hipix) = hival;
    loRF(lopix) = loval;

    logRF = zeros(size(RF));
    if OnOff == 1
    logRF(hipix) = 1;
    elseif OnOff == 0
        logRF(lopix) = 1;
    end
    RFlog = bwareaopen(logRF,10);

    figure
    if OnOff == 1
    subplot(1,2,1), imagesc(hiRF)
    elseif OnOff == 0
        subplot(1,2,1), imagesc(loRF)
    end
    hold on
    subplot(1,2,2), imagesc(RFlog)

    RFsize(r,1) = length(nonzeros(RFlog)) * str2double(data(r).results{3,2}) / 64;
    if OnOff == 1
        RFsize(r,2) = mean(hival) - backgrnd;
    elseif OnOff == 0
        RFsize(r,2) = mean(loval) - backgrnd;
    end

end
RFsize

