from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import os
import pandas as pd


regions = []
latmins = []
latmaxs = []
lonmins = []
lonmaxs = []
datestring = []

entrainment_set = ["RF01_Region01", "RF02_Region01", "RF04_Region01", "RF08_Region02"]

# Read all region properties
directory = "../"
for folder in os.listdir(directory):
	f = os.path.join(directory, folder)
	# checking if it is a file
	if os.path.isdir(f) and folder in entrainment_set:
		regions.append(folder)
		prop_file = os.path.join(f, "region_properties.csv")
		data = pd.read_csv(prop_file, skipinitialspace=True, sep='\,\s+|\,', engine='python')
		latmins.append(data.loc[:,"LatMin"].values[0])
		latmaxs.append(data.loc[:,"LatMax"].values[0])
		lonmins.append(data.loc[:,"LonMin"].values[0])
		lonmaxs.append(data.loc[:,"LonMax"].values[0])
		datestring.append(data.loc[:,"Date"].values[0])

# Read GNI data locations
'''
GNI_dir = "/home/simulations/Field_Projects/SPICULE/Data/GNI"
GNI_metadata = os.path.join(GNI_dir, "metadata_mass.csv")
gni_data = pd.read_csv(GNI_metadata, skipinitialspace=True)
gni_lons = gni_data.loc[:,"Slide exposure average longitude (deg.decimal)"].values[:]
gni_lats = gni_data.loc[:,"Slide exposure average latitude (deg.decimal)"].values[:]
gni_mass = gni_data.loc[:,"NaCl equivalent mass loading (microg/m**3)"].values[:]
gni_flight = gni_data.loc[:,"Flight number"].values[:]
'''



map = Basemap(projection='merc', llcrnrlon= -124.736342, llcrnrlat= 24.521208, urcrnrlon=-66.945392, urcrnrlat=49.382808, resolution=None)

#map = Basemap(projection='merc', llcrnrlon=-108.00, llcrnrlat=31.00, urcrnrlon=-87.00, urcrnrlat=43.00, resolution=None)
map.bluemarble(scale=1.0)
#map.shadedrelief()
#map.etopo()

'''
map.drawmapboundary(fill_color='aqua')
map.fillcontinents(color='#ddaa66', lake_color='aqua')
map.drawcountries()
map.drawstates(color='0.5')
'''

	
x1,y1 = map(-105.00,32.70)
x2,y2 = map(-105.00,41.00)
x3,y3 = map(-91.00,41.00)
x4,y4 = map(-91.00,32.70)


poly = Polygon([(x1,y1),(x2,y2),(x3,y3),(x4,y4)],facecolor='None',edgecolor='yellow',linewidth=1.25)
plt.gca().add_patch(poly)
#plt.annotate("Sampling", xy=(x4,y4), xytext=(x4+40000,y4-60000), fontsize=8, color='w')


for i in range(len(regions)):
	flightnum = regions[i].split("_")
	
	x1,y1 = map(lonmins[i],latmins[i])
	x2,y2 = map(lonmins[i],latmaxs[i])
	x3,y3 = map(lonmaxs[i],latmaxs[i])
	x4,y4 = map(lonmaxs[i],latmins[i])
	print(datestring[i])

	poly = Polygon([(x1,y1),(x2,y2),(x3,y3),(x4,y4)],facecolor='red',edgecolor='None')
	plt.gca().add_patch(poly)
	#plt.annotate(flightnum[0]+" "+flightnum[1] + "\n" + datestring[i] + ", 2021", xy=(x4,y4), xytext=(x4+40000,y4-40000), fontsize=8, color='w')

	

plt.savefig('map_project.png', dpi=1000, bbox_inches='tight')
