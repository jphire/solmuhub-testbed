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

$ python create-results.py

'''

latest = 0
sizes = []
nodes = []
depths = []
types = ['cpu', 'mem', 'latency', 'payload', 'profile']
tags_zero = ['feed_fetched', 'after_data_fetch', 'execution_end', 'before_sending_response']
tags_multi = ['feed_fetched', 'after_data_fetch', 'after_data_map', 'piece_response_latency', 'dist_response_latency', 'after_reducer', 'before_sending_response', 'after_response']
tags = ['feed_fetched', 'after_data_fetch', 'execution_end', 'after_data_map', 'piece_response_latency', 'dist_response_latency', 'after_reducer', 'before_sending_response', 'after_response']
tags_map = {
	'feed_fetched':'Fetching-feed', 
	'after_data_fetch':'Fetching-data', 
	'execution_end':'Executing-code',
	'after_data_map':'Mapping-data',
	'piece_response_latency':'Hub-latency', 
	'dist_response_latency':'Gathering-all-responses', 
	'after_reducer':'Reducing-data', 
	'before_sending_response':'Formatting-response',
	'after_response':'Response-in-flight'
}

def mean_confidence_interval(data, confidence=0.95):
    a = 1.0 * np.array(data)
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
				if is_number(usage['cpu']):
					cpuData.append(usage['cpu'])
				memData.append(usage['mem'])
				latencyData.append(latency)
				# payload data
				if ('contentLength' in val[0]):
					content_length.append(val[0]['contentLength'])

				# profiling data
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
	return tags_map[tag]


# Get latest log files' timestamped path
for dirname, dirnames, filenames in os.walk('../logs/profiler'):
	for subdirname in dirnames:
		try:
			tmp = int(subdirname)
		except ValueError:
			continue

		latest = max(latest, tmp)
		latest_path = os.path.join(dirname, str(latest))

# Get node count and sizes from the logs
for dirname, dirnames, filenames in os.walk(latest_path):
	for name in filenames:
		try:
			nodeCount = name.split('-')[0]
			size = name.split('-')[3]
			depth = name.split('-')[5]
			if size not in sizes:
				sizes.append(size)
			if nodeCount not in nodes:
				nodes.append(nodeCount)
			if depth not in depths:
				depths.append(depth)
		except IndexError:
			continue

# Create new timestamped folder in results and remove old ones
results_path = '../results/' + str(latest)
if not os.path.exists(results_path):
	os.makedirs(results_path)
else:
	shutil.rmtree(results_path)
	os.makedirs(results_path)

if os.path.exists('../results/latest'):
	os.unlink('../results/latest')

# symlink latest to point to the latest results
os.symlink(results_path, '../results/latest')

# Sort sizes so that results are in correct format for plotting
sizes.sort(key=int)
depths.sort(key=int)


# Write new results to timestamped folder
profile_data = {}
latency_data = {}
cpu_data = {}
data = {'cpu':{}, 'mem':{}, 'latency':{}, 'payload':{}, 'profile':{}}

for depth in depths:
	for node in range(0, len(nodes)):
		is_first = True
		for size in sizes:

			filename = "-".join([str(node), 'node', 'url', size, 'depth', depth])
			ret = run(os.path.join(latest_path, filename), str(node), str(size))

			# Write the averages
			for name in types:
				if len(ret[name]) == 0:
					continue

				if node not in data[name]:
					data[name][node] = {}
				data[name][node][size] = ret[name]

				if name == 'profile':
					outfile = os.path.join(results_path, str(node) + "-" + str(size) + '-' + str(depth) + '-profile')
					# Write all profiling data
					with open(outfile, 'a') as out:
						profile = ret[name]
						# To keep correct order in tags, use list
						for tag in tags:
							if tag in profile.keys():
								# print "\t".join([tag, str(means[tag][0]), str(means[tag][1]), str(means[tag][2]), "0.6", "\n"])
								out.write("\t".join([tag, str(profile[tag][0]), str(profile[tag][1]), str(profile[tag][2]), "\n"]))
				else:
					outfile = os.path.join(results_path, name + ".out")

					with open(outfile, 'a') as out:
						# print outfile, "\t".join([ret['nodes'], str(ret[name][0]), str(ret[name][1]), str(ret[name][2])])
						if is_first:
							out.write("\t".join([ret['nodes'], str(ret[name][0]), str(ret[name][1]), str(ret[name][2]), "0.6", "\t"]))
						else:
							out.write("\t".join([str(ret[name][0]), str(ret[name][1]), str(ret[name][2]), "0.6", "\t"]))
			is_first = False
		for name in types:
			outf = os.path.join(results_path, name + ".out")
			with open(outf, 'a') as out:
				out.write("\n")

# Aggregate data to plottable files
tags_data = {}
for depth in depths:
	for node in range(0, len(nodes)):
		profile_file = os.path.join(results_path, str(node) + '-nodes-' + str(depth) + '-depth-profile-stacked')
		with open(profile_file, 'a') as prof:
			prof.write("Size\t")
			if node == 0:
				prof.write("\t".join(map(prettify, tags_zero)))
			else:
				prof.write("\t".join(map(prettify, tags_multi)))
			prof.write("\n")

			for size in sizes:
				prof.write(size + "\t")
				for i, tag in enumerate(tags_multi):
					if tag in data['profile'][node][size]:
						tmp = data['profile'][node][size][tag]
						prof.write("\t".join([str(tmp[0]), "\t"]))

				# Write newline after each finished tag line
				prof.write("\n")

