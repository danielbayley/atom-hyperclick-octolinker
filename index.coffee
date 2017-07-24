{openExternal} = require 'shell'
{install} = require 'atom-package-deps'
resolve = require 'live-resolver/src/utils/do-request'
{name, config} = require './package'#.json

activate = -> install name, false unless atom.inSpecMode()

browsers =
  'browser-plus': (repo) -> atom.workspace.open repo
  'pane-browser': (repo) ->
    clipboard = atom.clipboard.readWithMetadata()
    atom.clipboard.write repo
    context = atom.views.getView atom.workspace
    atom.commands.dispatch context, 'Pane Browser: Open from clipboard'
    atom.clipboard.write clipboard

loaded = Object.keys(browsers).filter (browser) ->
  atom.packages.isPackageLoaded browser

config.browser =
  description: "Open links in your default browser, or within Atom."
  type: 'string'
  default: "External"
  enum: [ "External", loaded... ]

octolink = ->
  providerName: name
  priority: 1
  grammarScopes: Object.keys config?.registry
  wordRegExp: /\b[.\w_-]+(?=['"`:])/g

  getSuggestionForWord: (editor, module, range) ->
    {scopeName} = editor.getGrammar()
    {browser} = atom.config.get name
    range: range
    callback: ->
      resolve module, config?.registry[scopeName]
        .then browsers[browser] ? openExternal
        .catch atom.notifications.addError

#-------------------------------------------------------------------------------
module.exports = { config, activate, octolink }
