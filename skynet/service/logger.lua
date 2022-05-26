local skynet = require "skynet"
require "skynet.manager"

local MAIN_LOG_NAME = "skynet"
local ZERO_MOVE_TIME = 0 --second
local DEFAULT_FILE_MODE = "w+"

local init = false
local log_service = {}
local service_file = {}
local log_service_no_change = {}
local dir_path = {}
local file_mode = {}
local is_daemon = skynet.getenv("daemon") ~= nil
local log_path = skynet.getenv("logpath")

local function check_exists(path)
    if not os.rename(path, path) then
        os.execute("mkdir -p " .. path)
    end
end

local function time_dir()
    local now = math.floor(skynet.time())
    local curr_time = {}
    curr_time.year = os.date("%Y", now)
    curr_time.month = os.date("%m", now)
    curr_time.day = os.date("%d", now)

    log_path = skynet.getenv("logpath")..curr_time.year..curr_time.month..curr_time.day.."/"
    check_exists(log_path)
    for _, path in pairs(dir_path) do
        check_exists(log_path..path)
    end

    for source, file in pairs(service_file) do
        if not log_service_no_change[source] then
            service_file[source] = nil
            io.close(file)
        end
    end

    local tomorrow_zore_time = os.time({year=curr_time.year, month=curr_time.month, day=curr_time.day, hour=0,min=0,sec=0}) + 86400 + ZERO_MOVE_TIME

    skynet.timeout((tomorrow_zore_time-now)*100, function()
        time_dir()
    end )
end

local function file_path(path_file)
    return log_path .. path_file .. ".log"
end

local function try_open_file(source)
    local path_file = MAIN_LOG_NAME
    local opend_file = service_file[0]
    if log_service[source] then
        path_file = log_service[source]
        opend_file = service_file[source]
    end

    if opend_file then
        return opend_file
    end

    local args = DEFAULT_FILE_MODE
    if file_mode[source] then
        args = file_mode[source]
    end
    local f, e = io.open(file_path(path_file), args)
    if not f then
        print("error", path_file)
        return
    end
    if log_service[source] then
        service_file[source] = f
    else
        service_file[0] = f
    end

    return f
end

local function log_time()
    local now = math.floor(skynet.time())
    return string.format("%02d:%02d:%02d", tonumber(os.date("%H", now)), tonumber(os.date("%M", now)), tonumber(os.date("%S", now)))
end

local CMD = {}

local logging_fun = function(source, type, msg)
    msg = string.format("[:%08x][%s][%s] %s", source, log_time(), type, msg)
    print(string.format(":%08x(%.2f): %s", source, skynet.time(), msg))
end
if is_daemon then
    logging_fun = function(source, type, msg)
        local opend_file = try_open_file(source)

        msg = string.format("[:%08x][%s][%s] %s", source, log_time(), type, msg)
        -- msg = string.format(":%08x(%.2f): %s", source, skynet.time(), msg..'\r\n'))
        opend_file:write(msg .. '\n')
        opend_file:flush()
    end
end

function CMD.logging(source, type, msg)
    logging_fun(source, type, msg)
end

function CMD.reopen(source, type, str)
    if is_daemon and log_service[source] and service_file[source] then
        io.close(service_file[source])
        log_service[source] = nil
        service_file[source] = nil
        file_mode[source] = nil
    end
end

function CMD.separate(source, path, file, no_change_dir, mode)
    if is_daemon then
        file_mode[source] = mode or DEFAULT_FILE_MODE
        check_exists(log_path..path)
        dir_path[source] = path
        log_service[source] = path.."/"..file
        if no_change_dir then
            log_service_no_change[source] = true
        end
    end
end

function CMD.close(source)
    if is_daemon and log_service[source] and service_file[source] then
        io.close(service_file[source])
        log_service[source] = nil
        service_file[source] = nil
        file_mode[source] = nil
    end
end

function CMD.forward(source, path, file, no_change_dir, mode)
    if is_daemon then
        if not path then
            CMD.close(source)
        else
            CMD.close(source)
            CMD.separate(source, path, file, no_change_dir)
            file_mode[source] = mode or DEFAULT_FILE_MODE
        end
    end
end

-- register protocol text before skynet.start would be better.
skynet.register_protocol {
    name = "text",
    id = skynet.PTYPE_TEXT,
    unpack = skynet.tostring,
    dispatch = function(session, source, msg)
        CMD.logging(source, "SKYNET", msg)
    end
}

skynet.register_protocol {
    name = "SYSTEM",
    id = skynet.PTYPE_SYSTEM,
    unpack = function(...) return ... end,
    dispatch = function(_, source)
        -- reopen signal
        -- print("SIGHUP")
        CMD.reopen(source, "SIGHUP", "SIGHUP")
    
    end
}

time_dir()

skynet.start(function()
    -- local replaypath="./"..WORLD_NAME.."/"
    -- print("log dir",replaypath)
    -- local err=os.execute("mkdir "..replaypath)

    skynet.register ".logger"

    skynet.dispatch("lua", function(session, source, cmd, ...)
        local f = assert(CMD[cmd], cmd .. " not found")
        if session > 0 then
            skynet.ret(skynet.pack(f(source, ...)))
        else
            f(source, ...)
        end
    end)
end)
