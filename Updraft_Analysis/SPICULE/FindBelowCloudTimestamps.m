function out = FindBelowCloudTimestamps()
% Find within 500 m below cloud base within the region and timestamps and
% flying flat

regions = ["RF02_Region01", "RF04_Region01", "RF04_Region02", "RF08_Region03"];
directory = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/';


for r = 1 : length(regions)
    region = regions(r);
    flightnum = split(region, "_");
    flightnum = flightnum{1};
    
    folder = fullfile(directory, regions(r));
    region_data = readtable(fullfile(folder, 'region_properties.csv'));
    timestamps = readtable(fullfile(folder, 'InCloud/timestamps.csv'));
    mintime = timestamps{1,1} - minutes(30);
    maxtime = timestamps{end,end} + minutes(30);

    nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
    flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnum)));
    ncfile = fullfile(nc_path, flight_nc.name);
    flightdate = ncreadatt(ncfile, '/', 'FlightDate');
    time_ref = split(flightdate, "/");
    
    time = ncread(ncfile,'Time');
    time = datetime(str2double(time_ref{3}),str2double(time_ref{1}),str2double(time_ref{2})) + seconds(time(:,1));
    alt = ncread(ncfile,'GGALT'); %'Reference GPS Altitude (MSL) (m)' 
    lat = ncread(ncfile,'LAT');
    lon = ncread(ncfile,'LON');
    
    % impose time limit
    timeIndexes = (time <= maxtime) & (time >= mintime);
    times = time(timeIndexes);
    alts = alt(timeIndexes);
    lats = lat(timeIndexes);
    lons = lon(timeIndexes);
    
    % impose altitude, lat, lon limits
    latmin = region_data.LatMin - 0.2;
    latmax = region_data.LatMax + 0.2;
    lonmin = region_data.LonMin - 0.2;
    lonmax = region_data.LonMax + 0.2;
    altmin = region_data.CloudBase_m - 250;
    altmax = region_data.CloudBase_m;
    
    posIndexes = (lats >= latmin) & (lats <=latmax) & (lons <= lonmax) & (lons >=lonmin) & (alts<=altmax) & (alts>=altmin);
%     times = times(posIndexes);
%     alts = alts(posIndexes);
%     size(alts);
    
    % Label each region with a label - an "ID" number.
    [labeledVector, numRegions] = bwlabel(posIndexes);
    % Measure lengths of each region and the indexes
    measurements = regionprops(labeledVector, lats, 'Area', 'PixelValues', 'PixelIdxList');
    % Find regions where the area (length) are 3 or greater and
    % put the values into a cell of a cell array
    indices=[];
    n=1;
    for k = 1 : numRegions
      if measurements(k).Area >= 5;
        % Area (length) is duration_threshold or greater, so store the values.
        out{n} = measurements(k).PixelValues;
        indices{n} = measurements(k).PixelIdxList;
        n=n+1;
      end
    end
    % Display the regions that meet the criteria:
    
    
    
    datafile = fullfile(folder, sprintf('%s_belowcloud.csv', region));
    output_data = table('Size',[0 5],...
                        'VariableTypes',{'datetime','datetime','duration','double', 'double'},...
                        'VariableNames', ["start", "end", "duration", "min_altitude", "max_altitude"]);
    for p = 1 : length(indices)
        i_start = indices{p}(1);
        i_end = indices{p}(end);
        start_time = times(i_start);
        end_time = times(i_end);
        duration = end_time - start_time
        max_alt = max(alts(i_start:i_end))
        min_alt = min(alts(i_start:i_end))
        data = {start_time, end_time, duration, min_alt, max_alt};
        output_data = [output_data; data];       
    end
    
    writetable(output_data, datafile, 'WriteMode','overwrite');

    

    


end
    
% % Find logical vector where lwc > threshold
%     binaryVector = (vwind > wind_threshold) & (~isinf(LWC));
% 
%     % Label each region with a label - an "ID" number.
%     [labeledVector, numRegions] = bwlabel(binaryVector);
%     % Measure lengths of each region and the indexes
%     measurements = regionprops(labeledVector, vwind, 'Area', 'PixelValues', 'PixelIdxList');
%     % Find regions where the area (length) are 3 or greater and
%     % put the values into a cell of a cell array
%     indices=[];
%     n=1;
%     for k = 1 : numRegions
%       if measurements(k).Area >= duration_threshold;
%         % Area (length) is duration_threshold or greater, so store the values.
%         out{n} = measurements(k).PixelValues;
%         indices{n} = measurements(k).PixelIdxList;
%         n=n+1;
%       end
%     end
%     % Display the regions that meet the criteria:
%     celldisp(out);
%     
%     for p = 1 : length(indices)
%         i_start = indices{p}(1);
%         i_end = indices{p}(end);
%         start_time = time2(i_start);
%         end_time = time2(i_end);
%         timestamps_UTC{p} = [start_time, end_time];
%         timestamps_datenum{p} = [datenum(time2(i_start)), datenum(time2(i_end))];
%     end

