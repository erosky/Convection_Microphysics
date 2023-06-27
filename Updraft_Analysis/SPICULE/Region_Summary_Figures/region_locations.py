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

# Read all region properties
directory = "/home/simulations/Field_Projects/Updraft_Analysis/SPICULE"
for folder in os.listdir(directory):
	f = os.path.join(directory, folder)
	# checking if it is a file
	if os.path.isdir(f) and "_Region0" in folder:
		regions.append(folder)
		prop_file = os.path.join(f, "region_properties.csv")
		data = pd.read_csv(prop_file, skipinitialspace=True, sep='\,\s+|\,', engine='python')
		latmins.append(data.loc[:,"LatMin"].values[0])
		latmaxs.append(data.loc[:,"LatMax"].values[0])
		lonmins.append(data.loc[:,"LonMin"].values[0])
		lonmaxs.append(data.loc[:,"LonMax"].values[0])


# Read GNI data locations
GNI_dir = "/home/simulations/Field_Projects/SPICULE/Data/GNI"
GNI_metadata = os.path.join(GNI_dir, "metadata_mass.csv")
gni_data = pd.read_csv(GNI_metadata, skipinitialspace=True)
gni_lons = gni_data.loc[:,"Slide exposure average longitude (deg.decimal)"].values[:]
gni_lats = gni_data.loc[:,"Slide exposure average latitude (deg.decimal)"].values[:]
gni_mass = gni_data.loc[:,"NaCl equivalent mass loading (microg/m**3)"].values[:]
gni_flight = gni_data.loc[:,"Flight number"].values[:]




map = Basemap(projection='merc', llcrnrlon=-108.00, llcrnrlat=31.00, urcrnrlon=-84.00, urcrnrlat=47.00, resolution=None)
map.bluemarble(scale=1.0)
#map.shadedrelief()
#map.etopo()

'''
map.drawmapboundary(fill_color='aqua')
map.fillcontinents(color='#ddaa66', lake_color='aqua')
map.drawcountries()
map.drawstates(color='0.5')
'''


for i in range(len(regions)):
	flightnum = regions[i].split("_")
	
	x1,y1 = map(lonmins[i],latmins[i])
	x2,y2 = map(lonmins[i],latmaxs[i])
	x3,y3 = map(lonmaxs[i],latmaxs[i])
	x4,y4 = map(lonmaxs[i],latmins[i])

	poly = Polygon([(x1,y1),(x2,y2),(x3,y3),(x4,y4)],facecolor='None',edgecolor='green',linewidth=1.5)
	plt.gca().add_patch(poly)
	plt.annotate(flightnum[0]+" "+flightnum[1], xy=(x4,y4), xytext=(x4+10000,y4-50000), fontsize=8, color='w')
	
	'''
	for j in range(len(gni_flight)):
		if gni_flight[j] == flightnum[0]:
			x, y = map(gni_lons[j], gni_lats[j])
			map.scatter(x, y, marker='o',color='m', s=10*gni_mass[j])
	'''

plt.savefig('mapregions.png', dpi=1000)
