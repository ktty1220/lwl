#jshint loopfunc:true
util = require 'util'
fs = require 'fs'

###*
* モジュール本体
###
lwl =
  logLevel: 'warn'
  logFile: './lwl.log'
  logFormatFunc: null

###*
* スタック情報拡張
*
* 参考: http://stackoverflow.com/questions/11386492/accessing-line-number-in-v8-javascript-chrome-node-js
###
Object.defineProperty lwl, '__stack',
  get: () ->
    orig = Error.prepareStackTrace
    Error.prepareStackTrace = (err, stack) ->
      ### coffee-scriptのpatchStackTrace()で拡張されたエラーメッセージをセットしたスタックを返す ###
      exErrStack = orig? err, stack
      if exErrStack?
        messages = exErrStack.split /[\r\n]\s*/
        ### 1行目は'Error:'だけなのでいらない ###
        messages.shift()
      else
        messages = []
      ### スタックに拡張エラー情報をセットしていく ###
      for s, i in stack
        Object.defineProperties s,
          messageEx:
            value: messages[i]
            writable: false
            enumerable: false
            configurable: false
          func: get: () -> @getFunctionName() ? '<anonymous>'
          file: get: () -> @getFileName().match(/([^\\\/]*)$/)[1]
          line: get: () ->
            ### 拡張エラー情報がなければオリジナルのgetLineNumber()の結果を返す ###
            return @getLineNumber() unless @messageEx
            ###*
            * 以下のようなcoffee-script拡張エラー情報から行番号の部分を抜き出す
            * ex) 'at test (/path/to/test.coffee:7:1, <js>:15:3)'
            ###
            (@messageEx.match /[^\\\/:]+:(\d+):\d+/ ? [])[1]
      stack
    e = new Error()
    Error.captureStackTrace e, arguments.callee
    stack = e.stack
    Error.prepareStackTrace = orig
    stack

###*
* 指定できるログレベル一覧
###
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

###*
* ゼロ埋め
###
_zeroPadding = (d) => "0#{d}".substr(-2)

###*
* ログ出力処理
*
* 参考: http://memo.yomukaku.net/entries/jfugzXU
###

### '<タイムスタンプ> <関数名>@<ファイル名>:<行番号>'のフォーマット文字列で返す ###
_defaultLogFormatFunc = (timestamp, level, func, file, line, message) ->
  util.format '%s %s@%s:%s [%s] %s', timestamp, func, file, line, level, message

_log = (level, msg) ->
  ### msgがnullやundefinedのみの場合はなかった事にする ###
  msg.length = 0 if msg.length is 0 or (msg.length is 1 and not msg[0]?)
  if msg.length > 0 and logLevels.indexOf(level) >= logLevels.indexOf(lwl.logLevel)
    ### 変数内容を文字列として展開 ###
    args = []
    for m in msg
      v = util.inspect m, false, null
      v = v.replace /^'(.+)'$/, '$1' if typeof(m) is 'string'
      args.push v

    ### タイムスタンプ作成 ###
    d = new Date()
    timestamp = util.format '%s-%s-%s %s:%s:%s',
      d.getFullYear(), _zeroPadding(d.getMonth() + 1), _zeroPadding(d.getDate()),
      _zeroPadding(d.getHours()), _zeroPadding(d.getMinutes()), _zeroPadding(d.getSeconds())

    ### 拡張スタックからファイル名、行番号、関数名を取得 ###
    stack = lwl.__stack[2]

    ### ログフォーマット ###
    output = (lwl.logFormatFunc ? _defaultLogFormatFunc)(
      timestamp, level, stack.func, stack.file, stack.line, args.join(' ')
    )

    if lwl.logFile?
      if lwl.logFile is '-'
        console.log output
      else
        fs.appendFileSync lwl.logFile, "#{output}\n"
    output

###*
* 各ログレベルの名前の出力関数をlwlオブジェクトに作成
###
for lv in logLevels
  lwl[lv] = do (lv) -> () -> _log lv, Array::slice.call(arguments)

module.exports = lwl
