/* global atom */
var ESLintView = require('./eslint-view');

module.exports = {

  activate: function () {

    atom.workspaceView.eachEditorView(function (editorView) {
      var editor = editorView.getEditor()
        , eslintView;

      if (editor.getTitle().match(/\.js$/)) {
        eslintView = new ESLintView(editorView);

        editorView.on('editor:path-changed', eslintView.subscribeToBuffer.bind(eslintView));
        editorView.on('editor:display-updated', eslintView.display.bind(eslintView));
        editorView.on('editor:will-be-removed', eslintView.unsubscribeFromBuffer.bind(eslintView));
      }
    });

  }

};
