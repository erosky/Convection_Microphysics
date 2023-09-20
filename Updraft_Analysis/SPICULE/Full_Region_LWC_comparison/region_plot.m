function out = region_plot(region, flightnumber)

% go through all edge and cloud pass holoquicklooks
% calculate LWC in each timestep
% use holoquicklooks to set time range
% plot the cdp, king, holo LWC across entire time range
% plot vertical wind speed as well

nc_path = '../../../../SPICULE/Data/LRT_Aircraft_2.1';
flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnumber)));
ncfile = fullfile(nc_path, flight_nc.name);

quicklook_path = '../';
quicklooklist = [dir(fullfile(quicklook_path, region, 'holoquicklook_*.mat')); dir(fullfile(quicklook_path, region, 'EdgeCloud', 'holoquicklook_*.mat'))];

holotimes = [];
holo_LWC = [];

for q=1 : length(quicklooklist)
    quicklookfile = fullfile(quicklooklist(q).folder, quicklooklist(q).name);
    [times, LWC] = holoquicklook_to_LWC(quicklookfile);
    holotimes = [holotimes; times];
    holo_LWC = [holo_LWC; LWC];
end



holo_array = [holotimes, holo_LWC];
holo_sorted = sortrows(holo_array);

holotimes = datetime(holo_sorted(:,1),'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')
holo_LWC = holo_sorted(:,2)

starttime = min(holotimes)-seconds(8)
endtime = max(holotimes)+seconds(8)


%Get data from the netCDF file
time = ncread(ncfile,'Time');
flightdate = ncreadatt(ncfile, '/', 'FlightDate');
time_ref = split(flightdate, "/");

% variables
lwc_king = ncread(ncfile,'PLWCC');
lwc_cdp = ncread(ncfile,'PLWCD_LWOO');
vwind = ncread(ncfile,'WIC');

% Reformat time to human readable format
% Given in netcdf file as seconds since 00:00:00 +0000 of flight date
time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
timeIndexes = (time2 <= endtime) & (time2 >= starttime);


    %Make figure
    figure(1);
    tiledlayout(2,1);
    ax1 = nexttile;
    
    %Concentration contour
    plot(datenum(holotimes), holo_LWC, 'DisplayName', 'Holodec');
    hold on
    plot(datenum(time2(timeIndexes)), lwc_cdp(timeIndexes), 'DisplayName', 'CDP');
    hold on
    plot(datenum(time2(timeIndexes)), lwc_king(timeIndexes), 'DisplayName', 'King');
    legend
    datetick('x');
    grid on

    xlabel('Time (s)')
    ylabel('LWC (g/m^3)');
    title([flightnumber ' ' date]);
       
%     %Wind
    ax2 = nexttile;
    plot(datenum(time2(timeIndexes)), lwc_king(timeIndexes));
    datetick('x')
    xlabel('Time (s)')
    ylabel('vwind (m/s)')
    grid on
    
    %Link axes for panning and zooming
    linkaxes([ax1, ax2],'x');
    zoom xon;  %Zoom x-axis only
    pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
    pan;






