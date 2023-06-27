function out = compare_belowcloud()
% compare below cloud in updraft and out of updraft
% plot average and standard deviation out of updraft alongside in-updraft
% data points

% For each region in list
    regions = ["RF01_Region01", "RF08_Region02", "RF08_Region05"];
    
    directory_updraft = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/';
    directory_belowcloud = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/BelowCloudTest';

    for r = 1 : length(regions)
        folder_updraft = fullfile(directory_updraft, regions(r), "/BelowCloud");
        folder_belowcloud = fullfile(directory_belowcloud, regions(r), "/BelowCloud");
        cloudinfo_updraft = readtable(fullfile(folder_updraft, 'belowcloud_summary.csv'));
        cloudinfo_belowcloud = readtable(fullfile(folder_belowcloud, 'belowcloud_summary.csv'));

        alt_updraft = cloudinfo_updraft.AverageAlt;
        temp_updraft = cloudinfo_updraft.AverageTemp;
        cn_updraft = cloudinfo_updraft.Average_CN;
        humidity_updraft = cloudinfo_updraft.AbsoluteHumidity;
        mse_updraft = cloudinfo_updraft.MoistStaticEnergy;
        
        alt_belowcloud = cloudinfo_belowcloud.AverageAlt;
        temp_belowcloud = cloudinfo_belowcloud.AverageTemp;
        cn_belowcloud = cloudinfo_belowcloud.Average_CN;
        humidity_belowcloud = cloudinfo_belowcloud.AbsoluteHumidity;
        mse_belowcloud = cloudinfo_belowcloud.MoistStaticEnergy;
        
        % average and standard deviation below cloud
        alt_avg = mean(alt_belowcloud)
        alt_dev = std(alt_belowcloud)
        temp_avg =mean(temp_belowcloud);
        temp_dev = std(temp_belowcloud);
        cn_avg = mean(cn_belowcloud);
        cn_dev = std(cn_belowcloud);
        humidity_avg = mean(humidity_belowcloud);
        humidity_dev = std(humidity_belowcloud);
        mse_avg = mean(mse_belowcloud);
        mse_dev = std(mse_belowcloud);
        
        %%%% plot humidity comparison
        figure(1)
        ey = errorbar(alt_avg, humidity_avg, humidity_dev, 'o', "MarkerSize",10,"MarkerEdgeColor","blue", 'DisplayName', 'Not updrafts')
        ey.Color = 'blue';
        hold on
        ex = errorbar(alt_avg, humidity_avg, alt_dev,'horizontal', "LineStyle","none", 'HandleVisibility','off')
        ex.Color = 'blue';
        
        % In updraft data points
        scatter(alt_belowcloud, humidity_belowcloud, 'o', "MarkerEdgeColor","blue", "MarkerFaceColor", "blue", 'DisplayName', 'Not updrafts');
        hold on
        scatter(alt_updraft, humidity_updraft, 'o', "MarkerEdgeColor","red", "MarkerFaceColor", "red", 'DisplayName', 'Updrafts');
        
        hold off
        grid on
        ylabel('Absolute Humidity (g/kg)');
        xlabel('Altitude (m)');
        title(regions(r), 'Interpreter', 'none');
        legend();
        
        figname = regions(r) + "_humidity.png";
        saveas(gcf,fullfile(directory_belowcloud, figname));
        
        
        %%%% plot temperature comparison
        figure(1)
        ey = errorbar(alt_avg, temp_avg, temp_dev, 'o', "MarkerSize",10,"MarkerEdgeColor","blue", 'DisplayName', 'Not updrafts')
        ey.Color = 'blue';
        hold on
        ex = errorbar(alt_avg, temp_avg, alt_dev,'horizontal', "LineStyle","none", 'HandleVisibility','off')
        ex.Color = 'blue';
        
        % In updraft data points
        scatter(alt_belowcloud, temp_belowcloud, 'o', "MarkerEdgeColor","blue", "MarkerFaceColor", "blue", 'DisplayName', 'Not updrafts');
        hold on
        scatter(alt_updraft, temp_updraft, 'o', "MarkerEdgeColor","red", "MarkerFaceColor", "red", 'DisplayName', 'Updrafts');
        
        hold off
        grid on
        ylabel('Temperature (C)');
        xlabel('Altitude (m)');
        title(regions(r), 'Interpreter', 'none');
        legend();
        
        figname = regions(r) + "_temperature.png";
        saveas(gcf,fullfile(directory_belowcloud, figname));
        
        
        %%%% plot CN comparison
        figure(1)
        ey = errorbar(alt_avg, cn_avg, cn_dev, 'o', "MarkerSize",10,"MarkerEdgeColor","blue", 'DisplayName', 'Not updrafts')
        ey.Color = 'blue';
        hold on
        ex = errorbar(alt_avg, cn_avg, alt_dev,'horizontal', "LineStyle","none", 'HandleVisibility','off')
        ex.Color = 'blue';
        
        % In updraft data points
        scatter(alt_belowcloud, cn_belowcloud, 'o', "MarkerEdgeColor","blue", "MarkerFaceColor", "blue", 'DisplayName', 'Not updrafts');
        hold on
        scatter(alt_updraft, cn_updraft, 'o', "MarkerEdgeColor","red", "MarkerFaceColor", "red", 'DisplayName', 'Updrafts');
        
        hold off
        grid on
        ylabel('CN concentration (#/cm3)');
        xlabel('Altitude (m)');
        title(regions(r), 'Interpreter', 'none');
        legend();
        
        figname = regions(r) + "_cn.png";
        saveas(gcf,fullfile(directory_belowcloud, figname));
        
        
        
        %%%% plot MSE comparison
        figure(1)
        ey = errorbar(alt_avg, mse_avg, mse_dev, 'o', "MarkerSize",10,"MarkerEdgeColor","blue", 'DisplayName', 'Not updrafts')
        ey.Color = 'blue';
        hold on
        ex = errorbar(alt_avg, mse_avg, alt_dev,'horizontal', "LineStyle","none", 'HandleVisibility','off')
        ex.Color = 'blue';
        
        % In updraft data points
        scatter(alt_belowcloud, mse_belowcloud, 'o', "MarkerEdgeColor","blue", "MarkerFaceColor", "blue", 'DisplayName', 'Not updrafts');
        hold on
        scatter(alt_updraft, mse_updraft, 'o', "MarkerEdgeColor","red", "MarkerFaceColor", "red", 'DisplayName', 'Updrafts');
        
        hold off
        grid on
        ylabel('Moist Static Energy (J/kg)');
        xlabel('Altitude (m)');
        title(regions(r), 'Interpreter', 'none');
        legend();
        
        figname = regions(r) + "_mse.png";
        saveas(gcf,fullfile(directory_belowcloud, figname));
end