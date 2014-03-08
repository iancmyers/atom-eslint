eslint = require('eslint').linter
{Subscriber} = require 'emissary'

module.exports =
class ESLintGutterView
  Subscriber.includeInto(this)

  constructor: (@editorView, @config) ->
    {@editor, @gutter} = @editorView

    @messages = []

    @subscribe @editorView, 'editor:path-changed', @subscribeToBuffer
    @subscribe @editorView, 'editor:display-updated', @renderErrors

    @subscribeToBuffer()

  setConfig: (@config) ->
    @scheduleUpdate()

  unsubscribeFromBuffer: ->
    if @buffer?
      @removeErrors()
      @buffer.off 'saved', @lint
      @buffer = null

  subscribeToBuffer: =>
    @unsubscribeFromBuffer()

    if @buffer = @editor.getBuffer()
      @scheduleUpdate()
      @buffer.on 'saved', @lint

  scheduleUpdate: ->
    setImmediate(@lint)

  lint: =>
    @lang = @editor.getGrammar().name
    return unless @buffer? and (@lang is 'JavaScript' or @editor.getTitle().match(/\.js$/))
    @messages = eslint.verify(@buffer.getText(), @config)
    console.log @messages
    @messages.sort (a, b) ->
      a.line - b.line
    @renderErrors()

  removeErrors: =>
    if @gutter.hasESLintMessages
      @gutter.removeClassFromAllLines('eslint-gutter-error')
      @gutter.hasESLintMessages = false

  renderErrors: =>
    return unless @gutter.isVisible()
    @removeErrors()

    linesHighlighted = false
    for {line} in @messages
      linesHighlighted |= @gutter.addClassToLine(line - 1, 'eslint-gutter-error')
    @gutter.hasESLintMessages = linesHighlighted
