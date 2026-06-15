-- === Flying Carpet Menu by Grok ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local flyingCarpet = nil
local carpetEnabled = false
local carpetSpeed = 50
local connections = {}

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.Text = "🧞 Flying Carpet"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
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

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 80)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleBtn.Text = "КОВЁР ЛЕТАЮЩИЙ: OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 30)
speedLabel.Position = UDim2.new(0.05, 0, 0, 150)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: " .. carpetSpeed
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextScaled = true
speedLabel.Parent = mainFrame

-- Draggable (работает на телефоне)
local dragging, dragStart, startPos
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

-- Создание ковра
local function createCarpet()
    if flyingCarpet then flyingCarpet:Destroy() end
    
    flyingCarpet = Instance.new("Part")
    flyingCarpet.Name = "FlyingCarpet"
    flyingCarpet.Size = Vector3.new(6, 0.5, 8)
    flyingCarpet.Color = Color3.fromRGB(139, 69, 19) -- Коричневый ковёр
    flyingCarpet.Material = Enum.Material.Fabric
    flyingCarpet.Anchored = false
    flyingCarpet.CanCollide = false
    flyingCarpet.Position = character.HumanoidRootPart.Position + Vector3.new(0, -3, 0)
    flyingCarpet.Parent = workspace
    
    -- Красивый декор
    local decal = Instance.new("Decal")
    decal.Texture = "rbxassetid://241736678" -- Можно поменять на другой ID ковра
    decal.Face = Enum.NormalId.Top
    decal.Parent = flyingCarpet
    
    return flyingCarpet
end

-- Управление ковром
local bodyVelocity = nil
local function startFlying()
    if not flyingCarpet then return end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = flyingCarpet
    
    -- Прикрепляем игрока к ковру
    character.HumanoidRootPart.CFrame = flyingCarpet.CFrame * CFrame.new(0, 4, 0)
    
    local moveDirection = Vector3.new()
    
    local conn1 = RunService.RenderStepped:Connect(function()
        if not carpetEnabled or not flyingCarpet then return end
        
        moveDirection = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + character.HumanoidRootPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - character.HumanoidRootPart.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - character.HumanoidRootPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + character.HumanoidRootPart.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0,1,0) end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * carpetSpeed
        end
        
        bodyVelocity.Velocity = moveDirection
        -- Держим игрока на ковре
        character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        character.HumanoidRootPart.CFrame = flyingCarpet.CFrame * CFrame.new(0, 4, 0)
    end)
    
    table.insert(connections, conn1)
end

-- Включение / Выключение
toggleBtn.MouseButton1Click:Connect(function()
    carpetEnabled = not carpetEnabled
    
    if carpetEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "КОВЁР ЛЕТАЮЩИЙ: ON"
        flyingCarpet = createCarpet()
        startFlying()
        humanoid.PlatformStand = true
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "КОВЁР ЛЕТАЮЩИЙ: OFF"
        humanoid.PlatformStand = false
        
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        
        if flyingCarpet then
            flyingCarpet:Destroy()
            flyingCarpet = nil
        end
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if flyingCarpet then flyingCarpet:Destroy() end
    screenGui:Destroy()
end)

-- Обработка респавна
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    if carpetEnabled then
        wait(1)
        flyingCarpet = createCarpet()
        startFlying()
    end
end)

print("Летающий ковёр загружен! Включи и летай с WASD + Space/Ctrl")
