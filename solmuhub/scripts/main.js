'use strict';

var request = require('request');
var fs = require('fs');
var conf = require('./conf.json');
var async = require('async');
var winston = require('winston');
var path = require('path');
var loggers = require('./lib/loggers');
var mkdirSync = require('./lib/mkdirSync');


var timestamp = Date.now() + '';
mkdirSync.do(path.join(__dirname, '../logs', 'profiler', timestamp+''));

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

var reqOptions = require('./requests/image-processing');

var sendRequest = function (requestBody, params) {
    var responses = [];
    var options = {
        method: 'POST',
        uri: conf.urls.controllerUrl + '/1/run',
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
                generic.error('Error executing code on node: ', JSON.parse(body).error.message)
                var err = new Error('Could not fetch defined data for feed : ' 
                    + response);
                err.name = 'Data Error';
                err.statusCode = err.status = response.statusCode;
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
    let reqBody = require('./requests/image-processing');
    let nodes = conf.nodes;
    reqBody.data[0].url = reqBody.data[0].url.replace(/SIZE/g, size);

    if (nodeCount > 0) {
        reqBody.distribution.enabled = true;
        reqBody.distribution.nodes = nodes.slice(0, nodeCount);
    }
    let params = {
        nodeCount: nodeCount,
        size: size
    }
    return sendRequest(reqBody, params);
    // .then((val) => {
    //     cb(null, val);
    // }, (err) => {cb(err)});
    // return Promise.resolve(reqP);
    // Send requests to all hubs in parallel. Note that if the hubs are
    // located on the same node, performance starts to go down if there are more 
    // hubs specified than cores to execute.
    // Promise.all(hubs.map(sendRequest)).then((values) => {
    //     cb(null, values);
    // });
}

var list = [];

var size = process.argv[3] || '512';
var nodeCount = process.argv[4] || 3;
var reqCount = process.argv[2] || 10;


// for (var k = 0; k < sizes.length; k++) {
    for (var i = 0; i < nodeCount; i++) {
        for (var j = 0; j < reqCount; j++) {
            let nodeCount = i;
            list.push(function (callback) {
                run(nodeCount, size).then(
                    (res) => callback(null, res), 
                    (err)=> {console.log('Error', err)}
                );
            });
        }
    }
// };

// Run tests serially
async.series(list);




