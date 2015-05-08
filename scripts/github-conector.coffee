# Description:
#
#
# Dependencies:
#   "redis": "0.8.4"
#
# Configration:
#   HUBOT_BCRYPT_MASTER_GITHUB
#
# Commands:
#   hubot get token -github <username>/<repositoryname> - respond token
#
# Authors:
#   ArLE

Redis = require "redis"
Bcrypt = require "bcrypt"
MKEY = process.env.HUBOT_BCRYPT_MASTER_GITHUB

class GithubConector
  compare = (repoName) ->
    result = Bcrypt.compareSync(MKEY+repoName)
    return result

  getToken: (repoName) ->
    salt = Bcrypt.genSaltSync(10)
    gToken = Bcrypt.hashSync(MKEY+repoName, salt)
    return gToken

module.exports = (robot) ->
  gConector = new GithubConector()
  robot.respond /bcrypt-gen (.*)$/i, (msg) ->
    b_key = msg.match[1].trim()
    salt = Bcrypt.genSaltSync(10)
    hash = Bcrypt.hashSync(b_key, salt)
    msg.send 'salt -> ' + salt
    msg.send 'hash -> ' + hash
    result = Bcrypt.compareSync(b_key, hash)
    msg.send 'hash==' + b_key + ' -> ' + result
    result = Bcrypt.compareSync('aa' + b_key, hash)
    msg.send 'hash==aa' + b_key + ' -> ' + result

  robot.respond /redis-get (.*)$/i, (msg) ->
    redis_key = msg.match[1].trim()
    client = Redis.createClient()
    client.get "#{redis_key}", (err, reply) ->
      if err
        throw err
      else if reply
        result = JSON.parse(reply)
        msg.send result
      else
        msg.send "key: #{redis_key} is not find"

  robot.respond /redis-set ([^\s]*) (.*)$/i, (msg) ->
    redis_key = msg.match[1].trim()
    redis_val = msg.match[2].trim()
    client = Redis.createClient()
    client.set "#{redis_key}", "#{redis_val}", (err, keys_replies) ->
      if err
        throw err

  robot.respond /get token -github (.*)\/(.*)$/i, (msg) ->
    gUser = msg.match[1].trim()
    gRepo = msg.match[2].trim()
    gToken = gConector.getToken("#{gUser}/#{gRepo}")
    msg.send "token of #{gUser}/#{gRepo} is #{gToken}"
