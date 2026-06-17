-- === Detach All Body Parts (Full Death) ===
-- Для Executor (Mobile/PC)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

wait(0.5) -- небольшая задержка на загрузку персонажа

local function detachAllParts()
    if not character then return end
    
    -- Включаем физику для всех частей
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = true
            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5) -- чуть более реалистичная физика
        end
    end
    
    -- Удаляем все Motor6D (суставы)
    for _, motor in ipairs(character:GetDescendants()) do
        if motor:IsA("Motor6D") then
            motor:Destroy() -- полностью отсоединяет часть
        end
    end
    
    -- Дополнительно ломаем все BallSocket, Weld и другие соединения
    for _, joint in ipairs(character:GetDescendants()) do
        if joint:IsA("BallSocketConstraint") or joint:IsA("Weld") or joint:IsA("WeldConstraint") or joint:IsA("NoCollisionConstraint") then
            joint:Destroy()
        end
    end
    
    -- Отключаем Humanoid (чтобы не мешал)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:Destroy()
    end
    
    -- Делаем все части падающими и независимыми
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.new(math.random(-10,10), math.random(15,30), math.random(-10,10))
            part.Velocity = part.AssemblyLinearVelocity
        end
    end
    
    print("Все части тела отсоединены!")
end

-- Запуск
detachAllParts()

-- Если хочешь, чтобы работало при респавне:
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(1)
    detachAllParts()
end)
