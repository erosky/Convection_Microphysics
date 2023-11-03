function [region, shadow_density, holo_brightness] = LWC_v_brightness()

water_density = 0.997E6 ; %g/m^3

% go through all core regions
% compare average shadow density in pass with average hologram brighness
% in pass
% find timestamps in .mat files and calculate average hologram brightness

Directory = "../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

brightnessfolder = dir(fullfile('../../Hologram_Brightness', '*.mat'));

output_folder = './';

% shadow_density = {};
% holo_brightness = {};
% LWC_difference = {};

for f = 1:length(Regions)
    
    shadow_density{f} = [];
    holo_brightness{f} = [];
    LWC_difference{f} = [];
    LWC_cdp{f} = [];
    LWC_holodec{f} = [];
    
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    brightness_data = load(fullfile(brightnessfolder(f).folder, brightnessfolder(f).name)).data;
    
    directory = fullfile('../../', Regions(f).name);
    
    cdp_folder = fullfile(directory, '/InCloud');    
    cdp_data = dir(fullfile(cdp_folder, 'cdp_*.nc'));

    
    time = brightness_data.imagetime; 
    time = datetime(time, 'convertfrom', 'datenum') - seconds(1.0); % 1 second offset to correct for holodec offset
    brightness = brightness_data.brightness;
    flightdate = brightness_data.flightdate;
    time_ref = split(flightdate, "/");

    holo_path = fullfile(directory,'/NCAR_reconstruction');
    holo_data = dir(fullfile(holo_path, '*_HOLODEC.nc'));
    holo_file = fullfile(holo_data.folder, holo_data.name);
    holotime = ncread(holo_file,'time');
    holo_region_LWC = ncread(holo_file,'lwc_round');
    holotime = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(holotime); 
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    %time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time);
    
    
    
    for p = 1 : size(cdp_data)
            
            core_cdpfile = fullfile(cdp_data(p).folder, cdp_data(p).name);
            N = ncread(core_cdpfile,'TotalConc');
            R = ncread(core_cdpfile,'MeanDiameter')/2;
            
            D_cdp = ncread(core_cdpfile, 'bins');
            cutoff = find(D_cdp >= 12, 1);
            D_cdp = D_cdp(cutoff:end)
   
            cdp_contours = transpose(ncread(core_cdpfile, 'PSD'));
            cdp_contours = cdp_contours(cutoff:end,:);
            cdp_conc = sum(cdp_contours); % droplets per m3
            cdp_LWC = [];
            size(cdp_contours,2)
            cdp_dropmass = [];
            for d = 1 : size(D_cdp)
                D_center = D_cdp(d)*10^-6; % meters
                D_volume = (1/6)*pi*(D_center)^3;  % cubic meters (volume of each water droplet)
                D_Mass = water_density*D_volume; % g
                cdp_dropmass = [cdp_dropmass; D_Mass];
            end
                       
            cdp_perLWC = cdp_contours.*cdp_dropmass; % mass per bin g/m3/um
            cdp_LWC = transpose(sum(cdp_perLWC)*10^6)  % g/cm3
            size(cdp_LWC)
            %cdp_LWC = ncread(core_cdpfile,'LWC');
            
            shadow = pi*N.*((R*10^(-4)).^2)*15;
            
    
             starttime = datetime(min(ncread(core_cdpfile,'time')), 'convertfrom', 'datenum');
             endtime = datetime(max(ncread(core_cdpfile,'time')), 'convertfrom', 'datenum');
             timeIndexes = (time <= endtime) & (time >= starttime);
             holoIndexes = (holotime <= endtime) & (holotime >= starttime);
             
             holo_LWC = holo_region_LWC(holoIndexes);
             size(holo_LWC)
             
              t = time(timeIndexes);
              b = brightness(timeIndexes);
              holo_t = holotime(holoIndexes);
              
              b_1Hz = [];
              for tm = 1:(length(holo_t))
                  if tm > length(holo_t)-1
                      b_indexes = (t >= holo_t(tm));
                  else  
                      b_indexes = (t < holo_t(tm+1)) & (t >= holo_t(tm));
                  end
                  b_1Hz = [b_1Hz; mean(b(b_indexes))];
              end
                    
              shadow_density{f} = [shadow_density{f}; shadow];
              holo_brightness{f} = [holo_brightness{f}; b_1Hz];
              LWC_difference{f} = [LWC_difference{f}; cdp_LWC-holo_LWC];
              LWC_cdp{f} = [LWC_cdp{f}; cdp_LWC];
              LWC_holodec{f} = [LWC_holodec{f}; holo_LWC];
             
    end        

end


datamarkers = ["hexagram", "v", "o", "square"];

    fig = figure(1);

    for R = 1:length(Regions)
%     scatter(cell2mat(shadow_density(R)), cell2mat(LWC_difference(R)), 50, "filled", "b");
%     hold on
    scatter(cell2mat(shadow_density(R)), cell2mat(LWC_cdp(R)), 55, "filled", "b");
    hold on
    scatter(cell2mat(shadow_density(R)), cell2mat(LWC_holodec(R)), 55, "filled","square", "r");
    hold on 
    end
    hold off
    
    ylabel('Liquid water content (g/cm^{3})', 'FontSize', 16);
    xlabel('Shadow density parameter', 'FontSize', 16);
    grid on
    %legend({'CDP-HOLODEC','CDP','HOLODEC'}, 'location', 'best')
    legend({'CDP','HOLODEC'}, 'location', 'best', 'FontSize', 16)

    fig2 = figure(2);
    
    for R = 1:length(Regions)
    scatter(cell2mat(holo_brightness(R)), cell2mat(LWC_difference(R)), 50, "filled", 'DisplayName', Regions(R).name);
    hold on
    end

    hold off
    ylabel('Difference between Hologram LWC and CDP LWC (CORRECTED FOR SIZE RANGE)');
    xlabel('Hologram brightness');
    grid on
    legend('Interpreter', 'none')
    
    
    fig3 = figure(3);
    
    for R = 1:length(Regions)
    scatter(cell2mat(holo_brightness(R)), (cell2mat(LWC_holodec(R))./cell2mat(LWC_cdp(R))), 50, "filled", 'DisplayName', Regions(R).name);
    hold on
    end

    hold off
    xlabel('Hologram Brightness');
    ylabel('Hologram LWC / CDP LWC (CORRECTED FOR SIZE RANGE)');
    grid on
    legend('Interpreter', 'none')
    
        
    fig4 = figure(4);
    
    for R = 1:length(Regions)
    scatter(cell2mat(shadow_density(R)), cell2mat(LWC_difference(R)), 50, "filled", 'DisplayName', Regions(R).name);
    hold on
    end

    hold off
    xlabel('Shadow density using CDP mean diameter');
    ylabel('Difference between Hologram LWC and CDP LWC (CORRECTED FOR SIZE RANGE)');
    grid on
    legend('Interpreter', 'none')
    
    
end
        