function [Dcenters, mass_CDF, err] = lwc_test(quicklookfile, numberofbins);
% return bin centers and number of particles in the bin

quicklook = load(quicklookfile); % loaded structure
diameters = quicklook.ans.eqDiam;
totalN = length(diameters)


numbins = numberofbins;
Dcenters = [];
N = [];


% Find total sample volume of all holograms combined
samples = length(quicklook.ans.counts)
dy = 2*0.28; %cm
dx = 1.44; %cm
dz = 13; %cm
sample_volume = dy*dx*dz; %cubic cm
volume = samples*sample_volume; %cubic cm
water_density = 1.0E6; %grams per cubic meter


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

Dcenters
particlesinbin
N = particlesinbin;
C = particlesinbin./volume;
V = (1/6)*pi*Dcenters.^3  %cubic meters (volume of one water droplet)

% remove dropelts that have less than 3 counts in bin
N_certain = N;
N_certain(N_certain<3)=0

% calculate LWC
mass = (water_density*N_certain.*transpose(V)) %g
LWC = (water_density*N_certain.*transpose(V))/(volume*1.0E-6); % g/m3
TotalLWC = sum(LWC);
totalMASS = sum(mass);

err = sqrt(particlesinbin)./(volume);

mass_CDF = [];
for p = 1:length(Dcenters)
        c = sum(mass(1:p));
        mass_CDF = [mass_CDF; c/totalMASS]; 
end





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






