# lwl - ファイル名 & 行番号 & 関数名付きのログを出力するNode.jsモジュール (js & coffee 両対応)

lwlは、 __L__og __W__ith __L__ineNumber の略です。

lwlの各種メソッド(error、alert、warnなど)を実行したファイル名と行番号、関数名が付加されたログがファイルに出力されます。また、coffee-scriptで実行した場合も.coffee上の行番号が出力されます(いくつか条件があります。後述)。

運用中に発生したエラーの箇所を簡単に特定できるので、問題解決の助けになると思います。

## サンプル

### sample.js

    01  var lwl = require('lwl');
    02
    03  lwl.error('test');
    04  function test() {
    05    lwl.alert('テスト', 0.0005);
    06  }
    07  test();
    08  var x = (function () {
    09    lwl.warn([1, 2, 3, 4, 5]);
    10  })();

上記JSファイルを実行すると、以下のようなログファイルが出力されます。

### lwl.log

    2013-06-20 15:36:02 <anonymous>@sample.js:3 [error] test
    2013-06-20 15:36:02 test@sample.js:5 [alert] テスト 0.0005
    2013-06-20 15:36:02 <anonymous>@sample.js:9 [warn] [ 1, 2, 3, 4, 5 ]

デフォルトのログ出力フォーマットは

__`タイムスタンプ` `関数名`@`ファイル名`:`行番号` [`出力レベル`] `メッセージ`__

です。

関数外で実行された場合や無名関数内で実行された場合は関数名に`<anonymous>`が、

test()関数内で実行された場合は関数名に`test`と入っているのが確認できます。

## インストール

    npm install lwl

## 使用方法

    var lwl = require('lwl');

で、lwlモジュールをロードします。ロードした変数`lwl`から各種ログ出力メソッドを実行できます。

### メソッド

#### lwl.&lt;メソッド名(出力レベル)&gt;([message1, message2, ...]);

メソッド名には以下の8つが利用できます。呼び出したメソッド名がログに付加されます。数字が大きくなるにつれて重要度が増していきます。

1. __debug__
2. __info__
3. __notice__
4. __warn__
5. __error__
6. __crit__
7. __alert__
8. __emerg__

##### サンプル

    lwl.debug(...);

##### 引数

`console.log()`と同じような感覚で自由に何でもいくつでもセットできます。`Array`や`Object`は展開して出力されます。

##### 戻り値

出力されたログと同じ内容の文字列です。なお、引数が`null`もしくは`undefined`の場合はログは出力されず、戻り値も`undefined`になります。したがって、以下のようにコールバックのエラー変数の内容をチェックせず、無条件にlwlメソッドを呼び出すようにしておけば、エラーがある場合はエラーメッセージがログに出力され、エラーがない場合は何も出力しない、といった利用ができます。

例)

    hogehoge(function (err, result) {
      lwl.error(err);
        ・
        ・
        ・
    });

もっとも、エラーがある場合に処理を中断させたい時には使用できない方法ですが・・・

### プロパティ(Read & Write)

#### lwl.logLevel(文字列)

デフォルトでは`warn`未満のメソッドを実行してもログは出力されません。`lwl.logLevel`を変更するとログに出力する基準となるログレベルを設定できます。

設定する値は、ログ出力メソッドの8つの内のいずれかを指定してください。指定したレベル未満のログは実行しても出力されなくなります。運用時にデバッグメッセージを表示させたくない場合などに使用してください。

例)

    lwl.logLevel = 'info';
    lwl.debug('hogehoge'); // 出力されない
    lwl.logLevel = 'debug';
    lwl.debug('hogehoge'); // 出力される

#### lwl.logFile(文字列)

デフォルトでは`./lwl.log`にログが出力されます。この値を変更すると変更したファイル名にログが出力されます。

例)

    lwl.error('hogehoge'); // デフォルトのlwl.logにログが出力される
    lwl.logFile = '/path/to/logfile.txt';
    lwl.error('hogehoge'); // /path/to/logfile.txtにログが出力される

また、`logFile`には特殊な指定方法が2つあります。

* ログファイル名に`-`を指定するとファイルではなく標準出力(stdout)にログが出力されます。

        lwl.logFile = '-';
        lwl.warn('hogehoge'); // 標準出力に表示される

* ログファイル名に`null`もしくは`undefined`を指定するとファイルにも標準出力にもログは出力されず、メソッドの戻り値にログ文字列を返すだけになります。発生したエラー情報を呼び出し元に返し、何かしらの加工をした後で`console.log()`などで出力するといった使い方ができます。

        lwl.logFile = null;
        var log = lwl.warn('hogehoge');         // 変数logにログメッセージが入る
          ・
          ・
          ・
        console.log('エラーだよ!! -> ' + log);  // ここで改めてログを出力

#### lwl.logFormatFunc(関数)

以下の6つを引数として受けて文字列を返す関数を指定します。ここで指定した関数で返される文字列がログファイルに出力されます。`null`もしくは`undefined`を指定するとデフォルトのログフォーマットで出力します。

* __timestamp__: `YYYY-MM-DD hh:mm:ss`形式のタイムスタンプ
* __level__: ログ出力レベル(error、alert、warnなど)
* __func__: 関数名(無名関数や関数外の場合は`<anonymous>`)
* __file__: ディレクトリを除いたファイル名
* __line__: coffee-scriptに対応した行番号
* __message__: ログ出力メッセージ

例)

    lwl.logFormatFunc = function (timestamp, level, func, file, line, message) {
      return '[' + level + ']' + timestamp + ' ' + file + ':' + line + '(' + func + ') -> ' + message;
    };

### プロパティ(ReadOnly)

#### lwl.__stack

※普通にログの出力だけを行う分には必要のない情報です。

このプロパティを記述した位置の__拡張__スタックトレース情報および呼び出し元の__拡張__スタックトレース情報を大元まで配列で返します。意味が良く分からないかもしれませんが、スクリプトでエラーが発生した時に出るアレの元情報を取得できるわけです。

例)

    $ node
    > a.x()
    ReferenceError: a is not defined
       at repl:1:2                                        ← StackTrace[0]
       at REPLServer.self.eval (repl.js:109:21)           ← StackTrace[1]
       at Interface.<anonymous> (repl.js:248:12)          ← StackTrace[2] 
       at Interface.EventEmitter.emit (events.js:96:17)   ← StackTrace[3] 
       at Interface._onLine (readline.js:200:10)          ← StackTrace[4] 
       at Interface._line (readline.js:518:8)             ← StackTrace[5] 
       at Interface._ttyWrite (readline.js:736:14)        ← StackTrace[6] 
       at ReadStream.onkeypress (readline.js:97:10)       ← StackTrace[7] 
       at ReadStream.EventEmitter.emit (events.js:126:20) ← StackTrace[8] 
       at emitKey (readline.js:1058:12)                   ← StackTrace[9] 

何が__拡張__かというと、`lwl.__stack`で取得したスタックトレース情報には特別なプロパティが用意されています。

* __func__: 関数名(無名関数や関数外の場合は`<anonymous>`)
* __file__: ディレクトリを除いたファイル名
* __line__: coffee-scriptに対応した行番号

ログ出力以外のデバッグ目的などでこれらのプロパティを使用する場合などにどうぞ。

例)

    var stack = lwl.__stack;
    console.log(stack[0].file + 'の' + stack[0].line + '行目 (関数名: ' + stack[0].func + ')です');
    // この例の場合console.log()の1行上の行番号が表示されますが・・・

## coffee-scriptでの利用上の注意

coffee-scriptで.coffee上の行番号を出力させるにはcoffee-scriptのバージョンが__1.6.2以上__である必要があります。

また、coffee-scriptがスタックトレースに.coffee上の行番号を付加するのはcoffeeコマンドで実行されたときのみなので、下記のように.jsファイル内から.coffeeファイルをrequireした場合は.coffeeがJavaScriptにコンパイルされて展開された後の行番号になってしまいます。

※今後のcoffee-scriptのバージョンアップによって自動的に直る可能性があります。

### test.coffee

    01  lwl = require 'lwl'
    02
    03  lwl.error 'hoge'

### coffee-in-js.js

    require('coffee-script');
    require('./test');

### lwl.log

    2013-06-20 16:09:43 <anonymous>@test.coffee:6 [error] hoge
                                                ~ JavaScriptに展開された後の行番号になってしまう

## Changelog

### 0.2.0 (2013-06-21)

* coffee-scriptの行番号に対応
* ログフォーマットをカスタマイズできるようにした(`lwl.logFormatFunc`)
* デフォルトのログフォーマットに関数名追加
* `lwl.__stack`プロパティの追加

### 0.1.0 (2013-03-15)

* 初版リリース

## ライセンス

[MIT license](http://www.opensource.org/licenses/mit-license)で配布します。

&copy; 2013 [ktty1220](mailto:ktty1220@gmail.com)
