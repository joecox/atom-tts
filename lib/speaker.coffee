{spawn} = require 'child_process'

module.exports =
class TextSpeaker

  settings: null
  active: false
  process: null

  constructor: ->
    @settings = null

  speak: (text) ->
    @process = spawn('say')
    @active = true

    # Attach to `exit` event
    @process.on('exit', (code, signal) =>
      @active = false
    )

    @process.stdin.write(text)
    @process.stdin.end()

  stop: () ->
    if @active
      @process?.kill()
      return 1

  # Naive - will replace 'tts' substring regardless of context
  # Example - watts will be spoken as "wa text to speech"
  # replaceAbbreviations: (text) ->
  #   for abbrev, expand of @abbreviations
  #     text = text.replace(abbrev, expand)
  #
  #   return text
