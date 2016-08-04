import os
import sys
import json
import numpy as np
import scipy as sp
import scipy.stats

'''
This script is used to get the averages and confidence intervals of latency, CPU and memory usages.
Results are saved in a timestamped folder. 

Example usage: 

$ python avg.py 512 5

Where 512 represents image size and 5 is the total number of nodes, including controller node.

'''

def mean_confidence_interval(data, confidence=0.95):
    a = 1.0*np.array(data)
    n = len(a)
    m, se = np.mean(a), scipy.stats.sem(a)
    h = se * sp.stats.t._ppf((1+confidence)/2., n-1)
    return m, m-h, m+h

def run(filename, nodes, size):
	profile = {}
	means = {}
	with open(filename) as file:
		for line in file:
			data = json.loads(line)['profiler']['data']
			latency = json.loads(line)['profiler']['latency']
			for key, val in data.items():
				if not key in profile:
					profile[key] = []
				for value in val:
					profile[key].append(value['time'])

	for tag, val in profile.items():
		means[tag] = mean_confidence_interval(val)


	return {'means':means}

latest = 0
size = str(sys.argv[1])
sizes = ['256', '512', '1024']
nodeCount = sys.argv[2]
names = ['profile']
s = '-'

# Get latest logs' directory name
for dirname, dirnames, filenames in os.walk('../logs/profiler'):
	for subdirname in dirnames:	
		tmp = int(subdirname)
		latest = max(latest, tmp)
		latestPath = os.path.join(dirname, str(latest))

results_path = '../results/' + str(latest)

if not os.path.exists(results_path):
    os.makedirs(results_path)

for name in names:
	outfile = os.path.join(results_path, name + "-" + str(size) + ".profile")
	try:
		os.remove(outfile)
	except:
		print ""

tags = ['feed_fetched', 'after_data_fetch', 'after_data_map', 'execution_end', 'piece_response_latency', 'dist_response_latency', 'after_reducer', 'before_sending_response', ]

for name in names:
	for node in range(0, int(nodeCount)):
		filename = s.join([str(node), 'node', size]) 
		ret = run(os.path.join(latestPath, filename), str(node), str(size))['means']
		outfile = os.path.join(results_path, str(node) + "-" + str(size) + ".profile")

		with open(outfile, 'a') as out:
			for tag in tags:
				if (tag in ret.keys()):
					print "\t".join([tag, str(ret[tag][0]), str(ret[tag][1]), str(ret[tag][2]), "0.6", "\n"])
					out.write("\t".join([str(ret[tag][0]), str(ret[tag][1]), str(ret[tag][2]), "0.6", "\n"]))

