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
        text += @astToText(switchCase) + ', ' for switchCase in ast.cases
      when 'ReturnStatement'
        if ast.argument
          text = 'return ' + @astToText(ast.argument)
        else
          text = 'return'
      when 'ThrowStatement'
        text = 'throw ' + @astToText(ast.argument)
      when 'TryStatement'
        @unsupported()
      when 'WhileStatement'
        text = 'while ' + @astToText(ast.test) + ', '
        text += @astToText(ast.body)
      when 'DoWhileStatement'
        text = 'do ' + @astToText(ast.body)
        text += ', while ' + @astToText(ast.test)
      when 'ForStatement'
        text = 'for '
        if (ast.init)
          text += @astToText(ast.init) + ', '
        else
          text += 'no initialization, '
        if (ast.test)
          text += @astToText(ast.test) + ', '
        else
          text += 'no test, '
        if (ast.update)
          text += @astToText(ast.update) + ', '
        else
          text += 'no update, '
        text += @astToText(ast.body)
      when 'ForInStatement'
        text = 'for ' + @astToText(ast.left) + ' in ' + @astToText(ast.right) + ', '
        text += @astToText(ast.body)
      when 'DebuggerStatement'
        @unsupported()
      # when 'Declaration'
      when 'FunctionDeclaration', 'FunctionExpression'
        if (ast.id)
          text = 'function ' + @astToText(ast.id)
        else
          text = 'function '
        if (ast.params.length)
          text += ' with parameters '
          text += @astToText(param) + ', ' for param in ast.params
        text += @astToText(ast.body)
      when 'VariableDeclaration'
        if (ast.declarations > 1)
          text = 'vars '
        else
          text = 'var '
        text += @astToText(decl) + ', ' for decl in ast.declarations
      when 'VariableDeclarator'
        text = @astToText(ast.id)
        if (ast.init)
          text += ' equals ' + @astToText(ast.init)
      # when 'Expression'
      when 'ThisExpression'
        text = 'this'
      when 'ArrayExpression'
        text = 'array with elements '
        text += @astToText(elem) + ', ' for elem in ast.elements
      when 'ObjectExpression'
        text = 'object with pairs '
        text += @astToText(prop)  + ', ' for prop in ast.properties
      when 'Property'
        text = 'key: ' + @astToText(ast.key) + ', value: ' + @astToText(ast.value)
      when 'SequenceExpression'
        text = @astToText(expr) + ', ' for expr in ast.expressions
      when 'BinaryExpression', 'AssignmentExpression', 'LogicalExpression'
        text = @astToText(ast.left) + ' ' + @opToText(ast.operator) + ' ' + @astToText(ast.right)
      when 'UnaryOperator', 'UpdateExpression'
        if ast.prefix
          text = @opToText(ast.operator) + ' ' + @astToText(ast.argument)
        else
          text = @astToText(ast.argument) + ' ' + @opToText(ast.operator)
      when 'ConditionalExpression'
        text = @astToText(ast.consequent) + ', if ' + @astToText(ast.test) + ', '
        text += ', otherwise ' + @astToText(ast.alternate)
      when 'CallExpression'
        text = @astToText(ast.callee)
        if (ast.arguments.length)
          text += ' with parameters '
          text += @astToText(param) + ', ' for param in ast.arguments
      when 'NewExpression'
        text = 'new ' + @astToText(ast.callee)
        if (ast.arguments.length)
          text += ' with parameters '
          text += @astToText(param) + ', ' for param in ast.arguments
      when 'MemberExpression'
        if (ast.computed)
          text = 'member ' + @astToText(ast.property) + ' of ' + @astToText(ast.object)
        else
          text = @astToText(ast.object) + ' dot ' + @astToText(ast.property)
      # when 'Pattern'
        # @unsupported() # -- In ES5, only subtype is Identifier
      when 'SwitchCase'
        if ast.test
          text = 'case ' + @astToText(ast.test)
        else
          text = 'default case '
        text += @astToText(stmt) + ', ' for stmt in ast.consequent
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
        ;
      else
        throw Error 'unknown or unsupported node type ' + ast.type
    return text

  opToText: (op) ->
    opMap =
      '-': 'minus'
      '+': 'plus'
      '*': 'times'
      '/': 'divided by'
      '%': 'modulo'
      '!': 'not'
      '|': 'or'
      '||': 'or'
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

      # -- Unsupported operators (how do we speak these?)
      '~': ''
      '^': ''
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
