%% Tail fit by GEV distribution 2.5.2
% first we transfer density of moneyness to density of return

% we use "RND_2_2_0_4week.m" to estimate Q_Figlewski

% also output density of moneyness "K/S_t"

% INPUT: Q-density with truncated tails

% OUTPUT: Q-density of return with tails [-1, 1]
%         log return: log(K/S_t), range [-1, 1]
%         parameters of GEV tails    

clear,clc
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Moneyness");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Return");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Output");
dates_cell = ["2021-01-02",...
    "2021-01-30","2021-02-27","2021-04-03","2021-05-01","2021-05-29",...
    "2021-07-03","2021-07-31","2021-08-28","2021-10-02","2021-10-30",...
    "2021-12-04","2022-01-01","2022-01-29","2022-02-26","2022-04-02",...
    "2022-04-30","2022-05-28","2022-07-02","2022-07-30","2022-09-03",...
    "2022-10-01","2022-10-29"];

rng("default")
error_case=zeros(size(dates_cell));
paras_l = zeros(numel(dates_cell), 3);
paras_r = zeros(numel(dates_cell), 3);
figure;
for i = 1:numel(dates_cell)
    a = strcat("Compare_Q_Figlewski/RND/RND_2_2_0/RND_Figlewski_4weeks_", dates_cell(i), ".csv");
    data_epk = readtable(a);

    %%%%%%%%%%  log return  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [Q_rt, rt, paras] = Q_tail_logret(data_epk.spdy, data_epk.m);
    [Q_rt, rt, paras, details] = Q_tail_logret_Figlewski(data_epk.RND_M(data_epk.Moneyness>0.5 & data_epk.Moneyness<=2), data_epk.Moneyness(data_epk.Moneyness>0.5 & data_epk.Moneyness<=2));

    paras_l(i,:) = paras(1,:);
    paras_r(i,:) = paras(2,:);
    
    %%% input Q-density
%     figure; 
    plot(details.raw_rt, details.raw_Qrt)
    ylim([0, 3.5])
    xlim([min(rt), max(rt)])
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Return/Q_density_',dates_cell(i),'.png'))

    %%% procedure of tail fit
%     figure;
    plot(details.raw_rt, details.raw_Qrt)
    xlim([min(rt), max(rt)])
    hold on
    plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
    plot(details.return_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
    plot(details.return_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
    hold off
    legend({'Q Rookley','target points','left tail','right tail'})
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Return/Fit_Tail_',dates_cell(i),'.png'))

    %%% full tail
%     figure;
    plot(rt, Q_rt)
    ylim([0, 3.5])
    xlim([min(rt), max(rt)])
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Return/Q_density_',dates_cell(i),'.png'))

    %%% tail with different colors
%     figure;
    plot(details.raw_rt, details.raw_Qrt)
    hold on 
    plot(details.return_range(details.return_range<details.raw_rt(1)), details.q_l(details.return_range<details.raw_rt(1)), '--','Color',[0.2235, 0.0588, 0.4314])
    plot(details.return_range(details.return_range>details.raw_rt(end)), details.q_r(details.return_range>details.raw_rt(end)), '--','Color',[0.9922, 0.6314, 0.4314])
    hold off
    ylim([0, 3.5])
    xlim([min(rt), max(rt)])
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Return/Show_tail_',dates_cell(i),'.png'))

    % write Q density
    output = table(rt', Q_rt','VariableNames',{'Return', 'Q_density'});
    writetable(output,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Output/Q_density_logreturn_',dates_cell(i),'.csv'))




    %%%%%%%%%%%%  Moneyness  %%%%%%%%%%%%%%%%%%%%%
    [Q_m, m, paras, details] = Q_tail_moneyness_Figlewski(data_epk.RND_M(data_epk.Moneyness>0 & data_epk.Moneyness<=2), data_epk.Moneyness(data_epk.Moneyness>0 & data_epk.Moneyness<=2));

    %%% input Q-density
%     figure; 
    plot(details.raw_moneyness, details.raw_Qmoneyness)
    ylim([0, 3.5])
    xlim([min(m), max(m)])
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Moneyness/Q_density_',dates_cell(i),'.png'))

    %%% procedure of tail fit
%     figure;
    plot(details.raw_moneyness, details.raw_Qmoneyness)
    xlim([min(m), max(m)])
    hold on
    plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
    plot(details.moneyness_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
    plot(details.moneyness_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
    hold off
    legend({'Q Rookley','target points','left tail','right tail'})
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Moneyness/Fit_Tail_',dates_cell(i),'.png'))

    %%% full tail
%     figure;
    plot(m, Q_m)
    ylim([0, 3.5])
    xlim([min(m), max(m)])
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Moneyness/Q_density_',dates_cell(i),'.png'))

    %%% tail with different colors
%     figure;
    plot(details.raw_moneyness, details.raw_Qmoneyness)
    hold on 
    plot(details.moneyness_range(details.moneyness_range<details.raw_moneyness(1)), details.q_l(details.moneyness_range<details.raw_moneyness(1)), '--','Color',[0.2235, 0.0588, 0.4314])
    plot(details.moneyness_range(details.moneyness_range>details.raw_moneyness(end)), details.q_r(details.moneyness_range>details.raw_moneyness(end)), '--','Color',[0.9922, 0.6314, 0.4314])
    hold off
    ylim([0, 3.5])
    xlim([min(m), max(m)])
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Moneyness/Show_tail_',dates_cell(i),'.png'))

    % write Q density
    output = table(m', Q_m','VariableNames',{'Moneyness', 'Q_density'});
    writetable(output,strcat('Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Output/Q_density_moneyness_',dates_cell(i),'.csv'))

end