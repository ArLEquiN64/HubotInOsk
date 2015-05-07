# Description:
#
#
# Dependencies:
#   "redis": "0.8.4"
#
# Commands:
#
#
# Authors:
#   ArLE

Redis = require "redis"
Bcrypt = require "bcrypt"

module.exports = (robot) ->
  robot.respond /bcrypt-gen (.*)$/i, (msg) ->
    b_key = msg.match[1].trim()
    salt = Bcrypt.gen_salt_sync(10)
    hash = Bcrypt.encrypt_sync(b_key, salt)
    msg.send 'salt -> ' + salt
    msg.send 'hash -> ' + hash
    result = Bcrypt.compare_sync(b_key, hash)
    msg.send 'hash==' + b_key + ' -> ' + result
    result = Bcrypt.compare_sync('aa' + b_key, hash)
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
