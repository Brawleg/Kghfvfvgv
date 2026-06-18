-- Jerk Animation Toggle Menu (R6, Mobile Friendly)
-- Вставь в executor

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local animationId = "rbxassetid://1234567890"  -- ← Замени на реальный ID jerk-анимации (R6). Попробуй из популярных скриптов, например из Universal Jerk Off

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local anim = Instance.new("Animation")
anim.AnimationId = animationId

local track = nil
local isPlaying = false

-- Создаём GUI (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JerkMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 180)
frame.Position = UDim2.new(0.5, -125, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Jerk Menu"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "ВКЛ АНИМАЦИЮ"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0.75, 0)
status.BackgroundTransparency = 1
status.Text = "Статус: Выкл"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.TextScaled = true
status.Parent = frame

-- Draggable (для удобства на телефоне)
local dragging = false
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- Функция toggle
local function toggleAnimation()
    if not track then
        track = humanoid:LoadAnimation(anim)
        track.Looped = true
    end
    
    if isPlaying then
        track:Stop()
        isPlaying = false
        toggleBtn.Text = "ВКЛ АНИМАЦИЮ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        status.Text = "Статус: Выкл"
    else
        track:Play()
        isPlaying = true
        toggleBtn.Text = "ВЫКЛ АНИМАЦИЮ"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        status.Text = "Статус: Вкл (видно всем)"
    end
end

toggleBtn.MouseButton1Click:Connect(toggleAnimation)

-- Авто-обновление character
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    track = nil  -- сброс
    if isPlaying then
        wait(1)
        toggleAnimation()  -- перезапустить если было включено
    end
end)

print("Jerk Menu загружен! Перетаскивай за заголовок.")
