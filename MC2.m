% In this code we import data of an index/stock
% Find the t-distribution fitting historical returns
% Monte-Carlo simulate future values/returns
% Finally plot all the results

% Import the data/indexes, compute the returns
ESTX50table = readtable('ESTX50.csv');
ESTX50table.Date= datetime(ESTX50table.Date);
dys = day(datetime(ESTX50table.Date) - datetime(ESTX50table.Date(1)));
ESTXreturns = tick2ret(ESTX50table.Close,dys);



% Now let's find the right t-student distribution fitting returns
tFit = fitdist(ESTXreturns(1:300),'tlocationscale');

% Monte-Carlo Simulations for a t distribution
nSteps = 10;       % Number of future steps 
nExp = 1e4;        % Number of rand experiments

% random numbers from the fitted t-distribution
simReturns = random(tFit,nSteps,nExp);

% predictions of the prices and of their quantile trajectories 
predictions = ret2tick(simReturns,ESTX50table.Close(1));
quantileCurves = quantile(predictions,[0.01 0.05 0.5 0.95 0.99],2);

% Plotting the values and the quantile predictions
figure
subplot(2,1,1)
plot(ESTX50table.Date(1:300),ESTX50table.Close(1:300),'LineWidth',2)
title('ESTX50 Closing Value')
xlabel('Date')
grid on
hold on
plot(ESTX50table.Date(1) + (0:nSteps),quantileCurves,'r')
legend('Market known Data','Future Values','Location','NE')
hold off

subplot(2,1,2)
histogram(predictions(end,:),'Normalization','pdf')
xlabel('ESTX50 Closing Value')
title('Distrubtion of Simulated Values')