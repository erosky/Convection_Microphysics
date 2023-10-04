function out = spicule_hologram_timeseries(region, flightnumber)

% timeframes of the region
region_times = load('RF_timeframes.mat');
starttime = region_times.(flightnumber)(1);
endtime = region_times.(flightnumber)(2);


% timeseries of CDP LWC
nc_path = '../../../../SPICULE/Data/LRT_Aircraft_2.1';
flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnumber)));
ncfile = fullfile(nc_path, flight_nc.name);
cdptime = ncread(ncfile,'Time');
flightdate = ncreadatt(ncfile, '/', 'FlightDate');
time_ref = split(flightdate, "/");


% high resoltion time series of holodec
holo_path = sprintf('../%s/NCAR_reconstruction', region);
holofile = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_nc = fullfile(holo_path, holofile.name);

test = holoNC_to_LWC(holo_nc, starttime, endtime, time_ref, 12.0);


% 1 Hz resolution time series of holodec
holotime = ncread(holo_nc,'time');
holo_LWC = ncread(holo_nc,'lwc_round');




% high resolution time series of hologram brightness
% (high resolution?) time series of CDP-HOLO LWC