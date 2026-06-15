-- === Body Parts Disassemble Menu (Реальные части тела рассыпаются) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local disassembled = false
local savedJoints = {}
local bodyVelocityConnections = {}

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
title.Text = "💥 РАССЫПАНИЕ ТЕЛА"
title.TextColor3 = Color3.fromRGB(255, 80, 0)
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
toggleBtn.Text = "РАССЫПАТЬ ТЕЛО\n(другие видят)"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 50)
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

-- Сохранение и разрыв соединений
local function disassembleBody()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = true  -- чтобы не умирать и не падать в анимацию
    end

    for _, motor in pairs(character:GetDescendants()) do
        if motor:IsA("Motor6D") and motor.Part1 then
            if not savedJoints[motor] then
                savedJoints[motor] = {
                    C0 = motor.C0,
                    C1 = motor.C1,
                    Parent = motor.Parent
                }
            end
            
            local part1 = motor.Part1
            motor:Destroy()  -- разрываем соединение (видно всем)
            
            -- Даём импульс чтобы части разлетелись
            if part1 then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(10000, 10000, 10000)
                bv.Velocity = Vector3.new(math.random(-20,20), math.random(10,30), math.random(-20,20))
                bv.Parent = part1
                game.Debris:AddItem(bv, 4)
                
                part1.CanCollide = true
            end
        end
    end
end

local function reassembleBody()
    local character = player.Character
    if not character then return end
    
    for motor, data in pairs(savedJoints) do
        if not motor.Parent then
            local newMotor = Instance.new("Motor6D")
            newMotor.Name = "ReassembledJoint"
            newMotor.C0 = data.C0
            newMotor.C1 = data.C1
            newMotor.Part0 = character:FindFirstChild("HumanoidRootPart") or data.Parent
            newMotor.Part1 = character:FindFirstChild(motor.Part1 and motor.Part1.Name or "")
            newMotor.Parent = data.Parent
        end
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    savedJoints = {}
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    disassembled = not disassembled
    
    if disassembled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        toggleBtn.Text = "СОБРАТЬ ТЕЛО"
        statusLabel.Text = "Тело рассыпано (видно всем)"
        disassembleBody()
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "РАССЫПАТЬ ТЕЛО\n(другие видят)"
        statusLabel.Text = "Выключено"
        reassembleBody()
    end
end)

-- Респавн
player.CharacterAdded:Connect(function()
    wait(2)
    savedJoints = {}
    if disassembled then
        disassembled = false
        toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        toggleBtn.Text = "РАССЫПАТЬ ТЕЛО\n(другие видят)"
        statusLabel.Text = "Выключено"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if disassembled then
        reassembleBody()
    end
    screenGui:Destroy()
end)

print("Скрипт рассыпания тела загружен! Другие игроки увидят разлетевшиеся части.")
