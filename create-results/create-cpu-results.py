import os
import sys
import getopt

'''
This script is used to calculate the average CPU usage.

Example usage:

$ python create-results.py -d <urlMapped> -n <depth>

'''

latest = 0
sizes = []
nodes = []
depths = []
results_path = ''
sources_path = ''
mapping = 'url'
cpu_file_name = 'cpu.out'
depth = 1

try:
    argv = sys.argv[1:]
    opts, args = getopt.getopt(argv, "d:n:")
except getopt.GetoptError:
    print 'Usage: create-cpu-results.py -d <source_path> -n <depth>'
    sys.exit(2)

for opt, arg in opts:
    if opt == '-d':
        sources_path = '../results/' + str(arg)
        results_path = '../results/' + str(arg)
    elif opt == '-n':
        depth = int(arg)

if results_path == '':
    print 'Usage: create-cpu-results.py -d <source_path> -n <depth>'
    sys.exit(2)
if depth not in [1, 2, 3]:
    print 'Depth must be 1, 2 or 3'
    sys.exit(2)

print 'Source files > ' + sources_path
print 'Result files > ' + results_path

sizes = [256, 512, 1024]

if (depth == 1):
    nodes = [0, 2, 4, 8, 16, 32]
elif (depth == 2):
    nodes = [0, 4, 8, 16, 32]
elif (depth == 3):
    nodes = [0, 8, 16, 32]

# Create new folder in results and remove old ones
if not os.path.exists(results_path):
    sys.exit(1)

# Write new results to the results folder
latency_data = {}
cpu_data = {}

cpufile = os.path.join(results_path, "cpu.out")
processed_cpu_file = os.path.join(results_path, "processed-cpu.out")

with open(cpufile, 'r') as cpu:
    for line in cpu:
        tmp = line.split('\t')
        cpu_data[tmp[0]] = []
        # 1 is index of CPU for 256, 5 for 512 and so on
        cpu_data[tmp[0]].append(tmp[1])
        cpu_data[tmp[0]].append(tmp[6])
        cpu_data[tmp[0]].append(tmp[11])

with open(processed_cpu_file, 'w') as out:
    for node in nodes:
        node = int(node)
        relative_cpu_time = 1
        filename = "-".join([str(node), 'nodes', str(depth), 'depth-profile-stacked'])
        latencyfile = os.path.join(results_path, filename)

        out.write(str(node))

        with open(latencyfile, 'r') as lat:
            for num, line in enumerate(lat, 1):
                if num == 1:
                    continue
                if node == 0:
                    lat_arr = line.split('\t')
                    exec_factor = 1
                    relative_cpu_time = float(cpu_data[str(node)][num-2]) * exec_factor
                    out.write("\t" + str(relative_cpu_time))
                else:
                    lat_arr = line.split('\t')
                    exec_factor = 1-((float(lat_arr[9]) - float(lat_arr[5]))/float(lat_arr[15]))
                    relative_cpu_time = float(cpu_data[str(node)][num-2]) * exec_factor
                    out.write("\t" + str(relative_cpu_time))

        out.write("\n")
print "Done"

