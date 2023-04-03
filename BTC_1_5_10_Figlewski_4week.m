%% updates 1.5.10
% 1.EPK CDI vs EPK classic
% 2.tau = 1 month
% 3.Figlewski's Q and classic EPK
% 4.x-axis is Moneyness=K/S_T
% 5.Return of [-1, 1], of which we use Figlewski's method to calculate Q
% of moneyness [0.8, 1.2] and transfer to density of return [log0.8, log1.2], 
% use GEV to fit [-1, log0.8] and [log1.2, 1]
% 6.interest rates are fixed at 0.00
% 7.use 1 file to calculate all months
% 8.integral from -1 to realized return
% 9.use "RND_2_2_0_4week.m" to estimate Q_Figlewski and
%   "TailFit_GEV_2_5_2.m" to complete tails
% 10 use one figure to plot CDI with different # knots
%% load data
clear,clc
addpath("m_Files_Color\colormap\")
daily_price = readtable("data/BTC_USD_Quandl_2022.csv");
dates_CDI = ["20221029", "20221001", "20220903", "20220730", "20220702", "20220528", "20220430", ...
    "20220402", "20220226","20220129","20220101","20211204","20211030","20211002", ...
    "20210828","20210731","20210703","20210529","20210501"];
dates_CDI_yyyymmdd = ["2022-10-29","2022-10-01","2022-09-03","2022-07-30","2022-07-02","2022-05-28","2022-04-30", ...
    "2022-04-02", "2022-02-26","2022-01-29","2022-01-01","2021-12-04","2021-10-30","2021-10-02", ...
    "2021-08-28","2021-07-31","2021-07-03","2021-05-29","2021-05-01"];
dates_Q = ["2022-10-01","2022-09-03","2022-07-30","2022-07-02","2022-05-28","2022-04-30", ...
    "2022-04-02", "2022-02-26","2022-01-29","2022-01-01","2021-12-04","2021-10-30","2021-10-02", ...
    "2021-08-28","2021-07-31","2021-07-03","2021-05-29","2021-05-01","2021-04-03"];
for i0=1:numel(dates_CDI)
    [~,~,~]=mkdir(strcat("EPK_figures/CDI_Figlewski_1_5_10_return/"));
    % prepare Q-density
    dates_cell = dates_Q(i0:numel(dates_Q));

    realizedKhRet=cell(length(dates_cell),1);
    realizedQdenRet=cell(length(dates_cell),1);
    for i = 1:length(dates_cell)

        a = strcat("Q_Tail_Fit/All_Tail_2_5_2_Figlewski/Output/Q_density_logreturn_",dates_cell(i),".csv");
        data_q = readtable(a);

        sp1=daily_price;
        sp1(datenum(sp1.Date)<datenum(dates_cell(i),"yyyy-mm-dd") | datenum(sp1.Date)>datenum(dates_cell(i),"yyyy-mm-dd")+30,:)=[];
        rt=linspace(-1,log(sp1.Adj_Close(end)/sp1.Adj_Close(1)),500);

        Qdentisty = spline(data_q.Return,data_q.Q_density,rt);

        realizedKhRet{i,1}=rt;
        realizedQdenRet{i,1}=Qdentisty;
    end
    % delete empty cell if any
    i = 1;
    while i <= length(realizedKhRet)
        if isempty(realizedQdenRet{i,1})
            realizedQdenRet(i,:)=[];
            realizedKhRet(i,:)=[];
        else
            i=i+1;
        end
    end
%     % load confidence bands and EPK based on Rookley's method
%     EPK_classic = readtable(strcat("Compare_Q_different_BW/M_0d8_to_1d2_1_3_0/btc_pk_",dates_CDI_yyyymmdd(i0),"_bw_0.3.csv"));
    % CDI part 4, 4, 0 .0001 end of day price
    [sampleestimate_4_4_00001, returns_4_4_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,4,4, .0001) ;
    figure;
    Colors = rainbow(7);
    ret=returns_4_4_00001 ;
    plot(ret, sampleestimate_4_4_00001,"Color",Colors(1,:))
    hold on 
    [sampleestimate_5_5_00001, returns_5_5_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,5,5, .0001) ;
    ret=returns_5_5_00001 ;
    plot(ret, sampleestimate_5_5_00001,"Color",Colors(2,:))
    [sampleestimate_6_6_00001, returns_6_6_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,6,6, .0001) ;
    ret=returns_6_6_00001 ;
    plot(ret, sampleestimate_6_6_00001,"Color",Colors(3,:))
    [sampleestimate_7_7_00001, returns_7_7_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,7,7, .0001) ;
    ret=returns_7_7_00001 ;
    plot(ret, sampleestimate_7_7_00001,"Color",Colors(4,:))
    [sampleestimate_5_8_00001, returns_5_8_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,5,8, .0001) ;
    ret=returns_5_8_00001 ;
    plot(ret, sampleestimate_5_8_00001,"Color",Colors(5,:))
    [sampleestimate_5_9_00001, returns_5_9_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,5,9, .0001) ;
    ret=returns_5_9_00001 ;
    plot(ret, sampleestimate_5_9_00001,"Color",Colors(6,:))
    [sampleestimate_5_10_00001, returns_5_10_00001] = CDI_estimator(realizedKhRet,realizedQdenRet, @OptSDF,5,10, .0001) ;
    ret=returns_5_10_00001 ;
    plot(ret, sampleestimate_5_10_00001,"Color",Colors(7,:))
    xlabel('r=log(S_{t+\tau}/S_t)'),ylabel('EPK')
    xlim([-0.15,0.15]);
    ylim([0.3 5]);     hold off
%     legend('4, 4','5, 5','6, 6','7, 7','8, 8','9, 9','10, 10','Classic EPK','Confidence bands','Confidence bands')
    legend('4, 4','5, 5','6, 6','7, 7','5, 8','5, 9','5, 10')
    title('# moments, # knots')
    saveas(gcf,strcat("EPK_figures/CDI_Figlewski_1_5_10_return/EPK_1month_",dates_CDI(i0),".png"))

    outtable = table(ret',sampleestimate_4_4_00001,sampleestimate_5_5_00001,sampleestimate_6_6_00001, ...
        sampleestimate_7_7_00001,sampleestimate_5_8_00001,sampleestimate_5_9_00001,sampleestimate_5_10_00001, ...
        'VariableNames',{'Return','J_4_m_4','J_5_m_5','J_6_m_6','J_7_m_7','J_5_m_8','J_5_m_9','J_5_m_10'});
    writetable(outtable,strcat("EPK_figures/CDI_Figlewski_1_5_10_return/EPK_1month_",dates_CDI_yyyymmdd(i0),".csv"))
end