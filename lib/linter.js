/* global atom */
var eslint = require('eslint').linter
  , fs = require('fs')
  , _ = require('underscore');

function lint (editor, editorView) {
  var text, config, messages, gutter;

  if (editor.getTitle().match(/.js$/)) {

    text = editor.getText();
    config = loadConfig();
    messages = eslint.verify(text, config);
    gutter = editorView.gutter;

    gutter.removeClassFromAllLines('atom-eslint-error');

    messages.forEach(function (message) {
      gutter.addClassToLine(message.line - 1, 'atom-eslint-error');
    });
  }
}

function loadConfig () {
  var configFile
    , eslintrc
    , mergedConfig = {}
    , configPath = atom.project.path + '/.eslintrc'
    , defaults = eslint.defaults();

  if (fs.existsSync(configPath)) {
    configFile = fs.readFileSync(configPath,'UTF8');
    try {
      eslintrc = JSON.parse(configFile);
    } catch (e) {
      console.error('Could not parse .eslintrc file');
    }

    mergedConfig.rules = _.extend(defaults.rules, eslintrc.rules);
    mergedConfig.env = _.extend(defaults.env, eslintrc.env);
  } else {
    mergedConfig = defaults;
  }

  return mergedConfig;
}

exports.lint = lint;
