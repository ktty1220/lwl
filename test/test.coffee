vows = require 'vows'
assert = require 'assert'
fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'
util = require 'util'
lwl = require '../lib/lwl'

__cwd = path.dirname(__filename)
defaultLogFile = "#{__cwd}/lwl.log"
logLevels = [
  'debug'
  'info'
  'notice'
  'warn'
  'error'
  'crit'
  'alert'
  'emerg'
]

logParse = (log) ->
  line = log.trim().split '\n'
  parses = []
  for l in line
    p = l.match /^([\d\-]+)\s+([\d:]+)\s+([^@]+)@([^\s]+)\s+\[(\w+)\]\s+(.+)$/
    parses.push
      orig: l
      date: p[1]
      time: p[2]
      func: p[3]
      filename: p[4]
      level: p[5]
      message: p[6]
  #console.log parses
  parses

unlinkLog = (logFile = defaultLogFile) -> fs.unlinkSync defaultLogFile if fs.existsSync defaultLogFile
logExists = () -> fs.existsSync defaultLogFile

suite = vows.describe 'lwl test'

###*
* 基本テスト
###
suite.addBatch
  'logFile: デフォルト':
    topic: () ->
      lwl.logFile = defaultLogFile
      retval = lwl.error 'logFile: デフォルト'
      retval: retval, log: logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    './lwl.logに1行書き出される': (topic) =>
      assert.equal topic.log.length, 1
    'メッセージは"logFile: デフォルト"': (topic) =>
      assert.equal topic.log[0].message, 'logFile: デフォルト'
    '出力時の戻り値とログに出力されたメッセージが同一': (topic) =>
      assert.equal topic.log[0].orig, topic.retval

###*
* logFileの指定方法による出力の違いの検証
###
suite.addBatch
  'logFile: "-"':
    topic: () ->
      lwl.logFile = '-'
      lwl.error 'logFile: "-"'
      fs.existsSync defaultLogFile
    teardown: (topic) ->
      unlinkLog()
    '標準出力に表示される(コンソールにログ内容が出力されているか目で確認ｗ)': (topic) =>
      assert.isFalsentopic

suite.addBatch
  'logFile: null':
    topic: () ->
      lwl.logFile = null
      retval = lwl.error 'logFile: null'
      retval: retval, log: logExists()
    teardown: (topic) ->
      unlinkLog()
    '出力されない': (topic) =>
      assert.isFalse topic.log
    '出力時の戻り値はある': (topic) =>
      parsed = logParse(topic.retval)
      assert.equal parsed.length, 1
      assert.equal parsed[0].message, 'logFile: null'

###*
* ログに出力するメッセージの型の検証
###
suite.addBatch
  'message: なし':
    topic: () ->
      lwl.logFile = defaultLogFile
      retval = lwl.error()
      retval: retval, log: logExists()
    teardown: (topic) ->
      unlinkLog()
    '出力されない': (topic) =>
      assert.isFalse topic.log
    '出力時の戻り値もなし': (topic) =>
      assert.isUndefined topic.retval

suite.addBatch
  'message: null':
    topic: () ->
      lwl.logFile = defaultLogFile
      retval = lwl.error null
      retval: retval, log: logExists()
    teardown: (topic) ->
      unlinkLog()
    '出力されない': (topic) =>
      assert.isFalse topic.log
    '出力時の戻り値もなし': (topic) =>
      assert.isUndefined topic.retval

suite.addBatch
  'message: undefined':
    topic: () ->
      lwl.logFile = defaultLogFile
      retval = lwl.error undefined
      retval: retval, log: logExists()
    teardown: (topic) ->
      unlinkLog()
    '出力されない': (topic) =>
      assert.isFalse topic.log
    '出力時の戻り値もなし': (topic) =>
      assert.isUndefined topic.retval

suite.addBatch
  'message: undefined or null複数':
    topic: () ->
      lwl.logFile = defaultLogFile
      retval = lwl.error undefined, null
      retval: retval, log: logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    './lwl.logに1行書き出される': (topic) =>
      assert.equal topic.log.length, 1
    'メッセージは"undefined null"': (topic) =>
      assert.equal topic.log[0].message, 'undefined null'
    '出力時の戻り値とログに出力されたメッセージが同一': (topic) =>
      assert.equal topic.log[0].orig, topic.retval

suite.addBatch
  'message: 文字列':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logFile = null
      logParse(lwl.error 'message: 文字列')[0]
    teardown: (topic) ->
      unlinkLog()
    '囲みクォーテーションが除去された状態で出力される': (topic) =>
      assert.equal topic.message, 'message: 文字列'

suite.addBatch
  'message: 整数':
    topic: () ->
      lwl.logFile = defaultLogFile
      logParse(lwl.error 100)[0]
    teardown: (topic) ->
      unlinkLog()
    'そのまま出力される': (topic) =>
      assert.equal topic.message, 100

suite.addBatch
  'message: 小数':
    topic: () ->
      lwl.logFile = defaultLogFile
      logParse(lwl.error 0.00999009)[0]
    teardown: (topic) ->
      unlinkLog()
    'そのまま出力される': (topic) =>
      assert.equal topic.message, 0.00999009

suite.addBatch
  'message: true':
    topic: () ->
      lwl.logFile = defaultLogFile
      return logParse(lwl.error true)[0]
    teardown: (topic) ->
      unlinkLog()
    '文字列"true"が出力される': (topic) =>
      assert.equal topic.message, 'true'

suite.addBatch
  'message: false':
    topic: () ->
      lwl.logFile = defaultLogFile
      return logParse(lwl.error false)[0]
    teardown: (topic) ->
      unlinkLog()
    '文字列"false"が出力される': (topic) =>
      assert.equal topic.message, 'false'

suite.addBatch
  'message: 配列':
    topic: () ->
      lwl.logFile = defaultLogFile
      msg = [ 'aaa', 'bbb', 111, 222, 333, 'ccc' ]
      msg: msg, log: logParse(lwl.error msg)[0]
    teardown: (topic) ->
      unlinkLog()
    '展開されて出力される': (topic) =>
      assert.equal util.inspect(topic.msg, false, null), topic.log.message

suite.addBatch
  'message: 配列内のundefined or null':
    topic: () ->
      lwl.logFile = defaultLogFile
      msg = [ 'aaa', 'bbb', undefined, 111, 222, null, 333, 'ccc' ]
      msg: msg, log: logParse(lwl.error msg)[0]
    teardown: (topic) ->
      unlinkLog()
    'undefinedが含まれている': (topic) =>
      assert.equal util.inspect(topic.msg, false, null), topic.log.message
      assert.isUndefined topic.msg[2]
    'nullが含まれている': (topic) =>
      assert.isNull topic.msg[5]

suite.addBatch
  'message: オブジェクト':
    topic: () ->
      lwl.logFile = defaultLogFile
      msg = { aaa: 1000, bbb: 'xxx', ccc: 0.05, ddd: '999' }
      msg: msg, log: logParse(lwl.error msg)[0]
    teardown: (topic) ->
      unlinkLog()
    '展開されて出力される': (topic) =>
      assert.equal util.inspect(topic.msg, false, null), topic.log.message

suite.addBatch
  'message: オブジェクト内のundefined or null':
    topic: () ->
      lwl.logFile = defaultLogFile
      msg = { aaa: 1000, bbb: undefined, ccc: 0.05, ddd: null }
      msg: msg, log: logParse(lwl.error msg)[0]
    teardown: (topic) ->
      unlinkLog()
    'undefinedが含まれている': (topic) =>
      assert.equal util.inspect(topic.msg, false, null), topic.log.message
      assert.isUndefined topic.msg.bbb
    'nullが含まれている': (topic) =>
      assert.isNull topic.msg.ddd

suite.addBatch
  'message: 配列内のオブジェクト':
    topic: () ->
      lwl.logFile = defaultLogFile
      msg = [ { aaa: 111, bbb: 222 }, { ccc: 333, ddd: 444 } ]
      msg: msg, log: logParse(lwl.error msg)[0]
    teardown: (topic) ->
      unlinkLog()
    '全て展開されて出力される': (topic) =>
      assert.equal util.inspect(topic.msg, false, null), topic.log.message

suite.addBatch
  'message: オブジェクト内の配列':
    topic: () ->
      lwl.logFile = defaultLogFile
      msg = { aaa: [ 'xxx', 'yyy', 111 ], bbb: [ 'www', 0.932, '888' ] }
      msg: msg, log: logParse(lwl.error msg)[0]
    teardown: (topic) ->
      unlinkLog()
    '全て展開されて出力される': (topic) =>
      assert.equal util.inspect(topic.msg, false, null), topic.log.message

###*
* ログレベルの指定の検証
*
* forで回そうとしたらindentがおかしいとかでcoffee-scriptでエラーになったのでベタ書き
###
suite.addBatch
  'logLevel: "emerg"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'emerg'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"emerg"以外のログは出力されない': (topic) =>
      assert.equal topic.length, 1
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "alert"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'alert'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"alert"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 2
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "crit"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'crit'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"crit"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 3
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "error"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'error'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"error"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 4
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "warn"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'warn'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"warn"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 5
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "notice"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'notice'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"notice"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 6
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "info"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'info'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"info"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 7
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "debug"':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'debug'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '"debug"未満のログは出力されない': (topic) =>
      assert.equal topic.length, 8
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

suite.addBatch
  'logLevel: "unknown"(規定外のレベル)':
    topic: () ->
      lwl.logFile = defaultLogFile
      lwl.logLevel = 'unknown'
      lwl[ll] ll for ll in logLevels
      logParse fs.readFileSync(defaultLogFile, 'utf-8')
    teardown: (topic) ->
      unlinkLog()
    '全てのログが出力される': (topic) =>
      assert.equal topic.length, 8
      assert.equal t.level, logLevels[logLevels.length - topic.length + i] for t, i in topic

###*
* 外部ファイル実行におけるログファイルの内容の検証(ファイル名、関数名、行番号)
*
* vows内でcoffeeファイルをrequireしてもjsに展開されてしまうので外部ファイルとして実行する
###
suite.addBatch
  '外部ファイル: coffee':
    topic: () ->
      coffee = "#{__cwd}/../node_modules/coffee-script/bin/coffee"
      extPath = "#{__cwd}/external/coffee"
      child = spawn 'node', [ coffee, "#{extPath}/main.coffee" ], cwd: extPath
      child.on 'exit', (code) =>
        lwl.logFile = defaultLogFile
        @callback undefined, logParse(fs.readFileSync(defaultLogFile, 'utf-8'))
      return
    teardown: (topic) ->
      unlinkLog()
    '各ログの内容を検証': (topic) =>
      assert.equal topic.length, 10
      srcInfo = []
      # 外部ファイルを読んでlwl.～している場所を取得してログ出力内容と比較する
      for extSrc in [ 'main', 'sub' ]
        srcLine = fs.readFileSync("#{__cwd}/external/coffee/#{extSrc}.coffee", 'utf-8').split /[\r\n]/
        for src, line in srcLine
          chk = src.match /lwl\.\w+\s+'(.*)'/
          if chk
            tmp = chk[1].split /\s+/
            tmp.unshift "#{extSrc}.coffee:#{line + 1}"
            srcInfo.push tmp
      for t, idx in topic
        assert.equal t.filename, srcInfo[idx][0]
        assert.equal t.func, srcInfo[idx][1]
        assert.equal t.level, srcInfo[idx][2]

suite.addBatch
  '外部ファイル: js':
    topic: () ->
      extPath = "#{__cwd}/external/js"
      child = spawn 'node', [ "#{extPath}/main.js" ], cwd: extPath
      child.on 'exit', (code) =>
        lwl.logFile = defaultLogFile
        @callback undefined, logParse(fs.readFileSync(defaultLogFile, 'utf-8'))
      return
    teardown: (topic) ->
      unlinkLog()
    '各ログの内容を検証': (topic) =>
      assert.equal topic.length, 10
      srcInfo = []
      # 外部ファイルを読んでlwl.～している場所を取得してログ出力内容と比較する
      for extSrc in [ 'main', 'sub' ]
        srcLine = fs.readFileSync("#{__cwd}/external/js/#{extSrc}.js", 'utf-8').split /[\r\n]/
        for src, line in srcLine
          chk = src.match /lwl\.\w+\('(.*)'\)/
          if chk
            tmp = chk[1].split /\s+/
            tmp.unshift "#{extSrc}.js:#{line + 1}"
            srcInfo.push tmp
      for t, idx in topic
        assert.equal t.filename, srcInfo[idx][0]
        assert.equal t.func, srcInfo[idx][1]
        assert.equal t.level, srcInfo[idx][2]

suite.export module
