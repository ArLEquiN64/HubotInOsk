# Commands:
# hubot hello - reply hello!!
module.exports = (robot) ->
  robot.hear /.*hello.*/i, (msg) ->
    msg.reply "hello!!"

  robot.respond /.*thanks.*/i, (msg) ->
    msg.reply "sure!"

  robot.respond /who are you?/i, (msg) ->
    msg.reply "I am " + robot.name

  robot.respond /echo/i, (msg) ->
    msg.reply msg.getBody()
