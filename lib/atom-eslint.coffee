ESLintView = require './eslint-view'

module.exports =

  activate: ->

    atom.workspaceView.eachEditorView (editorView) ->
      editor = editorView.getEditor()

      if editor.getTitle().match /\.js$/
        eslintView = new ESLintView(editorView)

        editorView.on 'editor:path-changed', eslintView.subscribeToBuffer
        editorView.on 'editor:display-updated', eslintView.display
        editorView.on 'editor:will-be-removed', eslintView.unsubscribeFromBuffer
