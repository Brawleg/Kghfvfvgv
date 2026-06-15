-- === Right Hand Shrinker Menu (Уменьшение правой руки в 100 раз) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local shrinkEnabled = false
local originalSizes = {}

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 220)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
title.Text = "✋ Правая Рука ×1/100"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
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
toggleBtn.Text = "УМЕНЬШИТЬ ПРАВУЮ РУКУ\n(в 100 раз)"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Выключено"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Parent = mainFrame

-- Draggable (работает на телефоне)
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

-- Сохранение оригинальных размеров и уменьшение
local function applyShrink()
    local character = player.Character
    if not character then return end
    
    local parts = {
        character:FindFirstChild("RightUpperArm"),
        character:FindFirstChild("RightLowerArm"),
        character:FindFirstChild("RightHand")
    }
    
    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            if not originalSizes[part] then
                originalSizes[part] = part.Size
            end
            part.Size = originalSizes[part] * 0.01  -- уменьшение в 100 раз
        end
    end
end

local function resetHand()
    local character = player.Character
    if not character then return end
    
    local parts = {
        character:FindFirstChild("RightUpperArm"),
        character:FindFirstChild("RightLowerArm"),
        character:FindFirstChild("RightHand")
    }
    
    for _, part in pairs(parts) do
        if part and originalSizes[part] then
            part.Size = originalSizes[part]
        end
    end
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    shrinkEnabled = not shrinkEnabled
    
    if shrinkEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "РУКА УМЕНЬШЕНА\n(Нажми чтобы вернуть)"
        statusLabel.Text = "Правая рука уменьшена в 100 раз"
        applyShrink()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "УМЕНЬШИТЬ ПРАВУЮ РУКУ\n(в 100 раз)"
        statusLabel.Text = "Выключено"
        resetHand()
    end
end)

-- Обновление при респавне
player.CharacterAdded:Connect(function(newChar)
    wait(1.5)
    originalSizes = {}  -- сброс оригинальных размеров
    if shrinkEnabled then
        applyShrink()
    end
end)

-- Если персонаж уже есть
if player.Character then
    wait(1)
    if shrinkEnabled then
        applyShrink()
    end
end

closeBtn.MouseButton1Click:Connect(function()
    resetHand()
    screenGui:Destroy()
end)

print("Скрипт уменьшения правой руки загружен! Меню перетаскивается.")
