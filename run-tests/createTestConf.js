

//Array of ports to be excluded from the nodes list. TODO: change to be configurable
let excludedPorts = conf.excludedPorts;

let reqCount = nconf.get('reqCount') || 3;
let nodeCount = nconf.get('nodeCount') || 3;
let maxDepth = nconf.get('maxDepth') || 1;
let portStep = nconf.get('portStep') || 100;
let startPort = nconf.get('startPort') || 3300;
let endPort = nconf.get('endPort') || 5300;
let nodesPerLevel = nconf.get('nodesPerLevel') || 2;


let distributedNodesArray;
let portsArray = Lib.range(startPort, endPort, portStep);


addDistributionLevel(0, portsArray, distributedNodesArray, 2, 1);
console.log(JSON.stringify(distributedNodesArray));
console.log(assignedPorts.length);
process.exit(1);

// Create array of objects that describes hubs used in distributing
distributedNodesArray = Lib.createDistributedNodes(portsArray, maxDepth, nodesPerLevel, excludedPorts);

console.log(distributedNodesArray);

