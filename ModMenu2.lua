-- === MOD MENU by Grok (для мобильных и ПК) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "Mod Menu"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.TextScaled = true
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = mainFrame

-- Draggable (работает на мобильных)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)

-- Переменные для хаков
local speedValue = 50
local jumpPowerValue = 100
local infJumpEnabled = false
local throwEnabled = false
local throwDistance = 8
local throwSpeed = 0.3

-- Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 30)
speedLabel.Position = UDim2.new(0, 10, 0, 50)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. speedValue
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Parent = mainFrame

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0.45, 0, 0, 30)
speedUp.Position = UDim2.new(0, 10, 0, 85)
speedUp.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
speedUp.Text = "+10"
speedUp.Parent = mainFrame

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0.45, 0, 0, 30)
speedDown.Position = UDim2.new(0.5, 5, 0, 85)
speedDown.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
speedDown.Text = "-10"
speedDown.Parent = mainFrame

-- Jump
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -20, 0, 30)
jumpLabel.Position = UDim2.new(0, 10, 0, 130)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Jump Power: " .. jumpPowerValue
jumpLabel.TextColor3 = Color3.new(1,1,1)
jumpLabel.Parent = mainFrame

local jumpUp = Instance.new("TextButton")
jumpUp.Size = UDim2.new(0.45, 0, 0, 30)
jumpUp.Position = UDim2.new(0, 10, 0, 165)
jumpUp.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
jumpUp.Text = "+20"
jumpUp.Parent = mainFrame

local jumpDown = Instance.new("TextButton")
jumpDown.Size = UDim2.new(0.45, 0, 0, 30)
jumpDown.Position = UDim2.new(0.5, 5, 0, 165)
jumpDown.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
jumpDown.Text = "-20"
jumpDown.Parent = mainFrame

local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Size = UDim2.new(1, -20, 0, 40)
infJumpBtn.Position = UDim2.new(0, 10, 0, 205)
infJumpBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
infJumpBtn.Text = "Infinite Jump: OFF"
infJumpBtn.Parent = mainFrame

-- Throw Hand
local throwLabel = Instance.new("TextLabel")
throwLabel.Size = UDim2.new(1, -20, 0, 30)
throwLabel.Position = UDim2.new(0, 10, 0, 260)
throwLabel.BackgroundTransparency = 1
throwLabel.Text = "Throw Distance: " .. throwDistance
throwLabel.TextColor3 = Color3.new(1,1,1)
throwLabel.Parent = mainFrame

local throwBtn = Instance.new("TextButton")
throwBtn.Size = UDim2.new(1, -20, 0, 40)
throwBtn.Position = UDim2.new(0, 10, 0, 295)
throwBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
throwBtn.Text = "Throw Right Hand (Toggle)"
throwBtn.Parent = mainFrame

-- Логика Speed
speedUp.MouseButton1Click:Connect(function()
    speedValue = speedValue + 10
    speedLabel.Text = "Speed: " .. speedValue
    if humanoid then humanoid.WalkSpeed = speedValue end
end)

speedDown.MouseButton1Click:Connect(function()
    speedValue = math.max(16, speedValue - 10)
    speedLabel.Text = "Speed: " .. speedValue
    if humanoid then humanoid.WalkSpeed = speedValue end
end)

-- Jump
jumpUp.MouseButton1Click:Connect(function()
    jumpPowerValue = jumpPowerValue + 20
    jumpLabel.Text = "Jump Power: " .. jumpPowerValue
    if humanoid then humanoid.JumpPower = jumpPowerValue end
end)

jumpDown.MouseButton1Click:Connect(function()
    jumpPowerValue = math.max(50, jumpPowerValue - 20)
    jumpLabel.Text = "Jump Power: " .. jumpPowerValue
    if humanoid then humanoid.JumpPower = jumpPowerValue end
end)

infJumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    infJumpBtn.Text = "Infinite Jump: " .. (infJumpEnabled and "ON" or "OFF")
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Throw Right Hand
local originalC0 = nil
local rightShoulder = nil
local isThrowing = false

local function resetArm()
    if rightShoulder and originalC0 then
        rightShoulder.C0 = originalC0
    end
    isThrowing = false
end

throwBtn.MouseButton1Click:Connect(function()
    throwEnabled = not throwEnabled
    throwBtn.Text = throwEnabled and "Throwing: ON (tap again to stop)" or "Throw Right Hand (Toggle)"
    
    if throwEnabled then
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        rightShoulder = character:FindFirstChild("Right Shoulder") or character:FindFirstChild("RightUpperArm"):FindFirstChild("RightShoulder")
        
        if rightShoulder and not originalC0 then
            originalC0 = rightShoulder.C0
        end
        
        -- Анимация броска
        spawn(function()
            while throwEnabled and character and character.Parent do
                if rightShoulder then
                    -- Бросок вперёд
                    local tweenInfo = TweenInfo.new(throwSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local throwGoal = {C0 = originalC0 * CFrame.new(throwDistance, 0, 0) * CFrame.Angles(0, 0, math.rad(-45))}
                    local throwTween = TweenService:Create(rightShoulder, tweenInfo, throwGoal)
                    throwTween:Play()
                    throwTween.Completed:Wait()
                    
                    wait(0.2)
                    
                    -- Возврат
                    local returnTween = TweenService:Create(rightShoulder, tweenInfo, {C0 = originalC0})
                    returnTween:Play()
                    returnTween.Completed:Wait()
                end
                wait(0.5)
            end
            resetArm()
        end)
    else
        resetArm()
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Авто-обновление humanoid при респавне
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    humanoid.WalkSpeed = speedValue
    humanoid.JumpPower = jumpPowerValue
end)

print("Mod Menu загружен! Перетаскивай за заголовок. Работает на телефоне.")
