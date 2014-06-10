ESLintListView = require './eslint-list-view'
ESLintGutterView = require './eslint-gutter-view'

fs = require 'fs'
_ = require 'underscore-plus'
eslint = require('eslint').linter

module.exports =

  activate: ->
    atom.config.setDefaults("eslint", configFile: '.eslintrc')
    @config = @config or @loadConfig()
    atom.workspaceView.eachEditorView (editorView) =>
      if editorView.attached and not editorView.mini
        eslintListView = new ESLintListView(editorView, @config)
        eslintGutterView = new ESLintGutterView(editorView, @config)

        editorView.on 'eslint:reload-config', =>
          @config = @loadConfig()
          eslintListView.setConfig(@config)
          eslintGutterView.setConfig(@config)

        editorView.on 'editor:will-be-removed', ->
          eslintListView.remove()
          eslintGutterView.unsubscribe()
          eslintGutterView.unsubscribeFromBuffer()

  loadConfig: ->
    configFileName = atom.config.get 'eslint.configFile'
    configPath = atom.project.getPath() + '/' + configFileName
    mergedConfig = {}
    defaults = eslint.defaults()

    if fs.existsSync configPath
      configFile = fs.readFileSync configPath, 'UTF8'
      try eslintrc = JSON.parse configFile
      catch e
        console.error 'Could not parse file (' + configFileName + ')'

      mergedConfig.rules = _.extend defaults.rules, eslintrc.rules
      mergedConfig.env = _.extend defaults.env, eslintrc.env
    else
      mergedConfig = defaults
    mergedConfig
