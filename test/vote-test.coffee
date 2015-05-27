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
