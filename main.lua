-- credits to snc my dad for helping me

local gameName = "V1"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local snc = {
    TextColor = Color3.fromRGB(230, 230, 230),
    Background = Color3.fromRGB(10, 10, 10),
    Topbar = Color3.fromRGB(20, 20, 20),
    Shadow = Color3.fromRGB(0, 0, 0),
    NotificationBackground = Color3.fromRGB(20, 20, 20),
    NotificationActionsBackground = Color3.fromRGB(80, 80, 80),
    TabBackground = Color3.fromRGB(25, 25, 25),
    TabStroke = Color3.fromRGB(60, 60, 60),
    TabBackgroundSelected = Color3.fromRGB(50, 50, 50),
    TabTextColor = Color3.fromRGB(230, 230, 230),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
    ElementBackground = Color3.fromRGB(20, 20, 20),
    ElementBackgroundHover = Color3.fromRGB(35, 35, 35),
    SecondaryElementBackground = Color3.fromRGB(15, 15, 15),
    ElementStroke = Color3.fromRGB(60, 60, 60),
    SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
    SliderBackground = Color3.fromRGB(60, 60, 60),
    SliderProgress = Color3.fromRGB(120, 120, 120),
    SliderStroke = Color3.fromRGB(100, 100, 100),
    ToggleBackground = Color3.fromRGB(25, 25, 25),
    ToggleEnabled = Color3.fromRGB(120, 120, 120),
    ToggleDisabled = Color3.fromRGB(60, 60, 60),
    ToggleEnabledStroke = Color3.fromRGB(150, 150, 150),
    ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
    ToggleEnabledOuterStroke = Color3.fromRGB(200, 200, 200),
    ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),
    DropdownSelected = Color3.fromRGB(35, 35, 35),
    DropdownUnselected = Color3.fromRGB(20, 20, 20),
    InputBackground = Color3.fromRGB(20, 20, 20),
    InputStroke = Color3.fromRGB(80, 80, 80),
    PlaceholderColor = Color3.fromRGB(180, 180, 180)
}

local Window = Rayfield:CreateWindow({
    Name = "Xero" .. gameName,
    Icon = "circle-arrow-out-up-left",
    LoadingTitle = "Loading....",
    LoadingSubtitle = "Xero",
    ShowText = "",
    Theme = snc,
    ToggleUIKeybind = Enum.KeyCode.Insert,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Xero"
    },
    Discord = {
        Enabled = true,
        Invite = "https://discord.gg/SqxnfjjwgC",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Key",
        Subtitle = "Xero",
        Note = "This script only giving by trusted friends :)",
        FileName = "Trusted Only",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Xero"}
    }
})

-- Create tabs
local visualTab = Window:CreateTab("Visuals", "shield-check")
local aimbotTab = Window:CreateTab("Aimbot", "crosshair")
local funTab = Window:CreateTab("Fun", "party-popper") 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ------------------ Visuals: ESP with Rainbow & Color Options ------------------

local highlights = {}
local rainbowColor = function()
    local hue = tick() % 1
    return Color3.fromHSV(hue, 1, 1)
end

local ESPActive = false
local useRainbow = false -- toggle for rainbow

-- Color options
local espColorOptions = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 0, 255)},
    {Name = "Black", Color = Color3.fromRGB(0, 0, 0)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Gold", Color3.fromRGB(255, 215, 0)},
    {Name = "Silver", Color3.fromRGB(192, 192, 192)},
    {Name = "Platinum", Color3.fromRGB(229, 228, 226)},
    {Name = "Ember", Color3.fromRGB(255, 69, 0)},
}

local selectedESPColor = espColorOptions[1].Color -- default
local function getESPColor()
    if useRainbow then
        return rainbowColor()
    else
        return selectedESPColor
    end
end

-- Dropdown for color selection
local colorDropdown = visualTab:CreateDropdown({
    Name = "ESP Color",
    Options = (function()
        local opts = {}
        for _, v in ipairs(espColorOptions) do
            table.insert(opts, v.Name)
        end
        return opts
    end)(),
    CurrentOption = {espColorOptions[1].Name},
    Callback = function(option)
        for _, col in ipairs(espColorOptions) do
            if col.Name == option[1] then
                selectedESPColor = col.Color
                break
            end
        end
        if ESPActive then
            updateESP()
        end
    end
})

-- Toggle for rainbow
local rainbowToggle = visualTab:CreateToggle({
    Name = "Rainbow",
    CurrentValue = false,
    Callback = function(state)
        useRainbow = state
        if ESPActive then
            updateESP()
        end
    end
})

local function updateESP()
    -- clear previous
    for _, h in pairs(highlights) do if h then h:Destroy() end end
    highlights = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = character
                    highlight.FillColor = getESPColor()
                    highlight.OutlineColor = getESPColor()
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = character
                    highlights[player] = highlight
                end
            end
        end
    end
end

local function toggleESP(state)
    ESPActive = state
    if not state then
        for _, h in pairs(highlights) do if h then h:Destroy() end end
        highlights = {}
    else
        updateESP()
    end
end

local espToggle = visualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = toggleESP
})

-- Continuously update ESP if active
RunService.RenderStepped:Connect(function()
    if ESPActive then
        updateESP()
    end
end)

-- ------------------ Aimbot: Closest Player & Aim with right click hold ------------------

local aimbotActive = false
local aimPart = "HumanoidRootPart"
local rainbowHighlight -- for highlighting closest player
local UserInputService = game:GetService("UserInputService")
local isRightMouseHeld = false

-- Detect right mouse hold
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isRightMouseHeld = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isRightMouseHeld = false
        end
    end
end)

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local hrp = player.Character[aimPart]
                local targetPos = hrp.Position
                -- Raycast for line of sight
                local origin = Camera.CFrame.Position
                local direction = (targetPos - origin)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(origin, direction, raycastParams)
                if result then
                    if result.Instance and result.Instance:IsDescendantOf(player.Character) then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                        if onScreen then
                            local dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist < closestDistance then
                                closestDistance = dist
                                closestPlayer = player
                            end
                        end
                    end
                else
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist < closestDistance then
                            closestDistance = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function aimAtTarget(target, aimPart)
    if target and target.Character and target.Character:FindFirstChild(aimPart) then
        local hrp = target.Character[aimPart]
        if hrp then
            local targetPosition = hrp.Position
            -- Set camera to look at the target
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        end
    end
end

-- Update camera to aim at closest player when aimbot is active and right mouse is held
RunService.RenderStepped:Connect(function()
    if aimbotActive and isRightMouseHeld then
        local target = getClosestPlayer()
        aimAtTarget(target, aimPart)
    end
end)

local function toggleAimbot(state)
    aimbotActive = state
    if not state and rainbowHighlight then
        rainbowHighlight:Destroy()
        rainbowHighlight = nil
    end
end

local aimbotToggle = aimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = toggleAimbot
})

-- Dropdown for aim part
local aimPartDropdown = aimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"HumanoidRootPart", "Head"},
    CurrentOption = {"HumanoidRootPart"},
    Callback = function(option)
        aimPart = option[1]
    end
})

-- ----------------- Trolling Tab -------

-- Add Trolling tab
local trollingTab = Window:CreateTab("Trolling", "robot")

-- Create RemoteEvent for fart (server side needs to handle this event)
local fartEvent = Instance.new("RemoteEvent")
fartEvent.Name = "FartEvent"
fartEvent.Parent = game:GetService("ReplicatedStorage")

-- Client-side: Button to trigger fart
local fartButton = trollingTab:CreateButton({
    Name = "Fart",
    Callback = function()
        -- Fire server event to trigger fart effect
        fartEvent:FireServer()
    end
})

-- Server-side: Listen for the fart event and create green fart effects
if game:GetService("RunService"):IsServer() then
    fartEvent.OnServerEvent:Connect(function(player)
        -- Create green fart effects around the player's character
        local character = player.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Create multiple fart particles
        for i = 1, 10 do
            local fartPart = Instance.new("Part")
            fartPart.Size = Vector3.new(0.2, 0.2, 0.2)
            fartPart.CFrame = hrp.CFrame * CFrame.new(math.random(-2,2), math.random(0,2), math.random(-2,2))
            fartPart.Anchored = false
            fartPart.CanCollide = false
            fartPart.Material = Enum.Material.Neon
            fartPart.BrickColor = BrickColor.new("Bright green")
            fartPart.Parent = workspace

            -- Add a ParticleEmitter for green effects
            local particle = Instance.new("ParticleEmitter")
            particle.Color = ColorSequence.new(Color3.new(0,1,0))
            particle.LightEmission = 1
            particle.Speed = NumberRange.new(2, 4)
            particle.Lifetime = NumberRange.new(1, 2)
            particle.Rate = 50
            particle.Parent = fartPart

            -- Make the fart particles fade away
            game:GetService("Debris"):AddItem(fartPart, 2)
        end
    end)
end

-- ------------------ Fun Tab Features ------------------

-- Fly toggle and speed
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil

local function toggleFly(state)
    flyEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        -- Add BodyVelocity for flying
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new()
        bv.Parent = hrp

        -- Move based on WASD + Space/Shift
        flyConnection = RunService.Heartbeat:Connect(function()
            local moveDir = Vector3.new()
            local uis = game:GetService("UserInputService")
            if uis:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if uis:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if uis:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if uis:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            if uis:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0,1,0)
            end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0,1,0)
            end
            if moveDir.Magnitude > 0 then
                bv.Velocity = moveDir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
        end)
    else
        -- Remove BodyVelocity
        if flyConnection then flyConnection:Disconnect() end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
        end
    end
end

local flyToggle = funTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = toggleFly
})

local flySpeedSlider = funTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = flySpeed,
    Callback = function(val)
        flySpeed = val
    end
})

-- Speed Walk (fixed version)
local speedWalkEnabled = false
local walkSpeed = 16
local defaultWalkSpeed = 16
local speedConnection = nil

local function toggleSpeedWalk(state)
    speedWalkEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if state then
        humanoid.WalkSpeed = walkSpeed
        -- Optional: Keep updating in case other scripts change it
        -- Comment out if not needed
        -- speedConnection = RunService.Heartbeat:Connect(function()
        --     humanoid.WalkSpeed = walkSpeed
        -- end)
    else
        -- Reset to default
        humanoid.WalkSpeed = defaultWalkSpeed
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
    end
end

local function updateWalkSpeed(val)
    walkSpeed = val
    if speedWalkEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkSpeed
            end
        end
    end
end

local speedToggle = funTab:CreateToggle({
    Name = "Speed Walk",
    CurrentValue = false,
    Callback = toggleSpeedWalk
})

local walkSpeedSlider = funTab:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = walkSpeed,
    Callback = function(val)
        updateWalkSpeed(val)
    end
})

-- Spin
local spinEnabled = false
local spinSpeed = 10
local spinConnection = nil

local function toggleSpin(state)
    spinEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        spinConnection = RunService.Heartbeat:Connect(function()
            if spinEnabled then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end
        end)
    else
        if spinConnection then spinConnection:Disconnect() end
    end
end

local spinToggle = funTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = toggleSpin
})

local spinSpeedSlider = funTab:CreateSlider({
    Name = "Spin Speed",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = spinSpeed,
    Callback = function(val)
        spinSpeed = val
    end
})

-- Infinite Jump
local infiniteJumpEnabled = false
local function toggleInfiniteJump(state)
    infiniteJumpEnabled = state
end

local infiniteJumpToggle = funTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = toggleInfiniteJump
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)
