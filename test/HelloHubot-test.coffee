require './helper'
TextMessage = require('hubot/src/message').TextMessage

describe 'HelloHubot', ->
  {robot, user, adapter} = {}

  shared_context.robot_is_running (ret) ->
    {robot, user, adapter} = ret

  beforeEach ->
    require('../src/HelloHubot')(robot)

  it 'hear "hello"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "hello!!"
    , done

    adapter.receive new TextMessage user, 'hello'

  it 'reply "sure"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "sure!"
    , done

    adapter.receive new TextMessage user, 'hubot thanks'

  it 'reply "who are you"', (done) ->
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "I am hubot"
    , done

    adapter.receive new TextMessage user, 'hubot Who are you'
