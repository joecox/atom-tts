{exec} = require 'child_process'
path   = require 'path'

module.exports =
class AbbreviationManager

  root: null

  constructor: ->
    cwd = path.dirname atom.workspace.getActiveTextEditor().getPath()
    p = exec 'git rev-parse --show-toplevel',
          { 'cwd': cwd }
          (err, stdout, stderr) ->
            if err
            then console.log(err)
            else @root = stdout
