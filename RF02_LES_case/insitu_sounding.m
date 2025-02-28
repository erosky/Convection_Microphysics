function out = insitu_sounding(ncfile)
    
    temp = ncread(ncfile,'ATX'); % 'Ambient Temperature, Reference', in units of degrees Celsius
    alt = ncread(ncfile,'GGALT'); %'Reference GPS Altitude (MSL) (m)' 
    lat = ncread(ncfile,'LAT');
    lon = ncread(ncfile,'LON');
    dpt = ncread(ncfile,'DPXC'); % dewpoint temp
    psxc = ncread(ncfile,'PSXC'); % mixing ratio dependency (corrected static pressure)
    ewx = ncread(ncfile,'EWX'); % mixing ratio dependency (ambient water vapor pressure)
    abs_hum = ncread(ncfile,'RHODT'); %Absolute humidity g/m3
    lwc_king = ncread(ncfile,'PLWCC');
    time = ncread(ncfile,'Time');
    % vxl = ncread(ncfile,'VMR_VXL');
    % H2o_pic2 = ncread(ncfile,'H2O_WVISO2');

    latmin = 38.5521;
    latmax = 38.7756;
    lonmin = -102.0935;
    lonmax = -101.9074;


    flightnumber = upper(ncreadatt(ncfile, '/', 'FlightNumber'));
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/")
    time = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));

    timestart = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2}),18,15,00)
    timeend = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2}),19,40,00)
  
    timeIndexes = (time <= timeend) & (time >= timestart);
    sum(timeIndexes)

    locIndexes = timeIndexes & (lat <= latmax) & (lat >= latmin) & (lon <= lonmax) & (lon >= lonmin);
    sum(locIndexes)

    out_of_cloud = locIndexes & (lwc_king == 0.00);
    sum(out_of_cloud)

    in_cloud = locIndexes & (lwc_king > 0.1);

    % Plot
    % x - temperature
    % ylefft - hPa

    height = alt(out_of_cloud);
    t_sounding = temp(out_of_cloud);
    height_cloud = alt(in_cloud);
    t_cloud = temp(in_cloud);

    dpt_sounding = dpt(out_of_cloud);

   figure(1);
   hold off;
   scatter(t_sounding, height, 'DisplayName', 'Temperature out of cloud');
   hold on;
   scatter(t_cloud, height_cloud,  'DisplayName', 'Temperature in cloud');
   hold on;
   scatter(dpt_sounding, height,  'DisplayName', 'Dewpoint temperature out of cloud');
   hold on;
   yline(1900, 'DisplayName', 'Cloud boundary'); hold on;
   yline(4700, 'DisplayName', 'Cloud boundary');
   legend()
   xlabel('Temperature (C)');
   ylabel('Altitude (m)');
