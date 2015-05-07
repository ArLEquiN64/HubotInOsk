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

module.exports = (robot) ->
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
    salt = Bcrypt.genSaltSync(10)
    gUser = msg.match[1].trim()
    gRepo = msg.match[2].trim()
    msg.send 'user name is ' + gUser
    msg.send 'repository name is ' + gRepo
    cry_key = MKEY + gUser + gRepo
    gToken = Bcrypt.hashSync(cry_key, salt)
    msg.send 'token of ' + gUser + '/' + gRepo + ' is ' gToken
