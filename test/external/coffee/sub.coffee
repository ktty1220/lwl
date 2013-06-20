lwl = require '../../../lib/lwl'
lwl.logFile = '../../lwl.log'
lwl.logLevel = 'info'










test = () ->
  lwl.warn 'test warn'









  a = do () -> lwl.error '<anonymous> error'









  funcB = () -> lwl.info 'funcB info'
  funcB()






  class ClassB
    constructor: () ->
      lwl.crit 'ClassB crit'
    methodB: () =>
      lwl.emerg 'ClassB.methodB emerg'

  c = new ClassB()
  c.methodB()

module.exports = test
