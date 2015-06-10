{CompositeDisposable} = require 'atom'

TextSpeaker = require './speaker'
Selector    = require './selector'
Parser      = require './parser'

speaker  = new TextSpeaker
selector = new Selector

module.exports = AtomTTS =
  atomTtsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @parser = new Parser

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor',
      # 'atom-tts:speak': =>
      #   unless speaker.stop()
      #     selection = selector.getSelection()
      #     speaker.speak(selection)
      # 'atom-tts:add': =>
      #   selection = selector.getSelection()
      #   if selection
      #     editor = atom.workspace.getActiveTextEditor()
      #     range = editor.getSelectedBufferRange()
      #     marker = editor.markBufferRange(range)
      #     decoration = editor.decorateMarker(marker, {type: 'overlay', item: new SearchView().getElement(), position: 'tail'})
      'atom-tts:speak': =>
        unless speaker.stop()
          speaker.speak(@parser.getText())

    @parser.bindParseEvent()

    console.log 'AtomTTS loaded'

  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @atomTtsView.destroy()

  serialize: ->
    # atomTtsViewState: @atomTtsView.serialize()
