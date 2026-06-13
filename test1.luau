if game:IsLoaded() == false then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function kick(message)
    pcall(function()
        LocalPlayer:Kick(message)
    end)
    error(message, 0)
end

if type(getgenv) ~= "function" then
    kick("missing function: getgenv")
end

local env = getgenv()

local RequiredExecutorFunctions = {
    "hookfunction",
    "hookmetamethod",
    "newcclosure",
    "checkcaller",
    "clonefunction",
    "cloneref",
    "getrawmetatable",
    "setreadonly",
    "loadfile",
    "readfile",
    "loadstring"
}

for i = 1, #RequiredExecutorFunctions do
    local name = RequiredExecutorFunctions[i]
    if type(env[name]) ~= "function" then
        kick("missing function: " .. name)
    end
end

local function getExecutorName()
    if type(identifyexecutor) == "function" then
        local ok, name = pcall(function()
            return identifyexecutor()
        end)
        if ok and name then
            return tostring(name)
        end
    end

    if type(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and name then
            return tostring(name)
        end
    end

    return ""
end

local executorName = getExecutorName()
local lowerName = string.lower(executorName)
if lowerName:find("xeno", 1, true) or lowerName:find("solara", 1, true) then
    kick("unsupported executor: " .. executorName)
end

local isVelocity = lowerName:find("velocity", 1, true) ~= nil

local var = (function()
    local data = {
        104,116,116,112,115,58,47,47,
        114,97,119,46,103,105,116,104,117,98,117,115,
        101,114,99,111,110,116,101,110,116,46,99,111,109,47,
        112,111,116,97,110,103,105,110,97,109,111,51,55,51,45,108,97,110,103,47,
        116,114,111,108,108,47,
        109,97,105,110,47
    }
    for i, v in ipairs(data) do
        data[i] = string.char(v)
    end
    return table.concat(data)
end)()

local function loadMain()
    local ok, source = pcall(function()
        return game:HttpGet(var .. "main.lua")
    end)
    if ok and source and #source > 0 then
        if type(loadstring) == "function" then
            local compiled = loadstring(source, "@main.lua")
            if not compiled then
                return nil, "failed to compile remote main.lua"
            end
        end
        return source
    end
    return nil, source or "failed to fetch remote main.lua"
end

local mainSource, loadErr = loadMain()
if not mainSource then
    kick("failed to load main.lua: " .. tostring(loadErr))
end

if isVelocity then
    local hasRunOnActor = type(run_on_actor) == "function"
    local hasGetActors  = type(getactors) == "function"

    if hasRunOnActor and hasGetActors then
        local actors = getactors()
        local targetActor = actors and actors[1]

        if not targetActor then
            hasRunOnActor = false
        else
            if env.__OP1NIBBLER_LOADER__ then return end
            env.__OP1NIBBLER_LOADER__ = true

            local ok, runtimeErr = pcall(function()
                run_on_actor(targetActor, mainSource)
            end)
            if not ok then
                kick(tostring(runtimeErr))
            end
            return
        end
    end

    local hasSetFFlag = type(setfflag) == "function"
    local hasGetFFlag = type(getfflag) == "function"

    if hasSetFFlag and hasGetFFlag then
        local flagOk, flagVal = pcall(function()
            return getfflag("DebugRunParallelLuaOnMainThread")
        end)

        if flagOk and (flagVal == "true" or flagVal == true) then
            if env.__OP1NIBBLER_LOADER__ then return end
            env.__OP1NIBBLER_LOADER__ = true

            local compiled, compileErr = loadstring(mainSource, "@main.lua")
            if not compiled then
                kick("compile error: " .. tostring(compileErr))
            end
            local ok, runtimeErr = pcall(compiled)
            if not ok then
                kick(tostring(runtimeErr))
            end
            return
        else
            pcall(function()
                setfflag("DebugRunParallelLuaOnMainThread", "true")
            end)
            kick("Velocity: rejoin the game to continue loading Astro")
        end
    end

    kick("Velocity: unsupported configuration, missing run_on_actor and setfflag")
end

local hasRunOnActor = type(run_on_actor) == "function"
local hasGetActors  = type(getactors) == "function"

if not hasRunOnActor or not hasGetActors then
    local hasSetFFlag = type(setfflag) == "function"
    local hasGetFFlag = type(getfflag) == "function"

    if hasSetFFlag and hasGetFFlag then
        pcall(function()
            setfflag("DebugRunParallelLuaOnMainThread", "true")
        end)
        kick("rejoin the game")
    end

    if not hasRunOnActor then
        kick("missing function: run_on_actor")
    end

    kick("missing function: getactors")
end

if env.__OP1NIBBLER_LOADER__ then return end
env.__OP1NIBBLER_LOADER__ = true

local actors = getactors()
local targetActor = actors and actors[1]
if not targetActor then
    kick("rejoin the game")
end

local ok, runtimeErr = pcall(function()
    run_on_actor(targetActor, mainSource)
end)
if not ok then
    kick(tostring(runtimeErr))
end
