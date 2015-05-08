# Commands:
# hubot hello - reply hello!!
module.exports = (robot) ->
  robot.hear /HELLO$/i, (msg) ->
    msg.reply "hello!!"

  robot.respond /THANKS$/i, (msg) ->
    msg.reply "sure!"

  robot.respond /WHO ARE YOU$/i, (msg) ->
    msg.reply "I am " + robot.name

  robot.hear /hoshinotoon$/i, (msg) ->
    msg.send "hoshinotoon"
