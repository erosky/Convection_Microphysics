function out = create_region_timeseries_csv(region, flightnumber)

% go through all edge and cloud pass holoquicklooks
% calculate LWC in each timestep
% use holoquicklooks to set time range
% plot the cdp, king, holo LWC across entire time range
% plot vertical wind speed as well

nc_path = '../../../../../SPICULE/Data/LRT_Aircraft_2.1';
flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnumber)));
ncfile = fullfile(nc_path, flight_nc.name);

outputdir = fullfile('../../',region);


% timeframes of the region
region_times = load('RF_timeframes.mat');
starttime = region_times.(flightnumber)(1);
endtime = region_times.(flightnumber)(2);


%Get data from the netCDF file
time = ncread(ncfile,'Time');
flightdate = ncreadatt(ncfile, '/', 'FlightDate');
time_ref = split(flightdate, "/");

% variables
%lwc_king = ncread(ncfile,'PLWCC');
lwc = ncread(ncfile,'PLWCD_LWOO');
temp = ncread(ncfile,'ATX'); % 'Ambient Temperature, Reference', in units of degrees Celsius
vwind = ncread(ncfile,'WIC'); %Vertical windspeed derived from Rosemount 858 airdata probe located on the starboard pylon, in units of metres per second
alt = ncread(ncfile,'GGALT'); %'Reference GPS Altitude (MSL) (m)' 
lat = ncread(ncfile,'LAT');
lon = ncread(ncfile,'LON');

% Reformat time to human readable format
% Given in netcdf file as seconds since 00:00:00 +0000 of flight date
time2 = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
timeIndexes = (time2 <= endtime) & (time2 >= starttime);

         output_data = table('Size', [length(time2(timeIndexes)) 0]);
         output_data.Time = time2(timeIndexes);
         output_data.Altitude = alt(timeIndexes);
         output_data.Latitude = lat(timeIndexes);
         output_data.Longitude = lon(timeIndexes);
         output_data.VerticalWind = vwind(timeIndexes);
         output_data.Temperature = temp(timeIndexes); 
         output_data.LWC = lwc(timeIndexes);
        
         
 output_filename = fullfile(outputdir, 'region_timeseries.csv');
 writetable(output_data, output_filename, 'WriteMode','overwrite');






