{openExternal} = require 'shell'
{install} = require 'atom-package-deps'
{request} = require 'http'
{name, config} = require './package'#.json

activate = -> install name, false unless atom.inSpecMode()

browsers =
  'browser-plus': (repo) -> atom.workspace.open repo
  'pane-browser': (repo) ->
    atom.clipboard.write repo
    context = atom.views.getView atom.workspace
    try atom.commands.dispatch context, 'Pane Browser: Open from clipboard'
    catch error
      atom.notifications.addError error

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
  wordRegExp: /// (@[.\w_-]+/)? \b[.\w_-]+(?=['"`:]) ///g

  getSuggestionForWord: (editor, module, range) ->
    {scopeName} = editor.getGrammar()
    registry = config?.registry[scopeName]
    range: range
    callback: ->
      get =
        host: 'githublinker.herokuapp.com'
        path: "/q/#{registry}/#{module}"
      request(get, parse).end()

parse = (data) ->
  string = ''
  data.on 'data', (chunk) -> string += chunk
  data.on 'end', -> open JSON.parse string

open = ({url, error, message}) ->
  {browser} = atom.config.get name
  browse = browsers[browser] ? openExternal
  if error? then atom.notifications.addError name, detail: message
  else browse url

#-------------------------------------------------------------------------------
module.exports = {config, activate, octolink}
