{CompositeDisposable} = require 'atom'

TextSpeaker = require './text-speaker'
Selector    = require './selector'

speaker  = new TextSpeaker
selector = new Selector

module.exports = AtomTTS =
  atomTtsView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'atom-tts:speak': =>
        unless speaker.stop()
          selection = selector.getSelection()
          speaker.speak(selection)

    console.log 'AtomTTS loaded'

  deactivate: ->
    # Need to release `say` process here...maybe
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @atomTtsView.destroy()

  serialize: ->
    # atomTtsViewState: @atomTtsView.serialize()
