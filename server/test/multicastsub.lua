local skynet = require "skynet"
local datacenter = require "skynet.datacenter"
local mc = require "skynet.multicast"

local function recvChannel(channel, source, msg, ...)
    skynet.error("channel ID:", channel, "source:", skynet.address(source), "msg:", msg)
end
skynet.start(function()
    local channelid = datacenter.get("testmc")
    local channel = mc.new({
        channel = channelid,
        dispatch = recvChannel
    })
    channel:subscribe()
    skynet.timeout(500, function()
        channel:unsubscribe()
    end)
end)
