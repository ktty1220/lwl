var vows = require('vows');
var assert = require('assert');
var fs = require('fs');
var util = require('util');
var lwl = require('../lib/lwl');

var defaultLogFile = './lwl.log';
var logLevels = ['debug', 'info', 'notice', 'warn', 'error', 'crit', 'alert', 'emerg'];

function logParse(log) {
  var line = log.trim().split('\n');
  var parses = [];
  for (var l = 0; l < line.length; l++) {
    var p = line[l].match(/^([\d\-]+)\s+([\d:]+)\s+([^\s]+)\s+\[(\w+)\]\s+(.+)$/);
    parses.push({
      orig: line[l],
      date: p[1],
      time: p[2],
      filename: p[3],
      level: p[4],
      message: p[5]
    });
  }
  return parses;
}

vows.describe('lwl test')
.addBatch({
  'logFile: デフォルト': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      var retval = lwl.error('logFile: デフォルト');
      return {
        retval: retval,
        log: logParse(fs.readFileSync(defaultLogFile, 'utf-8'))
      }
    },
    './lwl.logに1行書き出される': function (topic) {
      assert.equal(topic.log.length, 1);
    },
    'メッセージは"logFile: デフォルト"': function (topic) {
      assert.equal(topic.log[0].message, 'logFile: デフォルト');
    },
    '出力時の戻り値とログに出力されたメッセージが同一': function (topic) {
      assert.equal(topic.log[0].orig, topic.retval);
    }
  }
})
.addBatch({
  'logFile: "-"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = '-';
      lwl.error('logFile: "-"');
      return fs.existsSync(defaultLogFile)
    },
    '標準出力に表示される': function (topic) {
      assert.isFalse(topic);
    }
  }
})
.addBatch({
  'logFile: null': {
    topic: function () {
      lwl.logFile = null;
      var retval = lwl.error('logFile: null');
      return {
        retval: retval,
        log: fs.existsSync(defaultLogFile)
      }
    },
    '出力されない': function (topic) {
      assert.isFalse(topic.log);
    },
    '出力時の戻り値はある': function (topic) {
      var parsed = logParse(topic.retval);
      assert.equal(parsed.length, 1);
      assert.equal(parsed[0].message, 'logFile: null');
    },
  }
})
.addBatch({
  'message: なし': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      var retval = lwl.error();
      return {
        retval: retval,
        log: fs.existsSync(defaultLogFile)
      }
    },
    '出力されない': function (topic) {
      assert.isFalse(topic.log);
    },
    '出力時の戻り値もなし': function (topic) {
      assert.isUndefined(topic.retval);
    }
  }
})
.addBatch({
  'message: null': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      var retval = lwl.error(null);
      return {
        retval: retval,
        log: fs.existsSync(defaultLogFile)
      }
    },
    '出力されない': function (topic) {
      assert.isFalse(topic.log);
    },
    '出力時の戻り値もなし': function (topic) {
      assert.isUndefined(topic.retval);
    }
  }
})
.addBatch({
  'message: undefined': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      var retval = lwl.error(undefined);
      return {
        retval: retval,
        log: fs.existsSync(defaultLogFile)
      }
    },
    '出力されない': function (topic) {
      assert.isFalse(topic.log);
    },
    '出力時の戻り値もなし': function (topic) {
      assert.isUndefined(topic.retval);
    }
  }
})
.addBatch({
  'message: undefined or null複数': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      var retval = lwl.error(undefined, null);
      return {
        retval: retval,
        log: logParse(fs.readFileSync(defaultLogFile, 'utf-8'))
      }
    },
    './lwl.logに1行書き出される': function (topic) {
      assert.equal(topic.log.length, 1);
    },
    'メッセージは"undefined null"': function (topic) {
      assert.equal(topic.log[0].message, 'undefined null');
    },
    '出力時の戻り値とログに出力されたメッセージが同一': function (topic) {
      assert.equal(topic.log[0].orig, topic.retval);
    }
  }
})
.addBatch({
  'message: 文字列': {
    topic: function () {
      lwl.logFile = null;
      return logParse(lwl.error('message: 文字列'))[0];
    },
    '囲みクォーテーションが除去された状態で出力される': function (topic) {
      assert.equal(topic.message, 'message: 文字列');
    }
  }
})
.addBatch({
  'message: 整数': {
    topic: function () {
      return logParse(lwl.error(100))[0];
    },
    'そのまま出力される': function (topic) {
      assert.equal(topic.message, 100);
    }
  }
})
.addBatch({
  'message: 小数': {
    topic: function () {
      return logParse(lwl.error(0.00999009))[0];
    },
    'そのまま出力される': function (topic) {
      assert.equal(topic.message, 0.00999009);
    }
  }
})
.addBatch({
  'message: true': {
    topic: function () {
      return logParse(lwl.error(true))[0];
    },
    '文字列"true"が出力される': function (topic) {
      assert.equal(topic.message, 'true');
    }
  }
})
.addBatch({
  'message: false': {
    topic: function () {
      return logParse(lwl.error(false))[0];
    },
    '文字列"false"が出力される': function (topic) {
      assert.equal(topic.message, 'false');
    }
  }
})
.addBatch({
  'message: 配列': {
    topic: function () {
      var msg = [ 'aaa', 'bbb', 111, 222, 333, 'ccc' ];
      return {
        msg: msg,
        log: logParse(lwl.error(msg))[0]
      }
    },
    '展開されて出力される': function (topic) {
      assert.equal(util.inspect(topic.msg, false, null), topic.log.message);
    }
  }
})
.addBatch({
  'message: 配列内のundefined or null': {
    topic: function () {
      var msg = [ 'aaa', 'bbb', undefined, 111, 222, null, 333, 'ccc' ];
      return {
        msg: msg,
        log: logParse(lwl.error(msg))[0]
      }
    },
    'undefinedが含まれている': function (topic) {
      assert.equal(util.inspect(topic.msg, false, null), topic.log.message);
      assert.isUndefined(topic.msg[2]);
    },
    'nullが含まれている': function (topic) {
      assert.isNull(topic.msg[5]);
    }
  }
})
.addBatch({
  'message: オブジェクト': {
    topic: function () {
      var msg = { aaa: 1000, bbb: 'xxx', ccc: 0.05, ddd: '999' };
      return {
        msg: msg,
        log: logParse(lwl.error(msg))[0]
      }
    },
    '展開されて出力される': function (topic) {
      assert.equal(util.inspect(topic.msg, false, null), topic.log.message);
    }
  }
})
.addBatch({
  'message: オブジェクト内のundefined or null': {
    topic: function () {
      var msg = { aaa: 1000, bbb: undefined, ccc: 0.05, ddd: null };
      return {
        msg: msg,
        log: logParse(lwl.error(msg))[0]
      }
    },
    'undefinedが含まれている': function (topic) {
      assert.equal(util.inspect(topic.msg, false, null), topic.log.message);
      assert.isUndefined(topic.msg.bbb);
    },
    'nullが含まれている': function (topic) {
      assert.isNull(topic.msg.ddd);
    }
  }
})
.addBatch({
  'message: 配列内のオブジェクト': {
    topic: function () {
      var msg = [ { aaa: 111, bbb: 222 }, { ccc: 333, ddd: 444 } ];
      return {
        msg: msg,
        log: logParse(lwl.error(msg))[0]
      }
    },
    '全て展開されて出力される': function (topic) {
      assert.equal(util.inspect(topic.msg, false, null), topic.log.message);
    }
  }
})
.addBatch({
  'message: オブジェクト内の配列': {
    topic: function () {
      var msg = { aaa: [ 'xxx', 'yyy', 111 ], bbb: [ 'www', 0.932, '888' ] };
      return {
        msg: msg,
        log: logParse(lwl.error(msg))[0]
      }
    },
    '全て展開されて出力される': function (topic) {
      assert.equal(util.inspect(topic.msg, false, null), topic.log.message);
    }
  }
})
.addBatch({
  'logLevel: "emerg"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'emerg';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"emerg"以外のログは出力されない': function (topic) {
      assert.equal(topic.length, 1);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "alert"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'alert';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"alert"未満のログは出力されない': function (topic) {
      assert.equal(topic.length, 2);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "crit"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'crit';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"crit"未満のログは出力されない': function (topic) {
      assert.equal(topic.length, 3);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "error"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'error';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"error"未満のログは出力されない': function (topic) {
      assert.equal(topic.length, 4);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "warn"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'warn';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"warn"未満のログは出力されない': function (topic) {
      assert.equal(topic.length, 5);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "notice"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'notice';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"notice"未満のログは出力されない': function (topic) {
      assert.equal(topic.length, 6);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "info"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'info';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '"info"未満のログは出力されない': function (topic) {
      assert.equal(topic.length, 7);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    }
  }
})
.addBatch({
  'logLevel: "debug"': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'debug';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '全てのログが出力される': function (topic) {
      assert.equal(topic.length, 8);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    },
    teardown: function (topic) {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
    }
  }
})
.addBatch({
  'logLevel: "unknown"(規定外のレベル)': {
    topic: function () {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
      lwl.logFile = defaultLogFile;
      lwl.logLevel = 'unknown';
      for (var ll = 0; ll < logLevels.length; ll++) {
        lwl[logLevels[ll]](logLevels[ll]);
      }
      return logParse(fs.readFileSync(defaultLogFile, 'utf-8'));
    },
    '全てのログが出力される': function (topic) {
      assert.equal(topic.length, 8);
      for (var ll = 0; ll < topic.length; ll++) {
        assert.equal(topic[ll].level, logLevels[logLevels.length - topic.length + ll]);
      }
    },
    teardown: function (topic) {
      if (fs.existsSync(defaultLogFile)) {
        fs.unlinkSync(defaultLogFile);
      }
    }
  }
}).export(module);

