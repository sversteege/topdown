%% Initialization
clc
close all
clearvars;

%% Loading
fname	= fullfile('v2_all_behavioural_data.csv');
T		= readtable(fname);

%% Preprocessing
sel = T.orientation~=100;
T = T(sel,:);

r = T.response;
s = T.orientation;

[s,r] = preprocess(s,r);

T.response = r;
T.orientation = s;

%% initial plot
sel0 = T.electrode == 0;
T_0 = T(sel0,:);
sel38 = T.electrode ==38;
T_38 = T(sel38,:);
sel58 = T.electrode == 58;
T_58 = T(sel58,:);

statsResponses = computeStatsResponses(T_0); %returns mean response and standard error of the mean for each orientation
%% 3 electrode stim cond plots with all data, mean and se
figure(1)
clf;
electrodes = [0, 38, 58]; % Array of electrode numbers
lineColors = colororder("gem");
%colors = [1 0.6 0.6; 0.6 0.6 1; 1 0.8 0.6]; % Array of colors for mean lines
datasets = {T_0, T_38, T_58}; % Use a cell array to refer to each data table

for ii = 1:3
    subplot(1, 3, ii)
    T_current = datasets{ii};
    statsResponses = computeStatsResponses(T_current);
    plot(T_current.orientation, T_current.response, 'ko');
    title(['Electrode ' num2str(electrodes(ii))]);
    hold on;
    %plot mean
    plot(statsResponses(:, 1), statsResponses(:, 2), 'Color', lineColors(ii,:), 'LineWidth', 2);
    %plot se of the mean
    fillX = [statsResponses(:, 1); flipud(statsResponses(:, 1))]; 
    fillY = [statsResponses(:, 2) + statsResponses(:, 3); flipud(statsResponses(:, 2) - statsResponses(:, 3))];
    fill(fillX, fillY, lineColors(ii,:), 'FaceAlpha', .4, 'EdgeColor', 'none'); % Shaded area
    axis square;
    xlabel('orientation (\circ)');
    ylabel('response orientation (\circ)');
    nicegraph;
    unityline;
end

%% plot only mean +- se

figure;
clf;
electrodes = [0, 38, 58];
colors = [1 0.6 0.6; 0.6 0.6 1; 1 0.8 0.6];
lineColors = colororder("gem");
datasets = {T_0, T_38, T_58};

for ii = 1:3
    T_current = datasets{ii};
    statsResponses = computeStatsResponses(T_current);
    title('Comparison between electrode stim conditions');
    hold on;
    %plot mean
    plot(statsResponses(:, 1), statsResponses(:, 2), 'Color', lineColors(ii,:), 'LineWidth', 2);
    %plot se of the mean
    fillX = [statsResponses(:, 1); flipud(statsResponses(:, 1))]; 
    fillY = [statsResponses(:, 2) + statsResponses(:, 3); flipud(statsResponses(:, 2) - statsResponses(:, 3))];
    fill(fillX, fillY, lineColors(ii,:), 'FaceAlpha', .4, 'EdgeColor', 'none'); % Shaded area
    axis square;
    xlabel('orientation (\circ)');
    ylabel('response orientation (\circ)');
    nicegraph;
    unityline;
end

% Create dummy objects for the legend
h = zeros(3, 1); % Preallocate
for ii = 1:3
    h(ii) = fill(nan, nan, lineColors(ii,:), 'FaceAlpha', 0.6, 'EdgeColor', 'none'); % Dummy handles
end
% Add a legend for the shaded areas
legend(h, {'no stim', 'electrode 38', 'electrode 58'}, 'Location', 'southeast');

%% Bayesian Analysis
Y = T.response;
X1 = T.orientation;
X2 = T.electrode;
%% run jags
samples = jags_anova(Y,X1,X2,'showDiag',true,'numSavedSteps',15000,'burnInSteps',5000);

%% save it to not run jags every time
%filepath = '/Volumes/mbneufy2/Haptic/Data/behavioural_data/samplesJags.mat';
%save(filepath, 'samples');

%%
lineColors = colororder("gem");
%colors = [1 0.6 0.6; 0.6 0.6 1; 1 0.8 0.6];

ue = unique(X2); 
uo = unique(X1); 
no = size(samples.b1,2);
ne = size(samples.b2,2);

%compute model predictions based on sample distribution (demeaned)
model0 = samples.b1+samples.b2(:,1)+squeeze(samples.b1b2(:,:,1));
model38 = samples.b1+samples.b2(:,2)+squeeze(samples.b1b2(:,:,2));
model58 = samples.b1+samples.b2(:,3)+squeeze(samples.b1b2(:,:,3));

%add b0
model0 = model0 + samples.b0;
model38 = model38 + samples.b0;
model58 = model58 + samples.b0;

%compute mean response
y0 = mean(model0);
y38 = mean(model38);
y58 = mean(model58);

%compute 95% hdi
hdi0 = hdimcmc(model0);
hdi38 = hdimcmc(model38);
hdi58 = hdimcmc(model58);

ys = {y0,y38,y58};
hdis = {hdi0,hdi38,hdi58};
e = gobjects(3, 1);

%variance of response
sd  = samples.ySigma;
rho = NaN(ne, no); 
rhohdi = NaN(ne, no, 2);
for ee = 1:ne
    for oo = 1:no
        a = samples.ySigma(:, oo, ee);
        rho(ee, oo) = mean(a);
        rhohdi(ee, oo, :) = hdimcmc(a );
    end
end

%plot
figure(1);
clf;
x = uo;
for ii = 1:3
y = ys{ii};
hdi = hdis{ii};
e(ii) = errorpatch(x,y,hdi,lineColors(ii,:));
end
nicegraph;
legend(e, {'no stim', 'electrode 38', 'electrode 58'}, 'Location', 'SE', 'FontSize', 10,'AutoUpdate','off');
axis square;
xlabel('orientation (\circ)');
ylabel('response orientation (\circ)');
unityline;

figure(2);
clf;
for ii = 1:3
y = ys{ii}-x';
hdi = hdis{ii}-x';
e(ii) = errorpatch(x,y,hdi,lineColors(ii,:));
end
horline(0);
verline(0);
nicegraph;
legend(e, {'no stim', 'electrode 38', 'electrode 58'}, 'Location', 'NE', 'FontSize', 10,'AutoUpdate','off');
axis square;
xlabel('orientation (\circ)');
ylabel('response error (\circ)');
set(gca, 'XTick', [-90, -45, 0, 45, 90]);

figure(3);
cla
hold on 
clear h
h = zeros(3,1);
for ee = 1:ne
   		x = uo;
	y = rho(ee, :);
	e = squeeze(rhohdi(ee,:,:));
	x = x';
	e = e';
	h(ee) = errorpatch(x,y,e,lineColors(ee,:));
end
nicegraph;
xlabel('orientation (°)', 'FontSize', 12); 
ylabel('response standard deviation (°)', 'FontSize', 12); 
set(gca, 'XTick', [-90, -45, 0, 45, 90]);
legend(h, {'no stim', 'electrode 38', 'electrode 58'}, 'Location', 'SE', 'FontSize', 10,'AutoUpdate','off');

%% functions

function statsResponses = computeStatsResponses(T_x)
    uniqueOrientations = unique(T_x.orientation);
    statsResponses = zeros(length(uniqueOrientations), 3);
    for i = 1:length(uniqueOrientations)
        orientation = uniqueOrientations(i);
        responses = T_x.response(T_x.orientation == orientation);
        meanResponse = mean(responses);
        stdError = std(responses) / sqrt(length(responses));
        statsResponses(i, :) = [orientation, meanResponse, stdError];
    end
end

function [x,y] = preprocess(x,y)
x		= deg2rad(clockmin2deg(x));
y		= deg2rad(clockmin2deg(y));
sel		= abs(y-x)>0.5*pi;
y(sel)	= -y(sel);
x		= rad2deg(x);
y		= rad2deg(y);
x = round(x);
y = round(y);
end

function y = clockmin2deg(x)
y = x/60*360;
end