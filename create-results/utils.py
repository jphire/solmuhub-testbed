import os
import numpy as np
import scipy as sp
import scipy.stats
import json

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

def run(filename, nodes, size):
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

    return {'nodes':nodes, 'size':size, 'cpu':cpu, 'mem':mem, 'latency':latency, 'payload':payload, 'profile':means}


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

def prettify(tag):
    return tags_map[tag]


def getLatestTimestamp():
    latest = 0

    # Get latest log files' timestamped path
    for dirname, dirnames, filenames in os.walk('../logs/solmuhub'):
        for subdirname in dirnames:
            try:
                tmp = int(subdirname)
                latest = max(latest, tmp)
                latest_path = os.path.join(dirname, str(latest))
            except ValueError:
                continue

    return latest, latest_path

def configureTest(path):
    sizes = []
    nodes = []
    depths = []

    # Get node count and sizes from the logs
    for dirname, dirnames, filenames in os.walk(path):
        for name in filenames:
            try:
                nodeCount = name.split('-')[0]
                size = name.split('-')[3]
                depth = name.split('-')[5]
                if size not in sizes:
                    sizes.append(size)
                if nodeCount not in nodes:
                    print nodeCount
                    nodes.append(nodeCount)
                if depth not in depths:
                    depths.append(depth)
            except IndexError:
                continue
            except ValueError:
                continue

    # Sort sizes so that results are in correct format for plotting
    sizes.sort(key=int)
    depths.sort(key=int)
    nodes.sort(key=int)

    return sizes, nodes, depths
