# Description
#   hubot ちゃんに投票の司会をしてもらうよ
#
# Commands:
#   hubot <agenda>について投票開始 #<channnel> <key1> <key2>... - hubot start vote form
#   hubot <key>に投票 - hubot add `value` in `key`
#   hubot 投票結果 - hubot show `key`: `value`
#   hubot 投票終了 - hubot end vote form
#
# Author:
#   ArLE

Redis = require "redis"

class Vote
  voteJson = {
    start: false
    owner: ""
    channel: ""
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

  voteStart: (usr, channnel, keys, func) ->
    getVote((reply) ->
      if reply.start
        func false
      else
        reply.start = true
        reply.owner = usr
        reply.channnel = "##{channnel}"
        for key in keys
          reply.keys[key] = keyJsonTemp
        setVote reply, func(true)
    , ->
      func false
    )

  voteEnd: (usr, func) ->
    getVote((reply) ->
      if reply.start && (reply.owner == usr)
        setVote voteJson, func(true, reply.channnel)
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
      if reply.start && !reply.peoples[usr] && reply.keys[vKey]
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
  robot.respond /(.*)について投票開始\s#?(.*)\s項目:\s(.*)/i, (msg) ->
    agenda = msg.match[1]
    channel = msg.match[2]
    keys = msg.match[3].split(" ")
    vote.voteStart msg.message.user.name, channel, keys, (result) ->
      if result
        return ->
          robot.send {room:"##{channel}"}, """
          #{agenda}についてのアンケートを開始します！
          私にDMで \`\`\`<key>に投票\`\`\` と話しかけると投票出来ます！
          \`<key>\` には、#{" \`#{key}\` " for key in keys} のいずれかを入れてください！
          """
      else
        msg.send "fatal error"

  robot.respond /投票結果/i, (msg) ->
    vote.voteGet msg.message.user.name, (result, reply = {}) ->
      if result
        bufS = ""
        for key, content of reply.keys
          bufS += "\n> #{key} : #{content.value}"
        msg.reply "現在の状態は、#{bufS}\nです"
      else
        msg.send "fatal error"

  robot.respond /(.*)に投票/i, (msg) ->
    vKey = msg.match[1].trim()
    vote.voteVote msg.message.user.name, vKey, (result) ->
      if result
        return ->
          msg.reply "\`#{vKey}\` に投票しました！"
      else
        msg.send "fatal error"

  robot.respond /投票終了/i, (msg) ->
    vote.voteEnd msg.message.user.name, (result, channel) ->
      if result
        return ->
          robot.send {room:channel}, "アンケートを終了します。ご協力ありがとうございました！"
      else
        msg.send "fatal error"
