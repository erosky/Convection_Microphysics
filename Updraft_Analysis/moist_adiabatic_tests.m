function out = moist_adiabatic_tests()

% For in-cloud passes that are warmer that -2C

% Test 1:
% find difference in saturation mixing ratio between each pair of cloud passes
% find difference in LWC between each pair of cloud passes, scaled by air density
% find change in LWC and saturation mixing ratio between each cloud pass
% and cloud base


    % For each region in list
    regions = ["RF02_Region01", "RF04_Region01", "RF04_Region02", "RF05_Region01", "RF08_Region02", "RF08_Region03", "RF08_Region04", "RF08_Region05", "RF10_Region01"];
    
    directory = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/';

    fig = figure(1);

    for r = 1 : length(regions)
        folder = fullfile(directory, regions(r), "/InCloud");
        cloudinfo = readtable(fullfile(folder, 'incloud_summary.csv'));

        temp = cloudinfo.AverageTemp;
        pres = cloudinfo.StaticPres_hPa;
        vap_pres = cloudinfo.SaturationPessure;
        sat_mr = cloudinfo.SaturationMixingRatio;
        lwc = cloudinfo.LWC_king;
        alt = cloudinfo.AverageAlt;

        dry_air_density = 100*(pres-vap_pres)./(287*(temp+273.15)); % kg/m3
        scaled_lwc = lwc./dry_air_density; %g/kg

        cold = [];

        % remove potentially frozen passes
        for t = 1 : length(temp)
            if temp(t) =< -10
                cold = [cold ; t];
            end
        end
        cold

        temp(cold) = []
        sat_mr(cold) = [];
        scaled_lwc(cold) = [];
        alt(cold) = [];
        
        sorted_data = cat(2, alt, sat_mr, scaled_lwc, temp);
        sorted_data = sortrows(sorted_data)

        % matrix comparing each pass to each other
        sorted_data(:,2)
        sorted_data(:,2).'
        d_mr = sorted_data(:,2) - sorted_data(:,2).'
        d_sc_lwc = sorted_data(:,3) - sorted_data(:,3).';
        % keep only upper triangle of the MxM matrix
        d_mr = triu(d_mr,1);
        d_sc_lwc = triu(d_sc_lwc,1);
        % change to 1d array
        d_mr = d_mr(:);
        d_sc_lwc = d_sc_lwc(:);
        %remove zeros
        d_mr = nonzeros(d_mr')
        d_sc_lwc = nonzeros(d_sc_lwc')


        scatter(d_mr, -d_sc_lwc,'DisplayName',regions(r));
        ylabel('change in LWC scaled by density of dry air (g/kg)');
        xlabel('change in saturation mixing ratio between two cloud passes (g/kg)');
        hold on
        grid on

    end
    plot(xlim,xlim,'-b', 'HandleVisibility','off')
    legend('Interpreter', 'none')
    hold off
    
    
end
