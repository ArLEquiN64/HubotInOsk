assert = require 'power-assert'
sinon = require 'sinon'
Robot = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'HelloHubot', ->
  robot = null
  user = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot null, 'mock-adapter', false, 'hubot'
    robot.adapter.on 'connected', ->
      require('../src/HelloHubot')(robot)
      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'
      adapter = robot.adapter
      done()
    robot.run()

  afterEach -> robot.shutdown()

  it 'hear "hello"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "hello!!"
      done()

    adapter.receive new TextMessage user, 'hello'

  it 'reply "sure"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "sure!"
      done()

    adapter.receive new TextMessage user, 'hubot thanks'

  it 'reply "who are you"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "I am hubot"
      done()

    adapter.receive new TextMessage user, 'hubot Who are you'
