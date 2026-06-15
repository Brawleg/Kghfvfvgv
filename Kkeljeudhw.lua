-- === MOBILE RIGHT HAND JERK SCRIPT (только правая рука) ===
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

-- GODMODE
humanoid.MaxHealth = math.huge
humanoid.Health = math.huge

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0,12); Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "🔞 Right Hand Jerk"
Title.TextColor3 = Color3.fromRGB(255, 60, 60)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,-20,0,180)
Scroll.Position = UDim2.new(0,10,0,60)
Scroll.BackgroundTransparency = 1
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout"); UIList.Padding = UDim.new(0,5); UIList.Parent = Scroll

local function updateList()
    for _,v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,40)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Parent = Scroll
            local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,8); c.Parent = btn
            btn.MouseButton1Click:Connect(function()
                currentVictim = plr
                Title.Text = "Жертва: "..plr.Name
            end)
        end
    end
    Scroll.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y)
end
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Кнопки
local function createBtn(txt, y, col, func)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,50)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = col
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = MainFrame
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,10); c.Parent = b
    b.MouseButton1Click:Connect(func)
end

createBtn("▶️ Начать Right Hand Jerk", 250, Color3.fromRGB(180,0,80), function()
    if not currentVictim then Title.Text = "Выбери жертву!"; return end

    local victim = currentVictim.Character
    if not victim then return end
    local vRoot = victim:FindFirstChild("HumanoidRootPart")
    if not vRoot then return end

    -- Анимация для правой руки (jerk motion)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://5918726675"  -- Лучший вариант для hand jerk (можно поменять на 698251653 если слабо)

    if animTrack then animTrack:Stop() end
    animTrack = humanoid:LoadAnimation(anim)
    animTrack.Looped = true
    animTrack:Play()
    animTrack:AdjustSpeed(2.0)  -- Быстрее = интенсивнее

    -- Следование + рука остаётся в зоне паха
    if followConnection then followConnection:Disconnect() end
    followConnection = RunService.Stepped:Connect(function()
        if not root.Parent or not vRoot.Parent then return end

        -- Следуем сзади
        local behind = vRoot.CFrame * CFrame.new(0, 0.8, 2.5)
        local look = CFrame.lookAt(behind.Position, vRoot.Position)
        root.CFrame = CFrame.new(behind.Position) * look.Rotation * CFrame.Angles(0, math.rad(160), 0)

        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
    end)

    Title.Text = "Right Hand Jerk запущен"
end)

createBtn("⏹️ Остановить", 310, Color3.fromRGB(70,70,70), function()
    if animTrack then 
        animTrack:Stop() 
        animTrack = nil 
    end
    if followConnection then 
        followConnection:Disconnect() 
        followConnection = nil 
    end
    Title.Text = "Right Hand Jerk остановлен"
end)

createBtn("🔄 Обновить список", 370, Color3.fromRGB(50,100,200), updateList)

-- Drag меню
local dragging = false
local dragStart, startPos
MainFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = inp.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function() dragging = false end)

print("✅ Right Hand Jerk скрипт загружен (только правая рука)")
