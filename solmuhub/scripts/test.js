'use strict';

/**
 * This script is used to run the Solmuhub tests on multiple IoT hubs. Usage: 
 * $ node test.js [requestCount] [hubCount] [imageSize]
 * where requestCount is the amount of request sent for one test type, hubCount is
 * total amount of hubs and imageSize is the amount of pixels per side in test data.
 */

var request = require('request');
var fs = require('fs');
var async = require('async');
var winston = require('winston');
var path = require('path');
var loggers = require('../lib/loggers');
var mkdirSync = require('../lib/mkdirSync');

let nconf = require('nconf')
nconf.env().argv();

if (nconf.get('type') === 'remote') {
    nconf.file('./remote-conf.json');
} else {
    nconf.file('./conf.json');
}

nconf.required(['solmuhub']);

let conf = nconf.get('solmuhub');

var timestamp = Date.now() + '';
mkdirSync.do(path.join(__dirname, '../logs', 'profiler', timestamp+''));

// Initialize loggers
loggers.generic.forEach((logger, index, arr) => {
    logger.transports.file.filename = path.join(__dirname, '../logs/generic', timestamp, 'local');
    winston.loggers.add(logger.name, logger.transports);
});

loggers.profiler.forEach((logger, index, arr) => {
    logger.transports.file.filename = path.join(__dirname, '../logs/profiler', timestamp, 'local');
    winston.loggers.add(logger.name, logger.transports);
});

var profiler = winston.loggers.get('profiler');
var generic = winston.loggers.get('generic');
var reqDataPath = '../requests/' + nconf.get('data') + '-data';
var reqBody = require(reqDataPath);
var requestNodes = []

// Array of ports to be excluded from the nodes list
var exclude = [3000, 4000];
var range = function (start, stop, step) {
    var a=[start], b=start;
    while(b<stop){b+=step;a.push(b)}
    return a;
};

var reqCount = nconf.get('reqCount') || 3;
var nodeCount = nconf.get('nodeCount') || 3;

var sizes = [256, 512, 1024];

// Create array 
let arr = range(3300, 5300, 100);
for (var i in arr) {
    if (exclude.indexOf(arr[i]) == -1) {
        let url = { url: "https://localhost:" + arr[i] + "/api/feeds/executable/1/run" };
        requestNodes.push(url);
    }
}

// Function for sending processing tasks to hubs
var sendRequest = function (requestBody, params) {
    var responses = [];
    var options = {
        method: 'POST',
        uri: conf.controller.url + ':' + conf.controller.port + conf.runPath,
        body: JSON.stringify(requestBody),
        headers: {
            'Content-Type': 'application/json'
        }
    }
    
    return new Promise((resolve, reject) => {
        console.log('SEND', params.nodeCount, params.size)
        let start = new Date().getTime();
        request(options, function (error, response, body) {
            let end = new Date().getTime();
            console.log('RECEIVE', params.nodeCount, params.size, end-start);
            if (error) {
                reject(error);
            } else if (response.statusCode !== 200 && response.statusCode !== 0) {
                // generic.error('Error executing code on node: ', JSON.parse(body).error.message)
                var err = new Error('Could not fetch defined data for feed : ' 
                    + response);
                err.name = 'Data Error';
                err.statusCode = err.status = response.statusCode;
                console.log(body)
                reject(err);
            } else {
                // profiler.info(JSON.parse(body));
                let outfile = params.nodeCount + '-node-' + params.size; 
                let filename = '../logs/profiler/' + timestamp + '/' + outfile;
                let output = JSON.parse(body);
                output.profiler.latency = end-start;
                output = JSON.stringify(output);
                fs.appendFileSync(filename, output);
                fs.appendFileSync(filename, "\n");
                resolve({result:body});
            }
        });
    });
}

var run = function (nodeCount, size)  {
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
    
    // replace SIZE in url with the current requested size
    reqBody.data[0].url = "http://localhost:4000/api/feeds/executable/1?size=" + size + "&nodes=1&index=1";
    // somehow this does not work:
    //reqBody.data[0].url.replace(/SIZE/g, size);
    
    if (nodeCount > 0) {
        reqBody.distribution.enabled = true;
        reqBody.distribution.nodes = requestNodes.slice(0, nodeCount);
    } else {
        reqBody.distribution.enabled = false;
        reqBody.distribution.nodes = [];
    }
    console.log(reqBody.distribution.nodes, nodeCount)
    let params = {
        nodeCount: nodeCount,
        size: size
    }
    return sendRequest(reqBody, params);

    // Send requests to all hubs in parallel. Note that if the hubs are
    // located on the same node, performance starts to go down if there are more 
    // hubs specified than cores to execute.
    // Promise.all(hubs.map(sendRequest)).then((values) => {
    //     cb(null, values);
    // });
}


let loadList = function (index) {

    let list = []
    // We want to loop up to nodeCount, 0 nodeCount means no distribution
    for (var i = 0; i <= nodeCount; i++) {
        for (var j = 0; j < reqCount; j++) {
            let nodeCount = i;
            list.push(function (callback) {
                run(nodeCount, sizes[index]).then(
                    (res) => callback(null, res), 
                    (err)=> {console.log('Error', err)}
                );
            });
        }
    }

    async.series(list, (err, results) => {
        console.log(sizes[index] + ' done')
        index++;
        if (index < sizes.length) {
            loadList(index, sizes);
        }
    });
}

loadList(0);


