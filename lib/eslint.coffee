ESLintView = require './eslint-view'
fs = require 'fs'
_ = require 'underscore'
eslint = require('eslint').linter

module.exports =
  config: {}
  eslintViews: []
  editorViewSubscription: null

  activate: (state) ->
    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        config = state.config or @loadConfig()
        eslintView = new ESLintView(editorView, config)

        editorView.on 'editor:will-be-removed', =>
          eslintView.remove() unless eslintView.hasParent()
          _.remove(@eslintViews, eslintView)
        @eslintViews.push(eslintView)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @eslintViews.forEach (eslintView) -> eslintView.remove()
    @eslintViews = []

  serialize: ->
    config: @config

  loadConfig: ->
    unless @config?
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

    @config = mergedConfig
