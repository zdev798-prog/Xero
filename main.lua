-- Full script: Xero with OVERPOWER tab and features

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

-- Create main tabs
local visualTab = Window:CreateTab("Visuals", "shield-check")
local aimbotTab = Window:CreateTab("Aimbot", "crosshair")
local funTab = Window:CreateTab("Fun", "party-popper") 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ChatService = game:GetService("Chat")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- =======================
-- Visuals: ESP with Rainbow & Color Options
-- =======================

local highlights = {}
local rainbowColor = function()
    local hue = tick() % 1
    return Color3.fromHSV(hue, 1, 1)
end

local ESPActive = false
local useRainbow = false

local espColorOptions = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 0, 255)},
    {Name = "Black", Color3.fromRGB(0, 0, 0)},
    {Name = "White", Color3.fromRGB(255, 255, 255)},
    {Name = "Gold", Color3.fromRGB(255, 215, 0)},
    {Name = "Silver", Color3.fromRGB(192, 192, 192)},
    {Name = "Platinum", Color3.fromRGB(229, 228, 226)},
    {Name = "Ember", Color3.fromRGB(255, 69, 0)},
}

local selectedESPColor = espColorOptions[1].Color

local function getESPColor()
    if useRainbow then
        return rainbowColor()
    else
        return selectedESPColor
    end
end

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
        if ESPActive then updateESP() end
    end
})

local rainbowToggle = visualTab:CreateToggle({
    Name = "Rainbow",
    CurrentValue = false,
    Callback = function(state)
        useRainbow = state
        if ESPActive then updateESP() end
    end
})

local function updateESP()
    for _, h in pairs(highlights) do if h then h:Destroy() end end
    highlights = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = player.Character
                    hl.FillColor = getESPColor()
                    hl.OutlineColor = getESPColor()
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = player.Character
                    highlights[player] = hl
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

RunService.RenderStepped:Connect(function()
    if ESPActive then updateESP() end
end)

-- =======================
-- Aimbot: Closest Player & Aim with right click hold
-- =======================

local aimbotActive = false
local aimPart = "HumanoidRootPart"
local UserInputService = game:GetService("UserInputService")
local isRightMouseHeld = false

UserInputService.InputBegan:Connect(function(input, gProc)
    if not gProc and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gProc)
    if not gProc and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseHeld = false
    end
end)

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            -- Skip teammates
            if player.Team ~= nil and player.Team == LocalPlayer.Team then
                -- skip
            else
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local hrp = player.Character[aimPart]
                    local targetPos = hrp and hrp.Position
                    if targetPos then
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
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestPlayer = player
                                    end
                                end
                            end
                        else
                            local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                            if onScreen then
                                local dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closestPlayer = player
                                end
                            end
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
            local targetPos = hrp.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotActive and isRightMouseHeld then
        local target = getClosestPlayer()
        if target then aimAtTarget(target, aimPart) end
    end
end)

local function toggleAimbot(state)
    aimbotActive = state
end

local aimbotToggle = aimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = toggleAimbot
})

local aimPartDropdown = aimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"HumanoidRootPart", "Head"},
    CurrentOption = {"HumanoidRootPart"},
    Callback = function(option)
        aimPart = option[1]
    end
})

-- =======================
-- Fun: Fly, Speed, Spin, Third Person, Infinite Jump
-- =======================

-- Fly toggle
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil
local function toggleFly(state)
    flyEnabled = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if state then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Velocity = Vector3.new()
        bv.Parent = hrp
        flyConnection = RunService.Heartbeat:Connect(function()
            local moveDir = Vector3.new()
            local uis = game:GetService("UserInputService")
            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
            if moveDir.Magnitude > 0 then
                bv.Velocity = moveDir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new()
            end
        end)
    else
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

-- Speed Walk
local speedWalk = 16
local speedWalkEnabled = false
local speedConnection = nil
local defaultWalkSpeed = 16

local function toggleSpeedWalk(state)
    speedWalkEnabled = state
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum.WalkSpeed = speedWalk
    else
        hum.WalkSpeed = defaultWalkSpeed
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
    end
end

local function updateWalkSpeed(val)
    speedWalk = val
    if speedWalkEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speedWalk end
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
    CurrentValue = speedWalk,
    Callback = function(val) updateWalkSpeed(val) end
})

-- Spin (optimized)
local spinEnabled = false
local spinSpeed = 10
local spinConnection = nil
local currentAngle = 0

local function toggleSpin(state)
    spinEnabled = state
    if spinConnection then spinConnection:Disconnect() end
    if state then
        spinConnection = RunService.Heartbeat:Connect(function()
            if spinEnabled then
                currentAngle = (currentAngle + math.rad(spinSpeed)) % (2*math.pi)
                local currentCFrame = Camera.CFrame
                local rotationCFrame = CFrame.Angles(0, currentAngle, 0)
                Camera.CFrame = CFrame.new(currentCFrame.Position) * rotationCFrame
            end
        end)
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

-- Third Person toggle (enforce)
local thirdPerson = false
local function toggleThirdPerson(state)
    thirdPerson = state
end

local thirdPersonToggle = funTab:CreateToggle({
    Name = "Third Person",
    CurrentValue = false,
    Callback = toggleThirdPerson
})

-- Enforce camera target every frame
RunService.RenderStepped:Connect(function()
    -- Enforce third person if toggled
    if thirdPerson then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and Camera.CameraSubject ~= hrp then
                Camera.CameraSubject = hrp
            end
        end
    else
        -- default to humanoid for first person
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and Camera.CameraSubject ~= hum then
                Camera.CameraSubject = hum
            end
        end
    end
end)

-- Infinite Jump
local infiniteJump = false
local function toggleInfiniteJump(state)
    infiniteJump = state
end

local infiniteJumpToggle = funTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = toggleInfiniteJump
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJump then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)



-- =======================
-- END OF SCRIPT
-- =======================
