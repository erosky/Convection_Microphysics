function out = moist_adiabatic_tests_MSE()

% For in-cloud passes that are warmer that -2C

% Test 2:
% plot moist static energy as a function of height above cloud


    % For each region in list
    %regions = ["RF01_Region01", "RF02_Region01", "RF04_Region02", "RF05_Region01", "RF08_Region02", "RF08_Region03", "RF08_Region04", "RF08_Region05", "RF10_Region01"];
    regions = ["RF01_Region01", "RF02_Region01", "RF04_Region01", "RF08_Region02"];
    labels = ["RF01 cloud", "RF02 cloud", "RF04 cloud", "RF08 cloud"];
    
    directory = './SPICULE/';

    fig1 = figure(1);
    %fig2 = figure(2);

    for r = 1 : length(regions)
       
        folder = fullfile(directory, regions(r), "/InCloud");
        belowfolder =  fullfile(directory, regions(r), "/BelowCloud");
        cloudinfo = readtable(fullfile(folder, 'incloud_summary.csv'));
        belowinfo = readtable(fullfile(belowfolder, 'belowcloud_summary.csv'));

        temp = [cloudinfo.AverageTemp; belowinfo.AverageTemp];
        height_abv_cb = [cloudinfo.HeightAboveCB; zeros(size(belowinfo.MoistStaticEnergy))];
        lwc = cloudinfo.LWC_king;
        %eff_rad = [cloudinfo.EffRad_cdp; belowinfo.EffRad_cdp];
        mse = [cloudinfo.MoistStaticEnergy; belowinfo.MoistStaticEnergy];


        cold = [];

        for t = 1 : length(temp)
            if temp(t) < -10
                cold = [cold ; t];
            end
        end

        height_abv_cb(cold) = [];
        lwc(cold) = [];
        %eff_rad(cold) = [];
        mse(cold) = [];
        
        sorted_data = cat(2, height_abv_cb, mse);
        sorted_data = sortrows(sorted_data);
        
        err = 1000*ones(size(sorted_data(:,2)));
        
        
       
        figure(1)
        e = errorbar(sorted_data(:,1), sorted_data(:,2), err, 'DisplayName',labels(r), 'CapSize',0, 'LineWidth',2.0);
        e.Marker = '*';
        e.MarkerSize = 10;
        e.CapSize = 0;
        ylabel('Moist Static Energy (J/kg)');
        xlabel('Height above cloud base (m)');
        set(gca,'fontsize',25)
        view([90 -90])
        hold on
        grid on
        
%         figure(2)
%         plot(sorted_data(:,1), sorted_data(:,3),'DisplayName',regions(r));
%         ylabel('Effective Radius CDP (um)');
%         xlabel('Height above cloud base (m)');
%         hold on
%         grid on

    end
    figure(1)
    legend('Interpreter', 'none', 'fontsize',25)
    hold off
    
    saveas(fig1, 'MSE_conserved_entrainment-set.png')
    
%     figure(2)
%     legend('Interpreter', 'none')
%     hold off
    
    
end
