process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

var request = require('request').defaults({
	strictSSL: false,
        rejectUnauthorized: false,
        timeout: 120000
});
const fs = require('fs');
const async = require('async');
const winston = require('winston');
const path = require('path');
const loggers = require('../lib/loggers');

const nconf = require('nconf');



class Lib {
    constructor() {

    }

    /**
     * assignedPorts = [];
     * @param portsArray
     * @param maxDepth
     * @param nodesPerLevel
     * @param excludedPorts
     */
    static createDistributedNodes (urlsArray, portsArray, maxDepth, nodesPerLevel, excludedPorts) {

        let distributedNodesArray = [];

        if (maxDepth === 1) {
            // Flat structure, easy
            for (var url of urlsArray) {
                for (var port of portsArray) {
                    distributedNodesArray.push({url: url + ":" + port + "/api/feeds/executable/1/run"});

                }
            }
        } else if (maxDepth > 1 && maxDepth < 15) {
            // Use breadth-first style to assign nodes to a nested object
            let portsIndex = 0;
            let urlsIndex = 0;
            Lib.addDistributionLevel(urlsIndex, urlsArray, portsIndex, portsArray, distributedNodesArray, nodesPerLevel, 1);
        } else {
            throw new Error("Invalid maxDepth defined, must be between 1 and 15");
        }
        return distributedNodesArray;
    }

    static range (start, stop, step) {
        var a = [start], b = start;
        while (b < stop){
            b += step;
            a.push(b)
        }
        return a;
    }


    /**
     * Adds a level of nodes to the distributed nodes array, used for creating nested distribution objects
     * @param urlsIndex
     * @param urlsArray
     * @param portsIndex
     * @param portsArr
     * @param distributedNodesArray
     * @param perLevel
     * @param currentDepth
     * @returns {*}
     */
    static addDistributionLevel (urlsIndex, urlsArray, portsIndex, portsArr, distributedNodesArray, perLevel, currentDepth) {
        let addedNodesCount = 0;
        // First add nodes to this level
        for (let j = 0; j < urlsArray.length; j++) {
            for (let i = 0; i < perLevel; i++) {
                if (!portsArr[portsIndex]) {
                    throw new Error("Could not assign port to node: not enough ports reserved for use. You need approx " +
                        Math.pow(perLevel, maxDepth + 1) + " ports");
                }
                distributedNodesArray.push({url: urlsArray[urlsIndex] + ":" + portsArr[portsIndex] + "/api/feeds/executable/1/run"});
                //assignedPorts.push(portsArr[portsIndex]);
                portsIndex++;

                // Add next level to each node if needed
                if (currentDepth < maxDepth) {
                    let nextDepth = currentDepth + 1;
                    distributedNodesArray[i].nodes = [];
                    addedNodesCount += Lib.addDistributionLevel(urlsIndex, urlsArray, portsIndex, portsArr,
                        distributedNodesArray[i].nodes, perLevel, nextDepth);
                }

                portsIndex += addedNodesCount;
            }
        }
        return addedNodesCount + perLevel;
    }

    /**
     * Method for sending processing tasks to hubs
     * @param requestBody
     * @param params
     * @returns {Promise}
     */
    static sendRequest (requestBody, params) {
        process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

        let options = {
            method: 'POST',
            strictSSL: false,
            timeout: 120000,
            rejectUnauthorized: false,
            uri: params.uri,
            body: JSON.stringify(requestBody),
            headers: {
                'Content-Type': 'application/json'
            }
        };
        let timestamp = params.timestamp;
        let maxDepth = (requestBody.distribution && requestBody.distribution.maxDepth) || 0;

        return new Promise((resolve, reject) => {
            console.log('SEND', options)
            let start = new Date().getTime();
            process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
            request(options, function (error, response, body) {
                let end = new Date().getTime();
                console.log('RECEIVE', params.maxNodes, params.size, end-start);
                if (error) {
                    reject(error);
                } else if (response.statusCode !== 200 && response.statusCode !== 0) {
                    // generic.error('Error executing code on node: ', JSON.parse(body).error.message)
                    var err = new Error('Could not fetch defined data for feed : '
                        + response.body);
                    err.name = 'Data Error';
                    err.statusCode = err.status = response.statusCode;
                    console.log(body)
                    reject(err);
                } else {
                    // profiler.info(JSON.parse(body));
                    // TODO: add request-json file alongside results in log folder, for later inspection
                    let outfile = params.maxNodes + '-node-' + params.distType + '-' + params.size + '-depth-' + maxDepth;
                    let filename = '../logs/profiler/' + timestamp + '/' + outfile;
                    let output = JSON.parse(body);
                    output.profiler.latency = end-start;
                    output = JSON.stringify(output);

                    // Write results to log files
                    fs.appendFileSync(filename, output);
                    fs.appendFileSync(filename, "\n");
                    resolve({result:body});
                }
            });
        });
    };

    /**
     *
     * @param requestConf
     * @param maxNodes
     * @param size
     * @param distributedNodesArray
     * @returns {Promise}
     */
    static run (requestConf, maxNodes, size, distributedNodesArray, timestamp)  {
        process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

        let reqBody = requestConf.request;

        // replace SIZE in url with the current requested size
        reqBody.data[0].url = requestConf.imageServerUrl.replace(/SIZE/g, size);

        if (maxNodes > 0) {
            reqBody.distribution.enabled = true;
            reqBody.distribution.nodes = distributedNodesArray.slice(0, maxNodes);
            reqBody.data[0].maxNodes = maxNodes;
        } else {
            reqBody.distribution.enabled = false;
            reqBody.distribution.nodes = [];
        }

        let params = {
            maxNodes: maxNodes,
            size: size,
            timestamp: timestamp,
            uri: requestConf.controller.url + ':' + requestConf.controller.port + requestConf.runPath
        }
        if (reqBody.data[0].type === 'remote') {
            params.distType = 'url';
        } else {
            params.distType = 'data';
        }
        return Lib.sendRequest(reqBody, params);

        // Send requests to all hubs in parallel. Note that if the hubs are
        // located on the same node, performance starts to go down if there are more
        // hubs specified than cores to execute.
        // Promise.all(hubs.map(sendRequest)).then((values) => {
        //     cb(null, values);
        // });
    }

    static loadList (confs, distributedNodesArray, timestamp) {
        let list = [];

        // Create array of promises, which are then executed serially using async library.
        // Loop up to nodeCount, 0 nodeCount means no distribution
        for (let testConf of confs) {
            let maxNodesArr = testConf.maxNodesArr || [0];
            let reqCount = testConf.requestsPerType || 3;
            for (let size of testConf.sizes) {
                for (let maxNodes of maxNodesArr) {
                    for (var j = 0; j < reqCount; j++) {
                        list.push(function (callback) {
                            Lib.run(testConf, maxNodes, size, distributedNodesArray, timestamp).then(
                                (res) => callback(null, res),
                                (err) => {
                                    console.log('Error', err)
                                }
                            );
                        });
                    }
                }
            }
        }
        async.series(list, (err, results) => {
            if (err) {
                err.message = 'Could not run loadList: ' + err.message;
                throw err;
            }
        });
    }

    static runTest(options) {
        let nodes = JSON.parse(JSON.stringify(options.confs[0].request.distribution.nodes));

        Lib.loadList(options.confs, nodes, options.timestamp);
    }

}

module.exports = Lib;
