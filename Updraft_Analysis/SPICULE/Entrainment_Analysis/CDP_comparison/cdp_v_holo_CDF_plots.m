function out = cdp_v_holo_CDF_plots(region)

% plot holodec and cdp CDF's on same figure.
% use data_two_cdfs_continuous file

region_folder = '../../';
timestamps = readtable(fullfile(region_folder, region, 'core_edge_pairs.csv'));

edge_holo = dir(fullfile(region_folder, region, 'EdgeCloud', 'holoquicklook_*.mat'))
core_holo = dir(fullfile(region_folder, region, 'holoquicklook_*.mat'))

edge_cdp = dir(fullfile(region_folder, region, 'EdgeCloud', 'cdp_*.nc'))
core_cdp= dir(fullfile(region_folder, region, 'InCloud', 'cdp_*.nc'))

output_path = '../';
outputfolder = fullfile(output_path, region, 'CDP');


for r=1 : height(timestamps)
   % get droplet size data
   core_pass = timestamps{r,2}
   edge_pass = timestamps{r,1}
   titlestring = region + "_CDPvHOLO_" + "Edge" + edge_pass + "_Core" + core_pass;
   
   quicklookedge = load(fullfile(edge_holo(edge_pass).folder, edge_holo(edge_pass).name)); % loaded structure
   diametersedge = quicklookedge.ans.eqDiam*1000000;
   diametersedge = diametersedge(diametersedge >= 12);
   quicklookcore = load(fullfile(core_holo(core_pass).folder, core_holo(core_pass).name)); % loaded structure
   diameterscore = quicklookcore.ans.eqDiam*1000000;
   diameterscore = diameterscore(diameterscore >= 12);
   
   Dcentersedge = ncread(fullfile(edge_cdp(edge_pass).folder, edge_cdp(edge_pass).name), 'bins');
   edgecutoff = find(Dcentersedge >= 12, 1);
   Dcentersedge = Dcentersedge(edgecutoff:end);
   Dcenterscore = ncread(fullfile(core_cdp(core_pass).folder, core_cdp(core_pass).name), 'bins');
   corecutoff = find(Dcenterscore >= 12, 1);
   Dcenterscore = Dcenterscore(corecutoff:end);

    contoursedge = transpose(ncread(fullfile(edge_cdp(edge_pass).folder, edge_cdp(edge_pass).name), 'PSD'));
    contoursedge = contoursedge(edgecutoff:end,:);
    contourscore = transpose(ncread(fullfile(core_cdp(core_pass).folder, core_cdp(core_pass).name), 'PSD'));
    contourscore = contourscore(corecutoff:end,:);
    
    % plot cdf and find index where cdf reaches 90%
    sumcore = sum(contourscore, 2);
    total_sumcore = sum(sumcore);
    sumedge = sum(contoursedge, 2);
    total_sumedge = sum(sumedge);
    C_cdpc = [];
    C_cdpe = [];
    for p = 1:length(Dcenterscore)
        c = sum(sumcore(1:p));
        C_cdpc = [C_cdpc; c]; 
    end
    for p = 1:length(Dcentersedge)
        c = sum(sumedge(1:p));
        C_cdpe = [C_cdpe; c]; 
    end

    C_cdpc = C_cdpc/total_sumcore;
    C_cdpe = C_cdpe/total_sumedge;
    

    %Plot droplet size distribution in #/cc/um
    fig = figure('visible','on');
    [c_hc, d_hc] = ecdf(diameterscore,'Bounds','off'); 
    [c_he, d_he] = ecdf(diametersedge,'Bounds','off'); 

    stairs(d_hc, c_hc, 'b:', 'LineWidth', 2, 'DisplayName','HOLODEC core'); hold on
    stairs(d_he, c_he, 'r:', 'LineWidth', 2, 'DisplayName','HOLODEC edge'); hold on

    stairs(Dcenterscore, C_cdpc, 'b-', 'LineWidth', 2, 'DisplayName','CDP core'); hold on
    stairs(Dcentersedge, C_cdpe, 'r-', 'LineWidth', 2, 'DisplayName','CDP core');

    legend('Location','northeastoutside')
    xlabel('Diameter (microns)'), ylabel('CDF')
    xlim([10, max([d_hc;d_he])])
    title(titlestring,  'interpreter', 'none')

    exportgraphics(fig,sprintf('%s/%s.png', outputfolder, titlestring),'Resolution',500);
    
end

end

