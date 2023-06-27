function out = Correlation_analysis()
% Create the following table
% avg LWC, max lwc, holodec 90% size, cdp 90% size, max updraft, avg updraft, cloud base temp, ccn conc, pcasp 90% size, gni largest size, moist static energy, height above CB,


datafile = fullfile('/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/Microphysics_Analysis', 'correlation_table.csv');
output_data = table('Size',[0 14],...
                    'VariableTypes',{'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'},...
                    'VariableNames', ["meanLWC", "holoSize", "maxUpdraft", "meanUpdraft", "CloudBaseTemp", "CloudBaseMSE", 'concCN', 'gniConc', 'gniSize', 'gniMass', 'gniRadius', 'MSE', 'HeightAbvCB', 'TempAbvCB']);


% For each region in list
regions = ["RF01_Region01", "RF02_Region01", "RF04_Region02", "RF05_Region01", "RF08_Region02", "RF08_Region03", "RF08_Region04", "RF08_Region05"];
directory = '/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/';

gni_dir = '/home/simulations/Field_Projects/SPICULE/Data/GNI';
gni = readtable(fullfile(gni_dir, 'metadata_mass.csv'));
gni_flight = convertCharsToStrings(gni.FlightNumber);
gni_lat = gni.SlideExposureAverageLatitude_deg_decimal_;
gni_lon = gni.SlideExposureAverageLongitude_deg_decimal_;
gni_alt = gni.SlideExposureAverageGPSAltitude_m_;
gni_slides = convertCharsToStrings(gni.slideLabel);
gni_mass = gni.NaClEquivalentMassLoading_microg_m__3_;
gni_radius = gni.Ranz_Vong50_Coll_effRadius_m_;
gni_bins = table2array(readtable(fullfile(gni_dir, 'bincenters.csv')))

for r = 1 : length(regions)
    region = regions(r);
    flightnum = split(region, "_");
    flightnum = flightnum{1};
    folder = fullfile(directory, regions(r));
    
    % cloud base temp, lat lon range for gni
    region_data = readtable(fullfile(folder, 'region_properties.csv'));
    CB_TEMP = region_data.CloudBaseTemp;
    cb_height = region_data.CloudBase_m;
    
    % ccn conc, 
    belowcloud_data = readtable(fullfile(folder, 'BelowCloud/belowcloud_summary.csv'));
    CONC_CN = mean(belowcloud_data.Average_CN);
    CB_MSE = mean(belowcloud_data.MoistStaticEnergy);
    
    % GNI data
    % impose altitude, lat, lon limits
    latmin = region_data.LatMin - 0.7;
    latmax = region_data.LatMax + 0.7;
    lonmin = region_data.LonMin - 0.7;
    lonmax = region_data.LonMax + 0.7;
    
    posIndexes = (gni_alt <= cb_height) & (gni_lat >= latmin) & (gni_lat <=latmax) & (gni_lon <= lonmax) & (gni_lon >=lonmin) & (gni_flight == flightnum);
    gni_labels = gni_slides(posIndexes);
    GNI_RADIUS = mean(gni_radius(posIndexes));
    GNI_MASS = mean(gni_mass(posIndexes));
    
    % Find 90th percentile size
    gni_conc = zeros(size(gni_bins));
    for g=1:length(gni_labels)
        hist = readtable(fullfile(gni_dir, sprintf('spicule_csv/%s.csv', gni_labels(g))));
        gni_conc = gni_conc + hist.Concentration___m__3_;
    end   
    total_conc = sum(gni_conc);
    conc_ind = (gni_conc > 0)
    largest_gni_bin = max(gni_bins(conc_ind))
    
    gni_CDF = [];
    for b = 1:size(gni_bins)
        c = nansum(gni_conc(1:b));
        gni_CDF = [gni_CDF; c]; 
    end
    gni_P = find( gni_CDF./total_conc > 0.90, 1 );
    %GNI_SIZE = gni_bins{gni_P,1};
    GNI_SIZE = largest_gni_bin;
    if isempty(largest_gni_bin)
        GNI_SIZE = -5;
    end
    
    % holo and cdp 90th percentiles
    holo_data = readtable(fullfile(folder, 'droplets_90percentile.csv'));
    holo_size = holo_data.HoloSize;
    
    % lwc mean, updraft, moist static energy, height above cloudbase
    incloud_data = readtable(fullfile(folder, 'InCloud/incloud_summary.csv'));
    lwc = incloud_data.LWC_king;
    mse = incloud_data.MoistStaticEnergy;
    height_abv_CB = incloud_data.HeightAboveCB;
    max_updraft = incloud_data.MaxUpdraft;
    mean_updraft = incloud_data.MeanUpdraft;
    temps = incloud_data.AverageTemp;
    
    % ["meanLWC", "holoSize", "maxUpdraft", "meanUpdraft", "CloudBaseTemp", "CloudBaseMSE", 'concCN', 'gniSize', 'gniMass', 'gniRadius', 'MSE', 'HeightAbvCB'])
    for p=1:height(incloud_data)
        data = {lwc(p), holo_size(p), max_updraft(p), mean_updraft(p), CB_TEMP, CB_MSE, CONC_CN, total_conc, GNI_SIZE, GNI_MASS, GNI_RADIUS, mse(p), height_abv_CB(p), temps(p)-CB_TEMP};
        output_data = [output_data; data];
    end

end

writetable(output_data, datafile, 'WriteMode','overwrite');

% % cloud base temp, lat lon range for gni
% region_data
% 
% % ccn conc, 
% belowcloud_data
% 
% % lwc mean, updraft, moist static energy, height above cloudbase
% incloud_data
% 
% % holodec 90% size
% holo_size_data
% 
% % mass loading, 10% size
% gni_metadata
% 
% 
% for r = 1 : length(regions)
%     region = regions(r);
%     flightnum = split(region, "_");
%     flightnum = flightnum{1};
%     
%     folder = fullfile(directory, regions(r));
%     region_data = readtable(fullfile(folder, 'region_properties.csv'));
%     timestamps = readtable(fullfile(folder, 'InCloud/timestamps.csv'));
%     mintime = timestamps{1,1} - minutes(30);
%     maxtime = timestamps{end,end} + minutes(30);
% 
%     nc_path = '/home/simulations/Field_Projects/SPICULE/Data/LRT_Aircraft_2.1';
%     flight_nc = dir(fullfile(nc_path, sprintf('%s.*.nc', flightnum)));
%     ncfile = fullfile(nc_path, flight_nc.name);
%     flightdate = ncreadatt(ncfile, '/', 'FlightDate');
%     time_ref = split(flightdate, "/");