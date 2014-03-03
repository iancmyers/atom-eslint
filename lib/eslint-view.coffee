eslint = require('eslint').linter
fs = require 'fs'
_ = require 'underscore'

module.exports =
class ESLintView

  constructor: (@editorView) ->
    @editor = @editorView.getEditor()
    @config = @loadConfig()

    @subscribeToBuffer()

  subscribeToBuffer: =>
    @unsubscribeFromBuffer()

    if @buffer = @editor.getBuffer()
      @buffer.on 'contents-modified', @update

  unsubscribeFromBuffer: =>
    if @buffer?
      @buffer.off 'contents-modified', @update
      @buffer = null

  update: =>
    @lint()
    @display()

  lint: ->
    text = @buffer.getText()
    @messages = eslint.verify text, @config

  display: =>
    if @messages?
      gutter = @editorView.gutter
      gutter.removeClassFromAllLines 'atom-eslint-error'

      @messages.forEach (message) ->
        gutter.addClassToLine message.line - 1, 'atom-eslint-error'

  loadConfig: ->
    configPath = atom.project.path + '/.eslintrc'
    mergedConfig = {}
    defaults = eslint.defaults()

    if fs.existsSync configPath
      configFile = fs.readFileSync configPath, 'UTF8'
      try eslintrc = JSON.parse configFile
      catch e
        console.error 'Could not parse .eslintrc file'

      mergedConfig.rules = _.extend defaults.rules, eslintrc.rules
      mergedConfig.env = _.extend defaults.env, eslintrc.env
    else
      mergedConfig = defaults

    mergedConfig
