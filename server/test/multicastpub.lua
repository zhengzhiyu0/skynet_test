local skynet = require "skynet"
local mc = require "skynet.multicast"
local datacenter = require "skynet.datacenter"
local channel

local function task()
    local i = 0
    while i < 100 do
        skynet.sleep(100)
        channel:publish("data" .. i)
        i = i + 1
    end
    channel:delete()
    skynet.exit()
end

skynet.start(function()
    channel = mc.new()
    skynet.error("新建频道，id为" .. channel.channel)
    datacenter.set("testmc", channel.channel)
    skynet.fork(task)
end)
