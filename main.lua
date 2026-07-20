local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

for _, player in pairs(Players:GetPlayers()) do
    setupPlayerHighlights(player)
end

Players.PlayerAdded:Connect(function(player)
    setupPlayerHighlights(player)
end)

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

local isAimbotActive = false -- Track if right mouse button is held

-- Detect right mouse button hold and release
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

-- Main loop
RunService.RenderStepped:Connect(function()
    local currentTime = tick()

    -- Update highlights colors
    for _, highlights in pairs(playerHighlights) do
        for _, hl in ipairs(highlights) do
            if hl and hl.Adornee then
                hl.FillColor = getRainbowColor(currentTime, 1)
            end
        end
    end

    -- Aim at target when holding right mouse button
    if isAimbotActive then
        local targetPlayer = getClosestTarget()
        if targetPlayer and targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head then
                local targetPosition = head.Position
                -- Instantly aim at the target's head
                local currentCFrame = Camera.CFrame
                Camera.CFrame = CFrame.new(currentCFrame.Position, targetPosition)
            end
        end
    end
end)
