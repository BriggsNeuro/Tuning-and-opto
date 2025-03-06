name = 'Enter mseq cell info';
prompt = {'unit','AorB','OnOff'};
numlines = 1;
defaultparams = {'3','1','[1]'};
params = inputdlg(prompt,name,numlines,defaultparams);
unit = str2num(params{1});
AorB = str2num(params{2});
OnOff= str2num(params{3});

%first load black/white m-sequence structure and plot that
[datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
load(datafile);

FPT = 2;
scrsz = get(groot,'ScreenSize');
f1 = figure('Name','No LED','OuterPosition',[1 scrsz(4)/1.5 scrsz(3)/1.5 scrsz(4)/1.5]);
% f2 = figure('Name','With LED','OuterPosition',[1 scrsz(4)/1.5 scrsz(3)/1.5 scrsz(4)/1.5]);
if AorB == 1
    KernelnL = data(1).kernelAs(:,2,unit); %change cone type AND AorB
%     KernelL = data(2).kernelAs(:,2,unit); %change cone type AND AorB
elseif AorB == 2
    KernelnL = data(1).kernelBs(:,2,unit); %change cone type AND AorB
%     KernelL = data(2).kernelBs(:,2,unit); %change cone type AND AorB
end
KnL   = interp2(reshape(KernelnL,16,16),2);
% KL  = interp2(reshape(KernelL,16,16),2);
figure(f1)
% subplot(4,5,4), imagesc(KnL)
subplot(1,5,4), imagesc(KnL)
colormap gray %change colormap
v1 = caxis;
% figure(f2)
% subplot(4,5,4), imagesc(KL)
% colormap gray %change colormap
% v2 = caxis;
diff1   = (abs(v1(2) - v1(1)))/2;
% diff2 = (abs(v2(2) - v2(1)))/2;
% usediff = max([diff1 diff2])*1.2;
% clims1 = [(mean(v1) - usediff) (mean(v1) + usediff)];
% usediff =  diff1*1.2; % noLED only
clims1  =  [(mean(v1) - diff1) (mean(v1) + diff1)];
% clims2 = [(mean(v2) - usediff) (mean(v2) + usediff)];

for r = 1:1
    if r == 1
        clims = clims1;
%     elseif r == 2
%         clims = clims2;
    end
    if AorB == 1
        Kernel = data(r).kernelAs(:,:,unit); %change cone type AND AorB
    elseif AorB == 2
        Kernel = data(r).kernelBs(:,:,unit);
    end
    KernelS.Mseq0 = interp2(reshape(Kernel(:,2),16,16),2);
    KernelS.Mseq1 = interp2(reshape(Kernel(:,3),16,16),2);
    KernelS.Mseq2 = interp2(reshape(Kernel(:,4),16,16),2);
    KernelS.Mseq3 = interp2(reshape(Kernel(:,5),16,16),2);
    if r == 1
        figure(f1)
%     elseif r == 2
%         figure(f2)
    end
    ax1 = subplot(1,5,4); imagesc(KernelS.Mseq0,clims); % ax1 = subplot(4,5,4); imagesc(KernelS.Mseq0,clims);
    colormap(ax1,gray);
    hold on
    ax1 = subplot(1,5,3); imagesc(KernelS.Mseq1,clims);
    colormap(ax1,gray);
    hold on
    ax1 = subplot(1,5,1); imagesc(KernelS.Mseq3,clims);
    colormap(ax1,gray);
    %colorbar
    hold on
    ax1 = subplot(1,5,2); imagesc(KernelS.Mseq2,clims);
    colormap(ax1,gray);
    hold on
    
    win = [5:57];
    %plot the impluse-response curves
    [f,z] = max(max(KernelS.Mseq0(win,win)));
    [c,d] = max(KernelS.Mseq0(win,z));
    [a,b] = max(max(KernelS.Mseq1(win,win)));
    [g,h] = max(KernelS.Mseq1(win,b));
    Cntrpix1 = [win(z),win(d)];
    Cntrpix2 = [win(b),win(h)];
    if z > b
        ONpix = Cntrpix1;
    else ONpix = Cntrpix2;
    end
    
    [i,j] = min(min(KernelS.Mseq0(win,win)));
    [k,l] = min(KernelS.Mseq0(win,j));
    [m,n] = min(min(KernelS.Mseq1(win,win)));
    [o,p] = min(KernelS.Mseq1(win,n));
    Cntrpix3 = [win(j),win(l)];
    Cntrpix4 = [win(n),win(p)];
    if j < n
        OFFpix = Cntrpix3;
    else OFFpix = Cntrpix4;
    end
    
    RFpixY = (ONpix(1)-4:1:ONpix(1)+4);
    RFpixX = (ONpix(2)-4:1:ONpix(2)+4);
    RF = KernelS.Mseq0(RFpixX,RFpixY);
    [f,z] = max(max(RF));
    [c,d] = max(RF(:,z));
    ONpix = [z,d];
    [i,j] = min(min(RF));
    [k,l] = min(RF(:,j));
    OFFpix = [j,l];
    tempRF = cat(3,KernelS.Mseq3(RFpixX,RFpixY),KernelS.Mseq2(RFpixX,RFpixY),KernelS.Mseq1(RFpixX,RFpixY),KernelS.Mseq0(RFpixX,RFpixY));
    
    xaxis = [-3*FPT*10 -2*FPT*10 -10*FPT 0];
    ONImpRes(r,:) = reshape(tempRF(ONpix(1),ONpix(2),:),[1 4]);
    OFFImpRes(r,:) = reshape(tempRF(OFFpix(1),OFFpix(2),:),[1 4]);
    subplot(1,5,5), plot(xaxis, ONImpRes(r,:),'y') % subplot(4,5,5), plot(xaxis, ONImpRes(r,:),'y')
    hold on
    subplot(1,5,5), plot(xaxis, OFFImpRes(r,:),'k')
    hold on
end
xaxis2 = (xaxis(1):1:xaxis(end));
if OnOff(1) == 1
    fitnL = fit(xaxis',ONImpRes(1,:)','fourier1');
%     fitL = fit(xaxis',ONImpRes(2,:)','fourier1');
    [q,s] = max(fitnL(xaxis2));
    [base(1),x] = min(fitnL(xaxis2));
%     [t,w] = max(fitL(xaxis2));
%     [base(2),y] = min(fitL(xaxis2));
elseif OnOff(1) == 0
    fitnL = fit(xaxis',OFFImpRes(1,:)','fourier1');
%     fitL = fit(xaxis',OFFImpRes(2,:)','fourier1');
    [q,s] = min(fitnL(xaxis2));
    [base(1),x] = max(fitnL(xaxis2));
%     [t,w] = min(fitL(xaxis2));
%     [base(2),y] = max(fitL(xaxis2));
end
lat(1) = xaxis2(s);
amp(1) = q-base(1);
% lat(2) = xaxis2(w);
% amp(2) = t-base(2);
half = base + (amp./2);
if x>s
    xaxis3 = xaxis2(s:x);
else xaxis3 = xaxis2(x:s);
end
% if y>w
%     xaxis4 = xaxis2(w:y);
% else xaxis4 = xaxis2(y:w);
% end
width(1) = xaxis3(round(mean(find(fitnL(xaxis3) > half(1)-0.0005 & fitnL(xaxis3) < half(1)+0.0005)))) - lat(1);
% width(2) = xaxis4(round(mean(find(fitL(xaxis4) > half(2)-0.0005 & fitL(xaxis4) < half(2)+0.0005)))) - lat(2);
figure(f1)
subplot(1,5,5), plot(fitnL,'r') % subplot(4,5,5), plot(fitnL,'r')
hold on
% figure(f2)
% subplot(4,5,5), plot(fitL,'b')
% hold on
output = cat(2,lat,width,amp);

clear channels data filelist

%second load cone m-sequence structure and plot that
% [datafile,path] = uigetfile('C:\Users\Farran Briggs\Documents\MATLAB\workspaces\');
% load(datafile);
% 
% for u = 1:3
%     if u == 1 && AorB == 1
%         KernelnL = data(1).kernelAs_R(:,2,unit); %change cone type AND AorB
% %         KernelL = data(2).kernelAs_R(:,2,unit); %change cone type AND AorB
%     elseif u == 1 && AorB == 2
%         KernelnL = data(1).kernelBs_R(:,2,unit); %change cone type AND AorB
% %         KernelL = data(2).kernelBs_R(:,2,unit); %change cone type AND AorB
%     elseif u == 2 && AorB == 1
%         KernelnL = data(1).kernelAs_G(:,2,unit); %change cone type AND AorB
% %         KernelL = data(2).kernelAs_G(:,2,unit); %change cone type AND AorB
%     elseif u == 2 && AorB == 2
%         KernelnL = data(1).kernelBs_G(:,2,unit); %change cone type AND AorB
% %         KernelL = data(2).kernelBs_G(:,2,unit); %change cone type AND AorB
%     elseif u == 3 && AorB == 1
%         KernelnL = data(1).kernelAs_B(:,2,unit); %change cone type AND AorB
% %         KernelL = data(2).kernelAs_B(:,2,unit); %change cone type AND AorB
%     elseif u == 3 && AorB == 2
%         KernelnL = data(1).kernelBs_B(:,2,unit); %change cone type AND AorB
% %         KernelL = data(2).kernelBs_B(:,2,unit); %change cone type AND AorB
%     end
%     
%     KnL = interp2(reshape(KernelnL,16,16),2);
% %     KL = interp2(reshape(KernelL,16,16),2);
%     figure(f1)
%     ax(u) = subplot(4,5,(u*5)+4); imagesc(KnL);
%     if u == 1
%         colormap(ax(u),autumn);
%     elseif u == 2
%         colormap(ax(u),summer);
%     elseif u == 3
%         colormap(ax(u),parula);
%     end
%     v1 = caxis;
% %     figure(f2)
% %     ax(u) = subplot(4,5,(u*5)+4); imagesc(KL);
% %     if u == 1
% %         colormap(ax(u),autumn);
% %     elseif u == 2
% %         colormap(ax(u),summer);
% %     elseif u == 3
% %         colormap(ax(u),parula);
% %     end
% %     v2 = caxis;
%     diff1 = (abs(v1(2) - v1(1)))/2;
% %     diff2 = (abs(v2(2) - v2(1)))/2;
% %     usediff = max([diff1 diff2])*1.2;
%     usediff = diff1*1.2;
%     clims1  = [(mean(v1) - usediff) (mean(v1) + usediff)];
% %     clims2 = [(mean(v2) - usediff) (mean(v2) + usediff)];
%     
%     for r = 1:2
%         if r == 1
%             clims = clims1;
% %         elseif r == 2
% %             clims = clims2;
%         end
%         
%         if u == 1 && AorB == 1
%             Kernel = data(r).kernelAs_R(:,:,unit);
%         elseif u == 1 && AorB == 2
%             Kernel = data(r).kernelBs_R(:,:,unit);
%         elseif u == 2 && AorB == 1
%             Kernel = data(r).kernelAs_G(:,:,unit);
%         elseif u == 2 && AorB == 2
%             Kernel = data(r).kernelBs_G(:,:,unit);
%         elseif u == 3 && AorB == 1
%             Kernel = data(r).kernelAs_B(:,:,unit);
%         elseif u == 3 && AorB == 2
%             Kernel = data(r).kernelBs_B(:,:,unit);
%         end
%         
%         KernelS.Mseq0 = interp2(reshape(Kernel(:,2),16,16),2);
%         KernelS.Mseq1 = interp2(reshape(Kernel(:,3),16,16),2);
%         KernelS.Mseq2 = interp2(reshape(Kernel(:,4),16,16),2);
%         KernelS.Mseq3 = interp2(reshape(Kernel(:,5),16,16),2);
%         if r == 1
%             figure(f1)
%         elseif r == 2
%             figure(f2)
%         end
%         ax(u) = subplot(4,5,(u*5)+4); imagesc(KernelS.Mseq0,clims);
%         if u == 1
%             colormap(ax(u),autumn);
%         elseif u == 2
%             colormap(ax(u),summer);
%         elseif u == 3
%             colormap(ax(u),parula);
%         end
%         hold on
%         ax(u) = subplot(4,5,(u*5)+3); imagesc(KernelS.Mseq1,clims);
%         if u == 1
%             colormap(ax(u),autumn);
%         elseif u == 2
%             colormap(ax(u),summer);
%         elseif u == 3
%             colormap(ax(u),parula);
%         end
%         hold on
%         ax(u) = subplot(4,5,(u*5)+1); imagesc(KernelS.Mseq3,clims);
%         if u == 1
%             colormap(ax(u),autumn);
%         elseif u == 2
%             colormap(ax(u),summer);
%         elseif u == 3
%             colormap(ax(u),parula);
%         end
%         %colorbar
%         hold on
%         ax(u) = subplot(4,5,(u*5)+2); imagesc(KernelS.Mseq2,clims);
%         if u == 1
%             colormap(ax(u),autumn);
%         elseif u == 2
%             colormap(ax(u),summer);
%         elseif u == 3
%             colormap(ax(u),parula);
%         end
%         hold on
%         
%         win = [5:57];
%         %plot the impluse-response curves
%         [f,z] = max(max(KernelS.Mseq0(win,win)));
%         [c,d] = max(KernelS.Mseq0(win,z));
%         [a,b] = max(max(KernelS.Mseq1(win,win)));
%         [g,h] = max(KernelS.Mseq1(win,b));
%         Cntrpix1 = [win(z),win(d)];
%         Cntrpix2 = [win(b),win(h)];
%         if z > b
%             ONpix = Cntrpix1;
%         else ONpix = Cntrpix2;
%         end
%         
%         [i,j] = min(min(KernelS.Mseq0(win,win)));
%         [k,l] = min(KernelS.Mseq0(win,j));
%         [m,n] = min(min(KernelS.Mseq1(win,win)));
%         [o,p] = min(KernelS.Mseq1(win,n));
%         Cntrpix3 = [win(j),win(l)];
%         Cntrpix4 = [win(n),win(p)];
%         if j < n
%             OFFpix = Cntrpix3;
%         else OFFpix = Cntrpix4;
%         end
%         
%         RFpixY = (ONpix(1)-4:1:ONpix(1)+4);
%         RFpixX = (ONpix(2)-4:1:ONpix(2)+4);
%         RF = KernelS.Mseq0(RFpixX,RFpixY);
%         [f,z] = max(max(RF));
%         [c,d] = max(RF(:,z));
%         ONpix = [z,d];
%         [i,j] = min(min(RF));
%         [k,l] = min(RF(:,j));
%         OFFpix = [j,l];
%         tempRF = cat(3,KernelS.Mseq3(RFpixX,RFpixY),KernelS.Mseq2(RFpixX,RFpixY),KernelS.Mseq1(RFpixX,RFpixY),KernelS.Mseq0(RFpixX,RFpixY));
%         
%         xaxis = [-3*FPT*10 -2*FPT*10 -10*FPT 0];
%         ONImpRes(r,:) = reshape(tempRF(ONpix(1),ONpix(2),:),[1 4]);
%         OFFImpRes(r,:) = reshape(tempRF(OFFpix(1),OFFpix(2),:),[1 4]);
%         subplot(4,5,(u*5)+5), plot(xaxis, ONImpRes(r,:),'y')
%         hold on
%         subplot(4,5,(u*5)+5), plot(xaxis, OFFImpRes(r,:),'k')
%         hold on
%     end
%     xaxis2 = (xaxis(1):1:xaxis(end));
%     if OnOff(u+1) == 1
%         fitnL = fit(xaxis',ONImpRes(1,:)','fourier1');
%         fitL = fit(xaxis',ONImpRes(2,:)','fourier1');
%         [q,s] = max(fitnL(xaxis2));
%         [base(1),x] = min(fitnL(xaxis2));
%         [t,w] = max(fitL(xaxis2));
%         [base(2),y] = min(fitL(xaxis2));
%     elseif OnOff(u+1) == 0
%         fitnL = fit(xaxis',OFFImpRes(1,:)','fourier1');
%         fitL = fit(xaxis',OFFImpRes(2,:)','fourier1');
%         [q,s] = min(fitnL(xaxis2));
%         [base(1),x] = max(fitnL(xaxis2));
%         [t,w] = min(fitL(xaxis2));
%         [base(2),y] = max(fitL(xaxis2));
%     end
%     lat(1) = xaxis2(s);
%     amp(1) = q-base(1);
%     lat(2) = xaxis2(w);
%     amp(2) = t-base(2);
%     half = base + (amp./2);
%     if x>s
%         xaxis3 = xaxis2(s:x);
%     else xaxis3 = xaxis2(x:s);
%     end
%     if y>w
%         xaxis4 = xaxis2(w:y);
%     else xaxis4 = xaxis2(y:w);
%     end
%     width(1) = xaxis3(round(mean(find(fitnL(xaxis3) > half(1)-0.0005 & fitnL(xaxis3) < half(1)+0.0005)))) - lat(1);
%     width(2) = xaxis4(round(mean(find(fitL(xaxis4) > half(2)-0.0005 & fitL(xaxis4) < half(2)+0.0005)))) - lat(2);
%     figure(f1)
%     subplot(4,5,(u*5)+5), plot(fitnL,'r')
%     hold on
% %     figure(f2)
% %     subplot(4,5,(u*5)+5), plot(fitL,'b')
%     hold on
%     output = cat(2,lat,width,amp);
% end
% clear data channels filelist