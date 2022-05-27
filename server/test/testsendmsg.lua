local skynet = require "skynet"
local datacenter = require "skynet.datacenter"

require "skynet.manager"

skynet.start(function()
    local msg, sz = skynet.pack("zhiyu", 16, 180)
    local arg1, arg2, arg3 = skynet.unpack(msg, sz)
    skynet.error(arg1, arg2, arg3)
    -- skynet.send(".testmsg", "lua", "say", "hello")
    local testmsg = datacenter.get("testmsg")
    -- skynet.send(testmsg, "lua", "say", "hello")
    -- skynet.call(testmsg, "lua", "say", "hello")
    local ok, ret = pcall(skynet.call, testmsg, "lua", "say", "hello")
    skynet.error("say ret: ", ret)
end)
