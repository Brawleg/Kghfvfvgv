-- === MOBILE VERSION of Xjdjjdks.lua (с drag'ом) ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local currentVictim = nil
local animTrack = nil
local connection = nil

-- GODMODE
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge
humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

-- === GUI МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleSexGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "FGUI"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "🔞 A Simple Fuck(ing) GUI"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 0, 180)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 8
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = Scroll

local function updatePlayerList()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.Parent = Scroll
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                currentVictim = plr
                Title.Text = "Выбрано: " .. plr.Name
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Кнопка FUCK
local FuckButton = Instance.new("TextButton")
FuckButton.Size = UDim2.new(0.9, 0, 0, 55)
FuckButton.Position = UDim2.new(0.05, 0, 0, 255)
FuckButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FuckButton.Text = "LET'S FUCK!!"
FuckButton.TextColor3 = Color3.new(1,1,1)
FuckButton.TextScaled = true
FuckButton.Font = Enum.Font.GothamBold
FuckButton.Parent = MainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,12)
btnCorner.Parent = FuckButton

FuckButton.MouseButton1Click:Connect(function()
    if not currentVictim then
        Title.Text = "Сначала выбери игрока!"
        return
    end

    local victimChar = currentVictim.Character
    if not victimChar then return end
    local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
    if not victimRoot then return end

    -- Снимаем одежду
    pcall(function() character:FindFirstChild("Pants"):Destroy() end)
    pcall(function() character:FindFirstChild("Shirt"):Destroy() end)

    -- Анимация
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://5918726675"  -- Более интенсивная

    if animTrack then animTrack:Stop() end
    animTrack = humanoid:LoadAnimation(anim)
    animTrack:Play()
    animTrack:AdjustSpeed(1.7)

    -- Телепорт + поворот лицом
    if connection then connection:Disconnect() end
    connection = RunService.Stepped:Connect(function()
        if not root.Parent or not victimRoot.Parent then return end

        local lookAt = CFrame.lookAt(root.Position, victimRoot.Position)
        local offset = victimRoot.CFrame * CFrame.new(0, 0.3, 1.7)
        root.CFrame = CFrame.new(offset.Position) * lookAt.Rotation * CFrame.Angles(0, math.rad(180), 0)

        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
    end)

    Title.Text = "Fucking " .. currentVictim.Name .. "..."
end)

-- Кнопка Stop
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.9, 0, 0, 45)
StopButton.Position = UDim2.new(0.05, 0, 0, 320)
StopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
StopButton.Text = "STOP"
StopButton.TextColor3 = Color3.new(1,1,1)
StopButton.TextScaled = true
StopButton.Font = Enum.Font.GothamBold
StopButton.Parent = MainFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0,12)
stopCorner.Parent = StopButton

StopButton.MouseButton1Click:Connect(function()
    if animTrack then
        animTrack:Stop()
        animTrack = nil
    end
    if connection then
        connection:Disconnect()
        connection = nil
    end
    Title.Text = "A Simple Fuck(ing) GUI"
end)

-- Draggable (работает на телефоне)
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("✅ Мобильная версия скрипта загружена! Перетаскивай меню пальцем.")
