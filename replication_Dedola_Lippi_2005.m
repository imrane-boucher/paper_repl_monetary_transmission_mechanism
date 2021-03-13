%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial data dedola & lippi worked with:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% monthly data for the 1995-1997 period.

% variables:
% France, Germany, Italy, UK: Industrial production, consumer price index,commodity price
% index, Short-term rate (3-months), Money (M3), Exchange rate
% US: Industrial production, Consumer price index, commodity price index,
% Short-term rate (FF rate), Money (M1)

% used lags suggested by LM test (Lagrange Multiplier)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Our Replication Work
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Working with the VAR toolbox 
% https://sites.google.com/site/ambropo/MatlabCodes
% code used from the following example: http://lrondina.com/matlab_html_scripts/SVAR_demo.html

% Add VAR toolbox to the MATLAB path (including all subfolders)
%%% YOU CAN UNCOMMENT THE FOLLOWING LINE IF YOU NEED TO ADD THE VAR TOOLBOX TO YOUR PATH
% addpath(genpath('VAR_toolbox'))

% load data
% for the us 
[ind_prod_us, ind_prod_us_txt] = xlsread('datasets/US_industrial production index.xlsx','Sheet1','A1:B194');
[cpi_us, cpi_us_txt] = xlsread('datasets/US_consumer price index.xlsx', 'Sheet1', 'A1:B194');
[ipi_us, ipi_us_txt] = xlsread('datasets/US_import price index.xlsx', 'Sheet1', 'A1:B194');
[ff_rate, ff_rate_txt] = xlsread('datasets/US_interbank immediate rates.xlsx', 'Sheet1', 'A1:B194');
[m1_us, m1_us_txt] = xlsread('datasets/United_States_M1.xlsx', 'Sheet1', 'A1:B194');

% for france
[ind_prod_fr, ind_prod_fr_txt] = xlsread('datasets/France_industrial production index.xlsx','Sheet1','A1:B194');
[cpi_fr, cpi_fr_txt] = xlsread('datasets/France_consumer price index.xlsx', 'Sheet1', 'A1:B194');
[ipi_fr, ipi_fr_txt] = xlsread('datasets/France_import price index.xlsx', 'Sheet1', 'A1:B194');
[short_rate_fr, short_rate_fr_txt] = xlsread('datasets/Euro_Area_interbank intermediate rates.xlsx', 'Sheet1', 'A1:B194');

% for germany
[ind_prod_deu, ind_prod_deu_txt] = xlsread('datasets/Germany_industrial production index.xlsx','Sheet1','A1:B194');
[cpi_deu, cpi_deu_txt] = xlsread('datasets/Germany_consumer price index.xlsx', 'Sheet1', 'A1:B194');
[ipi_deu, ipi_deu_txt] = xlsread('datasets/Germany_import price index.xlsx', 'Sheet1', 'A1:B194');
[short_rate_deu, short_rate_deu_txt] = xlsread('datasets/Euro_Area_interbank intermediate rates.xlsx', 'Sheet1', 'A1:B194');

% for uk
[ind_prod_uk, ind_prod_uk_txt] = xlsread('datasets/UK_industrial production index.xlsx','Sheet1','A1:B194');
[cpi_uk, cpi_uk_txt] = xlsread('datasets/UK_consumer price index.xlsx', 'Sheet1', 'A1:B194');
[ipi_uk, ipi_uk_txt] = xlsread('datasets/UK_import price index.xlsx', 'Sheet1', 'A1:B194');
[short_rate_uk, short_rate_uk_txt] = xlsread('datasets/UK_interbank immediate rates.xlsx', 'Sheet1', 'A1:B194');


% common europe data
[m1_euro, m1_euro_txt] = xlsread('datasets/Euro Area_M1.xlsx', 'Sheet1', 'A1:B194');
[xchg_rate_euro, xchg_rate_euro_txt] = xlsread('datasets/Euro Area_effective exchange rate.xlsx', 'Sheet1', 'A1:B194');



% we transform data in log level to match the papers specification
% log level transformation imporve comparability of results between
% variables
% which are in different scales 
% plus it corrects for exponential behaviors we can observe in certain time
% series (monetary aggregates)
% us
ind_prod_us = log(ind_prod_us);
cpi_us = log(cpi_us);
ipi_us = log(ipi_us);
m1_us = log(m1_us);

% france
ind_prod_fr = log(ind_prod_fr);
cpi_fr = log(cpi_fr);
ipi_fr = log(ipi_fr);

% Germany
ind_prod_deu = log(ind_prod_deu);
cpi_deu = log(cpi_deu);
ipi_deu = log(ipi_deu);

% euro 
m1_euro = log(m1_euro);


% SVAR Analysis for the US ------------------------------------------------
X = [ind_prod_us, cpi_us, ipi_us, ff_rate, m1_us];
vnames = {'us ind prod'; 'us cpi'; 'us ipi'; 'us short-term rate'; 'us m1'};

% define number of variables, observation
[nobs, nvar] = size(X);

% We use the same lag specification chosen by Dedola and Lippi 
% to simplify our analysis
nlags = 4;
const_trend = 2; % We apply a detrending method using this parameter, because most of our data are indices (base 100), which
% display a trend.

% Estimate the VAR
[VAR, VAR_options] = VARmodel(X, nlags,const_trend);

% Show estimated model parameters
VAR_options.vnames = vnames;
VARprint(VAR,VAR_options);
VAR_options.frequency = 'm';
% structural VAR
% we are no interested in the study of innovations but of structural
% shocks!

% Choose the identification scheme
VAR_options.ident = 'oir';          % 'oir' selects a recursive scheme + implementation of a short term shock
% Choose the horizon for the impulse responses
VAR_options.nsteps = 60;
% Apply the identification scheme and compute impulse responses
[IRF,VAR] = VARir(VAR,VAR_options);

% Compute confidence intervals using bootstrap methods
[IRF_lower,IRF_upper,IRF_median] = VARirband(VAR,VAR_options);

% Figures related options
VAR_options.savefigs = true;
VAR_options.quality  = 0;
% Plot impulse response functions
VARirplot(IRF_median,VAR_options,IRF_lower,IRF_upper);
% SVAR Analysis for France -----------------------------------------------
X_fr = [ind_prod_fr, cpi_fr, ipi_fr, short_rate_fr, m1_euro, xchg_rate_euro];
vnames = {'france ind prod'; 'france cpi'; 'france ipi'; 'euro area short-term rate'; 'euro m1'; 'euro-xchg-rae'};

% define number of variables, observation
[nobs, nvar] = size(X_fr);

nlags = 4;
const_trend = 2;

% Estimate the VAR
[VAR, VAR_options] = VARmodel(X_fr, nlags,const_trend);

% Show estimated model parameters
VAR_options.vnames = vnames;
VARprint(VAR,VAR_options);
VAR_options.frequency = 'm';
% structural VAR
% we are no interested in the study of innovations but of structural
% shocks!

% Choose the identification scheme
VAR_options.ident = 'oir';          % 'oir' selects a recursive scheme
% Choose the horizon for the impulse responses
VAR_options.nsteps = 60;
% Apply the identification scheme and compute impulse responses
[IRF,VAR] = VARir(VAR,VAR_options);

% Compute confidence intervals using bootstrap methods
[IRF_lower,IRF_upper,IRF_median] = VARirband(VAR,VAR_options);

% Figures related options
VAR_options.savefigs = true;
VAR_options.quality  = 0;
% Plot impulse response functions
VARirplot(IRF_median,VAR_options,IRF_lower,IRF_upper);

% SVAR Analysis for Germany -----------------------------------------------
X_deu = [ind_prod_deu, cpi_deu, ipi_deu, short_rate_deu, m1_euro, xchg_rate_euro];
vnames = {'germany ind prod'; 'germany cpi'; 'germany ipi'; 'euro area short-term rate'; 'euro m1';'euro-xchg-rate'};

% define number of variables, observation
[nobs, nvar] = size(X_deu);

nlags = 4;
const_trend = 2;

% Estimate the VAR
[VAR, VAR_options] = VARmodel(X_deu, nlags,const_trend);

% Show estimated model parameters
VAR_options.vnames = vnames;
VARprint(VAR,VAR_options);
VAR_options.frequency = 'm';
% structural VAR
% we are no interested in the study of innovations but of structural
% shocks!

% Choose the identification scheme
VAR_options.ident = 'oir';          % 'oir' selects a recursive scheme
% Choose the horizon for the impulse responses
VAR_options.nsteps = 60;
% Apply the identification scheme and compute impulse responses
[IRF,VAR] = VARir(VAR,VAR_options);

% Compute confidence intervals using bootstrap methods
[IRF_lower,IRF_upper,IRF_median] = VARirband(VAR,VAR_options);

% Figures related options
VAR_options.savefigs = true;
VAR_options.quality  = 0;
% Plot impulse response functions

VARirplot(IRF_median,VAR_options,IRF_lower,IRF_upper);

% NB: WE have saved under png format the impulse responses displaying the
% impact of monetary shock on US, Fr, Deu macroecnomic variables:
% - france_response_euro_monetary_shock.png
% - germany_response_euro_monetary_shock.png
% - us_response_monetary_shock.png
