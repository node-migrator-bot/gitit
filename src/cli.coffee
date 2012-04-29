fs      = require 'fs'
path    = require 'path'
{spawn, exec} = require 'child_process'


@Gitit = 

  opened: false

  open: (url) ->  
    @opened = true
    exec "open #{url}"


  hostURL: (host, user, repo) ->
    switch host
      when "github.com" then "https://#{host}/#{user}/#{repo}"
      else # TODO: Support more services


  actions:
    ".git/config": (filePath) ->
      fs.readFile filePath, (err, data) =>
        [matched, host, user, repo] = data.toString().match ///.*
          \[remote\s[\"\']origin[\"\']\]        # origin declaration
          [^\[]*                                # match anything until next config declaration
          .*url\s?=\s?.*@(.*):(.*)/(.*)\.git\n  # extract remote url details 
        ///        
        @open(@hostURL(host, user, repo)) if host? and user? and repo?


    "package.json": (filePath) -> 
      package = require(filePath)
      url =  package.repository?.url ? ""
      if url.length is 0 and package.name.toString().length > 0
        url = "'https://github.com/search?utf8=✓&q=#{package.name}&type=Everything&start_value=1'"
      @open(url) if url.length > 0


  run: ->
    for file, action of @actions
      do (file, action) =>
        filePath = path.resolve(file)
        path.exists filePath, (exists) => action.call(this, filePath) if exists and not @opened

