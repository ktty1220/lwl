/*jshint white:false, eqnull:true, immed:false, node:true */

// Generated by CoffeeScript 1.6.3
(function() {
  var lwl, test,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  lwl = require('../../../lib/lwl');

  lwl.logFile = '../../lwl.log';

  lwl.logLevel = 'info';

  test = function() {
    var ClassB, a, c, funcB;
    lwl.warn('test warn');
    a = (function() {
      return lwl.error('<anonymous> error');
    })();
    funcB = function() {
      return lwl.info('funcB info');
    };
    funcB();
    ClassB = (function() {
      function ClassB() {
        this.methodB = __bind(this.methodB, this);
        lwl.crit('ClassB crit');
      }

      ClassB.prototype.methodB = function() {
        return lwl.emerg('ClassB.methodB emerg');
      };

      return ClassB;

    })();
    c = new ClassB();
    return c.methodB();
  };

  module.exports = test;

}).call(this);