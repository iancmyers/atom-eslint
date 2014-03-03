/* global atom */
var eslint = require('eslint').linter
  , fs = require('fs')
  , _ = require('underscore');

function ESLintView (editorView) {
  this.editorView = editorView;
  this.editor = editorView.getEditor();
  this.config = this.loadConfig();

  this.subscribeToBuffer();
}

ESLintView.prototype.update = function () {
  this.lint();
  this.display();
};

ESLintView.prototype.lint = function () {
  var text = this.buffer.getText();
  this.messages = eslint.verify(text, this.config);
};

ESLintView.prototype.display = function () {
  if (!this.messages) { return; }

  var gutter = this.editorView.gutter;
  gutter.removeClassFromAllLines('atom-eslint-error');

  this.messages.forEach(function (message) {
    gutter.addClassToLine(message.line - 1, 'atom-eslint-error');
  });
};

ESLintView.prototype.subscribeToBuffer = function () {
  this.unsubscribeFromBuffer();

  var buffer = this.buffer = this.editor.getBuffer();
  buffer.on('contents-modified', this.update.bind(this));
};

ESLintView.prototype.unsubscribeFromBuffer = function () {
  if (this.buffer) {
    this.buffer.off('contents-modified', this.update);
    this.buffer = null;
  }
};

ESLintView.prototype.loadConfig = function () {
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
};

module.exports = ESLintView;
