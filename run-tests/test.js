'use strict';

/**
 * This script is used to run the Solmuhub tests on multiple IoT hubs. Usage: 
 * $ node test.js [requestCount] [hubCount] [imageSize]
 * where requestCount is the amount of request sent for one test type, hubCount is
 * total amount of hubs and imageSize is the amount of pixels per side in test data.
 */

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

const request = require('request').defaults({ 
        strictSSL: false,
        rejectUnauthorized: false,
        timeout: 120000
});
const fs = require('fs');
const async = require('async');
const winston = require('winston');
const path = require('path');
const loggers = require('../lib/loggers');
const mkdirSync = require('../lib/mkdirSync');
const Lib = require('./lib');

const nconf = require('nconf');
nconf.env().argv();

try {
    let confFile;
    if (confFile = nconf.get('conf')) {
        fs.accessSync(confFile, fs.F_OK);
        nconf.file('./' + confFile);
    }
    else {
        confFile = './conf.json';
        fs.accessSync(confFile, fs.F_OK);
        nconf.file(confFile);
    }
} catch (e) {
    throw new Error("Invalid configuration file specified: " + confFile);
}

nconf.required(['solmuhub']);
let conf = nconf.get('solmuhub');
let timestamp = Date.now() + '';

try {
    mkdirSync.do(path.join(__dirname, '../logs', 'profiler', timestamp+''));
    mkdirSync.do(path.join(__dirname, '../logs', 'profiler', timestamp + '/spec'));
} catch (e) {
    e.message = 'Could not create the logs directory: ' + e.message;
    throw e;
}

// Initialize loggers
loggers.generic.forEach((logger, index, arr) => {
    logger.transports.file.filename = path.join(__dirname, '../logs/generic', timestamp, 'local');
    winston.loggers.add(logger.name, logger.transports);
});

loggers.profiler.forEach((logger, index, arr) => {
    logger.transports.file.filename = path.join(__dirname, '../logs/profiler', timestamp, 'local');
    winston.loggers.add(logger.name, logger.transports);
});

const profiler = winston.loggers.get('profiler');
const generic = winston.loggers.get('generic');
// var reqDataPath = '../requests/' + nconf.get('data') + '-data';

// Get test configuration files to be used in test. An array of confs to be run serially on all nodes
const testFiles = conf.testRunFiles;
let testConfs = testFiles.map((req) => {
    // Write test configuration to spec file
    let testSpecFile = req + '.json';
    let filename = '../logs/profiler/' + timestamp + '/spec/' + testSpecFile;
    // Write results to log files
    fs.createReadStream('../requests/' + req + '.json').pipe(fs.createWriteStream(filename));

    return require('../requests/' + req);

});

let options = {
    confs: testConfs,
    timestamp: timestamp
}

// Run tests
Lib.runTest(options);

