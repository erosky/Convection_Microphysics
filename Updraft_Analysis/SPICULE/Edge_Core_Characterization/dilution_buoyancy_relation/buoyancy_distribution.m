
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

smallest_bin = [0.8, 0.9];
smaller_bin = [0.9, 0.95];
small_bin = [0.95, 1.0];
big_bin = [1.0, 1.05];
bigger_bin = [1.05, 1.1];
biggest_bin = [1.1, 1.2];

smallest_buoyancy = vwindratio_all(Dratio_all > smallest_bin(1) & Dratio_all <= smallest_bin(2));
smaller_buoyancy = vwindratio_all(Dratio_all > smaller_bin(1) & Dratio_all <= smaller_bin(2));
small_buoyancy = vwindratio_all(Dratio_all > small_bin(1) & Dratio_all <= small_bin(2));
big_buoyancy = vwindratio_all(Dratio_all > big_bin(1) & Dratio_all <= big_bin(2));
bigger_buoyancy = vwindratio_all(Dratio_all > bigger_bin(1) & Dratio_all <= bigger_bin(2));
biggest_buoyancy = vwindratio_all(Dratio_all > biggest_bin(1) & Dratio_all <= biggest_bin(2));
    
fig1 = figure(1);

    histogram(smallest_buoyancy, 'BinWidth', 0.2, 'Normalization', 'pdf', 'FaceColor', [0.3010 0.7450 0.9330]);
    hold on;
    histogram(smaller_buoyancy,'BinWidth', 0.2, 'Normalization', 'pdf','FaceColor', [0 0.4470 0.7410]);
    hold on;
    histogram(small_buoyancy,'BinWidth', 0.2, 'Normalization', 'pdf','FaceColor', [0.4940 0.1840 0.5560]);
    hold on;
    histogram(big_buoyancy,'BinWidth', 0.2, 'Normalization', 'pdf','FaceColor', [0.9290 0.6940 0.1250]);
    hold on;
    histogram(bigger_buoyancy,'BinWidth', 0.2, 'Normalization', 'pdf','FaceColor', [0.8500 0.3250 0.0980]);
    hold on;
    histogram(biggest_buoyancy,'BinWidth', 0.25,'Normalization', 'pdf', 'FaceColor', "red");
    hold off
    
    
    xlabel('buoyancy');
    grid on
    legend({'Smallest', 'Smaller', 'Small','Big', 'Bigger', 'Biggest'}, 'location', 'best')
   

    %saveas(fig1, sprintf('%s/%s_WINDvD90.png', output_folder, region));
    
