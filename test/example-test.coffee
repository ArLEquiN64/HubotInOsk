require './helper'
TextMessage = require('hubot/src/message').TextMessage

describe 'example', ->
  {robot, user, adapter} = {}

  shared_context.robot_is_running (ret) ->
    {robot, user, adapter} = ret

  beforeEach ->
    require('../src/example')(robot)

  it 'hear "Badger"', (done) ->
    done()
    ###
    adapter.on 'reply', (envelope, strings) ->
      assert.equal envelope.user.name, 'mocha'
      assert.equal strings[0], "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
      done()

    adapter.receive new TextMessage user, 'Badger'
    ###
