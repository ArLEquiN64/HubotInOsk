# Description:
#   Notifies TravisCI builds
#
# Author:
#   ArLE

module.exports = (robot) ->
  robot.router.post "/OSKMaster/travisCI/hooks", (req, res) ->
    envelope = room: "#osk-master-tuning"
    {payload} = req.body
    {status_message, build_url, message, number, repository, branch} = JSON.parse payload
    robot.send envelope, """
    TravisCI
    Build##{number} for #{repository.owner_name}/#{repository.name} #{if status_message is 'Pending' then 'started.' else "finished. (#{status_message})"}
    > #{message}
    #{build_url}
    """
    if branch == "master" && status_message == "Passed"
      command = "sh ~/batch/deployHubot.sh"
      robot.send envelope, "I'll be back!"
      @exec = require('child_process').exec
      @exec command, (error, stdout, stderr) ->
        robot.send envelope, error if error?
        robot.send envelope, stdout if stdout?
        robot.send envelope, stderr if stderr?
    res.end "OK"
