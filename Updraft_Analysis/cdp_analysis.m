function out = cdp_analysis()

    % warm clouds only
    % read cdp nc files
    % find 90th perfectile (dsd)
    % plot 2d plot with 9th percentile line
    % plot concentrarion of largest particles in/out of updraft as function
    % of updraft velocity
    
    Directory = "/home/simulations/Field_Projects/Updraft_Analysis/SPICULE";
    Analysis_Dir = "/home/simulations/Field_Projects/Updraft_Analysis/SPICULE/Microphysics_Analysis";
    Regions = dir(fullfile(Directory, 'RF*_Region*'));
    
 
    % For each Region, enter InCloud folder
    % read netcdp file and write analysis into analysis folder
    
    for f = 1:length(Regions)
        
        
        % create analysis folder for the region
        region_analysis = fullfile(Analysis_Dir, Regions(f).name)
        if ~exist(region_analysis, 'dir')
           mkdir(region_analysis)
        end
        
        % Open up each cdp file
        region_folder = fullfile(Regions(f).folder, Regions(f).name,'/InCloud');
        cdp_files = dir(fullfile(region_folder,'cdp_*.nc'));
        
        for f = 1:length(cdp_files)
        % Open up the cloudpass file
            ncfile = fullfile(cdp_files(f).folder, cdp_files(f).name);

            time = ncread(ncfile,'time');
            conc = ncread(ncfile, 'PSD');
            bin_edges = ncread(ncfile, 'bin_edges');
            bins = ncread(ncfile,'bins');
            cdplwc = ncread(ncfile,'LWC');
            effrad = ncread(ncfile,'EffectiveDiameter');
            totalconc = ncread(ncfile,'TotalConc');
            meandiam = ncread(ncfile,'MeanDiameter');
            
            % Reformat time to human readable format
            % Given in netcdf file as seconds since 00:00:00 +0000 of flight date
            time2 = datestr(time(:,1));
            
            % Find the 90th percentile
            % plot cdf and find index where cdf reaches 90%
            conc_sum = sum(conc);
            totalconc_sum = sum(totalconc);
            CDF = [];
            for p = 1:length(bins)
                c = sum(conc_sum(1:p));
                CDF = [CDF; c]; 
            end
            P = find( CDF./totalconc_sum > 0.90, 1 );
            SIZE = bins(P);
           
% Per timestep           
%             for t = 1:length(time)
%                 CDF = [];
%                 for p = 1:length(bins)
%                     c = sum(conc(t,(1:p)));
%                     CDF = [CDF; c]; 
%                 end
%                 P = find( CDF./totalconc(t) > 0.90, 1 );
%                 bins(P);
%             end

             fig = figure(1);
             %Concentration contour
             levels = 10.^(linspace(0,4,20));  %Log10 levels
             contourf(time, bins, transpose(conc), levels, 'LineStyle', 'none');
             if ~isempty(SIZE)
                hold on
                yline(SIZE,'-',sprintf('90th percentile: %0.2f',SIZE));
             end
             hold off
             datetick('x')
             set(gca,'ColorScale','log');
             grid on
             
             xlabel('Time')
             ylabel('Diameter (microns)');
             c=colorbar;
             set(gca,'ColorScale','log');
             c.Label.String = 'Concentration (#/cc/um)';

             % Save cloudpass
             date_txt = time2(1,:);
             img_name = date_txt + ".png";
             imgfile = fullfile(region_analysis, img_name);
             if exist(imgfile, 'file')==2
                  delete(imgfile);
             end



             % Save figure
             if ~isfile(imgfile)
                 saveas(fig, imgfile);
             end


        end
    end
    

%          
%          fig = figure(1);
%          tiledlayout(5,1);
%          ax1 = nexttile([2 1]);
%  
%          %Vertical Velocity
%          ax2 = nexttile;
%          plot(datenum(time2(logicalIndexes)), vwind(logicalIndexes))
%          datetick('x')
%          xlabel('Time')
%          ylabel('Vertical windspeed (m/s)')
%          grid on
%  
%  
%          %Link axes
%          linkaxes([ax1, ax2, ax3, ax4],'x');

    
end