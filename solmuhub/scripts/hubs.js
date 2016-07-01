'use strict'

const exec = require('child_process').spawn;
const execute = require('child_process').exec;
const remoteConf = require('./remote-conf.json');
const createExecFeed = require('./requests/createExecFeed.json');
const request = require('request');

let children = [];

let nconf = require('nconf')
nconf.argv();

if (nconf.get('type') === 'remote') {
	nconf.file('./remote-conf.json');
} else {
	nconf.file('./conf.json');
}

nconf.required(['solmuhub']);

let conf = nconf.get('solmuhub');
let hubs = conf.nodes;
let controller = conf.controller;
let ports = conf.ports;

let hubExecPath = conf.paths.hubsPath;
let executableFeedUrl = conf.controller.url + ':' + conf.controller.port + '/api/feeds/executable';

console.log(nconf.get('solmuhub').nodes[1])

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

if (nconf.get('type') === 'remote') {
	console.log('Setting up remote hubs');
	let hubs = conf.nodes;
	hubs.forEach((hub) => {
		let url = hub.url + ':' + hub.port + conf.runPath;
		let opts = {
			method: 'POST',
	        uri: url,
	        body: JSON.stringify(createExecFeed),
	        headers: {
	            'Content-Type': 'application/json'
	        }
		}
		request(opts, (err, res, body) => {
			if (err || body.error) {
				console.log('Could not create executable feed to host ' + hub.url + ' in port ' + hub.port + '. Error: ' + err.message)
			} else {
				console.log('Created executable feed for hub ' + hub.url + ' in port ' + hub.port)
			}
		});
	});
	
} else {
	console.log('Setting local hubs up');

	let child;
	hubs.forEach((hub) => {
		let options = {
			cwd: hubExecPath
			// execPath: 'index.js'
			// execArgv: ['--profile', '--port=' + hub.port]
		}
		let url = hub.url + ':' + hub.port + conf.runPath;
		console.log('Hub up at: ' + hub.port);
		child = exec('node', ['index', '--profiler', '--port=' + hub.port], options);
		// console.log(child)
		child.stdout.on('data', function (data) {
			console.log(data.toString('utf8'));
			let str = data.toString('utf8');
			if (str.startsWith('Web server listening at')) {
				let opts = {
					method: 'POST',
			        uri: url,
			        body: JSON.stringify(createExecFeed),
			        headers: {
			            'Content-Type': 'application/json'
			        }
				}
				request(opts, (err, res, body) => {
					if (err || body.error) {
						console.log('Could not create executable feed: ' + err.message)
					} else {
						console.log('Created executable feed for hub in port ' + hub.port)
					}
				});
			}
			
		});

		child.stderr.on('data', (err) => {
			console.log(err.toString('utf8'));
		})
		children.push(child);
	});
}
