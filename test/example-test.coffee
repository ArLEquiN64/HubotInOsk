assert = require 'power-assert'
sinon = require 'sinon'
Robot = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

describe 'example', ->
  robot = null
  user = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot null, 'mock-adapter', false, 'hubot'
    robot.adapter.on 'connected', ->
      require('../src/example')(robot)
      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'
      adapter = robot.adapter
      done()
    robot.run()

  afterEach -> robot.shutdown()

  it 'hear "Badger"', (done) ->
    done()
    ###
    adapter.on 'reply', (enveloop, strings) ->
      assert.equal enveloop.user.name, 'mocha'
      assert.equal strings[0], "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
      done()

    adapter.receive new TextMessage user, 'Badger'
    ###
