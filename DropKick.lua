-- === Teleport & Launch Grief Menu (для телефона) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local enabled = false
local loopConnection = nil

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
title.Text = "🚀 Launch Grief"
title.TextColor3 = Color3.fromRGB(255, 100, 0)
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
toggleBtn.Size = UDim2.new(0.9, 0, 0, 90)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleBtn.Text = "ВКЛЮЧИТЬ ГРИФ\n(Телепорт + Выброс)"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 50)
status.Position = UDim2.new(0.05, 0, 0, 180)
status.BackgroundTransparency = 1
status.Text = "Выключено"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextScaled = true
status.Parent = mainFrame

-- Draggable (отлично работает на телефоне)
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

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Основная функция грифа
local function launchPlayer(target)
    if not target or target == player then return end
    local targetChar = target.Character
    if not targetChar then return end
    
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Телепортируемся рядом
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        myRoot.CFrame = root.CFrame * CFrame.new(0, 0, -6)
    end
    
    wait(0.1)
    
    -- Мощный выброс за карту
    local bv = Instance.new("BodyVelocity")
    bv.Name = "LaunchForce"
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    
    -- Направление: сильно вверх + немного в сторону от центра карты
    local direction = (root.Position - Vector3.new(0,0,0)).Unit * 0.3 + Vector3.new(0, 1, 0)
    bv.Velocity = direction * 10000
    
    bv.Parent = root
    game.Debris:AddItem(bv, 3) -- Автоудаление
end

-- Цикл по всем игрокам
local function startGriefLoop()
    if loopConnection then loopConnection:Disconnect() end
    
    loopConnection = RunService.Heartbeat:Connect(function()
        if not enabled then return end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                launchPlayer(plr)
                wait(0.6) -- небольшая задержка между целями
            end
        end
    end)
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "ВЫКЛЮЧИТЬ ГРИФ"
        status.Text = "Активно — кидаю всех за карту"
        startGriefLoop()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "ВКЛЮЧИТЬ ГРИФ\n(Телепорт + Выброс)"
        status.Text = "Выключено"
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
    end
end)

-- Закрытие меню
closeBtn.MouseButton1Click:Connect(function()
    enabled = false
    if loopConnection then loopConnection:Disconnect() end
    screenGui:Destroy()
end)

-- При респавне
player.CharacterAdded:Connect(function()
    wait(1.5)
    if enabled then
        startGriefLoop()
    end
end)

print("Гриф-меню загружено! Перетаскивай за заголовок.")
