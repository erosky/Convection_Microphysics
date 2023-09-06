function [percentile_LIST, large_avg_LIST, largest_LIST] = get_core_mass90th(region)

% output list per cloudpass
% holodec 90th percentile

quicklook_path = '/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE';
quicklooks = dir(fullfile(quicklook_path, region, 'holoquicklook_*.mat'));
percentile_LIST = [];
large_avg_LIST = [];
largest_LIST = [];
mass_CDF_LIST = [];

for q=1 : length(quicklooks)
    quicklookfile = fullfile(quicklooks(q).folder, quicklooks(q).name);
    quicklook = load(quicklookfile); % loaded structure
    diameters = quicklook.ans.majsiz; % meters
    totalN = length(diameters);


    % numbins = numberofbins;
    % Dcenters = [];
    % N = [];


    % Find total sample volume of all holograms combined
    N_holograms = length(quicklook.ans.counts);
    holotimes = datetime(quicklook.ans.time,'ConvertFrom','datenum', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    holotimes = sortrows(holotimes);
    dy = 2*0.28; %cm
    dx = 1.44; %cm
    dz = 13; %cm
    sample_volume = dy*dx*dz; %cubic cm
    
    starttime = holotimes(1);
    endtime = holotimes(end);


    bin_edges = [4.5:1.0:200.5]; % microns
    bins = []; % microns
    for b = 1 : length(bin_edges)-1
        center = (bin_edges(b) + bin_edges(b+1))/2;
        bins = [bins; center];
    end


    % divide holodec data into time series - rows are time, columns are
    % concentration bins
    % bin holodec data the same as CDP bins

    holo_contours = zeros(length(bins),N_holograms);
    N_contours = zeros(length(bins),N_holograms);
    N_time_table = [quicklook.ans.time, transpose(1:N_holograms)];
    N_time_table = sortrows(N_time_table);
    index_search = N_time_table(:,2);

    for n=1 : N_holograms
        h = index_search(n);
        totalN = quicklook.ans.counts(h);
        indexes = (quicklook.ans.holonum == h);
        h_diameters = diameters(indexes);
        particlesinbin = zeros(length(bins),1);
        for i = 1:length(bin_edges)-1
              b1 = bin_edges(i)*10^-6; %convert from um to m
              b2 = bin_edges(i+1)*10^-6;
              Dsinbin = find(h_diameters>=b1 & h_diameters<b2); % b1 is the lower diameter
              particlesinbin(i) = length(Dsinbin); %this is the number of particle diameters that fell between the bin edges    
        end
        if totalN > 0 
            N = particlesinbin;
        else N = 0;
        end
        C = particlesinbin./sample_volume;
        holo_contours(:,n) = C;
        N_contours(:,n) = N;

    end


    % % Liquid Water content of Holodec and CDP
    % Using density of water, and diameter, calculate LWZ in g/m^3
    % Density of water
    rho_liquid = 997 * 1e3 ; %g/m^3

    % Find the 90th percentile based on mass
    % plot cdf and find index where mass cdf reaches 90%
    N_sum = sum(N_contours, 2);
    N_certain = N_sum;
    N_certain(N_certain<3)=0; % remove droplets where there were fewer than 3 counts in the bin
    
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




