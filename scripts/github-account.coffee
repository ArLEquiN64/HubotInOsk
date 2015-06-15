redis = require 'redis'
http = require 'http'
TOKEN = process.env.SLACK_WEBAPI_TOKEN

class GithubAccountHelper
  client = redis.createClient()
  getPeple = () ->
    http.get "https://slack.com/api/users.list?token=#{TOKEN}", (res) ->
      body = ''
      res.setEncoding 'utf8'

      res.on 'data', (chunk) ->
        body += chunk

      res.on 'end', (res) ->
        ret = JSON.parse body
        peoples = ret.members.name
        return peoples
    .on 'error', (e) ->
      console.log e.message

  checkAccount = (cb) ->
    client.get "accounts", (err, reply) ->
      if err
        throw err
      else if reply
        reply
      else
        cb()

  addAccount: (usr, service, name, cb) ->
    client.get "accounts", (err, reply) ->
      if err
        throw err
      else if reply
        json = JSON.parse reply
        for obj in json.members
          if obj.name == usr
            obj[service] = name
            sc = true
        if !sc
          json.members.push({
            name: usr
            "#{service}": name
          })
        client.set "accounts", JSON.stringify(json), (err, Keys_repliys) ->
          if err
            throw err
          else

      else


module.exports = (robot) ->
  gAH = new GithubAccountHelper()
  robot.respond /peoples/i, (msg) ->
    gAH.getPeple (obj) ->
      msg.send obj

  robot.respond /add account (.*) (.*)/i, (msg) ->
    gAH.addAccount msg.message.user.name, msg.match[1], msg.match[2], (obj) ->
      msg.send "Success"
