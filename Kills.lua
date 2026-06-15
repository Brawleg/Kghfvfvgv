-- === Kill Touch Menu by Grok ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local killEnabled = false
local connections = {}

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
title.Text = "Kill Touch Menu"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.TextScaled = true
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Parent = mainFrame

-- Kill Toggle Button
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0.9, 0, 0, 70)
killButton.Position = UDim2.new(0.05, 0, 0, 60)
killButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
killButton.Text = "KILL TOUCH: OFF"
killButton.TextColor3 = Color3.new(1,1,1)
killButton.TextScaled = true
killButton.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 140)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Прикоснись к игроку — он умрёт"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextScaled = true
statusLabel.Parent = mainFrame

-- Draggable (работает на телефоне)
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Функция убийства
local function killPlayer(targetChar)
    if not targetChar then return end
    local hum = targetChar:FindFirstChild("Humanoid")
    if hum then
        hum.Health = 0
    end
end

-- Подключение Touch событий
local function setupKillTouch()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}

    local character = player.Character
    if not character then return end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                if not killEnabled then return end
                local targetChar = hit.Parent
                if targetChar and targetChar ~= character and targetChar:FindFirstChild("Humanoid") then
                    killPlayer(targetChar)
                end
            end)
            table.insert(connections, conn)
        end
    end
end

-- Toggle Kill
killButton.MouseButton1Click:Connect(function()
    killEnabled = not killEnabled
    if killEnabled then
        killButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        killButton.Text = "KILL TOUCH: ON"
        setupKillTouch()
    else
        killButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        killButton.Text = "KILL TOUCH: OFF"
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
    end
end)

-- Обновление при респавне
player.CharacterAdded:Connect(function()
    wait(1)
    if killEnabled then
        setupKillTouch()
    end
end)

-- Если персонаж уже загружен
if player.Character then
    wait(1)
    if killEnabled then
        setupKillTouch()
    end
end

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

print("Kill Touch Menu загружен! Включи и касайся игроков.")
