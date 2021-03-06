local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local datacenter = require "skynet.datacenter"

local max_client = 64

skynet.start(function()
    skynet.error("Server start")
    skynet.uniqueservice("protoloader")
    if not skynet.getenv "daemon" then
        local console = skynet.newservice("console")
    end
    skynet.newservice("debug_console", 8000)
    skynet.newservice("simpledb")

    -- local testmsg = skynet.newservice("testmsg")
    -- datacenter.set("testmsg",testmsg)
    -- local testsendmsg = skynet.newservice("testsendmsg")
    -- datacenter.set("testsendmsg",testsendmsg)
    local multicastpub = skynet.newservice("multicastpub")
    datacenter.set("multicastpub", multicastpub)
    local multicastsub = skynet.newservice("multicastsub")
    datacenter.set("multicastsub", multicastsub)

    local watchdog = skynet.newservice("watchdog")
    skynet.call(watchdog, "lua", "start", {
        port = 8888,
        maxclient = max_client,
        nodelay = true
    })
    skynet.error("Watchdog listen on", 8888)
    skynet.exit()
end)
