%% Inverse option
% 1.options IV directly from Deribit, "Summary_stats_1_2_0.m"
% 2.IV_BS calculated by BS formula
% 3.add quantity as weight
% 4.delete option with prices less than 10
% 5.we use underlying price S_t by median price
% 6.risk free rate rf = 0
% 7.inputs are "all_btc33.csv" from 2021/1/2 to 2022/10/29
% 8.compare IV Deribit and IV BS
% 9.compare option price Deribit and option price BS, call and put
%   separately
% 10. options involve weekly option and monthly option
%% load data
clear,clc
option = readtable("data/processed/all_btc33_processed_1_2_2.csv");
daily_price = readtable("data/BTC_USD_Quandl_2022.csv");
[~,~,~]=mkdir("Inverse_option/1_0_2");
dateset = string(datetime(datestr(unique(option.date((option.tau==27) & (option.date>=datetime("2021-01-01")) & (option.date<=datetime("2022-10-29")))),'YYYY-mm-DD')));
% %% Normalize tau on the span of a year
% option.tau=option.tau/365;
%% parallel estimation
for i=1:length(dateset)
    i
    [~,~,~]=mkdir(strcat("Inverse_option/1_0_2/",dateset(i)));

    option1=option(datetime(option.date)==datetime(dateset(i)),:);
    option_4week=option1((option1.tau>=27) & (option1.tau<=33),:);
    option_4week=sortrows(option_4week,"K");

    option_1week=option1((option1.tau>=0) & (option1.tau<=9),:);
    option_1week=sortrows(option_1week,"K");

    delete_list=[];
    %     option2 = option1(strcmp(option1.putcall,'C'),:);
    option2 = option_4week;
    IV_BS = zeros(size(option2.tau));
    for j = 1:size(option2,1)
        S = option2.BTC_price(j);
        K = option2.K(j);
        rf=0.00;
        tau = option2.tau(j)/365;
        C = option2.option_price(j);
        if option2.putcall{j}=='C'
            IV_BS(j) = blsimpv(S,K,rf,tau,C);
        else
            IV_BS(j) = blsimpv(S,K,rf,tau,C,"Class","put");
        end

        if isnan(IV_BS(j))
            warning('iv of observation %6d is nan.',j)
            delete_list=[delete_list,j];
        end
    end
    option2(delete_list,:)=[];
    IV_BS(delete_list,:)=[];

    option2 = addvars(option2,IV_BS,'NewVariableNames','IV_BS');

    delete_list=[];
    %     option2 = option1(strcmp(option1.putcall,'C'),:);
    option3 = option_1week;
    IV_BS = zeros(size(option3.tau));
    for j = 1:size(option3,1)
        S = option3.BTC_price(j);
        K = option3.K(j);
        rf=0.00;
        tau = option3.tau(j)/365;
        C = option3.option_price(j);
        if option3.putcall{j}=='C'
            IV_BS(j) = blsimpv(S,K,rf,tau,C);
        else
            IV_BS(j) = blsimpv(S,K,rf,tau,C,"Class","put");
        end

        if isnan(IV_BS(j))
            warning('iv of observation %6d is nan.',j)
            delete_list=[delete_list,j];
        end
    end
    option3(delete_list,:)=[];
    IV_BS(delete_list,:)=[];

    option3 = addvars(option3,IV_BS,'NewVariableNames','IV_BS');

    iv_min = min([min(option2.IV/100),min(option2.IV_BS),min(option3.IV/100),min(option3.IV_BS)]);
    iv_max = max([max(option2.IV/100),max(option2.IV_BS),max(option3.IV/100),max(option3.IV_BS)]);
    figure;
    scatter(option2.IV_BS,option2.IV/100,10, [0 0.4470 0.7410],'Filled');hold on
    scatter(option3.IV_BS,option3.IV/100,10, [0 0.4470 0.7410],'Filled');
    plot(iv_min*0.9:0.01:iv_max*1.1,iv_min*0.9:0.01:iv_max*1.1);hold off
    xlabel('\sigma_{BS}')
    ylabel('iv')
    xlim([iv_min*0.9,iv_max*1.1])
    ylim([iv_min*0.9,iv_max*1.1])
        saveas(gcf,strcat("Inverse_option/1_0_2/",dateset(i),"/discrepancy_between_iv_ivbs.png"))

    p_4week = option2.option_price./option2.BTC_price;
    option_price_IVBS_4week = zeros(size(p_4week));
    option_price_iv_4week = zeros(size(p_4week));
    for j = 1:size(option2,1)
        S = option2.BTC_price(j);
        K = option2.K(j);
        rf=0.00;
        tau = option2.tau(j)/365;
        if strcmp(option2.putcall(j),'C')
            option_price_IVBS_4week(j) = blsprice(S, K, rf, tau, option2.IV_BS(j)) / S;
            option_price_iv_4week(j) = blsprice(S, K, rf, tau, option2.IV(j)/100) / S;
        else
            [~, option_price_IVBS_4week(j)] = blsprice(S, K, rf, tau, option2.IV_BS(j));
            option_price_IVBS_4week(j) = option_price_IVBS_4week(j)/S;
            [~, option_price_iv_4week(j)] = blsprice(S, K, rf, tau, option2.IV(j)/100);
            option_price_iv_4week(j)=option_price_iv_4week(j)/S;
        end
    end

    p_1week = option3.option_price./option3.BTC_price;
    option_price_IVBS_1week = zeros(size(p_1week));
    option_price_iv_1week = zeros(size(p_1week));
    for j = 1:size(option3,1)
        S = option3.BTC_price(j);
        K = option3.K(j);
        rf=0.00;
        tau = option3.tau(j)/365;
        if strcmp(option3.putcall(j),'C')
            option_price_IVBS_1week(j) = blsprice(S, K, rf, tau, option3.IV_BS(j)) / S;
            option_price_iv_1week(j) = blsprice(S, K, rf, tau, option3.IV(j)/100) / S;
        else
            [~, option_price_IVBS_1week(j)] = blsprice(S, K, rf, tau, option3.IV_BS(j));
            option_price_IVBS_1week(j) = option_price_IVBS_1week(j)/S;
            [~, option_price_iv_1week(j)] = blsprice(S, K, rf, tau, option3.IV(j)/100);
            option_price_iv_1week(j)=option_price_iv_1week(j)/S;
        end
    end


    p_min = 0;
    p_max = max([max(p_4week),max(option_price_IVBS_4week), max(option_price_iv_4week), ...
        max(p_1week),max(option_price_IVBS_1week), max(option_price_iv_1week)]);
    %     figure;
    option_price_iv_call_4week = option_price_iv_4week(strcmp(option2.putcall,'C'));
    option_price_iv_put_4week = option_price_iv_4week(strcmp(option2.putcall,'P'));
    p_call_4week = p_4week(strcmp(option2.putcall,'C'));
    p_put_4week = p_4week(strcmp(option2.putcall,'P'));
    option_price_IVBS_call_4week = option_price_IVBS_4week(strcmp(option2.putcall,'C'));
    option_price_IVBS_put_4week = option_price_IVBS_4week(strcmp(option2.putcall,'P'));

    option_price_iv_call_1week = option_price_iv_1week(strcmp(option3.putcall,'C'));
    option_price_iv_put_1week = option_price_iv_1week(strcmp(option3.putcall,'P'));
    p_call_1week = p_1week(strcmp(option3.putcall,'C'));
    p_put_1week = p_1week(strcmp(option3.putcall,'P'));
    option_price_IVBS_call_1week = option_price_IVBS_1week(strcmp(option3.putcall,'C'));
    option_price_IVBS_put_1week = option_price_IVBS_1week(strcmp(option3.putcall,'P'));

    subplot(1,2,1)
    scatter(option_price_iv_call_4week, p_call_4week, 10, "red",'Filled');hold on
    scatter(option_price_iv_put_4week, p_put_4week, 10, "blue",'Filled');
    scatter(option_price_iv_call_1week, p_call_1week, 10, "red");
    scatter(option_price_iv_put_1week, p_put_1week, 10, "blue");
    plot(0:0.01:p_max*1.1,0:0.01:p_max*1.1);hold off
    xlabel('m_{BS}(iv)')
    ylabel('p')
    xlim([0,p_max*1.1])
    ylim([0,p_max*1.1])
    legend('monthly call','monthly put','weekly call','weekly put','45 degree')
    subplot(1,2,2)
    scatter(option_price_IVBS_call_4week, p_call_4week, 10, "red",'Filled');hold on
    scatter(option_price_IVBS_put_4week, p_put_4week, 10, "blue",'Filled');
    scatter(option_price_IVBS_call_1week, p_call_1week, 10, "red");
    scatter(option_price_IVBS_put_1week, p_put_1week, 10, "blue");
    plot(0:0.01:p_max*1.1,0:0.01:p_max*1.1);hold off
    xlabel('m_{BS}(\sigma_{BS})')
    ylabel('p')
    xlim([0,p_max*1.1])
    ylim([0,p_max*1.1])
    set(gcf,'Position',[100,100,1000,500])
    saveas(gcf,strcat("Inverse_option/1_0_2/",dateset(i),"/pricing_inverse_option.png"))

    %     subplot(1,2,1)
    %     scatter(option_price_iv, p, 10, [0 0.4470 0.7410],'Filled');hold on
    %     plot(0:0.01:p_max*1.1,0:0.01:p_max*1.1);hold off
    %     xlabel('m_{BS}(iv)')
    %     ylabel('p')
    %     xlim([0, 0.22])
    %     ylim([0, 0.22])
    %     subplot(1,2,2)
    %     scatter(option_price_IVBS, p, 10, [0 0.4470 0.7410],'Filled');hold on
    %     plot(0:0.01:p_max*1.1,0:0.01:p_max*1.1);hold off
    %     xlabel('m_{BS}(\sigma_{BS})')
    %     ylabel('p')
    %     xlim([0, 0.22])
    %     ylim([0, 0.22])
    % set(gcf,'Position',[100,100,1000,500])
    %     saveas(gcf,strcat("Inverse_option/1_0_2/",dateset(i),"/pricing_inverse_option.png"))
end