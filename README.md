# lwl - ファイル名 & 行番号付きのログを出力するNode.jsモジュール

lwlは、__L__og __W__ith __L__ineNumber の略です。

lwlの各種メソッド(error, alert, warnなど)を実行したファイル名と行番号が付加されたログがファイルに出力されます。

運用中に発生したエラーの箇所を簡単に特定できるので、問題解決の助けになると思います。

## サンプル

### sample.js

    01  var lwl = require('lwl');
    02
    03  lwl.error('test');
    04  lwl.alert('テスト', 0.0005);
    05  lwl.warn([1, 2, 3, 4, 5]);

上記JSファイルを実行すると、以下のようなログファイルが出力されます。

### lwl.log

    2013-03-15 10:13:15 sample.js:3 [error] test
    2013-03-15 10:13:15 sample.js:4 [alert] テスト 0.0005
    2013-03-15 10:13:15 sample.js:5 [warn] [ 1, 2, 3, 4, 5 ]

## インストール

    npm install lwl

## 使用方法

    var lwl = require('lwl');

で、lwlモジュールをロードします。ロードした変数`lwl`から各種ログ出力メソッドを実行できます。

### メソッド

#### lwl.\<メソッド名>([message1, message2, ...]);

メソッド名には以下の8つが利用できます。呼び出したメソッド名がログに付加されます。数字が大きくなるにつれて重要度が増していきます。

1. debug
2. info
3. notice
4. warn
5. error
6. crit
7. alert
8. emerg

##### サンプル

    lwl.debug(...);

引数は`console.log()`と同じような感覚で自由に何でもセットできます。`Array`や`Object`は展開して出力されます。

戻り値は出力されたログと同じ内容の文字列です。なお、引数が`null`もしくは`undefined`の場合はログは出力されず、戻り値も`undefined`になります。したがって、以下のようにコールバックのエラー変数の内容をチェックせず、無条件にlwlメソッドを呼び出すようにしておけば、エラーがある場合はエラーメッセージがログに出力され、エラーがない場合は何も出力しない、といった利用ができます。

    hogehoge(function (err, result) {
      lwl.error(err);
        ・
        ・
        ・
    });

もっとも、エラーがある場合に処理を中断させたい時には使用できない方法ですが・・・

### プロパティ

#### lwl.logLevel

デフォルトでは`warn`未満のメソッドを実行してもログは出力されません。`lwl.logLevel`を変更するとログに出力する基準となるログレベルを設定できます。

設定する値は、ログ出力メソッドの8つの内のいずれかを指定してください。指定した値未満のログは実行しても出力されなくなります。運用時にデバッグメッセージを表示させたくない場合などに使用してください。

    lwl.logLevel = 'info';
    lwl.debug('hogehoge'); // 出力されない
    lwl.logLevel = 'debug';
    lwl.debug('hogehoge'); // 出力される

#### lwl.logFile

デフォルトでは`./lwl.log`にログが出力されます。この値を変更すると変更したファイル名にログが出力されます。

    lwl.error('hogehoge'); // デフォルトのlwl.logにログが出力される
    lwl.logFile = '/path/to/logfile.txt';
    lwl.error('hogehoge'); // /path/to/logfile.txtにログが出力される

また、`logFile`には特殊な指定方法が2つあります。

* ログファイル名に`-`を指定すると、ファイルではなく標準出力(stdout)にログが出力されます。

        lwl.logFile = '-'
        lwl.warn('hogehoge'); // 標準出力に表示される

* ログファイル名に`null`もしくは`undefined`を指定すると、ファイルにも標準出力にもログは出力されず、メソッドの戻り値にログ文字列を返すだけになります。発生したエラー情報を呼び出し元に返して、そこで`console.log()`などで出力するといった使い方ができます。

        lwl.logFile = null
        var log = lwl.warn('hogehoge'); // 変数logにログメッセージが入る
          ・
          ・
          ・
        console.log(log);               // ここで改めてログを出力

## Changelog

### 0.1.0 (2013-03-15)

* 初版リリース

## ライセンス

[MIT license](http://www.opensource.org/licenses/mit-license)で配布します。

&copy; 2013 [ktty1220](mailto:ktty1220@gmail.com)
