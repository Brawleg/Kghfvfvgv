-- === Chat Viewer + Sender Menu (для телефона) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local chatEnabled = false
local messages = {}

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 420)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
title.Text = "💬 Общий Чат (Bypass 16+)"
title.TextColor3 = Color3.fromRGB(0, 255, 180)
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

-- Кнопка открытия/закрытия меню (отдельная, чтобы можно было быстро открыть)
local openCloseBtn = Instance.new("TextButton")
openCloseBtn.Size = UDim2.new(0, 60, 0, 60)
openCloseBtn.Position = UDim2.new(0, 10, 0.5, -30)
openCloseBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
openCloseBtn.Text = "💬"
openCloseBtn.TextScaled = true
openCloseBtn.Parent = screenGui

-- Чат область
local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Size = UDim2.new(1, -20, 0, 220)
chatFrame.Position = UDim2.new(0, 10, 0, 60)
chatFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
chatFrame.ScrollBarThickness = 8
chatFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = chatFrame

-- Поле ввода
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -130, 0, 40)
inputBox.Position = UDim2.new(0, 10, 1, -55)
inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
inputBox.PlaceholderText = "Напиши сообщение..."
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.TextScaled = true
inputBox.Parent = mainFrame

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 110, 0, 40)
sendBtn.Position = UDim2.new(1, -120, 1, -55)
sendBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
sendBtn.Text = "Отправить"
sendBtn.TextColor3 = Color3.new(1,1,1)
sendBtn.TextScaled = true
sendBtn.Parent = mainFrame

-- Draggable (заголовок)
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

-- Функция добавления сообщения в меню
local function addMessage(sender, text, color)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -10, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Text = "[" .. sender .. "]: " .. text
    msg.TextColor3 = color or Color3.new(1,1,1)
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextScaled = true
    msg.Parent = chatFrame
    msg.AutomaticSize = Enum.AutomaticSize.Y
    
    chatFrame.CanvasPosition = Vector2.new(0, chatFrame.AbsoluteCanvasSize.Y)
end

-- Перехват сообщений чата
local function setupChatHook()
    -- Для современных игр (TextChatService)
    if TextChatService then
        TextChatService.MessageReceived:Connect(function(message)
            if not chatEnabled then return end
            local sender = message.TextSource and Players:GetPlayerByUserId(message.TextSource.UserId) or {Name = "Unknown"}
            addMessage(sender.Name, message.Text, Color3.fromRGB(255, 255, 200))
        end)
    end
    
    -- Для старых игр (DefaultChatSystem)
    local oldChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if oldChat then
        local onMessage = oldChat:FindFirstChild("OnMessageDoneFiltering")
        if onMessage then
            onMessage.OnClientEvent:Connect(function(data)
                if not chatEnabled then return end
                addMessage(data.SpeakerUserId and Players:GetPlayerByUserId(data.SpeakerUserId).Name or data.Speaker, data.Message, Color3.fromRGB(200, 255, 200))
            end)
        end
    end
end

-- Отправка сообщения
sendBtn.MouseButton1Click:Connect(function()
    local msg = inputBox.Text
    if msg == "" then return end
    
    -- Попытка отправки через ReplicatedStorage (работает в большинстве игр)
    local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                   ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
    
    if sayMsg then
        sayMsg:FireServer(msg, "All")
    else
        -- Альтернатива для TextChatService
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(msg)
            end
        end
    end
    
    inputBox.Text = ""
    addMessage(player.Name, msg, Color3.fromRGB(100, 200, 255)) -- показываем своё сообщение
end)

-- Toggle меню
local function toggleMenu()
    mainFrame.Visible = not mainFrame.Visible
end

openCloseBtn.MouseButton1Click:Connect(toggleMenu)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Включение просмотра чата
chatEnabled = true
setupChatHook()

print("Чат-меню загружено! Кнопка 💬 открывает/закрывает меню. Пиши и отправляй.")

-- Авто-обновление при респавне
player.CharacterAdded:Connect(function()
    wait(2)
    setupChatHook()
end)
