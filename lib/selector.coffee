module.exports =
class Selector

  settings: null

  constructor: ->
    @settings = null

  getSelection: ->
    editor = atom.workspace.getActiveTextEditor()
    editor?.getSelectedText()
