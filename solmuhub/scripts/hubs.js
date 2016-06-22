'use strict'

const exec = require('child_process').spawn;
const execute = require('child_process').exec;
const conf = require('./conf.json');
const createExecFeed = require('./requests/createExecFeed.json');
const request = require('request');

let hubExecPath = conf.paths.hubs_path;
let executableFeedUrl = conf.urls.executableUrl;
let children = [];
let ports = conf.ports;

process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

if (process.argv[2] == 'up') {
	console.log('Setting hubs up');
	let child;
	ports.forEach((port) => {
		let options = {
			cwd: hubExecPath
			// execPath: 'index.js'
			// execArgv: ['--profile', '--port=' + hub.port]
		}
		let url = conf.urls.baseUrl + ':' + port + conf.urls.urlSuffix;
		console.log('Hub up at: ' + port);
		child = exec('node', ['index', '--profiler', '--port=' + port], options);
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
						console.log('Could not create exectuable feed: ' + err.message)
					} else {
						console.log('Created executable feed for hub in port ' + port)
					}
				});
			}
			
		});

		child.stderr.on('data', (err) => {
			console.log(err.toString('utf8'));
		})
		children.push(child);
	});

} else if (process.argv[2] == 'down') {
	console.log('Shutting hubs down');
	hubs.forEach((hub) => {
		execute(`lsof -i tcp:${` + hub.port + `} | awk 'NR!=1 {print $2}' | xargs kill`);
	});
	console.log('All hubs shutdown')
}
