import os
import numpy as np
import matplotlib.pyplot as plt


DIR = "../txt/"
SUFFIX = "17.csv"


def plotter(fname, data_list, lnames, title=None):
    for data in data_list:
        plt.plot(range(1, 1 + len(data)), data, linewidth=2, linestyle='-')
        
    plt.legend(tuple(lnames))
    
    if title:
    	plt.title(title, fontsize=20)

    plt.grid()    
    plt.xlabel('Number of Elements', fontsize=14)
    plt.ylabel(fname, fontsize=14)
    plt.show()


filenames = sorted([filename for filename in os.listdir(DIR) if filename.endswith(SUFFIX)])
filenames = sorted([filename for filename in filenames if not filename.startswith('.')])


data_arrays = []
for filename in filenames:
	try:
		filename = os.path.abspath(os.path.join(DIR, filename))
		csv = np.genfromtxt(filename, delimiter=",")[1:]
		data_arrays.append(csv)
	except:
		continue
	

names = [filename[:-4] for filename in filenames]
forces = [np.sort(data[:,0]) for data in data_arrays]
lengths = [np.sort(data[:,1]) for data in data_arrays]
max_lengths = np.array([np.amax(data) for data in lengths])


title = 'Distribution of Forces With Target Height'
plotter('Forces - kN', forces, names, title)
