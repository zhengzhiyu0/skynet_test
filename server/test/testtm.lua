
local skynet = require "skynet"

function task()
    skynet.error("task", coroutine.running())
    -- skynet.timeout(500, task)
    skynet.sleep(200)
    skynet.error("time",skynet.time())
    skynet.error("now",skynet.now())
end

skynet.start(function ()
     skynet.error("start", coroutine.running())
    -- skynet.timeout(500, task)
    skynet.fork(task)
end)