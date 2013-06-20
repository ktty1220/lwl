lwl = require '../lib/lwl'

### ログ出力レベルをdebugに設定 ###
lwl.logLevel = 'debug'

### メッセージがnull or undefinedの場合は出力されない ###
lwl.alert null

### 関数外で実行された場合や無名関数で実行された場合は関数名が<anonymous>で出力される ###
lwl.emerg 'test'
a = do () -> lwl.crit 100

### 関数内で実行された場合は関数名がログに出力される ###
funcA = () ->
  lwl.error 0.0005
  lwl.warn [ 1, 2, 3, 4, '5' ]
funcA()

### クラス内で実行された場合はクラス.メソッド名がログに出力される ###
class ClassA
  constructor: () ->
    lwl.notice 'xxx', undefined, 123
  methodA: () =>
    lwl.info xxx: 'aaa', yyy: 'bbb'
  methodB: () =>
    lwl.debug 'test', 1, 4, [ 'xxx', 'yyy' ], { aaa: 1, bbb: 2 }
c = new ClassA
c.methodA()
c.methodB()

### ここからログ出力先を標準出力に設定 ###
lwl.logFile = '-'

### ついでにログフォーマット変更 ###
lwl.logFormatFunc = (timestamp, level, func, file, line, message) ->
  "[#{level}] #{timestamp} ... #{file}:#{line}(#{func}) -> #{message}"

lwl.info 'this is logged', 123, { a: [ undefined, null ], b: null }

### ログ出力レベルをwarnに設定 ###
lwl.logLevel = 'warn'
lwl.info 'this is not logged'

### ログを出力しない(戻り値にはログが入る) ###
lwl.logFile = null

log = lwl.error new Error('only return value')
console.log "####{log}###"

### 拡張スタック情報取得 ###
showStack = () ->
  stack = lwl.__stack
  console.log 'lwl.__stack:'
  console.log '  ' + ("#{s.func}@#{s.file}:#{s.line}" for s in stack).join '\n  '
showStack()
