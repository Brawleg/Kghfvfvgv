-- === Tiny Body Parts Menu (Каждая часть крошечная + нормально стоит) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local tinyEnabled = false
local originalSizes = {}
local originalHipHeight = 0
local antiFallConnection = nil

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
title.Text = "🌍 КРОШЕЧНЫЕ ЧАСТИ ТЕЛА"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.TextScaled = true
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 80)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleBtn.Text = "СДЕЛАТЬ ВСЕ ЧАСТИ КРОШЕЧНЫМИ\n(нормально стоит)"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 50)
statusLabel.Position = UDim2.new(0.05, 0, 0, 170)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Выключено"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Parent = mainFrame

-- Draggable
local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

title.InputEnded:Connect(function() dragging = false end)

-- Применить крошечные части
local function applyTinyParts()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        originalHipHeight = humanoid.HipHeight
        humanoid.HipHeight = 0.8   -- маленькое значение для крошечного тела
    end

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not originalSizes[part] then
                originalSizes[part] = part.Size
            end
            part.Size = originalSizes[part] * 0.01   -- каждая часть в 100 раз меньше
        end
    end

    -- RootPart оставляем для нормальной коллизии
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        if not originalSizes[root] then
            originalSizes[root] = root.Size
        end
        root.Size = Vector3.new(2, 2, 2) * 0.4   -- небольшой root для коллизии
        root.Transparency = 0.7
    end
end

local function resetBody()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HipHeight = originalHipHeight
    end

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and originalSizes[part] then
            part.Size = originalSizes[part]
            part.Transparency = 0
        end
    end
end

-- Анти-проваливание (мягкая корректировка)
local function startAntiFall()
    if antiFallConnection then return end
    
    antiFallConnection = RunService.Heartbeat:Connect(function()
        if not tinyEnabled then return end
        local character = player.Character
        if not character then return end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if root and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local ray = workspace:Raycast(root.Position + Vector3.new(0, 3, 0), Vector3.new(0, -10, 0), rayParams)
            if ray then
                local targetY = ray.Position.Y + humanoid.HipHeight + 0.5
                if math.abs(root.Position.Y - targetY) > 0.5 then
                    root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z) * root.CFrame.Rotation
                end
            end
        end
    end)
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    tinyEnabled = not tinyEnabled
    
    if tinyEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "ЧАСТИ КРОШЕЧНЫЕ\n(Нажми чтобы вернуть)"
        statusLabel.Text = "Все части тела уменьшены\nСтоит нормально"
        applyTinyParts()
        startAntiFall()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "СДЕЛАТЬ ВСЕ ЧАСТИ КРОШЕЧНЫМИ\n(нормально стоит)"
        statusLabel.Text = "Выключено"
        resetBody()
        if antiFallConnection then
            antiFallConnection:Disconnect()
            antiFallConnection = nil
        end
    end
end)

-- Респавн
player.CharacterAdded:Connect(function(newChar)
    wait(1.5)
    originalSizes = {}
    if tinyEnabled then
        applyTinyParts()
        startAntiFall()
    end
end)

if player.Character then
    wait(1)
    if tinyEnabled then
        applyTinyParts()
        startAntiFall()
    end
end

closeBtn.MouseButton1Click:Connect(function()
    tinyEnabled = false
    resetBody()
    if antiFallConnection then antiFallConnection:Disconnect() end
    screenGui:Destroy()
end)

print("Скрипт Крошечных Частей Тела загружен! Теперь каждая часть тела маленькая, но ты стоишь нормально.")
