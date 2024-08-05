name = 'SF data structure start';  %input GUI allows user to specify if tuning metrics are worth calculating.
prompt = {'Enter starting structure # for session with SF cones','GoodUnit'};
numlines = 1;
defaultparams = {'5','1'};
params = inputdlg(prompt,name,numlines,defaultparams);
NLED = (str2double(params{1}));
i = (str2double(params{2}));
NLED(2:4) = [NLED(1)+2 NLED(1)+4 NLED(1)+6];
YLED = NLED+1;

units=[0.010000000000000,0.175555555555556,0.341111111111111,0.506666666666667,0.672222222222222,0.837777777777778,1.003333333333333,1.168888888888889,1.334444444444445,1.500000000000000];

for a=1:4
    SFFits=[]; P=[]; SFFitsYLED=[]; PYLED=[];
    fitRates=data(NLED(a)).sumSF(:,i)';
    fitSterr=data(NLED(a)).SFSterr(:,i);
    [P,SFFits] = FitDifOfGaus(units,fitRates,0,3); % FitDifOfGaus found in vnl-tools GitHub.

    SFFit.fits{1,1} = SFFits;
    SFFit.P{1,1} = P;
    SFFit.rates{1,1} = fitRates;

    figure
    %Plotting a smoothed curve on top of original plot. SM 2/20/2023
    %Upsampling only units and SFFits, NOT original data values. SM
    D = interp(units,2);
    %interp(x,#) --> You can edit the factor (#), and test which ones fit
    %the data best. SM
    E = SFFits; %Making sure SFFits is the correct data type to
    %be used with 'interp'. SM
    F = interp(E,2);

    errorbar(units, fitRates, fitSterr, '.k');
    hold on
    %     plot(units, SFFit.fits{a}{a}, '--k'); %Original curve fit
    %     hold on
    plot(D, F, 'k'); %Plotting the smooth curve. SM
    xlabel('Cyles/Deg');
    ylabel('Spikes/s');
    xlim([0.05 max(units)]);
    set(gca,'XScale','log');
    title(['Spatial Frequency for Unit ', num2str(i)]);
    hold on

    fitRatesYLED=data(YLED(a)).sumSF(:,i)';
    fitSterrYLED=data(YLED(a)).SFSterr(:,i);
    [PYLED,SFFitsYLED] = FitDifOfGaus(units,fitRatesYLED,0,3); % FitDifOfGaus found in vnl-tools GitHub.

    SFFitYLED.fits{1,1} = SFFitsYLED;
    SFFitYLED.P{1,1} = PYLED;
    SFFitYLED.rates{1,1} = fitRatesYLED;

    E2 = SFFitsYLED;
    F2 = interp(E2, 2);

    errorbar(units, fitRatesYLED, fitSterrYLED, '.b');
    hold on
    %     plot(units, SFFitYLED.fits{a}{a}, '--b'); %Original YLED curve fit
    %     hold on
    plot(D,F2, 'b');

    name = 'Good Curves?';  %input GUI allows user to specify if tuning metrics are worth calculating.
    prompt = {'Good Curve No LED? No = 0, Yes = 1','Good Curve w/ LED? No = 0, Yes = 1'};
    numlines = 1;
    defaultparams = {'1','1'};
    params = inputdlg(prompt,name,numlines,defaultparams);
    goodcurveNLED = (str2double(params{1}));
    goodcurveYLED = (str2double(params{2}));

    if goodcurveNLED > 0
        set(figure(1),'Visible','on'); %calls figure 2
        [XNLED,YNLED] = ginput(1);
        TuningData(1,a) = XNLED;
    else
        TuningData(1,a) = 0;
    end
    if goodcurveYLED > 0
        set(figure(1),'Visible','on');
        [XYLED,YYLED] = ginput(1);
        TuningData(2,a) = XYLED;
    else
        TuningData(2,a) = 0;
    end
    close figure 1

end
