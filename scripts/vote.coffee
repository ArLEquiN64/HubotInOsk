# Description
#   hubot ちゃんに投票の司会をしてもらうよ
#
# Commands:
#   hubot vote 投票開始 <key1> <key2>... - hubot start vote form
#   hubot vote <key>に投票 - hubot add value in key
#   hubot vote 投票結果 - hubot show key: value
#   hubot vote 投票終了 - hubot end vote form
#
# Author:
#   ArLE

Redis = require "redis"

class Vote
  voteJson = {
    start: false
    owner: ""
    keys: {}
    peoples: {}
  }
  keyJsonTemp = {
    detail: ""
    value: 0
  }
  client = Redis.createClient()
  getVote = (sFunc, fFunc) ->
    client.get "vote", (err, reply) ->
      if err
        throw err
      else if reply
        sFunc JSON.parse(reply)
      else
        fFunc()

  setVote = (setObj, func) ->
    client.set "vote", JSON.stringify(setObj), (err, Keys_repliys) ->
      if err
        throw err
      else
        func()

  voteStart: (usr, keys, func) ->
    getVote((reply) ->
      if reply.start
        func false
      else
        reply.start = true
        reply.owner = usr
        for key in keys
          reply.keys[key] = keyJsonTemp
        setVote reply, func(true)
    , ->
      func false
    )

  voteEnd: (usr, func) ->
    getVote((reply) ->
      if reply.start && (reply.owner == usr)
        setVote voteJson, func(true)
      else
        func false
    , ->
      func false
    )

  voteGet: (usr, func) ->
    getVote((reply) ->
      if reply.start && (reply.owner == usr)
        func true, reply
      else
        func false
    , ->
      func false
    )

  voteVote: (usr, vKey, func) ->
    getVote((reply) ->
      if reply.start && !reply.peoples[usr]
        reply.peoples[usr] = true
        reply.keys[vKey].value++
        setVote reply, func(true)
      else
        func false
    , ->
      func false
    )


module.exports = (robot) ->
  vote = new Vote()
  robot.respond /vote 投票開始 (.*)/i, (msg) ->
    keys = msg.match[1].split(" ")
    vote.voteStart msg.message.user.name, keys, (result) ->
      if result
        return ->
          msg.send """投票を開始します！
                      私にDMで \"vote -v <key>\" と話しかけると投票出来ます！
                      <key> には、#{msg.match[1]} のいずれかを入れてください！"""
      else
        msg.send "fatal error"

  robot.respond /vote 投票結果/i, (msg) ->
    vote.voteGet msg.message.user.name, (result, reply = {}) ->
      if result
        bufS = ""
        for key, content of reply.keys
          bufS += "\n#{key} : #{content.value}"
        msg.send "現在の状態は、#{bufS}です"
      else
        msg.send "fatal error"

  robot.respond /vote (.*)に投票/i, (msg) ->
    vKey = msg.match[1].trim()
    vote.voteVote msg.message.user.name, vKey, (result) ->
      if result
        return ->
          msg.send "#{vKey}に投票しました！"
      else
        msg.send "fatal error"

  robot.respond /vote 投票終了/i, (msg) ->
    vote.voteEnd msg.message.user.name, (result) ->
      if result
        return ->
          msg.send "投票を終了します！"
      else
        msg.send "fatal error"
