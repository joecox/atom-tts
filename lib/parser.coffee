esprima = require 'esprima'
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s

ErrorMsg = require './error-msg'

module.exports =
class Parser

  ast: null
  text: null

  constructor: ->
    @errorMsgView = new ErrorMsg
    @modalPanel = atom.workspace.addModalPanel(item: @errorMsgView.getElement(), visible: false)

  bindParseEvent: ->
    atom.workspace.observeTextEditors (editor) =>
      if (editor.getTitle().endsWith('.js'))
        editor.onDidStopChanging =>
          @parse(editor.getText())
          console.log(@ast)
          console.log(@text)

  parse: (selection) ->
    try
      @ast = esprima.parse(selection)
      @text = @astToText(@ast)
    catch err
      console.error(err)

  astToText: (ast) ->
    text = ''
    switch ast.type
      when 'Program', 'BlockStatement'
        text += @astToText(stmt) + ' ' for stmt in ast.body
      # when 'Function'
      # when 'Statement'
      when 'ExpressionStatement'
        text = @astToText(ast.expression)
      when 'IfStatement'
        text = 'if ' + @astToText(ast.test) + ', '
        text += 'then ' + @astToText(ast.consequent)
        if ast.alternate
          text += ', else ' + @astToText(ast.alternate)
      when 'LabeledStatement'
        text = 'label ' + @astToText(ast.label)
        text += ' ' + @astToText(ast.body)
      when 'BreakStatement'
        text = 'break'
      when 'ContinueStatement'
        text = 'continue'
      when 'WithStatement' # -- NOT SUPPORTED
        @unsupported()
      when 'SwitchStatement'
        text = 'switch on ' + @astToText(ast.discriminant) + ' '
        text += @astToText(switchCase) + ' ' for switchCase in ast.cases
      when 'ReturnStatment'
        if ast.argument
          text = 'return ' + @astToText(ast.argument)
        else
          text = 'return'
      when 'ThrowStatement'
        text = 'throw ' + @astToText(ast.argument)
      when 'TryStatement'
        @unsupported()
      when 'WhileStatement'
        @unsupported()
      when 'DoWhileStatement'
        @unsupported()
      when 'ForStatement'
        @unsupported()
      when 'ForInStatement'
        @unsupported()
      when 'DebuggerStatement'
        @unsupported()
      # when 'Declaration'
      when 'FunctionDeclaration'
        @unsupported()
      when 'VariableDeclaration'
        @unsupported()
      when 'VariableDeclarator'
        @unsupported()
      # when 'Expression'
      when 'ThisExpression'
        @unsupported()
      when 'ArrayExpression'
        @unsupported()
      when 'ObjectExpression'
        @unsupported()
      when 'Property'
        @unsupported()
      when 'FunctionExpression'
        @unsupported()
      when 'SequenceExpression'
        @unsupported()
      when 'UnaryExpression'
        @unsupported()
      when 'BinaryExpression'
        @unsupported()
      when 'AssignmentExpression'
        @unsupported()
      when 'UpdateExpression'
        if ast.prefix
          text = @opToText(ast.operator) + ' ' + @astToText(ast.argument)
        else
          text = @astToText(ast.argument) + ' ' + @opToText(ast.operator)
      when 'LogicalExpression'
        text = @astToText(ast.left) + ' ' + @opToText(ast.operator) + ' ' + @astToText(right)
      when 'ConditionalExpression'
        text = @astToText(ast.consequent) + ', if ' + @astToText(ast.test) + ', '
        text += ', otherwise ' + @astToText(ast.alternate)
      when 'CallExpression'
        text = 'invocation of ' + @astToText(ast.callee)
        if (ast.arguments.length)
          text += ' with parameters '
          text += @astToText(param) + ', ' for param in ast.arguments
      when 'NewExpression'
        text = 'new ' + @astToText(ast.callee)
        if (ast.arguments.length)
          text += ' with parameters '
          text += @astToText(param) + ', ' for param in ast.arguments
      when 'MemberExpression'
        @unsupported()
      when 'Pattern'
        @unsupported() # -- ES6 feature, unsupported
      when 'SwitchCase'
        if ast.test
          text = 'case ' + @astToText(ast.test)
        else
          text = 'default case '
        text += @astToText(stmt) for stmt in ast.consequent + ' '
      when 'CatchClause'
        @unsupported()
      when 'Identifier'
        text = '\"' + ast.name + '\"'
      when 'Literal'
        text = ast.value.toString()
      when 'RegExpLiteral'
        @unsupported()
      # when 'UnaryOperator'
      #   @unsupported()
      # when 'BinaryOperator'
      #   @unsupported()
      # when 'LogicalOperator'
      #   @unsupported()
      # when 'AssignmentOperator'
      #   @unsupported()
      # when 'UpdateOperator'
      #   @unsupported()
      when 'EmptyStatement'
      else throw Error 'unknown or unsupported node type ' + ast.type
    return text

  opToText: (op) ->
    opMap =
      '-': 'minus'
      '+': 'plus'
      '*': 'times'
      '/': 'divided by'
      '%': 'modulo'
      '!': 'not'
      '~': ''
      '|': 'or'
      '||': 'or'
      '^': ''
      '&': 'and'
      '&&': 'and'
      '++': 'plus plus'
      '--': 'minus minus'
      'in': 'in'
      'instanceof': 'instanceof'
      'typeof': 'typeof'
      'void': 'void'
      'delete': 'delete'
      '==': 'double equals'
      '!=': 'not equals'
      '===': 'triple equals'
      '!==': 'double not equals'
      '<': 'less than'
      '<=': 'less than or equal to'
      '>': 'greater than'
      '>=': 'greater than or equal to'
      '<<': 'double less than'
      '>>': 'double greater than'
      '>>>': 'triple greater than'
      '=': 'equals'
      '+=': 'plus equals'
      '-=': 'minus equals'
      '*=': 'times equals'
      '/=': 'divide equals'
      '%=': 'modulo equals'
      '<<=': ''
      '>>=': ''
      '>>>=': ''
      '|=': ''
      '^=': ''
      '&=': ''
    return opMap[op]

  getAst: ->
    @ast

  getText: ->
    @text

  unsupported: ->
    @modalPanel.show()
    setTimeout(( => @modalPanel.hide()), 4000)
