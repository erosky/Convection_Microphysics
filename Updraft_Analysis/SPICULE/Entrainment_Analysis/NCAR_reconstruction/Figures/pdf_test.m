function [Dcenters, N, err] = pdf_test(region, starttime, endtime, numberofbins);
% return bin centers and number of particles in the bin

% high resoltion time series of holodec
holo_path = sprintf('../../../%s/NCAR_reconstruction', region);
holofile = dir(fullfile(holo_path, '*_HOLODEC.nc'));
holo_nc = fullfile(holo_path, holofile.name);

holotimes = ncread(holo_nc,'particletime');
diameters = ncread(holo_nc,'d');
totalN = length(diameters);

date_ref = split(holofile.name, "_");
year = date_ref{2}(1:4);
month = date_ref{2}(5:6);
day = date_ref{2}(7:8);


holotimes = datetime(str2double(year),str2double(month),str2double(day)) + seconds(holotimes(:,1));
Indexes = (holotimes >= starttime) & (holotimes <= endtime);

diameters = diameters(Indexes);
diameters = diameters(diameters > 12);
totalN = length(diameters);


numbins = numberofbins;
Dcenters = [];
N = [];


% Find total sample volume of all holograms combined
samples = length(unique(holotimes(Indexes))); % number of holograms
sample_volume = 13.095;  %cubic cm per hologram
volume = samples*sample_volume;


Dedges = zeros(numbins+1,1); Dedges(1) = min(diameters); Dedges(end) = max(diameters);
dD = Dedges(end) - Dedges(1);
increment = dD/numbins;
for i = 1:numbins
    Dedges(i+1) = Dedges(i) + increment;
    Dcenters(i) = Dedges(i) + increment/2;
end


%now go through and find particles
particlesinbin = zeros(numbins,1);
for i = 1:numbins
    Dsinbin = find(diameters>=Dedges(i) & diameters<Dedges(i+1)); %Dedges(i) is the lower diameter
    particlesinbin(i) = length(Dsinbin); %this is the number of particle diameters that fell between the bin edges    
end

particlesinbin;
N = particlesinbin./totalN;
C = particlesinbin./volume;
%err = sqrt(particlesinbin)./(volume);
err = sqrt(particlesinbin)./(totalN);


%Plot droplet size distribution in #/cc/um
%figure
%semilogy(Dcenters.*1000000,C), 
%xlabel('Diameter (microns)'), ylabel('Concentration (#/cc/micron)')
%title('DSD from SPICULE Holodec')

% fig = figure(1);
% %Concentration contour
% levels = 10.^(linspace(0,4,20));  %Log10 levels
% contourf(time, bins, transpose(conc), levels, 'LineStyle', 'none');
% if ~isempty(SIZE)
% hold on
% yline(SIZE,'-',sprintf('90th percentile: %0.2f',SIZE));
% end
% hold off
% datetick('x')
% set(gca,'ColorScale','log');
% grid on
% 
% xlabel('Time')
% ylabel('Diameter (microns)');
% c=colorbar;
% set(gca,'ColorScale','log');
% c.Label.String = 'Concentration (#/cc/um)';






