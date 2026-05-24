run_on_actor(getactors()[1], [[
local cloneref = cloneref or function(obj) return obj end
local newcclosure = newcclosure or function(fn) return fn end
local hookfunction = hookfunction or function(f, r) return f end

local workspace = cloneref(game:GetService("Workspace"))
local Instance_new = cloneref(Instance.new)

local tracked_parts = {} -- parts we've modified

local old_GetPropertyChangedSignal = hookfunction(
    game.GetPropertyChangedSignal,
    newcclosure(function(self, property)
        -- if this is one of our modified parts block any listeners
        if tracked_parts[self] and (
            property == "Size" or
            property == "Transparency" or
            property == "LocalTransparencyModifier" or
            property == "Color"
        ) then
            -- return dummy event so listener never fires
            return Instance_new("BindableEvent").Event
        end
        return old_GetPropertyChangedSignal(self, property)
    end)
)

local function remove_smoke_part(obj)
    pcall(function()
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                tracked_parts[part] = true -- track before changing
                part.LocalTransparencyModifier = 1
                part.Size = Vector3.new(0.001, 0.001, 0.001)
            end
            if part:IsA("ParticleEmitter") or part:IsA("Smoke") then
                part.Enabled = false
            end
        end
        if obj:IsA("BasePart") then
            tracked_parts[obj] = true
            obj.LocalTransparencyModifier = 1
            obj.Size = Vector3.new(0.001, 0.001, 0.001)
        end
    end)
end

for _, obj in ipairs(workspace:GetChildren()) do
    if obj.Name == "SmokePart" then
        remove_smoke_part(obj)
    end
end

workspace.ChildAdded:Connect(newcclosure(function(obj)
    if obj.Name == "SmokePart" then
        remove_smoke_part(obj)
    end
end))


print('nigga')
]])