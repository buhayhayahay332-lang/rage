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
    "replaceclosure",
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

local hasRunOnActor = type(run_on_actor) == "function"
local hasGetActors = type(getactors) == "function"

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

if env.__OP1NIBBLER_LOADER__ then
    return
end
env.__OP1NIBBLER_LOADER__ = true

local function loadMain()
    local chunk, err = loadfile("main.lua")
    if chunk then
        return chunk
    end

    if type(readfile) == "function" and type(loadstring) == "function" then
        local ok, source = pcall(readfile, "main.lua")
        if ok and source and #source > 0 then
            local loaded = loadstring(source, "@main.lua")
            if loaded then
                return loaded
            end
        end
    end

    if game.HttpGet and type(loadstring) == "function" then
        local baseUrl = env.OP1NIBBLER_BASE_URL or "https://raw.githubusercontent.com/buhayhayahay332-lang/rage/main/"
        local ok, source = pcall(function()
            return game:HttpGet(baseUrl .. "main.lua")
        end)
        if ok and source and #source > 0 then
            local loaded = loadstring(source, "@main.lua")
            if loaded then
                return loaded
            end
        end
    end

    return nil, err
end

local mainChunk, loadErr = loadMain()
if not mainChunk then
    kick("failed to load main.lua: " .. tostring(loadErr))
end

local actors = getactors()
local targetActor = actors and actors[1] or nil
if not targetActor then
    kick("rejoin the game")
end

local function runMain()
    local ok, runtimeErr = pcall(mainChunk)
    if not ok then
        error("main.lua failed: " .. tostring(runtimeErr), 0)
    end
end

local ok, runtimeErr = pcall(function()
    run_on_actor(targetActor, runMain)
end)
if not ok then
    kick(tostring(runtimeErr))
end
