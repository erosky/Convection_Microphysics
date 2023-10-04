import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.basemap import Basemap
import os
import pandas as pd
import numpy as np

import matplotlib
from mpl_toolkits import mplot3d
import matplotlib.cm as cm




regions = []
latmins = []
latmaxs = []
lonmins = []
lonmaxs = []
cloudbases = []
track_lons = []
track_lats = []
track_alts = []
temps = []
edge_lons = []
edge_lats = []
edge_alts = []
edge_temps = []

# Read all region properties
directory = "/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE"
for folder in os.listdir(directory):
	f = os.path.join(directory, folder)
	# checking if it is a file
	if os.path.isdir(f) and "_Region0" in folder:
		regions.append(folder)
		prop_file = os.path.join(f, "region_properties.csv")
		print(prop_file)
		data = pd.read_csv(prop_file, skipinitialspace=True, sep='\,\s+', engine='python')
		latmins.append(data.loc[:,"LatMin"].values[0])
		latmaxs.append(data.loc[:,"LatMax"].values[0])
		lonmins.append(data.loc[:,"LonMin"].values[0])
		lonmaxs.append(data.loc[:,"LonMax"].values[0])
		cloudbases.append(data.loc[:,"CloudBase_m"].values[0])
		
		incloud = os.path.join(f, "InCloud")
		lons = []
		lats = []
		alts = []
		temp = []
		edgecloud = os.path.join(f, "EdgeCloud")
		e_lons = []
		e_lats = []
		e_alts = []
		e_temp = []
		belowcloud = os.path.join(f, "BelowCloud")
		for passfile in sorted(os.listdir(incloud)):
			if "thermodynamics_" in passfile and "lock" not in passfile:
				pass_csv = os.path.join(incloud, passfile)
				passdata = pd.read_csv(pass_csv, skipinitialspace=True, sep=',', engine='python')
				lons.append(passdata.loc[:,"Longitude"].values[:])
				lats.append(passdata.loc[:,"Latitude"].values[:])
				alts.append(passdata.loc[:,"Altitude"].values[:])
				temp.append(np.average(passdata.loc[:,"Temperature"].values[:]))
		if os.path.isdir(edgecloud):
			for passfile in sorted(os.listdir(edgecloud)):
				if "thermodynamics_" in passfile and "lock" not in passfile:
					pass_csv = os.path.join(edgecloud, passfile)
					passdata = pd.read_csv(pass_csv, skipinitialspace=True, sep=',', engine='python')
					e_lons.append(passdata.loc[:,"Longitude"].values[:])
					e_lats.append(passdata.loc[:,"Latitude"].values[:])
					e_alts.append(passdata.loc[:,"Altitude"].values[:])
					e_temp.append(np.average(passdata.loc[:,"Temperature"].values[:]))
						
		if os.path.isdir(belowcloud):
			for passfile in os.listdir(belowcloud):
				if "thermodynamics_" in passfile and "lock" not in passfile:
					pass_csv = os.path.join(belowcloud, passfile)
					passdata = pd.read_csv(pass_csv, skipinitialspace=True, sep=',', engine='python')
					lons.append(passdata.loc[:,"Longitude"].values[:])
					lats.append(passdata.loc[:,"Latitude"].values[:])
					alts.append(passdata.loc[:,"Altitude"].values[:])
					temp.append(np.average(passdata.loc[:,"Temperature"].values[:]))
					
		track_lons.append(lons)
		track_lats.append(lats)
		track_alts.append(alts)
		temps.append(temp)
		
		edge_lons.append(e_lons)
		edge_lats.append(e_lats)
		edge_alts.append(e_alts)
		edge_temps.append(e_temp)
				
				


# Read GNI data locations
GNI_dir = "/data/emrosky-sim/Field_Projects/SPICULE/Data/GNI"
GNI_metadata = os.path.join(GNI_dir, "metadata_mass.csv")
gni_data = pd.read_csv(GNI_metadata, skipinitialspace=True)
gni_lons = gni_data.loc[:,"Slide exposure average longitude (deg.decimal)"].values[:]
gni_lats = gni_data.loc[:,"Slide exposure average latitude (deg.decimal)"].values[:]
gni_alts = gni_data.loc[:,"Slide exposure average GPS altitude (m)"].values[:]
gni_mass = gni_data.loc[:,"NaCl equivalent mass loading (microg/m**3)"].values[:]
gni_flight = gni_data.loc[:,"Flight number"].values[:]


for i in range(len(regions)):

	flightnum = regions[i].split("_")

	x = np.linspace(lonmins[i],lonmaxs[i], 30)
	print(latmins[i],latmaxs[i])
	y = np.linspace(latmins[i],latmaxs[i], 30)
	X, Y = np.meshgrid(x, y)
	Z =  cloudbases[i]*np.ones(X.shape)

	fig = plt.figure()
	ax = plt.axes(projection='3d')
	ax.plot_surface(X, Y, Z, edgecolor='royalblue', lw=0.5, rstride=8, cstride=8, alpha=0.3)
	#ax.plot_wireframe(X, Y, Z, color='black', linewidth=0.5, rcount = 10, ccount = 10, alpha=0.5, label='cloud base')
	
	gni_x = []
	gni_y = []
	gni_z = []
		
	for j in range(len(gni_flight)):
		if gni_flight[j] == flightnum[0]:
			x, y = gni_lons[j], gni_lats[j]
			if (gni_lons[j] <= lonmaxs[i]+0.2 and gni_lons[j] >= lonmins[i]-0.5 and gni_lats[j] <= latmaxs[i]+0.2 and gni_lats[j] >= latmins[i]-0.5):
				gni_x.append(x)
				gni_y.append(y)
				gni_z.append(gni_alts[j])
				
	ax.scatter(gni_x, gni_y, gni_z, label='GNI samples')
	
	### Plot flight passes
	minima = min(temps[i])
	maxima = max(temps[i])

	norm = matplotlib.colors.Normalize(vmin=minima, vmax=maxima, clip=True)
	mapper = cm.ScalarMappable(norm=norm, cmap=cm.jet)
	
	
	for p in range(len(track_lats[i])):
		zline = track_alts[i][p]
		xline = track_lons[i][p]
		yline = track_lats[i][p]
		ax.plot3D(xline, yline, zline, color=mapper.to_rgba(temps[i][p]))
		ax.text(xline[0], yline[0], zline[0], str(p+1), rotation=40.0, verticalalignment="baseline", horizontalalignment="left", color='k', fontsize='xx-small')
		
	for e in range(len(edge_lats[i])):
		zline_e = edge_alts[i][e]
		xline_e = edge_lons[i][e]
		yline_e = edge_lats[i][e]
		ax.plot3D(xline_e, yline_e, zline_e, color='m')
		ax.text(xline_e[0], yline_e[0], zline_e[0], str(e+1), rotation=40.0, verticalalignment="baseline", horizontalalignment="left", color='m', fontsize='xx-small')

		
		
	fig.colorbar(mapper, label="Temperature(C)", shrink=0.5, pad=0.1)
	ax.grid(False)
	ax.set_title(flightnum[0]+" "+flightnum[1]);
	ax.set_xlabel('Longitude', fontsize=8, rotation=0)
	ax.tick_params(axis='both', which='major', labelsize=5)
	ax.set_ylabel('Latitude', fontsize=8, rotation=20)
	ax.set_zlabel('Altitude (m)', fontsize=8, rotation=90)
	ax.legend()

	plt.savefig('Advanced/{}_sampling.png'.format(regions[i]), dpi=1000)
	
	

	fig2 = plt.figure()
	



'''
for i in range(len(regions)):
	flightnum = regions[i].split("_")
	
	x1,y1 = map(lonmins[i],latmins[i])
	x2,y2 = map(lonmins[i],latmaxs[i])
	x3,y3 = map(lonmaxs[i],latmaxs[i])
	x4,y4 = map(lonmaxs[i],latmins[i])

	poly = Polygon([(x1,y1),(x2,y2),(x3,y3),(x4,y4)],facecolor='None',edgecolor='green',linewidth=1)
	plt.gca().add_patch(poly)
	plt.annotate(flightnum[0]+" "+flightnum[1], xy=(x4,y4), xytext=(x4+10000,y4-50000), fontsize=5)
	
	
	for j in range(len(gni_flight)):
		if gni_flight[j] == flightnum[0]:
			x, y = map(gni_lons[j], gni_lats[j])
			map.scatter(x, y, marker='o',color='m', s=10*gni_mass[j])

plt.savefig('test.png', dpi=1000)
'''
