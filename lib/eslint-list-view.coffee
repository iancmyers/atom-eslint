eslint = require('eslint').linter
{$$, SelectListView} = require 'atom'

module.exports =
class ESLintView extends SelectListView

  initialize: (@editorView, @config) ->
    super
    @addClass('eslint-report popover-list')
    {@editor} = @editorView
    @handleEvents()

  setConfig: (@config) ->

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

    if @lang is 'JavaScript' or @editor.getTitle().match(/\.js$/)
      buffer = @editor.getBuffer()
      messages = eslint.verify(buffer.getText(), @config)
      @setItems messages.sort (a, b) ->
        a.line - b.line
    else
      @setItems []

  getEmptyMessage: (itemCount, filteredItemCount) ->
    console.log this
    if @lang isnt 'JavaScript'
      'Not a JavaScript file'
    else if itemCount is 0
      'No errors found'
    else if filteredItemCount is 0
      'No matching errors found'
    else
      super

  handleEvents: ->
    @editorView.command 'eslint:lint', => @toggle()
    @list.on 'mousewheel', (event) -> event.stopPropagation()

  selectNextItemView: ->
    super
    false

  selectPreviousItemView: ->
    super
    false

  viewForItem: ({message, line, column}) ->
    $$ ->
      @li =>
        @span class: 'eslint-line eslint-loc', line
        @span class: 'eslint-separator', ':'
        @span class: 'eslint-column eslint-loc', column
        @span class: 'eslint-message', message

  cancelled: ->
    super
    @editorView.focus()

  confirmed: ({line, column}) ->
    @cancel()
    @editor.setCursorBufferPosition([line - 1, column])

  attach: ->
    @editorView.appendToLinesView(this)
    @setPosition()
    @focusFilterEditor()

  setPosition: ->
    {top, left} = @editorView.offset()
    editorWidth = @editorView.width() / 2
    selectWidth = this.width() / 2
    leftPos = editorWidth - selectWidth + left
    @css(top: top + 10, left: leftPos, maxWidth: @editorView.width())

  populateList: ->
    super
    @setPosition()
