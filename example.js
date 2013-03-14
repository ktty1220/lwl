#!/usr/bin/env node

var lwl = require('./lib/lwl');

// ログ出力レベルをdebugに設定
lwl.logLevel = 'debug';

// 各レベルのログ出力
lwl.logLevel = 'debug';
lwl.emerg('test');
lwl.alert(null);  // メッセージがnull or undefinedの場合は出力されない
lwl.crit(100);
lwl.error(0.0005);
lwl.warn([1, 2, 3, 4, '5']);
lwl.notice('xxx', undefined, 123);
lwl.info({xxx: 'aaa', yyy: 'bbb'});
lwl.debug('test', 1, 4, ['xxx', 'yyy'], {aaa:1, bbb:2});

// ログ出力先を標準出力に設定
lwl.logFile = '-';

lwl.info('this is logged');

// ログ出力レベルをwarnに設定
lwl.logLevel = 'warn';
lwl.info('this is not logged');

// ログを出力しない(戻り値にはログが入る)
lwl.logFile = null;

var log = lwl.error('only return value');
console.log('### ' + log + ' ###');
