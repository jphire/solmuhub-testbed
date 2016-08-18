var monitor = require('os-monitor');
var winston = require('winston');

monitor.start({ delay: 3000 // interval in ms between monitor cycles 
              , freemem: 1000000000 // freemem under which event 'freemem' is triggered 
              , uptime: 1000000 // number of secs over which event 'uptime' is triggered 
              , critical1: 3.0 // loadavg1 over which event 'loadavg1' is triggered 
              , critical5: 2.5 // loadavg5 over which event 'loadavg5' is triggered 
              , critical15: 2.2 // loadavg15 over which event 'loadavg15' is triggered 
              , silent: false // set true to mute event 'monitor' 
              , stream: false // set true to enable the monitor as a Readable Stream 
              , immediate: false // set true to execute a monitor cycle at start() 
              });
 
 
// define handler that will always fire every cycle 
monitor.on('monitor', function(event) {
  console.log(event.type, ' Monitor event');
});
 
// define handler for a too high 1-minute load average 
monitor.on('loadavg1', function(event) {
  console.log(event.type, 'ALARM: Load average 1 high: ' + event.loadavg[0]);
});
 
// define handler for a too low free memory 
monitor.on('freemem', function(event) {
  console.log(event.type, 'ALARM: Free memory low: ' + event.freemem/event.totalmem);
});
 
// define a throttled handler, using Underscore.js's throttle function (http://underscorejs.org/#throttle) 
// monitor.throttle('loadavg5', function(event) {
 
  // whatever is done here will not happen 
  // more than once every 5 minutes(300000 ms) 
 
// }, monitor.minutes(5));
 
 
// change config while monitor is running 
monitor.config({
  freemem: 0.1 // alarm when 30% or less free memory available 
});
