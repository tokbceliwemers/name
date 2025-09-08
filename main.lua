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

-- Create mob list (initial fill)
local mobList = {}
local function rebuildMobList()
    mobList = {}
    for _, mob in ipairs(mobsFolder:GetChildren()) do
        table.insert(mobList, mob.Name)
    end
    table.sort(mobList)
end
rebuildMobList()

-- Function to detect mob names dynamically
local function detectMobNames()
    for mobType, data in pairs(mobDetection) do
        mobDetection[mobType].currentName = nil
        for _, mob in ipairs(mobsFolder:GetChildren()) do
            local lowerName = string.lower(mob.Name)
            for _, pattern in ipairs(data.patterns) do
                if string.find(lowerName, string.lower(pattern)) then
                    mobDetection[mobType].currentName = mob.Name
                    break
                end
            end
            if mobDetection[mobType].currentName then break end
        end
    end
end

-- Initial detection
detectMobNames()

-- Debug: Print detected mob names
print("Detected mob names:")
print("Undyne:", mobDetection.undyne.currentName)
print("Asriel:", mobDetection.asriel.currentName)
print("Spamton:", mobDetection.spamton.currentName)

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

-- Auto Reset Toggle
local autoResetActive = false
local autoResetConnection = nil
local lastResetAttack = 0
local resetAttackCooldown = 0.08

MainTab:CreateToggle({
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

                    -- Safety check for character
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                        return
                    end

                    -- Get player level
                    local leaderstats = player:FindFirstChild("leaderstats")
                    local levelValue = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "0"
                    local level = tonumber(levelValue) or 0

                    -- Stop if level >= 300, else attack Asriel
                    if level >= 300 then
                        autoResetActive = false
                        Rayfield:Notify({
                            Title = "Auto Reset",
                            Content = "Reached level 300! Stopping.",
                            Duration = 5,
                            Image = 4483362458
                        })
                        getgenv().AutoResetToggle:Set(false)
                    else
                        -- Use dynamically detected Asriel name
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

-- NOTE: Gold Farm option removed per request

-- FAST AutoFarm (0 to 300) toggle with dynamic names
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

-- Improved equipment handling
local function equipWeapon(toolName, key)
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if not character then return false end

    -- Check if already equipped
    if character:FindFirstChild(toolName) then
        equippedWeapon = toolName
        return true
    end

    -- Check if in backpack
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

    -- Check level periodically
    if now - lastCheck >= checkCooldown then
        lastCheck = now

        -- Safety check for character
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        -- Get player stats
        local leaderstats = player:FindFirstChild("leaderstats")
        local levelValue = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or "0"
        local level = tonumber(levelValue) or 0

        -- Stop at level 300
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

    -- Get dynamically detected mob names
    local undyneName = mobDetection.undyne.currentName
    local asrielName = mobDetection.asriel.currentName

    -- Check tools
    local undyneSpear = (backpack and backpack:FindFirstChild("Undyne Spear")) or character:FindFirstChild("Undyne Spear")
    local chaosSaber = (backpack and backpack:FindFirstChild("Chaos Saber")) or character:FindFirstChild("Chaos Saber")

    -- Phase 1: Get Undyne Spear
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
    -- Phase 2: Get Chaos Saber
    elseif undyneSpear and not chaosSaber then
        -- Equip spear if needed
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
    -- Phase 3: Level to 300
    elseif chaosSaber then
        -- Equip saber if needed
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

local AutoFarmToggle = MainTab:CreateToggle({
    Name = "FAST AutoFarm (0 to 300)",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        autoFarmActive = Value
        if autoFarmActive then
            -- Reset equipment state
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
                -- Safety check
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
                -- Safety check
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end

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

-- Dynamic mob dropdown (initial options from initial rebuild)
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

-- NOTE: removed automatic refresh on ChildAdded/ChildRemoved.
-- Mob list will now refresh ONLY when pressing the "Refresh Mob Detection" button below.

-- Add a button to manually refresh mob names AND the dropdown list
MainTab:CreateButton({
    Name = "Refresh Mob Detection",
    Callback = function()
        -- Rebuild mob list and refresh dropdown options
        rebuildMobList()
        Dropdown:Refresh(mobList, {selectedMob})

        -- Update detected mob names
        detectMobNames()
        Rayfield:Notify({
            Title = "Mob Detection",
            Content = "Refreshed mob names!",
            Duration = 3,
            Image = 4483362458
        })

        print("Refreshed mob names:")
        print("Undyne:", mobDetection.undyne.currentName)
        print("Asriel:", mobDetection.asriel.currentName)
        print("Spamton:", mobDetection.spamton.currentName)
    end,
})

-- Godmode toggle (client-side enforcement; server-side damage may still apply)
local godmodeActive = false
local godmodeConnection = nil

MainTab:CreateToggle({
    Name = "Godmode",
    CurrentValue = false,
    Flag = "GodmodeToggle",
    Callback = function(Value)
        godmodeActive = Value
        if godmodeActive then
            if godmodeConnection then
                godmodeConnection:Disconnect()
            end
            godmodeConnection = RunService.Heartbeat:Connect(function()
                if not player.Character then return end
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function()
                        -- enforce very large health locally; note: server-side damage may override this
                        humanoid.MaxHealth = 1e9
                        humanoid.Health = humanoid.MaxHealth
                        -- try to prevent ragdoll if possible
                        humanoid.PlatformStand = false
                    end)
                end
            end)
            Rayfield:Notify({
                Title = "Godmode",
                Content = "Godmode activated (client-side).",
                Duration = 3,
                Image = 4483362458
            })
        else
            if godmodeConnection then
                godmodeConnection:Disconnect()
                godmodeConnection = nil
            end
            -- attempt to restore reasonable defaults
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function()
                        humanoid.MaxHealth = 100
                        humanoid.Health = humanoid.MaxHealth
                    end)
                end
            end
            Rayfield:Notify({
                Title = "Godmode",
                Content = "Godmode deactivated.",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})
