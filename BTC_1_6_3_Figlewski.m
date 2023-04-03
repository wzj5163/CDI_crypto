%% BTC price, BTC VIX, Q_F, CDI EPK
% 1.We draw 2x2 plots including Q_F on the day, CDI EPK using that Q_F,
% corresponding BTC price and BTC VIX
% 2.For Q_F we use Figlewski method
% 3.Q_F by "RND_2_2_0_4week" and "TailFit_GEV_2_5_2.m"
% 4.EPK by "BTC_1_6_3_Figlewski.m"

%% load data
clear,clc
addpath("m_Files_Color\colormap\")
daily_price = readtable("data/BTC_USD_Quandl_2022.csv");
daily_price.Date = daily_price.Date(end:-1:1);
daily_price.Adj_Close = daily_price.Adj_Close(end:-1:1);

%% Different BW
[~,~,~]=mkdir("EPK_figures/CDI_Figlewski_1_6_3_4plots");

dateset = ["2022-10-29","2022-10-01","2022-09-03","2022-07-30","2022-07-02","2022-05-28","2022-04-30", ...
    "2022-04-02","2022-02-26","2022-01-29","2022-01-01","2021-12-04","2021-10-30","2021-10-02", ...
    "2021-08-28","2021-07-31","2021-07-03","2021-05-29","2021-05-01"];

figure;

for j = 1:numel(dateset)

    subplot(2,2,1)
    plot(daily_price.Date(1187:end), daily_price.Adj_Close(1187:end));
    ylabel('BTC Price')
    dateaxis('x',12)
    hold on
    scatter(daily_price.Date(daily_price.Date==dateset(j)),daily_price.Adj_Close(daily_price.Date==dateset(j)),15,'red','filled')
    hold off
    xticks(daily_price.Date(round(linspace(1187,1826,7))))
    xticklabels({'Apr21' 'Jul21' 'Oct22' 'Feb22' 'Jun22' 'Sep22' 'Dec22'})
    subtitle(append('BTC price on ', dateset(j)))

    subplot(2,2,3)
    a = strcat("data\BTC_VIX.csv");
    BTC_VIX = readtable(a);
    plot(BTC_VIX.date(9:end),BTC_VIX.index(9:end));
    ylabel('BTC Volatility Index')
    dateaxis('x',12)
    hold on
    scatter(BTC_VIX.date(BTC_VIX.date==dateset(j)),BTC_VIX.index(BTC_VIX.date==dateset(j)),15,'red','filled')
    hold off
    xticks(BTC_VIX.date(round(linspace(9,648,7))))
    xticklabels({'Apr21' 'Jul21' 'Oct22' 'Feb22' 'Jun22' 'Sep22' 'Dec22'})
    subtitle(append('BTC volatility index on ', dateset(j)))

    subplot(2,2,2)
    a = strcat("Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Output/Q_density_logreturn_",dateset(j),".csv");
    rnd_f = readtable(a);
    plot(rnd_f.Return,rnd_f.Q_density);
    xlabel('r=log(S_{t+\tau}/S_t)'),ylabel('Q Density')
    ylim([0 3.5]);
    subtitle(append('Q-density on ', dateset(j)))

    subplot(2,2,4)
    a = strcat("EPK_figures/CDI_Figlewski_1_5_10_return/EPK_1month_",dateset(j),".csv");
    CDI_EPK = readtable(a);
    Colors = rainbow(7);
    plot(CDI_EPK.Return, CDI_EPK.J_4_m_4,"Color",Colors(1,:))
    hold on
    plot(CDI_EPK.Return, CDI_EPK.J_5_m_5,"Color",Colors(2,:))
    plot(CDI_EPK.Return, CDI_EPK.J_6_m_6,"Color",Colors(3,:))
    plot(CDI_EPK.Return, CDI_EPK.J_7_m_7,"Color",Colors(4,:))
    plot(CDI_EPK.Return, CDI_EPK.J_5_m_8,"Color",Colors(5,:))
    plot(CDI_EPK.Return, CDI_EPK.J_5_m_9,"Color",Colors(6,:))
    plot(CDI_EPK.Return, CDI_EPK.J_5_m_10,"Color",Colors(7,:))
    hold off
    xlabel('r=log(S_{t+\tau}/S_t)'),ylabel('EPK')
    xlim([-0.15,0.15]);
    ylim([0.3 5]);
    xticks([-0.15 -0.1 -0.05 0 0.05 0.1 0.15])
    legend('4, 4','5, 5','6, 6','7, 7','5, 8','5, 9','5, 10')
    subtitle(append('CDI EPK on ', dateset(j),' (# moment conditions, # knots)'))

    set(gcf,'Position',[100,0,1000,1000])
    saveas(gcf, strcat("EPK_figures/CDI_Figlewski_1_6_3_4plots/EPK_Q_Price_VIX_",dateset(j),".png"));

end