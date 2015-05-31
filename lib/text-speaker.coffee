{spawn} = require 'child_process'

module.exports =
class TextSpeaker

  settings: null

  constructor: ->
    @settings = null

  speak: (text) ->
    say = spawn('say')
    say.stdin.write(text)
    say.stdin.end()
