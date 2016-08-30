% This code takes closing prices for a certain index, calculates
% future days returns (Monte Carlo) and correspondig VaR values

% read the nikkei historical data table (last 90 days)
% and select the closing price

M=csvread('nikkei.csv',1,1,[1,1,90,6]);
stock=M(:,6);

% day by day log returns , mean and stand. deviation
sReturns = diff(log(stock));
mr = mean(sReturns);
sigma = std(sReturns);

% M-C prices' simulation for 5 days in future based on GBM
deltaT = 1;
S0 = stock(end);
epsilon = randn(5,200);
fact1 = exp((mr-sigma^2/2)*deltaT + sigma*epsilon*sqrt(deltaT));
lastPrice = ones(1,200)*S0;
fact2 = [lastPrice;fact1];
paths = cumprod(fact2);

%paths
plot(paths)
figure()

% final prices
finalPrices = paths(end,:);

% the returns
possibleReturns = log(finalPrices) - log(S0);

% histogram of returns, with 25 bins
histogram(possibleReturns,25)

% VaR and plot in the histogram
var5 = tsprctile(possibleReturns,1)
hold on
plot([var5 var5],[0 40],'r')  %special instructions for histogram