/* global atom */
var lint = require('./linter').lint;

module.exports = {

  activate: function () {

    atom.workspaceView.eachEditorView(function (editorView) {
      var editor = editorView.getEditor()
        , buffer = editor.getBuffer()
        , lintEditor = lint.bind(undefined, editor, editorView);

      buffer.on('saved', lintEditor);

      lint(editor, editorView);
    });

  },

  deactivate: function () {
    // TODO: Be a good person a unsubscribe from the events here.
  }

};
