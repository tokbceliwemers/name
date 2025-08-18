local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Services and references
local player = Players.LocalPlayer
local mobsFolder = Workspace:WaitForChild("Mobs")
local remote = game:GetService("ReplicatedStorage").Remotes:WaitForChild("DamageMob")

-- Mob detection system
local mobDetection = {
    undyne = {
        patterns = {"undyne", "undying"},
        currentName = nil,
        tool = "Undyne Spear"
    },
    asriel = {
        patterns = {"asriel"},
        currentName = nil,
        tool = "Chaos Saber"
    },
    spamton = {
        patterns = {"spamton", "neo"},
        currentName = nil
    }
}

-- Clean mob names for display
local function cleanMobName(name)
    return name:gsub("%.$", ""):gsub("^%l", string.upper)
end

-- Function to detect mob names dynamically
local function detectMobNames()
    for mobType, data in pairs(mobDetection) do
        for _, mob in ipairs(mobsFolder:GetChildren()) do
            local match = true
            local lowerMobName = string.lower(mob.Name)
            for _, pattern in ipairs(data.patterns) do
                if not string.find(lowerMobName, string.lower(pattern)) then
                    match = false
                    break
                end
            end
            if match then
                mobDetection[mobType].currentName = mob.Name
                break
            end
        end
    end
end

-- Create mob list with clean names
local function getMobList()
    local mobList = {}
    for _, mob in ipairs(mobsFolder:GetChildren()) do
        table.insert(mobList, cleanMobName(mob.Name))
    end
    table.sort(mobList)
    return mobList
end

-- Initial detection
detectMobNames()
local mobList = getMobList()

local Window = Rayfield:CreateWindow({
    Name = "Made by YouR | Undertale Classic Rpg",
    LoadingTitle = "Undertale Classic Rpg",
    LoadingSubtitle = "by YouR",
    ShowText = "GUI",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = false }
})

-- Home tab for general features
local MainTab = Window:CreateTab("Home", 4483362458)

-- KillAura toggle with safety checks
local killAuraActive = false
local killAuraConnection = nil

local function closestMob()
    local character = player.Character
    if not character then return nil end
    
    local myRoot = character:FindFirstChild("HumanoidRootPart")
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
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
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

-- Typed Kill toggle with safety checks
local typedKillActive = false
local typedKillConnection = nil
local selectedMob = mobList[1] or ""
local actualMobNames = {}

-- Function to map clean names to actual names
local function mapMobNames()
    actualMobNames = {}
    for _, mob in ipairs(mobsFolder:GetChildren()) do
        actualMobNames[cleanMobName(mob.Name)] = mob.Name
    end
end

mapMobNames()

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
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                if selectedMob and selectedMob ~= "" then
                    local actualName = actualMobNames[selectedMob]
                    if actualName then
                        local target = mobsFolder:FindFirstChild(actualName)
                        if target then
                            remote:InvokeServer(target)
                        end
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

-- Dynamic mob dropdown with clean names
local Dropdown = MainTab:CreateDropdown({
    Name = "Mobs",
    Options = mobList,
    CurrentOption = {selectedMob},
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        selectedMob = Option[1]
    end,
})

-- Create dedicated AutoFarm tab
local AutoFarmTab = Window:CreateTab("AutoFarm", 123456789) -- Icon ID can be changed

-- Auto Reset Toggle
local autoResetActive = false
local autoResetConnection = nil
local lastResetAttack = 0
local resetAttackCooldown = 0.08

AutoFarmTab:CreateToggle({
    Name = "Auto Reset",
    CurrentValue = false,
    Flag = "AutoResetToggle",
    Callback = function(Value)
        autoResetActive = Value
        if autoResetActive then
            if autoResetConnection then
                autoResetConnection:Disconnect()
            end
            
            autoResetConnection = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - lastResetAttack >= resetAttackCooldown then
                    lastResetAttack = now
                    
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        return
                    end
                    
                    local leaderstats = player:FindFirstChild("leaderstats")
                    local levelValue = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "0"
                    local level = tonumber(levelValue) or 0
                    
                    if level >= 300 then
                        autoResetActive = false
                        Rayfield:Notify({
                            Title = "Auto Reset",
                            Content = "Reached level 300! Stopping.",
                            Duration = 5,
                            Image = 4483362458
                        })
                    else
                        local asrielName = mobDetection.asriel.currentName
                        if asrielName then
                            local target = mobsFolder:FindFirstChild(asrielName)
                            if target then
                                remote:InvokeServer(target)
                            end
                        end
                    end
                end
            end)
        else
            if autoResetConnection then
                autoResetConnection:Disconnect()
                autoResetConnection = nil
            end
        end
    end,
})

-- Gold Farm Toggle
local goldFarmActive = false
local goldFarmConnection = nil
local lastGoldAttack = 0
local goldAttackCooldown = 0.08

AutoFarmTab:CreateToggle({
    Name = "Gold Farm",
    CurrentValue = false,
    Flag = "GoldFarmToggle",
    Callback = function(Value)
        goldFarmActive = Value
        if goldFarmActive then
            if goldFarmConnection then
                goldFarmConnection:Disconnect()
            end
            
            goldFarmConnection = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - lastGoldAttack >= goldAttackCooldown then
                    lastGoldAttack = now
                    
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        return
                    end
                    
                    local spamtonName = mobDetection.spamton.currentName
                    if spamtonName then
                        local target = mobsFolder:FindFirstChild(spamtonName)
                        if target then
                            remote:InvokeServer(target)
                        end
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "Gold Farm",
                Content = "Started farming Spamton Neo!",
                Duration = 3,
                Image = 4483362458
            })
        else
            if goldFarmConnection then
                goldFarmConnection:Disconnect()
                goldFarmConnection = nil
            end
            Rayfield:Notify({
                Title = "Gold Farm",
                Content = "Stopped farming!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- FAST AutoFarm (0 to 300) toggle
local autoFarmActive = false
local autoFarmConnection = nil
local lastAttack = 0
local attackCooldown = 0.08
local lastEquip = 0
local equipCooldown = 0.5
local lastCheck = 0
local checkCooldown = 0.5
local targetMob = nil
local equippedWeapon = nil

local function equipWeapon(toolName, key)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if not character then return false end
    
    if character:FindFirstChild(toolName) then
        equippedWeapon = toolName
        return true
    end
    
    if backpack and backpack:FindFirstChild(toolName) then
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        equippedWeapon = toolName
        return true
    end
    
    return false
end

local function autoFarmUpdate()
    if not autoFarmActive then return end
    
    local now = tick()
    
    if now - lastCheck >= checkCooldown then
        lastCheck = now
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local leaderstats = player:FindFirstChild("leaderstats")
        local levelValue = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "0"
        local level = tonumber(levelValue) or 0
        
        if level >= 300 then
            Rayfield:Notify({
                Title = "AutoFarm",
                Content = "Reached level 300!",
                Duration = 5,
                Image = 4483362458
            })
            autoFarmActive = false
            AutoFarmToggle:Set(false)
            return
        end
    end
    
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if not character then return end
    
    local undyneName = mobDetection.undyne.currentName
    local asrielName = mobDetection.asriel.currentName
    
    local undyneSpear = (backpack and backpack:FindFirstChild("Undyne Spear")) or character:FindFirstChild("Undyne Spear")
    local chaosSaber = (backpack and backpack:FindFirstChild("Chaos Saber")) or character:FindFirstChild("Chaos Saber")
    
    if not undyneSpear then
        if undyneName then
            if not targetMob or not targetMob.Parent or targetMob.Parent ~= mobsFolder then
                targetMob = mobsFolder:FindFirstChild(undyneName)
            end
            
            if targetMob and now - lastAttack >= attackCooldown then
                remote:InvokeServer(targetMob)
                lastAttack = now
            end
        end
    elseif undyneSpear and not chaosSaber then
        if equippedWeapon ~= "Undyne Spear" then
            equipWeapon("Undyne Spear", Enum.KeyCode.Four)
        end
        
        if asrielName then
            if not targetMob or not targetMob.Parent or targetMob.Parent ~= mobsFolder then
                targetMob = mobsFolder:FindFirstChild(asrielName)
            end
            
            if targetMob and now - lastAttack >= attackCooldown then
                remote:InvokeServer(targetMob)
                lastAttack = now
            end
        end
    elseif chaosSaber then
        if equippedWeapon ~= "Chaos Saber" then
            equipWeapon("Chaos Saber", Enum.KeyCode.Five)
        end
        
        if asrielName then
            if not targetMob or not targetMob.Parent or targetMob.Parent ~= mobsFolder then
                targetMob = mobsFolder:FindFirstChild(asrielName)
            end
            
            if targetMob and now - lastAttack >= attackCooldown then
                remote:InvokeServer(targetMob)
                lastAttack = now
            end
        end
    end
end

local AutoFarmToggle = AutoFarmTab:CreateToggle({
    Name = "FAST AutoFarm (0 to 300)",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        autoFarmActive = Value
        if autoFarmActive then
            equippedWeapon = nil
            
            Rayfield:Notify({
                Title = "AutoFarm",
                Content = "Started FAST farming!",
                Duration = 3,
                Image = 4483362458
            })
            autoFarmConnection = RunService.Heartbeat:Connect(autoFarmUpdate)
        else
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
            Rayfield:Notify({
                Title = "AutoFarm",
                Content = "Stopped farming!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- Refresh Mob Detection button
AutoFarmTab:CreateButton({
    Name = "Refresh Mob Detection",
    Callback = function()
        detectMobNames()
        Rayfield:Notify({
            Title = "Mob Detection",
            Content = "Refreshed mob names!",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- Update mob lists when mobs change
mobsFolder.ChildAdded:Connect(function()
    mobList = getMobList()
    mapMobNames()
    Dropdown:Refresh(mobList, {selectedMob})
    detectMobNames()
end)

mobsFolder.ChildRemoved:Connect(function()
    mobList = getMobList()
    mapMobNames()
    Dropdown:Refresh(mobList, {selectedMob})
    detectMobNames()
end)
