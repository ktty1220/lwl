sub = require './sub'
lwl = require '../../../lib/lwl'
lwl.logFile = '../../lwl.log'
lwl.logLevel = 'info'





lwl.warn '<anonymous> warn'









a = do () -> lwl.error '<anonymous> error'









funcA = () -> lwl.info 'funcA info'
funcA()






class ClassA
  constructor: () ->
    lwl.crit 'ClassA crit'
  methodA: () =>
    lwl.emerg 'ClassA.methodA emerg'

c = new ClassA()
c.methodA()
sub()
