%shows for Hull White Model (calibrated) the trees of r, B, d, Q, 
% and price a euro-american put 
function [EuroPut, AmerPut]=HWputsfm(Rates, alpha, sigma,K, Mat)
%clc;
% Yearly zero coupon rates and tenors
Tenors =[1:length(Rates)];
%Rates = [.055 .06 .0625 .0675 .07 .0725];
%Tenors = [1:6];

% Maturity (T) number of time steps (N) and time increment (dt)
T=length(Rates)-1;
N=T;
%T = 5;
%N = 5;
dt = T/N;
Time = 1:T+1;
R = Rates(1:T+1);

% Discount factor of the market.
P = exp(-R.*Time);

% Strike price for puts on the discount bond (if not in input)
%K = 0.75;

% Hull White tree parameters (if not in input)
%alpha = 0.1;
%sigma = 0.01;
dr = sigma*sqrt(3*dt);
dx = dr;

% Threshold (M), jMax, and state vector (x)
M = -alpha*dt;
jMax = ceil(-0.1835/M)
x = dr.*[jMax:-1:-jMax];

% Build the HW probability trees for pu, pm, and pd.
[pu pm pd] = BuildHWprobs(jMax,N,M)
%check they sum to unity
sump_i=pu+pm+pd

% Construct the Hull-White interest rate tree (r), 
% discount factors (d) and Arrow Debreu prices (Q).
[r d Q] = BuildHWtree(R,P,jMax,N,x,dx,dt,pu,pm,pd)

% Initialize the discount bond B.
B = zeros(2*jMax+1,N+1);

% Last column of discount bond is 1 for definition.
B(:,end) = 1;

% Work backwards through tree to get remaining discount bond prices
for j=N:-1:1
	if j>jMax
		for i=1:2*jMax+1
			if i==1             % first row.
				B(i,j) = d(i,j)*(B(i,j+1)*pu(i,j) +...
                    B(i+1,j+1)*pm(i,j) + B(i+2,j+1)*pd(i,j));
			elseif i==2*jMax+1  % last row.
				B(i,j) = d(i,j)*(B(i,j+1)*pd(i,j) +...
                    B(i-1,j+1)*pm(i,j) + B(i-2,j+1)*pu(i,j));
			else
				B(i,j) = d(i,j)*(B(i-1,j+1)*pu(i,j) +...
                    B(i,j+1)*pm(i,j) + B(i+1,j+1)*pd(i,j));
			end
		end
	else
		for i=jMax-(j-2):jMax+j
			B(i,j) = d(i,j)*(B(i-1,j+1)*pu(i,j) +...
                B(i,j+1)*pm(i,j) + B(i+1,j+1)*pd(i,j));
		end
	end
end

% Prints the Discount bond
B
% Price the American and European puts.  
% Maturity if not in input
%Mat = 3;

% European put (payoff times the A-D prices)
Payoff = max(K- B(:,Mat+1), 0);
EuroPut = Q(:,Mat+1)' * Payoff

% Initial American put
AP = zeros(2*jMax+1,Mat+1);

% Value at maturity.
AP(:,Mat+1) = max(K-B(:,Mat+1),0);

% Backward through the tree
for j=Mat:-1:1
	if j>jMax   % Box of the tree
		for i=1:2*jMax+1
			if i==1             % first row.
				AP(i,j) = d(i,j)*(AP(i,j+1)*pu(i,j) +...
                    AP(i+1,j+1)*pm(i,j) + AP(i+2,j+1)*pd(i,j));
			elseif i==2*jMax+1  % last row.
				AP(i,j) = d(i,j)*(AP(i,j+1)*pd(i,j) +...
                    AP(i-1,j+1)*pm(i,j) + AP(i-2,j+1)*pu(i,j));
			else                % middle rows
				AP(i,j) = d(i,j)*(AP(i-1,j+1)*pu(i,j) +...
                    AP(i,j+1)*pm(i,j) + AP(i+1,j+1)*pd(i,j));
			end
			AP(i,j) = max(AP(i,j), K - B(i,j));
		end
	else       % Tip of the tree
		for i=jMax-(j-2):jMax+j
			AP(i,j) = d(i,j)*(AP(i-1,j+1)*pu(i,j) +...
                AP(i,j+1)*pm(i,j) + AP(i+1,j+1)*pd(i,j));
			AP(i,j) = max(AP(i,j), K - B(i,j));
		end
	end
end
% Printthe American put tree.
AP

% Print out the American put price
AmerPut = AP(jMax+1,1);


