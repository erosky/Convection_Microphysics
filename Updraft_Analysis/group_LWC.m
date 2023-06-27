function out = group_LWC()

% For in-cloud passes that are warmer that -2C

% Test 2:
% plot moist static energy as a function of height above cloud


    % For each region in list
    regions = ["RF01_Region01", "RF02_Region01", "RF04_Region01", "RF04_Region02", "RF05_Region01", "RF08_Region02", "RF08_Region03", "RF08_Region04", "RF08_Region05"];
    
    directory = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/';
    
    output = 'lwc_grouping.txt'

    fig1 = figure(1);
   all_lwc = [];
   all_lwc_var = [];

    for r = 1 : length(regions)
       
        folder = fullfile(directory, regions(r), "/InCloud");
        passes = dir(fullfile(folder, 'thermodynamics_*.csv'));
        cloudinfo = readtable(fullfile(folder, 'incloud_summary.csv'));

        temp = cloudinfo.AverageTemp;
        height_abv_cb = cloudinfo.HeightAboveCB;
        lwc = cloudinfo.LWC_king
        eff_rad = cloudinfo.EffRad_cdp;
        mse = cloudinfo.MoistStaticEnergy;
        all_lwc = [all_lwc; lwc(:,:)]
       
        lwc_max = [];
        lwc_var = [];
        
        for p=1:length(passes)
            pass_data = readtable(fullfile(passes(p).folder, passes(p).name));
            lwc_series = pass_data.LWC_king;
            lwc_max = [lwc_max; max(lwc_series)];
            lwc_var = [lwc_var; std(lwc_series)];
            all_lwc_var = [all_lwc_var, std(lwc_series)];
        end
    end
        
        size(all_lwc)
        
        figure(1)
        scatter(all_lwc, all_lwc);
        errorbar(all_lwc, all_lwc, all_lwc_var, 'horizontal', 'LineStyle','none');
        ylabel('cloud pass LWC');
        xlabel('cloud pass LWC');
        grid on
        

    
    
end

