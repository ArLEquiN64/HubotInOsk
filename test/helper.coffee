global.assert = require 'power-assert'
global.sinon = require 'sinon'

global.shared_context = {}
global.shared_context.robot_is_running = (callback) ->
  helper = require 'hubot-mock-adapter-helper'
  robot = null

  beforeEach (done) ->
    helper.setupRobot (ret) ->
      robot = ret.robot
      callback ret
      done()

  afterEach ->
    robot.shutdown()
