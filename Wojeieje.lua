-- === MOBILE JERK & FOLLOW SCRIPT (для телефона + drag меню) ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local currentVictim = nil
local animTrack = nil
local followConnection = nil
local isFollowing = false

-- GODMODE + анти-отлёт
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge
humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

RunService.Heartbeat:Connect(function()
    if root and root.Parent then
        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- === GUI МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "🔞 Jerk & Follow"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 0, 200)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.Parent = Scroll

local function updatePlayerList()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 45)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.Parent = Scroll
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                currentVictim = plr
                Title.Text = "Жертва: " .. plr.Name
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Кнопки
local function createBtn(text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,12); c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

-- Jerk анимация (хороший вариант для R15)
createBtn("▶️ Начать Jerk", 270, Color3.fromRGB(200, 0, 100), function()
    if not currentVictim then
        Title.Text = "Выбери жертву!"
        return
    end

    local victimChar = currentVictim.Character
    if not victimChar then return end
    local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
    if not victimRoot then return end

    -- Анимация jerk (движение рукой)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://5918726675"  -- Можно заменить на другую (например 698251653 или из jerk паков)

    if animTrack then animTrack:Stop() end
    animTrack = humanoid:LoadAnimation(anim)
    animTrack.Looped = true
    animTrack:Play()
    animTrack:AdjustSpeed(1.6)

    -- Следование за жертвой (сзади)
    if followConnection then followConnection:Disconnect() end
    isFollowing = true
    followConnection = RunService.Stepped:Connect(function()
        if not root.Parent or not victimRoot.Parent then
            isFollowing = false
            return
        end

        -- Позиция сзади жертвы
        local behind = victimRoot.CFrame * CFrame.new(0, 0.5, 3) * CFrame.Angles(0, math.rad(180), 0)
        
        -- Смотрим на жертву
        local lookAt = CFrame.lookAt(behind.Position, victimRoot.Position)
        root.CFrame = CFrame.new(behind.Position) * lookAt.Rotation

        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
    end)

    Title.Text = "Jerk + Follow за " .. currentVictim.Name
end)

createBtn("⏹️ Остановить", 330, Color3.fromRGB(80, 80, 80), function()
    if animTrack then
        animTrack:Stop()
        animTrack = nil
    end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isFollowing = false
    Title.Text = "Jerk & Follow — остановлено"
end)

createBtn("🔄 Обновить список", 390, Color3.fromRGB(60, 100, 200), updatePlayerList)

-- Draggable меню (палец)
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

print("✅ Jerk & Follow скрипт загружен! Выбери жертву и нажми 'Начать Jerk'")
