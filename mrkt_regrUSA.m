%Linear regression model for S&P500 using some of its movers
% Based on last 50 trading days


%Create the tables from data
SePtable = readtable('SeP.csv');
maroiltable = readtable('maroil.csv');
goldstable = readtable('golds.csv');
geneletable = readtable('genelec.csv');
appletable = readtable ('apple.csv');

%Extract stocks closing prices
SePstk = SePtable.Close(1:50);
maroilstk = maroiltable.Close(1:50);
goldsstk = goldstable.Close(1:50);
genelestk = geneletable.Close(1:50);
applestk = appletable.Close(1:50);

%Extract Days
dates = datetime(SePtable.Date);
dates= dates(2:50);


%Extract returns
SePrts =  diff(log(SePstk));
maroilrts =  diff(log(maroilstk));
goldsrts =  diff(log(goldsstk));
genelerts =  diff(log(genelestk));
applerts =  diff(log(applestk));


%Store factors into a matrix 
factors = [maroilrts,goldsrts,genelerts,applerts];

% Plot the market data returns
figure
plot(dates,SePrts,'b')
hold on
grid
title('Market Returns and Fitted Values')

% Fit a linear model to the data
marketModel = fitlm(factors,SePrts);

% Plot the fitted values
plot(dates,marketModel.Fitted,'r')