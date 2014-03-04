ESLintView = require './eslint-view'
fs = require 'fs'
_ = require 'underscore-plus'
eslint = require('eslint').linter

module.exports =
  eslintViews: []
  editorViewSubscription: null

  activate: ->
    @config = @config or @loadConfig()

    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        eslintView = new ESLintView(editorView, @config)

        editorView.on 'editor:will-be-removed', =>
          eslintView.remove() unless eslintView.hasParent()
          _.remove(@eslintViews, eslintView)

        @eslintViews.push(eslintView)

  deactivate: ->
    @editorViewSubscription?.off()
    @editorViewSubscription = null
    @eslintViews.forEach (eslintView) -> eslintView.remove()
    @eslintViews = []
    @config = null

  loadConfig: ->
    configPath = atom.project.getPath() + '/.eslintrc'
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
