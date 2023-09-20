function [percentile_LIST, large_avg_LIST, largest_LIST] = get_core_mass90th(region)

% output list per cloudpass
% holodec 90th percentile

quicklook_path = '../../';
quicklooks = dir(fullfile(quicklook_path, region, 'InCloud', 'cdp_*.nc'));
percentile_LIST = [];
large_avg_LIST = [];
largest_LIST = [];
mass_CDF_LIST = [];

for q=1 : length(quicklooks)
    quicklookfile = fullfile(quicklooks(q).folder, quicklooks(q).name);
    
    times = ncread(quicklookfile, 'time');
    times = datetime(times,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

    starttime = times(1);
    endtime = times(end);

    bin_edges = ncread(quicklookfile, 'bin_edges');
    bins = ncread(quicklookfile, 'bins');


    % divide holodec data into time series - rows are time, columns are
    % concentration bins
    % bin holodec data the same as CDP bins

    holo_contours = transpose(ncread(quicklookfile, 'PSD'));


    % % Liquid Water content of Holodec and CDP
    % Using density of water, and diameter, calculate LWZ in g/m^3
    % Density of water
    rho_liquid = 997 * 1e3 ; %g/m^3

    
    % get mass array
    V_bin = (1/6)*pi*(bins*10^-6).^3;  % cubic meters (volume of one water droplet)
    mass_array = rho_liquid*(N_certain.*V_bin); % grams
    mass_sum = sum(mass_array);
    
    mass_CDF = [];
    for p = 1:length(bins)
        c = sum(mass_array(1:p));
        mass_CDF = [mass_CDF; c]; 
    end
    holo_P = find( mass_CDF./mass_sum >= 0.95, 1 );
    percentile_SIZE = bins(holo_P);
    percentile_LIST = [percentile_LIST; percentile_SIZE];
    mass_CDF_LIST = [mass_CDF_LIST; mass_CDF];

    % Get average mass diameter larger than 90th
    larger = N_certain(holo_P:end);
    larger_diameters = bins(holo_P:end);
    large_avg_SIZE = (sum(larger.*(larger_diameters.^3))/sum(larger))^(1/3);
    large_avg_LIST = [large_avg_LIST; large_avg_SIZE];
    
    % Find largest droplet bin with at least 3 counts
    largest_SIZE = bins(find( N_certain > 0, 1, 'last' ));
    largest_LIST = [largest_LIST; largest_SIZE];

    
end

percentile_LIST
large_avg_LIST
       

end




