-- === Tiny Body Menu (Всё тело крошечное + не проваливается) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local tinyEnabled = false
local originalSizes = {}
local originalHipHeight = 0
local floatConnection = nil

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 240)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
title.Text = "🌍 КРОШЕЧНОЕ ТЕЛО"
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
toggleBtn.Text = "СДЕЛАТЬ ТЕЛО КРОШЕЧНЫМ\n(не проваливается)"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
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

-- Применить уменьшение
local function applyTinyBody()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        originalHipHeight = humanoid.HipHeight
        humanoid.HipHeight = 4 -- поднимаем чтобы не проваливался
    end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not originalSizes[part] then
                originalSizes[part] = part.Size
            end
            part.Size = originalSizes[part] * 0.01  -- в 100 раз меньше
        end
    end

    -- HumanoidRootPart делаем чуть больше, чтобы коллизия лучше работала
    local root = character:FindFirstChild("HumanoidRootPart")
    if root and not originalSizes[root] then
        originalSizes[root] = root.Size
        root.Size = Vector3.new(1, 1, 1) * 0.3
    end
end

local function resetBody()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HipHeight = originalHipHeight
    end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and originalSizes[part] then
            part.Size = originalSizes[part]
        end
    end
end

-- Постоянная поддержка высоты (чтобы не проваливался)
local function startFloating()
    if floatConnection then return end
    
    floatConnection = RunService.Heartbeat:Connect(function()
        if not tinyEnabled then return end
        local character = player.Character
        if not character then return end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if root and humanoid then
            -- Держим персонажа чуть выше земли
            local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0))
            if ray then
                root.CFrame = CFrame.new(ray.Position + Vector3.new(0, 2, 0)) * root.CFrame.Rotation
            end
        end
    end)
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    tinyEnabled = not tinyEnabled
    
    if tinyEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "ТЕЛО КРОШЕЧНОЕ\n(Нажми чтобы вернуть)"
        statusLabel.Text = "Ты теперь крошка! Не проваливаешься"
        applyTinyBody()
        startFloating()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "СДЕЛАТЬ ТЕЛО КРОШЕЧНЫМ\n(не проваливается)"
        statusLabel.Text = "Выключено"
        resetBody()
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end
    end
end)

-- Респавн
player.CharacterAdded:Connect(function(newChar)
    wait(1.5)
    originalSizes = {}
    if tinyEnabled then
        applyTinyBody()
        startFloating()
    end
end)

-- Если персонаж уже загружен
if player.Character then
    wait(1)
    if tinyEnabled then
        applyTinyBody()
        startFloating()
    end
end

closeBtn.MouseButton1Click:Connect(function()
    tinyEnabled = false
    resetBody()
    if floatConnection then floatConnection:Disconnect() end
    screenGui:Destroy()
end)

print("Скрипт Крошечного Тела загружен! Меню перетаскивается пальцем.")
