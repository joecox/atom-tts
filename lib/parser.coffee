esprima = require 'esprima'
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s

module.exports =
class Parser

  ast: null
  text: null

  constructor: ->

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
      # when 'WithStatement' -- NOT SUPPORTED
      when 'SwitchStatement'
        text = 'switch on ' + @astToText(ast.discriminant) + ' '
        text += @astToText(switchCase) + ' ' for switchCase in ast.cases
      when 'ReturnStatment'
        if ast.argument
          text = 'return ' + @astToText(ast.argument)
        else
          text = 'return'
      # when 'ThrowStatement'
      # when 'TryStatement'
      # when 'WhileStatement'
      # when 'DoWhileStatement'
      # when 'ForStatement'
      # when 'ForInStatement'
      # when 'DebuggerStatement'
      # # when 'Declaration'
      # when 'FunctionDeclaration'
      # when 'VariableDeclaration'
      # when 'VariableDeclarator'
      # # when 'Expression'
      # when 'ThisExpression'
      # when 'ArrayExpression'
      # when 'ObjectExpression'
      # when 'Property'
      # when 'FunctionExpression'
      # when 'SequenceExpression'
      # when 'UnaryExpression'
      # when 'BinaryExpression'
      # when 'AssignmentExpression'
      # when 'UpdateExpression'
      # when 'LogicalExpression'
      # when 'ConditionalExpression'
      # when 'CallExpression'
      # when 'NewExpression'
      # when 'MemberExpression'
      # when 'Pattern'
      # when 'SwitchClause'
      # when 'CatchClause'
      when 'Identifier'
        text = ast.name
      when 'Literal'
        text = ast.value.toString()
      # when 'RegExpLiteral'
      # when 'UnaryOperator'
      # when 'BinaryOperator'
      # when 'LogicalOperator'
      # when 'AssignmentOperator'
      # when 'UpdateOperator'
      when 'EmptyStatement'
      else throw Error 'unknown node type ' + ast.type
    return text

  getAst: ->
    @ast

  getText: ->
    @text
