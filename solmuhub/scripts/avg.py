import os
import sys
import json
import numpy as np
import scipy as sp
import scipy.stats

'''
This script is used to get the averages and confidence intervals of latency and CPU and memory usages.
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
	dataMap = {}
	cpuData = []
	memData = []
	latencyData = []
	with open(filename) as file:
		for line in file:
			data = json.loads(line)['profiler']['data']
			latency = json.loads(line)['profiler']['latency']
			for key, val in data.items():
				usage = val[0]['usage']
				cpuData.append(usage['cpu'])
				memData.append(usage['mem'])
				latencyData.append(latency)

	mem = mean_confidence_interval(memData)
	cpu = mean_confidence_interval(cpuData)
	latency = mean_confidence_interval(latencyData)

	return {'nodes':nodes, 'size':size, 'cpu':cpu, 'mem':mem, 'latency':latency}

latest = 0
size = str(sys.argv[1])
nodeCount = sys.argv[2]
names = ['cpu', 'mem', 'latency']
s = '-'
resultsPath = '../results/latest'

# Get latest logs' directory name
for dirname, dirnames, filenames in os.walk('../logs/profiler'):
	for subdirname in dirnames:	
		tmp = int(subdirname)
		latestPath = os.path.join(dirname, str(max(latest, tmp)))


for name in names:
	outfile = os.path.join(resultsPath, name + "-" + str(size) + ".out")
	try:
		os.remove(outfile)
	except:
		print ""


for name in names:
	for node in range(0, int(nodeCount)):
		# for size in sizes:
		filename = s.join([str(node), 'node', size]) 
		ret = run(os.path.join(latestPath, filename), str(node), str(size))
		# ret = to_csv(res)n
		outfile = os.path.join(resultsPath, name + "-" + str(size) + ".out")

		with open(outfile, 'a') as out:
			print "\t".join([ret['nodes'], str(ret[name][0]), str(ret[name][1]), str(ret[name][2])])
			out.write("\t".join([ret['nodes'], str(ret[name][0]), str(ret[name][1]), str(ret[name][2]), "0.6", "\n"]))
