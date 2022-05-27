local skynet = require "skynet"
require "skynet.manager" -- import skynet.register

local CMD = {}

function CMD.say(str)
    skynet.error("say=========" .. str)
    return "ok"
end

skynet.start(function()
    skynet.register ".testmsg"

    skynet.dispatch("lua", function(_, _, command, ...)
        local f = CMD[command]
        local r = f(...)
        if r then
            skynet.ret(skynet.pack(r))
        end
    end)

    -- skynet.dispatch("lua", function(session, address, ...)
    --     skynet.error("session==========", session)
    --     skynet.error("address==========", address)
    --     skynet.error("address skynet==========", skynet.address(address))

    --     local args = {...}
    --     for k, v in pairs(args) do
    --         skynet.error("agr_" .. k .. ": ", v)
    --     end
    -- end)
end)
