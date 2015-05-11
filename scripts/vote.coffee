# Description
#   hubot scripts for diagnosing hubot
#
# Commands:
#   hubot vote -s - aa
#
# Author:
#   ArLE

Redis = require "redis"


module.exports = (robot) ->
  robot.respond /vote -s/i, (msg) ->
    client = Redis.createClient()
    client.get "vote", (err, reply) ->
      if err
        throw err
      else if reply
        result = JSON.parse(reply)
        if result["start"]
          msg.send "already started"
        else
          result["start"] = true
          client.set "vote", JSON.stringify(result), (err, keys_replies) ->
            if err
              throw err
          msg.send "start \'vote -v <value>\' send"
      else
        send = {
          "start": true
          "key": []
        }
        client.set "vote", JSON.stringify(send), (err, keys_replies) ->
          if err
            throw err
        msg.send "start \'vote -v <value>\' send"

  robot.respond /vote -a (.*)/i, (msg) ->
    client = Redis.createClient()
    buf = msg.match[1].trim()
    client.get "#{buf}", (err, reply) ->
      if err
        throw err
      else if reply
        msg.reply "already exist #{buf}"
      else
        client.get "vote", (err, reply) ->
          if err
            throw err
          else if reply
            result = JSON.parse(reply)
            result["key"].push(buf)
            client.set "vote", JSON.stringify(result), (err, keys_replies) ->
              if err
                throw err
          else
            msg.send "fatal error"
        client.set "#{buf}", 0, (err, keys_replies) ->
          if err
            throw err
        msg.send "add value #{buf}"

  robot.respond /vote -g/i, (msg) ->
    client = Redis.createClient()
    client.get "vote", (err, reply) ->
      if err
        throw err
      else if reply
        result = JSON.parse(reply)
        for value in result["key"]
          client.get "#{value}", (err, reply2) ->
            if err
              throw err
            else if reply2
              msg.send "#{value}: #{reply2}"
            else
              msg.send "fatal error"
      else
        msg.send "fatal error"

  robot.respond /vote -v (.*)/i, (msg) ->
    client = Redis.createClient()
    buf = msg.match[1].trim()
    usr = msg.message.user["name"]
    client.get "#{buf}", (err, reply) ->
      if err
        throw err
      else if reply
        client.get "vote", (err, reply2) ->
          if err
            throw err
          else if reply2
            result = JSON.parse(reply2)
            if result["#{usr}"]
              msg.send "already voted"
            else
              client.incr "#{buf}", (err, keys_replies) ->
                if err
                  throw err
              result["#{usr}"] = true
              client.set "vote", JSON.stringify(result), (err, keys_replies) ->
                if err
                  throw err
              msg.reply "#{usr} voted #{buf}"
          else
            msg.send "fatal error"
      else
        msg.send "check value #{buf}"

  robot.respond /vote -c/i, (msg) ->
    client = Redis.createClient()
    client.get "vote", (err, reply) ->
      if err
        throw err
      else if reply
        result = JSON.parse(reply)
        for value in result["key"]
          client.del "#{value}", (err) ->
            if err
              throw err
      else
        msg.send "fatal error"
    client.del "vote", (err) ->
      if err
        throw err
