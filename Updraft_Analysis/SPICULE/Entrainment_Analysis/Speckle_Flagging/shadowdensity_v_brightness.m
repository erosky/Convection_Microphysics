function [region, shadow_density, holo_brightness] = shadowdensity_v_brightness()


% go through all core regions
% compare average shadow density in pass with average hologram brighness
% in pass
% find timestamps in .mat files and calculate average hologram brightness

Directory = "../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

brightnessfolder = dir(fullfile('../../Hologram_Brightness', '*.mat'));

output_folder = './';

full_data = [];
region = [];
shadow_density = [];
holo_brightness = [];

for f = 1:length(Regions)
    % Open up the cloudpass file
    region_folder = fullfile(Regions(f).folder, Regions(f).name);
    brightness_data = load(fullfile(brightnessfolder(f).folder, brightnessfolder(f).name)).data;
    
    directory = fullfile('../../', Regions(f).name);
    folder = fullfile(directory, '/InCloud');
    
    cdp_data = dir(fullfile(folder, 'cdp_*.nc'));
    
    
    time = brightness_data.imagetime;
    brightness = brightness_data.brightness;
    flightdate = brightness_data.flightdate;
    time_ref = split(flightdate, "/");

    
    % Reformat time to human readable format
    % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
    %time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time);
    time2 = datetime(time, 'convertfrom', 'datenum');
    
    
    for p = 1 : size(cdp_data)
            
            region = [region; Regions(f).name];
            
            core_cdpfile = fullfile(cdp_data(p).folder, cdp_data(p).name);
            N = mean(ncread(core_cdpfile,'TotalConc'),"omitnan");
            R = mean(ncread(core_cdpfile,'MeanDiameter'),"omitnan")/2;

            shadow = N*pi*((R*10^(-4))^2)*15;
            shadow_density = [shadow_density; shadow];
    
             starttime = min(ncread(core_cdpfile,'time'));
             endtime = max(ncread(core_cdpfile,'time'));
             timeIndexes = (time <= endtime) & (time >= starttime);
%             
             core_brightness = mean(brightness(timeIndexes),"omitnan")
             holo_brightness = [holo_brightness; core_brightness];
             
    end        

end

    fig = figure(1);
    scatter(shadow_density, holo_brightness, 50, 'filled');
    hold on
    xlabel('Shadow desnity using CDP mean diameter');
    ylabel('Hologram brightness');
    grid on

end
        