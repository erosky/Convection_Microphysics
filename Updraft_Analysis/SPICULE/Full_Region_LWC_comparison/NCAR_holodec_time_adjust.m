function [starttime, endtime] = NCAR_holodec_time_adjust(region, flightnumber, OFFSET)

% go through all edge and cloud pass holoquicklooks
% calculate LWC in each timestep
% use holoquicklooks to set time range
% plot the cdp, king, holo LWC across entire time range
% plot vertical wind speed as well

OFFSET = seconds(OFFSET)

nc_path = '../../../../SPICULE/Data/LRT_Aircraft_2.1';
flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnumber)));
ncfile = fullfile(nc_path, flight_nc.name);


holo_path = sprintf('../%s/NCAR_reconstruction', region);
holofile = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_nc = fullfile(holo_path, holofile.name);

holotime = ncread(holo_nc,'time');
holo_LWC = ncread(holo_nc,'lwc_round');

region_times = load('RF_timeframes.mat');

starttime = region_times.(flightnumber)(1);
endtime = region_times.(flightnumber)(2);


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
holotime2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(holotime(:,1)) + OFFSET;
time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
timeIndexes = (time2 <= endtime) & (time2 >= starttime);
holoIndexes = (holotime2 <= endtime) & (holotime2 >= starttime);


    %Make figure
    figure(1);
%     tiledlayout(2,1);
%     ax1 = nexttile;
    
    plot(datenum(holotime2(holoIndexes)), holo_LWC(holoIndexes), 'DisplayName', 'Holodec');
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
    grid on
       
% %     %Wind
%     ax2 = nexttile;
%     plot(datenum(time2(timeIndexes)), lwc_king(timeIndexes));
%     datetick('x')
%     xlabel('Time (s)')
%     ylabel('vwind (m/s)')
%     grid on
    
%     %Link axes for panning and zooming
%     linkaxes([ax1, ax2],'x');
     zoom xon;  %Zoom x-axis only
     pan;  %Toggling pan twice seems to trigger desired behavior, not sure why
     pan;


end