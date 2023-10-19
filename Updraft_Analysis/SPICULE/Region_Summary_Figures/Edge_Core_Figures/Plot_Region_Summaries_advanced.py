import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import os
import pandas as pd
import numpy as np

import matplotlib
from mpl_toolkits import mplot3d
import matplotlib.cm as cm
import matplotlib.patches as mpatches


Entrainment_Set = ["RF01_Region01", "RF02_Region01", "RF04_Region01", "RF08_Region02"]

regions = []
latmins = []
latmaxs = []
lonmins = []
lonmaxs = []
cloudbases = []
cloudtops = []

region_lons = []
region_lats = []
region_alts = []
region_temps = []
region_lwc = []
region_vwind = []

track_lons = []
track_lats = []
track_alts = []
temps = []
track_lwc = []
track_vwind = []

edge_lons = []
edge_lats = []
edge_alts = []
edge_temps = []
edge_lwc = []

below_lons = []
below_lats = []
below_alts = []
below_temps = []
below_vwind = []

# Read all region properties
directory = "/data/emrosky-sim/Field_Projects/Convection_Microphysics/Updraft_Analysis/SPICULE"
for folder in os.listdir(directory):
	f = os.path.join(directory, folder)
	# checking if it is a file
	if os.path.isdir(f) and folder in Entrainment_Set:
		
		print(folder)
		regions.append(folder)

		# Get flight track for full region				
		region_file = os.path.join(f, "region_timeseries.csv")
		timeseries = pd.read_csv(region_file, skipinitialspace=True, sep=',', engine='python')
		r_lons = timeseries.loc[:,"Longitude"].values[:]
		r_lats = timeseries.loc[:,"Latitude"].values[:]
		r_alts = timeseries.loc[:,"Altitude"].values[:]
		r_temp = timeseries.loc[:,"Temperature"].values[:]
		r_lwc = timeseries.loc[:,"LWC"].values[:]
		r_vwind = timeseries.loc[:,"VerticalWind"].values[:]
		
		
		# Get region cloud properties
		prop_file = os.path.join(f, "region_properties.csv")
		data = pd.read_csv(prop_file, skipinitialspace=True, sep='\,\s+', engine='python')
		latmins.append(data.loc[:,"LatMin"].values[0])
		latmaxs.append(data.loc[:,"LatMax"].values[0])
		lonmins.append(data.loc[:,"LonMin"].values[0])
		lonmaxs.append(data.loc[:,"LonMax"].values[0])
		cloudbases.append(data.loc[:,"CloudBase_m"].values[0])
		cloudtops.append(data.loc[:,"CloudTop_m"].values[0])
		
		incloud = os.path.join(f, "InCloud")
		lons = []
		lats = []
		alts = []
		temp = []
		lwc = []
		vwind = []
		
		edgecloud = os.path.join(f, "EdgeCloud")
		e_lons = []
		e_lats = []
		e_alts = []
		e_temp = []
		e_lwc = []
		
		belowcloud = os.path.join(f, "BelowCloud")
		b_lons = []
		b_lats = []
		b_alts = []
		b_temp = []
		b_vwind = []
		
		
		
		for passfile in sorted(os.listdir(incloud)):
			if "thermodynamics_" in passfile and "lock" not in passfile:
				pass_csv = os.path.join(incloud, passfile)
				passdata = pd.read_csv(pass_csv, skipinitialspace=True, sep=',', engine='python')
				lons.append(passdata.loc[:,"Longitude"].values[:])
				lats.append(passdata.loc[:,"Latitude"].values[:])
				alts.append(passdata.loc[:,"Altitude"].values[:])
				lwc.append(passdata.loc[:,"LWC_cdp"].values[:])
				vwind.append(passdata.loc[:,"VerticalWind"].values[:])
				temp.append(np.average(passdata.loc[:,"Temperature"].values[:]))
		if os.path.isdir(edgecloud):
			for passfile in sorted(os.listdir(edgecloud)):
				if "thermodynamics_" in passfile and "lock" not in passfile:
					pass_csv = os.path.join(edgecloud, passfile)
					passdata = pd.read_csv(pass_csv, skipinitialspace=True, sep=',', engine='python')
					e_lons.append(passdata.loc[:,"Longitude"].values[:])
					e_lats.append(passdata.loc[:,"Latitude"].values[:])
					e_alts.append(passdata.loc[:,"Altitude"].values[:])
					e_lwc.append(passdata.loc[:,"LWC_cdp"].values[:])
					e_temp.append(np.average(passdata.loc[:,"Temperature"].values[:]))
						
		if os.path.isdir(belowcloud):
			for passfile in os.listdir(belowcloud):
				if "thermodynamics_" in passfile and "lock" not in passfile:
					pass_csv = os.path.join(belowcloud, passfile)
					passdata = pd.read_csv(pass_csv, skipinitialspace=True, sep=',', engine='python')
					b_lons.append(passdata.loc[:,"Longitude"].values[:])
					b_lats.append(passdata.loc[:,"Latitude"].values[:])
					b_alts.append(passdata.loc[:,"Altitude"].values[:])
					b_vwind.append(passdata.loc[:,"VerticalWind"].values[:])
					b_temp.append(np.average(passdata.loc[:,"Temperature"].values[:]))
		
					
		region_lons.append(r_lons)
		region_lats.append(r_lats)
		region_alts.append(r_alts)
		region_temps.append(r_temp)
		region_lwc.append(r_lwc)
		region_vwind.append(r_vwind)
		
		track_lons.append(lons)
		track_lats.append(lats)
		track_alts.append(alts)
		track_lwc.append(lwc)
		track_vwind.append(vwind)
		temps.append(temp)
		
		edge_lons.append(e_lons)
		edge_lats.append(e_lats)
		edge_alts.append(e_alts)
		edge_temps.append(e_temp)
		edge_lwc.append(e_lwc)
		
		below_lons.append(b_lons)
		below_lats.append(b_lats)
		below_alts.append(b_alts)
		below_temps.append(b_temp)
		below_vwind.append(b_vwind)
				
				

for i in range(len(regions)):

	flightnum = regions[i].split("_")

	x = np.linspace(lonmins[i],lonmaxs[i], 30)
	y = np.linspace(latmins[i],latmaxs[i], 30)
	X, Y = np.meshgrid(x, y)
	Z =  cloudbases[i]*np.ones(X.shape)
	Ztop = cloudtops[i]*np.ones(X.shape)
	Zmid = max(region_alts[i])*np.ones(X.shape)

	fig = plt.figure()
	ax = plt.axes(projection='3d')
	ax.view_init(elev=15, azim=45)
	ax.plot_surface(X, Y, Z, edgecolor='royalblue', lw=0.5, rstride=9, cstride=9, alpha=0.3)
	ax.text(lonmins[i], latmaxs[i], cloudbases[i], 'cloud base', 'y', verticalalignment="bottom", horizontalalignment="right", color='royalblue', fontsize='small')
	
	ax.plot_surface(X, Y, Ztop, edgecolor='royalblue', lw=0.1, rstride=9, cstride=9, alpha=0.15, linestyle=':',)
	ax.text(lonmins[i], latmaxs[i], cloudtops[i], 'cloud top', 'y', verticalalignment="bottom", horizontalalignment="right", color='royalblue', fontsize='small')
	
	#ax.plot_surface(X, Y, Zmid, edgecolor='royalblue', lw=0.1, rstride=9, cstride=9, alpha=0.15, linestyle=':',)
	
	### Plot flight passes
	minima = min(region_temps[i])
	maxima = max(region_temps[i])

	norm = matplotlib.colors.Normalize(vmin=minima, vmax=maxima, clip=True)
	mapper = cm.ScalarMappable(norm=norm, cmap=cm.cividis.reversed())
	r_colors = []
	for pt in range(len(region_temps[i])):
		r_colors.append(mapper.to_rgba(region_temps[i][pt]))
	
	ax.scatter(region_lons[i], region_lats[i], region_alts[i], s=0.1, color=r_colors, alpha=0.8)
	#, lw=0.2, linestyle='--', color=mapper.to_rgba(region_temps[i]
	
	for p in range(len(track_lats[i])):
		zline = track_alts[i][p]
		xline = track_lons[i][p]
		yline = track_lats[i][p]
		colors = []
		for pt in range(len(track_lwc[i][p])):
			colors.append(mapper.to_rgba(track_lwc[i][p][pt]))
		ax.scatter(xline, yline, zline, s=7.0, color=(0.4660, 0.6740, 0.1880), alpha=1.0)
		#ax.text(xline[0], yline[0], zline[0], str(p+1), rotation=40.0, verticalalignment="baseline", horizontalalignment="left", color='k', fontsize='xx-small')
		
	for e in range(len(edge_lats[i])):
		zline_e = edge_alts[i][e]
		xline_e = edge_lons[i][e]
		yline_e = edge_lats[i][e]
		#ax.plot3D(xline_e, yline_e, zline_e, color='m')
		ax.scatter(xline_e, yline_e, zline_e, s=7.0, color=(0.4940, 0.1840, 0.5560), alpha=1.0)
		#ax.text(xline_e[0], yline_e[0], zline_e[0], str(e+1), rotation=40.0, verticalalignment="baseline", horizontalalignment="left", color='m', fontsize='xx-small')

		
		
	cb = fig.colorbar(mapper, label="Temperature(C)", shrink=0.5, pad=0.1)
	cb.ax.invert_yaxis()
	ax.grid(False)
	ax.set_title(flightnum[0]+" "+flightnum[1]);
	ax.set_xlabel('Longitude', fontsize=8, rotation=0)
	ax.tick_params(axis='both', which='major', labelsize=5)
	ax.set_ylabel('Latitude', fontsize=8, rotation=20)
	ax.set_zlabel('Altitude (m)', fontsize=8, rotation=90)
	ax.set_xlim(lonmins[i],lonmaxs[i])
	ax.set_ylim(latmins[i],latmaxs[i])
	#ax.legend()
	core_patch = mpatches.Patch(color=(0.4660, 0.6740, 0.1880), label='Adiabatic updraft')
	edge_patch = mpatches.Patch(color=(0.4940, 0.1840, 0.5560), label='Edge region')
	plt.legend(handles=[core_patch, edge_patch], fontsize='small')

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
