/*jshint node:true, noarg:false, strict:false, loopfunc:true, immed:false */
/*global __stack */

/**
 * add __stack and __line to global
 *
 * ref: http://stackoverflow.com/questions/11386492/accessing-line-number-in-v8-javascript-chrome-node-js
 */
Object.defineProperty(global, '__stack', {
  get: function () {
    var orig = Error.prepareStackTrace;
    Error.prepareStackTrace = function (_, stack) { return stack; };
    var err = new Error();
    Error.captureStackTrace(err, arguments.callee);
    var stack = err.stack;
    Error.prepareStackTrace = orig;
    return stack;
  }
});

Object.defineProperty(global, '__line', {
  get: function () {
    return __stack[1].getLineNumber();
  }
});

require('date-utils');
var util = require('util');
var fs = require('fs');

/**
 * log output module
 */
var lwl = {
  logLevel: 'warn',
  logFile: './lwl.log'
};

/**
 * log output function
 *
 * ref: http://memo.yomukaku.net/entries/jfugzXU
 */
var loglevels = ['debug', 'info', 'notice', 'warn', 'error', 'crit', 'alert', 'emerg'];
function _log(msg, level) {
  if (msg !== undefined && (!level || loglevels.indexOf(level) >= loglevels.indexOf(lwl.logLevel))) {
    var timestamp = new Date().toFormat('YYYY-MM-DD HH24:MI:SS');
    var file = __stack[2].getFileName().match(/([^\\\/]*)$/)[1];
    var line = __stack[2].getLineNumber();
    var output = util.format('%s %s:%s [%s] %s', timestamp, file, line, level || lwl.logLevel, msg);
    if (lwl.logFile) {
      if (lwl.logFile === '-') {
        console.log(output);
      } else {
        fs.appendFileSync(lwl.logFile, output + '\n');
      }
    }
    return output;
  }
}

/**
 * add log level name function to lwl
 */
for (var l = 0; l < loglevels.length; l++) {
  lwl[loglevels[l]] = function (level) {
    return function () {
      var msg;
      if (arguments.length <= 1 && (arguments[0] === undefined || arguments[0] === null)) {
        msg = undefined;
      } else {
        var args = [];
        for (var a = 0; a < arguments.length; a++) {
          var v = util.inspect(arguments[a], false, null);
          if (typeof(arguments[a]) === 'string') {
            v = v.match(/^'(.+)'$/, '$1')[1];
          }
          args.push(v);
        }
        msg = args.join(' ');
      }
      return _log(msg, level);
    };
  } (loglevels[l]);
}

module.exports = lwl;
