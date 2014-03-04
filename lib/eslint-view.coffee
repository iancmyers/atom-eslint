eslint = require('eslint').linter
{$, $$, SelectListView} = require 'atom'

module.exports =
class ESLintView extends SelectListView

  initialize: (@editorView, @config) ->
    super
    @addClass('eslint-report overlay from-top')
    @editor = @editorView.getEditor()
    @buffer = @editor.getBuffer()

    atom.workspaceView.command "eslint:toggle", @toggle

  viewForItem: ({message, line, column}) ->
    $$ ->
      @li =>
        @span class: 'eslint-line eslint-loc', line
        @span class: 'eslint-separator', ':'
        @span class: 'eslint-column eslint-loc', column
        @span class: 'eslint-message', ' ' + message

  toggle: =>
    if @hasParent()
      @cancel()
    else
      @attach()

  getEmptyMessage: (itemCount, filteredItemCount) ->
    if itemCount is 0
      'No errors found.'
    else if filteredItemCount is 0
      'No matching errors found.'
    else
      super

  getFilterKey: ->
    'message'

  lint: ->
    text = @buffer.getText()
    messages = eslint.verify text, @config
    messages

  attach: ->
    @storeFocusedElement()
    @setItems(@lint())
    @editorView.append(this)
    @focusFilterEditor()

  confirmed: ({line, column}) ->
    @cancel()
    @editor.setCursorBufferPosition([line - 1, column])
