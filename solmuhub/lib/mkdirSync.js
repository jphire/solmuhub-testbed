var fs    = require('fs')
  , path  = require('path');

var mkdirSync = function (path) {
  try {
    fs.mkdirSync(path);
  } catch(e) {
    if ( e.code != 'EEXIST' ) throw e;
  }
}

module.exports = {
	do: mkdirSync
}
