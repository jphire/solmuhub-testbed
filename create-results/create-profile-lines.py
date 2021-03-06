import os
import sys
import json
import numpy as np
import scipy as sp
import scipy.stats
import shutil

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

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
    except:
	return False

''' Calculates mean cpu, memory and latency from the log files' data.
	Only calculates one level currently, not taking into account piecesData element,
	which includes child nodes' profiling info.
'''
def run(filename, nodes, size):
	dataMap = {}
	profile = {}
	means = {}
	cpuData = []
	memData = []
	latencyData = []
	content_length = []
	profile['after_response'] = []

	with open(filename) as file:
		for line in file:
			data = json.loads(line)['profiler']['data']
			latency = json.loads(line)['profiler']['latency']
			for key, val in data.items():
				usage = val[0]['usage']
				
				# Have to check, because may be undefined
				if is_number(usage['cpu']):
					cpuData.append(usage['cpu'])
				memData.append(usage['mem'])
				latencyData.append(latency)
				
				# Record payload length information
				# if (key == 'piece_response_latency'):
				if ('contentLength' in val[0]):
					content_length.append(val[0]['contentLength'])

				# Profiling information
				if not key in profile:
					profile[key] = []
				for value in val:
					profile[key].append(value['time'])
			profile['after_response'].append(int(latency))

	for tag, val in profile.items():
		means[tag] = mean_confidence_interval(val)

	mem = mean_confidence_interval(memData)
	cpu = mean_confidence_interval(cpuData)
	latency = mean_confidence_interval(latencyData)
	
	if len(content_length) > 0: 
		payload = mean_confidence_interval(map(int, content_length))
	else:
		payload = []
	print payload

	return {'nodes':nodes, 'size':size, 'cpu':cpu, 'mem':mem, 'latency':latency, 'payload':payload, 'profile':means}



def prettify(tag):
	return tag.replace('_', '-').capitalize()

latest = 0
# size = str(sys.argv[1])
sizes = []
nodes = []
depths = []
types = ['cpu', 'mem', 'latency', 'payload']
tags = ['feed_fetched', 'after_data_fetch', 'after_data_map', 'execution_end', 'piece_response_latency', 'dist_response_latency', 'after_reducer', 'before_sending_response']

# Find latest logged results' directory path
for dirname, dirnames, filenames in os.walk('../logs/profiler'):
	for subdirname in dirnames:	
		try:
			tmp = int(subdirname)
			latest = max(latest, tmp)
			latest_path = os.path.join(dirname, str(latest))
		except ValueError:
			continue

# Deduce node count and sizes automatically from the logged results folder
for dirname, dirnames, filenames in os.walk(latest_path):
	for name in filenames:
		try:
			n = name.split('-')[0]
			s = name.split('-')[3]
			depth = name.split('-')[5]
			if s not in sizes:
				sizes.append(s)
			if n not in nodes:
				nodes.append(n)
			if depth not in depths:
				depths.append(depth)
		except IndexError:
			continue

# Sort sizes to make it easy to plot nice charts
sizes.sort(key=int)
depths.sort(key=int)

# Create new timestamped folder in results
results_path = '../results/' + str(latest)
if not os.path.exists(results_path):
	os.makedirs(results_path)
else:
	shutil.rmtree(results_path)
	os.makedirs(results_path)

if os.path.exists('../results/latest'):
	os.unlink('../results/latest')

# Symlink 'latest' dir to point to the latest results
os.symlink(results_path, '../results/latest')


profile_data = {}

# Write new results to timestamped folder
for depth in depths:
	for size in sizes:
		for node in range(0, len(nodes)):

			filename = "-".join([str(node), 'node', 'url', size, 'depth', depth])

			# Calculate the key indicators
			ret = run(os.path.join(latest_path, filename), str(node), str(size))

			if node not in profile_data:
				profile_data[node] = {}

			profile_data[node][size] = ret['profile']
			profile_file = os.path.join(results_path, str(node) + "-" + str(size) + '-profile')
			with open(profile_file, 'a') as prof:
				means = ret['profile']
				for tag in tags:
					if tag in means.keys():
						# print "\t".join([tag, str(means[tag][0]), str(means[tag][1]), str(means[tag][2]), "0.6", "\n"])
						prof.write("\t".join([tag, str(means[tag][0]), str(means[tag][1]), str(means[tag][2]), "\n"]))

			for name in types:
				outfile = os.path.join(results_path, name + "-" + str(size))

				with open(outfile, 'a') as out:
					# print outfile, "\t".join([ret['nodes'], str(ret[name][0]), str(ret[name][1]), str(ret[name][2])])
					if len(ret[name]) == 3:
						out.write("\t".join([ret['nodes'], str(ret[name][0]), str(ret[name][1]), str(ret[name][2]), "0.6", "\n"]))


tags_data = {}
for node in range(0, len(nodes)):
	profile_file = os.path.join(results_path, str(node) + '-' + 'profile-lines')
	with open(profile_file, 'a') as prof:
		prof.write("\t".join(["Index", "State", str(node) + "-256", "Min","Max", str(node) + "-512", "Min","Max","\n"]))
		for i, tag in enumerate(tags):
			is_first = True
			for size in sizes:
				if tag in profile_data[node][size]:
					tmp = profile_data[node][size][tag]
					if is_first:
						# print "\t".join([tag, str(tmp[0]), str(tmp[1]), str(tmp[2]), "0.6", "\n"])
						prof.write("\t".join([str(i+1), prettify(tag), str(tmp[0]), str(tmp[1]), str(tmp[2]), "\t"]))
						is_first = False
					else:
						# print "\t".join([str(tmp[0]), str(tmp[1]), str(tmp[2]), "0.6", "\n"])
						prof.write("\t".join([str(tmp[0]), str(tmp[1]), str(tmp[2]), "\t"]))

			# Write newline after each finished tag line
			if not is_first:
				prof.write("\n")

	# for item, values in profile_data[node].items():
	# 	# print item, values
	# 	for k, v in values.items():
	# 		if k not in tags_data:
	# 			tags_data[k] =  []
	# 		tags_data[k].append(v)

# for node in range(0, len(nodes)):
# 	for tag in tags:
# 		profile_file = os.path.join(results_path, str(node) + '-' + 'profile')
# 		with open(profile_file, 'a') as prof:
# 			if tag in profile_data[node]:
# 				# print profile_data[node][tag]
# 				tmp = profile_data[node][tag]
# 				prof.write("\t".join([tag, str(tmp[0]), str(tmp[1]), str(tmp[2]), "0.6", "\n"]))



