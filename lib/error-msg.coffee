module.exports =
class ErrorMsg
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-tts')

    # Create message element
    message = document.createElement('div')
    message.textContent = """
      Your code is using an as-of-yet unsupported language feature.
      Plugin is being actively developed.
    """
    message.classList.add('message')
    @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: =>
    @element
