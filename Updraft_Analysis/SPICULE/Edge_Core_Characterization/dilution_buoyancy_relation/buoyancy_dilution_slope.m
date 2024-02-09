
[Dratio_RF01, vwindratio_RF01, lwcratio_RF01] = buoyancy_distribution_region('RF01_Region01');
[Dratio_RF02, vwindratio_RF02, lwcratio_RF02] = buoyancy_distribution_region('RF02_Region01');
[Dratio_RF04, vwindratio_RF04, lwcratio_RF04] = buoyancy_distribution_region('RF04_Region01');
[Dratio_RF08, vwindratio_RF08, lwcratio_RF08] = buoyancy_distribution_region('RF08_Region02');

nan = isnan(lwcratio_RF08);
Dratio_RF08 = Dratio_RF08(~nan);
vwindratio_RF08 = vwindratio_RF08(~nan);
lwcratio_RF08 = lwcratio_RF08(~nan);

Dratio_all = [Dratio_RF01; Dratio_RF02; Dratio_RF04; Dratio_RF08];
vwindratio_all = [vwindratio_RF01; vwindratio_RF02; vwindratio_RF04; vwindratio_RF08];
lwcratio_all = [lwcratio_RF01; lwcratio_RF02; lwcratio_RF04; lwcratio_RF08];

fit_RF01 = polyfit(lwcratio_RF01, vwindratio_RF01, 1);
fit_RF02 = polyfit(lwcratio_RF02, vwindratio_RF02, 1);
fit_RF04 = polyfit(lwcratio_RF04, vwindratio_RF04, 1);
fit_RF08 = polyfit(lwcratio_RF08, vwindratio_RF08, 1)
fit_all = polyfit(lwcratio_all, vwindratio_all, 1)
% Make new x coordinates
x = linspace(min(lwcratio_all), max(lwcratio_all), 1000);
y01 = polyval(fit_RF01, x);

    
fig1 = figure(1);

    plot(x, y01, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 2, 'Linestyle', '--');
        hold on
    plot(x, polyval(fit_RF02, x), 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2, 'Linestyle', '--');
        hold on
    plot(x, polyval(fit_RF04, x), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2, 'Linestyle', '--');
        hold on
    plot(x, polyval(fit_RF08, x), 'Color', [0.3010 0.7450 0.9330], 'LineWidth', 2, 'Linestyle', '--');
        hold on
    plot(x, polyval(fit_all, x), "r-", 'LineWidth', 3);
    hold on
    scatter(lwcratio_RF01, vwindratio_RF01, 50, [0.9290 0.6940 0.1250], "o");
    hold on
    scatter(lwcratio_RF02, vwindratio_RF02, 50, [0.4940 0.1840 0.5560], "o");
    hold on
    scatter(lwcratio_RF04, vwindratio_RF04, 50, [0.4660 0.6740 0.1880], "o");
    hold on
    scatter(lwcratio_RF08, vwindratio_RF08, 50, [0.3010 0.7450 0.9330], "o");
    hold off
    
    ylabel('buoyancy');
    xlabel('dilution');
    ylim([-1 1.5])
    grid on
    legend({'RF01','RF02','RF04','RF08','Combined'}, 'location', 'best')
   

    %saveas(fig1, sprintf('%s/%s_WINDvD90.png', output_folder, region));
    
    fig2 = figure(2);

    scatter(Dratio_RF01, vwindratio_RF01, 50, "filled");
    hold on
    scatter(Dratio_RF02, vwindratio_RF02, 50, "filled");
    hold on
    scatter(Dratio_RF04, vwindratio_RF04, 50, "filled");
    hold on
    scatter(Dratio_RF08, vwindratio_RF08, 50, "filled");
    hold off
    
    ylabel('buoyancy');
    xlabel('D90 ratio');
    %ylim([0.6 1.4])
    grid on
    legend({'RF01','RF02','RF04','RF08'}, 'location', 'best')

    
%     fig2 = figure(2);
%     for R = 1:height(timestamps)
% %     wind_edge = cell2mat(vwind_edge_list(R));
% %     wind_core = cell2mat(vwind_core_list(R));
%     wind_edge = cell2mat(vwindratio_edge(R));
%     wind_core = cell2mat(vwindratio_core(R));
%     
%     Drat_edge = cell2mat(Dratio_edge(R));
%     Drat_core = cell2mat(Dratio_core(R));
%     
%      Drat_edge(Drat_edge>=1.2)=1.2;
%      Drat_edge(Drat_edge<0.8)=0.8;
%      
%      Drat_core(Drat_core>=1.2)=1.2;
%      Drat_core(Drat_core<0.8)=0.8;
% 
%     scatter(cell2mat(lwcratio_edge(R)), wind_edge, 50, Drat_edge, "o");
%     colormap(gca,"spring")
%     hold on
%     scatter(cell2mat(lwcratio_core(R)), wind_core, 50, Drat_core, "filled");
%     end
%     hold off
%     
%     ylabel('vertical wind velocity');
%     xlabel('dilution');
%     grid on
%     legend({'Edge','Core'}, 'location', 'best')
%     colorbar