function [region, shadow_density, holo_brightness] = LWC_v_brightness()


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
    holotime = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(holotime) - seconds(1.0); 
    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    %time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time);
    
    
    
    for p = 1 : size(cdp_data)
            
            
            core_cdpfile = fullfile(cdp_data(p).folder, cdp_data(p).name);
            N = ncread(core_cdpfile,'TotalConc');
            R = ncread(core_cdpfile,'MeanDiameter')/2;
            cdp_LWC = ncread(core_cdpfile,'LWC');
            
            shadow = pi*N.*((R*10^(-4)).^2)*15;
            
    
             starttime = datetime(min(ncread(core_cdpfile,'time')), 'convertfrom', 'datenum');
             endtime = datetime(max(ncread(core_cdpfile,'time')), 'convertfrom', 'datenum');
             timeIndexes = (time <= endtime) & (time >= starttime);
             holoIndexes = (holotime <= endtime) & (holotime >= starttime);
             
             holo_LWC = holo_region_LWC(holoIndexes);
             
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
              LWC_difference{f} = [LWC_difference{f}; cdp_LWC - holo_LWC];
             
    end        

end


datamarkers = ["hexagram", "v", "o", "square"];

    fig = figure(1);

    for R = 1:length(Regions)
    scatter(cell2mat(holo_brightness(R)), cell2mat(LWC_difference(R)), 50, "filled", 'DisplayName', Regions(R).name);
    hold on
    end

    
    hold off
    ylabel('Difference between Hologram LWC and CDP LWC (NOT CORRECTED FOR SIZE RANGE)');
    xlabel('Hologram brightness');
    grid on
    legend()

    fig2 = figure(2);
    
    for R = 1:length(Regions)
    scatter(cell2mat(holo_brightness(R)), cell2mat(shadow_density(R)), 50, "filled", 'DisplayName', Regions(R).name);
    hold on
    end

    hold off
    ylabel('Shadow density using CDP mean diameter');
    xlabel('Hologram brightness');
    grid on
    legend('Interpreter', 'none')
    
    
end
        