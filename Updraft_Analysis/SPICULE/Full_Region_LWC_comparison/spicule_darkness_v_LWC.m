function out = spicule_darkness_v_LWC();

regions = ["RF01_Region01", "RF02_Region01", "RF04_Region01", "RF08_Region02"]

Region_dir = "../";
Regions = dir(fullfile(Directory, 'RF*_Region*'));

brightnessfolder = dir(fullfile('../Hologram_Brightness', '*.mat'));
output_folder = './';


for R = 1:length(regions)
    
    timestamps_dir = fullfile(Regions_dir, regions(R))
    
   
    
   % get core timestamps
   
   % get per-second hologram brightness
   
   % get per-second hologram-CDP LWC difference
    
end