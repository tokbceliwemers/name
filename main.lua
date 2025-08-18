local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Services and references
local player = Players.LocalPlayer
local mobsFolder = Workspace:WaitForChild("Mobs")
local remote = game:GetService("ReplicatedStorage").Remotes:WaitForChild("DamageMob")

-- Closest mob function
local function closestMob()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest, minDist = nil, math.huge
    for _, mobModel in ipairs(mobsFolder:GetChildren()) do
        local mobRoot = mobModel:FindFirstChild("HumanoidRootPart")
        if mobRoot then
            local dist = (mobRoot.Position - myRoot.Position).Magnitude
            if dist < minDist then
                minDist, closest = dist, mobModel
            end
        end
    end
    return closest
end

-- Create mob list and auto-update functionality
local mobList = {}
local function updateMobList()
    mobList = {}
    for _, mob in ipairs(mobsFolder:GetChildren()) do
        table.insert(mobList, mob.Name)
    end
    table.sort(mobList)
end

-- Initial population
updateMobList()

-- Set up auto-update
mobsFolder.ChildAdded:Connect(updateMobList)
mobsFolder.ChildRemoved:Connect(updateMobList)

local Window = Rayfield:CreateWindow({
    Name = "Made by YouR | Undertale Classic Rpg",
    LoadingTitle = "Undertale Classic Rpg",
    LoadingSubtitle = "by YouR",
    ShowText = "GUI",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Home", 4483362458)

-- KillAura toggle
local killAuraActive = false
local killAuraConnection = nil

MainTab:CreateToggle({
    Name = "KillAura (Closest Mob)",
    CurrentValue = false,
    Flag = "KillAuraToggle",
    Callback = function(Value)
        killAuraActive = Value
        
        if killAuraActive then
            if killAuraConnection then
                killAuraConnection:Disconnect()
            end
            
            killAuraConnection = RunService.Heartbeat:Connect(function()
                local target = closestMob()
                if target then
                    remote:InvokeServer(target)
                end
            end)
        else
            if killAuraConnection then
                killAuraConnection:Disconnect()
                killAuraConnection = nil
            end
        end
    end,
})

-- Typed Kill toggle
local typedKillActive = false
local typedKillConnection = nil
local selectedMob = mobList[1] or ""

MainTab:CreateToggle({
    Name = "Typed Kill",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        typedKillActive = Value
        
        if typedKillActive then
            if typedKillConnection then
                typedKillConnection:Disconnect()
            end
            
            typedKillConnection = RunService.Heartbeat:Connect(function()
                if selectedMob and selectedMob ~= "" then
                    local target = mobsFolder:FindFirstChild(selectedMob)
                    if target then
                        remote:InvokeServer(target)
                    end
                end
            end)
        else
            if typedKillConnection then
                typedKillConnection:Disconnect()
                typedKillConnection = nil
            end
        end
    end,
})

-- Dynamic mob dropdown
local Dropdown = MainTab:CreateDropdown({
    Name = "Mobs",
    Options = mobList,
    CurrentOption = {selectedMob},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        selectedMob = Option[1]
        print("Selected mob:", selectedMob)
    end,
})

-- Function to refresh dropdown options
local function refreshDropdown()
    updateMobList()
    Dropdown:Refresh(mobList, {selectedMob})
    
    -- Update selection if current mob was removed
    if not table.find(mobList, selectedMob) then
        selectedMob = mobList[1] or ""
    end
end

-- Set up auto-refresh for dropdown
mobsFolder.ChildAdded:Connect(refreshDropdown)
mobsFolder.ChildRemoved:Connect(refreshDropdown)
