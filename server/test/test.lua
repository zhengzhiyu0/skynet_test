local skynet = require "skynet"

local function task(name)
    local i = 0
    skynet.error(name, "开始任务")

    while i < 20000000 do
        i = i + 1
        if i % 500000 == 0 then
            skynet.yield()
            skynet.error(name, "task yield")
        end
    end
    skynet.error(name, "结束任务", i)
end

skynet.start(function()
    skynet.error("server first test")

    -- local name = skynet.getenv("myname")
    -- skynet.error("my name is " .. name)

    -- skynet.timeout(1000,function()
    --     skynet.error("时间到...")
    -- end)

    skynet.fork(task, "task1")
    skynet.fork(task, "task2")
end)
