-- Полностью рабочее мод-меню для Roblox Executor (Kavo UI)
-- Функции: Speed, JumpPower, Godmode (no death, no knockback), Throw Right Arm (функционально, не визуал)
-- Все значения настраиваемые

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Мод Меню by Grok", "DarkTheme")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Переменные для тогглов
local speedEnabled = false
local jumpEnabled = false
local godEnabled = false
local armThrowEnabled = false

local defaultWalkSpeed = Humanoid.WalkSpeed
local defaultJumpPower = Humanoid.JumpPower

-- Обновление персонажа
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
end)

-- === TAB 1: Movement ===
local Tab1 = Window:NewTab("Movement")
local Section1 = Tab1:NewSection("Speed & Jump")

Section1:NewSlider("WalkSpeed", "Установи скорость", 500, 16, function(s)
    if speedEnabled then
        Humanoid.WalkSpeed = s
    end
end)

Section1:NewSlider("JumpPower", "Установи прыжок", 500, 50, function(s)
    if jumpEnabled then
        Humanoid.JumpPower = s
    end
end)

Section1:NewToggle("Infinite Speed", "Вкл/выкл скорость", false, function(state)
    speedEnabled = state
    if state then
        Humanoid.WalkSpeed = 100 -- default high
    else
        Humanoid.WalkSpeed = defaultWalkSpeed
    end
end)

Section1:NewToggle("Infinite Jump", "Вкл/выкл улучшенный прыжок", false, function(state)
    jumpEnabled = state
    if state then
        Humanoid.JumpPower = 150
    else
        Humanoid.JumpPower = defaultJumpPower
    end
end)

-- Infinite Jump loop
game:GetService("UserInputService").JumpRequest:Connect(function()
    if jumpEnabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- === TAB 2: Godmode ===
local Tab2 = Window:NewTab("Survival")
local Section2 = Tab2:NewSection("Godmode")

Section2:NewToggle("Godmode + No Knockback", "Не умираешь и не отлетаешь", false, function(state)
    godEnabled = state
    if state then
        -- Godmode: High health + anti-damage
        spawn(function()
            while godEnabled and Humanoid do
                Humanoid.Health = Humanoid.MaxHealth
                Humanoid.MaxHealth = math.huge
                -- Anti knockback / velocity reset
                if Character:FindFirstChild("HumanoidRootPart") then
                    local root = Character.HumanoidRootPart
                    root.Velocity = Vector3.new(0, root.Velocity.Y, 0) -- keep only vertical
                end
                wait(0.1)
            end
        end)
        
        -- Hook damage (if possible)
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
    end
end)

-- === TAB 3: Fun Features ===
local Tab3 = Window:NewTab("Fun")
local Section3 = Tab3:NewSection("Arm Throw")

local throwDistance = 20
local throwSpeed = 50
local retractTime = 0.8

Section3:NewSlider("Throw Distance", "Дальность броска руки", 100, 5, function(s)
    throwDistance = s
end)

Section3:NewSlider("Throw Speed", "Скорость броска", 200, 20, function(s)
    throwSpeed = s
end)

Section3:NewSlider("Return Time", "Время возврата (сек)", 3, 0.2, function(s)
    retractTime = s
end)

Section3:NewToggle("Enable Arm Throw (Right Arm)", "Кидай правую руку вперёд (функционально)", false, function(state)
    armThrowEnabled = state
end)

-- Keybind for throw (F key example)
local UIS = game:GetService("UserInputService")
local throwCooldown = false

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F and armThrowEnabled and not throwCooldown then
        throwCooldown = true
        ThrowRightArm()
        wait(1.5)
        throwCooldown = false
    end
end)

function ThrowRightArm()
    if not Character or not Character:FindFirstChild("Right Arm") then return end
    
    local rightArm = Character["Right Arm"]
    local root = Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Save original CFrame / Motor6D
    local originalCFrame = rightArm.CFrame
    local shoulder = Character:FindFirstChild("Right Shoulder") or rightArm:FindFirstChild("RightShoulder")
    
    -- Create temporary attachment or use BodyVelocity for functional throw
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = root.CFrame.LookVector * throwSpeed + Vector3.new(0, 10, 0)
    bv.Parent = rightArm
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.Parent = rightArm
    
    -- Detach visually/functionally
    if shoulder then shoulder:Destroy() end
    
    wait(0.6) -- flight time
    
    -- Retract back
    bv:Destroy()
    bg:Destroy()
    
    -- Return to position
    local tweenService = game:GetService("TweenService")
    local goal = {CFrame = originalCFrame}
    local tweenInfo = TweenInfo.new(retractTime, Enum.EasingStyle.Quad)
    local tween = tweenService:Create(rightArm, tweenInfo, goal)
    tween:Play()
    
    -- Re-attach Motor6D
    wait(retractTime)
    local newShoulder = Instance.new("Motor6D")
    newShoulder.Name = "Right Shoulder"
    newShoulder.Part0 = Character.Torso or Character.UpperTorso
    newShoulder.Part1 = rightArm
    newShoulder.C0 = CFrame.new(1.5, 0.5, 0) -- R6/R15 adjust if needed
    newShoulder.C1 = CFrame.new(0, 0.5, 0)
    newShoulder.Parent = Character
end

-- === TAB 4: Settings ===
local Tab4 = Window:NewTab("Settings")
local Section4 = Tab4:NewSection("Extras")

Section4:NewButton("Reset Character", "Перезагрузить персонаж", function()
    if Character then
        Character:BreakJoints()
    end
end)

Section4:NewKeybind("Toggle Menu", "Правый Shift", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)

print("Мод меню загружено! Нажми Right Shift для скрытия/показа. F - бросить руку.")
