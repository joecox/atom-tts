AtomTtsView = require './atom-tts-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomTts =
  atomTtsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomTtsView = new AtomTtsView(state.atomTtsViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomTtsView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-tts:toggle': => @toggle()

  deactivate: ->
    # Need to release `say` process here...maybe
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomTtsView.destroy()

  serialize: ->
    atomTtsViewState: @atomTtsView.serialize()

  toggle: ->
    console.log 'AtomTts was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
