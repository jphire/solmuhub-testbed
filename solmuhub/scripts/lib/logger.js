'use strict'

var winston = require('winston');
var path = require('path');
// winston.emitErrs = true;


module.exports = logger;
module.exports.stream = {
    write: function(message, encoding){
        logger.info(message);
    }
};