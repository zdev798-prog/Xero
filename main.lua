local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- FOV circle setup
local FOVRadius = 230
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVCircle.Position = UDim2.new(0.5, -FOVRadius, 0.5, -FOVRadius)
FOVCircle.BackgroundColor3 = Color3.new(1, 0, 0)
FOVCircle.BackgroundTransparency = 0.3
FOVCircle.BorderSizePixel = 0
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Parent = game:GetService("CoreGui") -- or ScreenGui

local playerHighlights = {}

-- Create highlights for character parts
local function createHighlightsForCharacter(character)
    local highlights = {}
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = part
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0
            highlight.FillTransparency = 0.3
            highlight.Parent = part
            table.insert(highlights, highlight)
        end
    end
    return highlights
end

local function setupPlayerHighlights(player)
    if not playerHighlights[player] then
        playerHighlights[player] = {}
    end
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local highlights = createHighlightsForCharacter(player.Character)
        playerHighlights[player] = highlights
    end
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        local highlights = createHighlightsForCharacter(character)
        playerHighlights[player] = highlights
    end)
end

-- Setup highlights for existing players
for _, player in pairs(Players:GetPlayers()) do
    setupPlayerHighlights(player)
end

-- Setup for new players
Players.PlayerAdded:Connect(function(player)
    setupPlayerHighlights(player)
end)

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    if playerHighlights[player] then
        for _, hl in ipairs(playerHighlights[player]) do
            if hl and hl.Parent then
                hl:Destroy()
            end
        end
        playerHighlights[player] = nil
    end
end)

local function getRainbowColor(time, speed)
    local hue = (time * speed) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Find the closest target within FOV
local function getClosestTarget()
    local closestPlayer = nil
    local closestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).magnitude
                    if distance <= FOVRadius then
                        -- Raycast to check line of sight
                        local origin = Camera.CFrame.Position
                        local direction = (hrp.Position - origin).unit * 1000
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local result = workspace:Raycast(origin, direction, raycastParams)
                        if not result or result.Instance:IsDescendantOf(character) then
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local isAimbotActive = false -- Track if right mouse is held

-- Detect right mouse hold for aim
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAimbotActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAimbotActive = false
    end
end)

-- Create a marker for current target
local function createTargetMarker()
    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 20, 0, 20)
    marker.BackgroundColor3 = Color3.new(0, 1, 0)
    marker.BorderSizePixel = 2
    marker.Parent = game:GetService("CoreGui")
    return marker
end

local targetMarker = createTargetMarker()

-- Main loop
RunService.RenderStepped:Connect(function()
    local currentTime = tick()

    -- Update rainbow colors for highlights
    for _, highlights in pairs(playerHighlights) do
        for _, hl in ipairs(highlights) do
            if hl and hl.Adornee then
                hl.FillColor = getRainbowColor(currentTime, 1)
            end
        end
    end

    -- Find closest target
    local targetPlayer = getClosestTarget()

    -- Show current target marker
    if targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                -- Position marker at head
                targetMarker.Position = UDim2.new(0, screenPos.X - 10, 0, screenPos.Y - 10)
                targetMarker.Visible = true
            else
                targetMarker.Visible = false
            end
        else
            targetMarker.Visible = false
        end
    else
        targetMarker.Visible = false
    end

    -- Smooth aim at target's head when holding right mouse button
    if isAimbotActive and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            local targetPosition = head.Position
            -- Smoothly rotate camera towards target
            local currentLook = Camera.CFrame.LookVector
            local desiredLook = (targetPosition - Camera.CFrame.Position).Unit
            local newLook = currentLook:Lerp(desiredLook, 0.2) -- Adjust for smoothness
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + newLook)
        end
    end
end)
