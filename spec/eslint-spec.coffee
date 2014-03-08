{WorkspaceView, EditorView} = require 'atom'
path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'

ESLintGutterView = require '../lib/eslint-gutter-view'

describe "Atom ESLint", ->
  [editorView, projectPath] = []

  beforeEach ->
    projectPath = temp.mkdirSync('eslint-spec-')
    fs.copySync(path.join(__dirname, 'fixtures', 'working-dir'), projectPath)
    atom.project.setPath(projectPath)

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('eslint')

  describe "ESLintGutterView", ->

    it "highlights error lines", ->
      atom.workspaceView.openSync('quicksort.js')
      editorView = atom.workspaceView.getActiveView()

      nextTick = false
      setImmediate -> nextTick = true
      waitsFor -> nextTick

      runs ->
        expect(editorView.find('.eslint-gutter-error').length).toBe 4

    it "updates error lines on save", ->
      spyOn(ESLintGutterView.prototype, 'lint')

      atom.workspaceView.openSync('clean.js')
      editorView = atom.workspaceView.getActiveView()

      {editor} = editorView
      editor.setCursorBufferPosition(2,19)
      editor.insertText(';')

      buffer = editor.getBuffer()
      buffer.emit 'saved'

      nextTick = false
      setImmediate -> nextTick = true
      waitsFor -> nextTick

      runs ->
        expect(ESLintGutterView.prototype.lint.calls.length).toBe 2

    it "reloads the config on eslint:config-reload", ->
      atom.workspaceView.openSync('quicksort.js')
      editorView = atom.workspaceView.getActiveView()

      fs.writeFileSync(path.join(projectPath, '.eslintrc'),
        fs.readFileSync(path.join(__dirname, 'fixtures', '.eslintrc')));

      editorView.trigger 'eslint:reload-config'

      nextTick = false
      setImmediate -> nextTick = true
      waitsFor -> nextTick

      runs ->
        expect(editorView.find('.eslint-gutter-error').length).toBe 2
