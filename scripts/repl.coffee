# Description
#   hubot relp with paiza.io
#
# Commands:
#   hubot relp <language>:<source> - compile `source` with `language` and reply stdout
#
# Author:
#   ArLE

http = require 'http'
querystring = require 'querystring'
redis = require 'redis'
sl = require('sleep-async')()

class Repl
  redCli = redis.createClient()
  option = {
    hostname: 'api.paiza.io'
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }
  apiKey = 'guest'

  create: (usr, lang, source, func) ->
    option.method = 'POST'
    option.path = '/runners/create/'
    form = querystring.stringify {
      source_code: source
      language: lang
      api_key: apiKey
    }
    req = http.request option, (res) ->
      body = ''
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', ->
        body = JSON.parse body
        if body.error
          func body
        else
          redCli.set "repl-#{usr}", body.id, (err, keys_replies) ->
            if err
              throw err
            else
              func body
    req.end form

  get: (usr, func) ->
    redCli.get "repl-#{usr}", (err, reply) ->
      if err
        throw err
      else if reply
        http.get "http://api.paiza.io/runners/get_details?id=#{reply}&api_key=#{apiKey}", (res) ->
          body = ''
          res.on 'data', (chunk) ->
            body += chunk
          res.on 'end', ->
            body = JSON.parse body
            if body.error
              func body
            else if body.status == 'completed'
              redCli.del "repl-#{usr}", (err, reply) ->
                if err
                  throw err
              func body
            else
              func body
      else
        func {error: "fatal error"}

module.exports = (robot) ->
  repl = new Repl()
  robot.respond /repl ([^:]*):([^]*)/i, (msg) ->
    repl.create msg.message.user.name, msg.match[1], msg.match[2], (obj) ->
      if obj.error
        msg.send obj.error
      else
        msg.send "OK. please wait 1 seconds..."
        sl.sleep 1000, ->
          repl.get msg.message.user.name, (gObj) ->
            if gObj.error
              msg.send gObj.error
            else if gObj.status == 'completed'
              if gObj.build_result?
                msg.send "build result : #{gObj.build_result}"
                if gObj.build_result == 'success'
                  msg.send "stdout > ```#{gObj.stdout}```"
                else
                  msg.send "build err > ```#{gObj.build_stderr}```"
              else if gObj.result == 'success'
                msg.send "result : #{gObj.result}\nstdout > ```#{gObj.stdout}```"
              else
                msg.send "result : #{gObj.result}\nerr > ```#{gObj.stderr}```"
