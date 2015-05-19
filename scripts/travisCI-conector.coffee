# Description:
#   Notifies TravisCI builds
#
# Author:
#   ArLE

module.exports = (robot) ->
  robot.router.post "/OSKMaster/travisCI/hooks", (req, res) ->
    envelope = room: "#osk-master-tuning"
    {payload} = req.body
    {status_message, build_url, message, number, repository} = JSON.parse payload
    robot.sent envelope, """
    Build##{number} for #{repository.owner_name}/#{repository.name} #{if status_message is 'Pending' then 'started.' else "finished. (#{status_message})"}
    > #{message}
    #{build_url}
    """
    res.end "OK"
