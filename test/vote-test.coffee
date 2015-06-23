require './helper'
TextMessage = require('hubot/src/message').TextMessage
client = require 'redis'
          .createClient()

describe 'vote', ->
  {robot, user, adapter} = {}

  shared_context.robot_is_running (ret) ->
    {robot, user, adapter} = ret

  beforeEach ->
    require('../src/vote')(robot)

  it 'hear "vote start"', (done) ->
    client.set "vote", JSON.stringify(
      start: false
      owner: ""
      channel: ""
      keys: {}
      peoples: {}
    ), (err, Keys_repliys) ->
      if err
        throw err
    
    adapter.on 'send', (envelope, strings) ->
      assert.equal envelope.room, '#TestRoom'
      assert.equal strings[0], """
        Testについてのアンケートを開始します！
        私にDMで \`\`\`<key>に投票\`\`\` と話しかけると投票出来ます！
        \`<key>\` には、 \`test1\` , \`test2\` , \`test3\`  のいずれかを入れてください！
      """
      done()

    adapter.receive new TextMessage user, 'hubot Testについて投票開始 #TestRoom 項目: test1 test2 test3'

  it 'hear "vote to test2"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.room, '#mocha'
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "\`test2\` に投票しました！"
      done()

    adapter.receive new TextMessage user, 'hubot test2に投票'

  it 'hear "vote status"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.room, '#mocha'
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], """
        現在の状態は、
        > test1 : 0
        > test2 : 1
        > test3 : 0
        です
      """
      done()

    adapter.receive new TextMessage user, 'hubot 投票結果'

  it 'hear "vote end"', (done) ->
    adapter.on 'send', (envelope, strings) ->
      assert.equal envelope.room, '#TestRoom'
      assert.equal strings[0], "アンケートを終了します。ご協力ありがとうございました！"
      done()

    adapter.receive new TextMessage user, 'hubot 投票終了'
