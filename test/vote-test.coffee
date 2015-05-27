assert = require 'power-assert'
sinon = require 'sinon'
Robot = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'vote', ->
  robot = null
  user = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot null, 'mock-adapter', false, 'hubot'
    robot.adapter.on 'connected', ->
      require('../src/vote')(robot)
      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'
      adapter = robot.adapter
      done()
    robot.run()

  afterEach -> robot.shutdown()

  it 'reply "投票開始"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.room, '#mocha'
      assert.equal strings[0], """
      TESTについてのアンケートを開始します！
      私にDMで \`\`\`<key>に投票\`\`\` と話しかけると投票出来ます！
      \`<key>\` には、\`test1\`,\`test2\`,\`test3\` のいずれかを入れてください！
      """
      done()

    adapter.receive new TextMessage user, 'TESTについて投票開始 #mocha 項目: test1 test2 test3'
