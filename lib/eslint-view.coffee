eslint = require('eslint').linter
{$$, SelectListView} = require 'atom'

module.exports =
class ESLintView extends SelectListView

  initialize: (@editorView, @config) ->
    super
    @addClass('eslint-report overlay from-top')
    @editor = @editorView.getEditor()

    atom.workspaceView.command "eslint:toggle", => @toggle()

  getFilterKey: ->
    'message'

  toggle: ->
    if @hasParent()
      @cancel()
    else
      @lint()
      @attach()

  lint: ->
    @lang = @editor.getGrammar().name

    if @lang is 'JavaScript'
      buffer = @editor.getBuffer()
      messages = eslint.verify buffer.getText(), @config
      @setItems messages
    else
      @setItems []

  getEmptyMessage: (itemCount, filteredItemCount) ->
    if @lang isnt 'JavaScript'
      'Not a JavaScript file'
    else if itemCount is 0
      'No errors found'
    else if filteredItemCount is 0
      'No matching errors found'
    else
      super

  viewForItem: ({message, line, column}) ->
    $$ ->
      @li =>
        @span class: 'eslint-line eslint-loc', line
        @span class: 'eslint-separator', ':'
        @span class: 'eslint-column eslint-loc', column
        @span class: 'eslint-message', ' ' + message

  confirmed: ({line, column}) ->
    @cancel()
    @editor.setCursorBufferPosition([line - 1, column])

  attach: ->
    @storeFocusedElement()
    @editorView.append(this)
    @focusFilterEditor()
