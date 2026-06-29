-- [[ KRB HUB ]] --  ULTIMATE 
-- Exploiting Direct Internal Remotes (StartCombatAction)
-- Specially Optimized for Abu Atab (cx)

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("KRB_AirFlowHub") then
    PlayerGui.KRB_AirFlowHub:Destroy()
end

_G.AutoFarm = false
_G.SelectedMob = ""
_G.AutoSkills = false
_G.AutoQuest = false
_G.IsParrying = false 

local CurrentTarget = nil
local NativeSkillsActivated = false
local MobileBlockButton = nil

-- محاولة صيد الريموت الداخلي للعبة بناءً على ملف الـ Constants
local StartActionRemote = ReplicatedStorage:FindFirstChild("StartCombatAction", true) 
    or ReplicatedStorage:FindFirstChild("CombatConsoleCommand", true)

local function GetMobLevel(name)
    local num = string.match(name, "%d+")
    return num and tonumber(num) or 0
end

local function GetSortedEnemies()
    local enemyList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local name = obj.Name
            if name == Player.Name or Players:GetPlayerFromCharacter(obj) or tonumber(name) then continue end
            if name == "Model" or name == "Part" or string.find(string.lower(name), "drop") then continue end
            if not table.find(enemyList, name) then table.insert(enemyList, name) end
        end
    end
    table.sort(enemyList, function(a, b) return GetMobLevel(a) < GetMobLevel(b) end)
    return enemyList
end

-- بناء واجهة الأيرفلو الفخمة بالأبيض والأسود
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KRB_AirFlowHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "KRBToggle"
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0, 15, 0, 150)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Text = "KRB"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 16
ToggleBtn.Parent = ScreenGui

local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)

local tDragging, tDragInput, tDragStart, tStartPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true tDragStart = input.Position tStartPos = ToggleBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then tDragging = false end end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then tDragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == tDragInput and tDragging then
        local delta = input.Position - tDragStart
        ToggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 360)
local CenterPosition = UDim2.new(0.5, -170, 0.5, -180)
MainFrame.Position = CenterPosition
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then MainFrame.Position = CenterPosition end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "  KRB HUB |  V1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 55)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, 0, 0, 35)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.Text = "SELECT MOB 🔽"
DropdownBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
DropdownBtn.Font = Enum.Font.Code
DropdownBtn.TextSize = 12
DropdownBtn.Parent = Container

local DropdownScroll = Instance.new("ScrollingFrame")
DropdownScroll.Size = UDim2.new(1, 0, 0, 140)
DropdownScroll.Position = UDim2.new(0, 0, 0, 40)
DropdownScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
DropdownScroll.Visible = false
DropdownScroll.ScrollBarThickness = 3
DropdownScroll.Parent = Container
Instance.new("UIListLayout", DropdownScroll).Padding = UDim.new(0, 4)

local function UpdateDropdown()
    for _, child in pairs(DropdownScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local sortedEnemies = GetSortedEnemies()
    DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #sortedEnemies * 34)
    for _, mobName in ipairs(sortedEnemies) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -5, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = mobName
        b.TextColor3 = Color3.fromRGB(0, 0, 0)
        b.Font = Enum.Font.Code
        b.TextSize = 11
        b.Parent = DropdownScroll
        b.MouseButton1Click:Connect(function()
            _G.SelectedMob = mobName
            DropdownBtn.Text = "TARGET: " .. mobName
            DropdownScroll.Visible = false
        end)
    end
end

DropdownBtn.MouseButton1Click:Connect(function()
    DropdownScroll.Visible = not DropdownScroll.Visible
    if DropdownScroll.Visible then UpdateDropdown() end
end)

local function AddAirFlowToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. " : OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.Parent = Container
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30)
        btn.TextColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        btn.Text = text .. (state and " : ON" or " : OFF")
        callback(state)
    end)
end

AddAirFlowToggle("AUTO FARM (MAP-WIDE SCAN)", 190, function(v) _G.AutoFarm = v end)
AddAirFlowToggle("AUTO SKILLS ", 230, function(v) _G.AutoSkills = v end)
AddAirFlowToggle("AUTO TAKE QUEST", 270, function(v) _G.AutoQuest = v end)

local function PressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function ClickGuiElement(btn)
    if btn and btn:IsA("GuiObject") and btn.AbsoluteSize.X > 0 then
        pcall(function()
            local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2)
            local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end)
    end
end

local function FindGameBlockButton()
    if MobileBlockButton and MobileBlockButton.Parent then return MobileBlockButton end
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local screenSize = camera.ViewportSize
    
    pcall(function()
        for _, v in ipairs(PlayerGui:GetDescendants()) do
            if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Name ~= "KRBToggle" then
                if v.AbsolutePosition.X > (screenSize.X * 0.7) and v.AbsolutePosition.Y > (screenSize.Y * 0.5) then
                    if v.Name:lower():find("block") or v.Text == "F" or (v:FindFirstChildOfClass("TextLabel") and v:FindFirstChildOfClass("TextLabel").Text == "F") then
                        MobileBlockButton = v
                        return
                    end
                end
            end
        end
    end)
    return MobileBlockButton
end

local function AutoQuestFunction()
    if _G.AutoQuest and _G.SelectedMob ~= "" then
        pcall(function()
            for _, v in pairs(ReplicatedStorage:GetSharedDescendants()) do
                if v:IsA("RemoteEvent") and (string.find(v.Name, "Quest") or string.find(v.Name, "Mission")) then
                    v:FireServer(_G.SelectedMob)
                end
            end
        end)
    end
end

local function ToggleNativeGameSkills(state)
    pcall(function()
        for _, key in ipairs({"Z", "X", "C"}) do
            local targetTemplate = "template" .. string.lower(key)
            for _, obj in ipairs(PlayerGui:GetDescendants()) do
                if obj:IsA("GuiObject") and string.lower(obj.Name) == targetTemplate then
                    if obj.Visible and obj.AbsolutePosition.Y > 0 then
                        local autoFrame = obj:FindFirstChild("Auto")
                        local openBtn = autoFrame and autoFrame:FindFirstChild("Open")
                        if openBtn then ClickGuiElement(openBtn) end
                    end
                end
            end
        end
    end)
end

-- [[ الرادار البصري الذكي المطور ]]
local function IsFIndicatorPresent()
    local detected = false
    local camera = workspace.CurrentCamera
    if not camera then return false end
    local screenSize = camera.ViewportSize
    
    pcall(function()
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.Text == "F" then
                -- فلترة الحجم: يجب أن يكون النص ضخم جداً لاستبعاد الزر الثابت
                if gui.AbsoluteSize.X > 50 and gui.Parent.Name ~= "KRB_AirFlowHub" and gui.Name ~= "KRBToggle" then
                    if gui.AbsolutePosition.X < (screenSize.X * 0.75) then
                        detected = true
                        return
                    end
                end
            end
            if gui:IsA("ImageLabel") and gui.Visible and gui.AbsoluteSize.X > 60 then
                local n = gui.Name:lower()
                if n:find("parry") or n:find("qte") or n:find("ring") or n:find("f_") then
                    if gui.AbsolutePosition.X < (screenSize.X * 0.8) and gui.AbsolutePosition.Y < (screenSize.Y * 0.8) then
                        detected = true
                        return
                    end
                end
            end
        end
        if CurrentTarget then
            for _, child in ipairs(CurrentTarget:GetDescendants()) do
                if child:IsA("BillboardGui") and child.Enabled then
                    detected = true
                    return
                end
            end
        end
    end)
    return detected
end

-- [المسار 1]: الملاحقة اللصيقة + الصد المزدوج (فيزيائي + ريموت داخلي)
task.spawn(function()
    while task.wait(0.01) do
        if _G.AutoFarm and _G.SelectedMob ~= "" then
            pcall(function()
                local char = Player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                    local target = nil
                    local nearestDistance = math.huge
                    
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name == _G.SelectedMob and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                            local dist = (char.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
                            if dist < nearestDistance then
                                nearestDistance = dist
                                target = obj
                            end
                        end
                    end
                    
                    CurrentTarget = target
                    
                    if not target then
                        char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        AutoQuestFunction()
                    else
                        char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        char.HumanoidRootPart.CFrame = CFrame.new(target.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
                        
                        -- كشف الضربة الحقيقية بالمنتصف
                        if IsFIndicatorPresent() then
                            if not _G.IsParrying then
                                _G.IsParrying = true
                                
                                VirtualInputManager:SendMouseButtonEvent(10, 10, 0, false, game, 1)
                                local blockBtn = FindGameBlockButton()
                                
                                while IsFIndicatorPresent() and _G.AutoFarm do
                                    -- 1. صدم الريموت الداخلي المستخرج (تخطي فريمات الشاشة)
                                    if StartActionRemote and StartActionRemote:IsA("RemoteEvent") then
                                        StartActionRemote:FireServer("GuardWindow")
                                        StartActionRemote:FireServer("CombatGuardSuccess")
                                    end
                                    
                                    -- 2. المحاكاة الفيزيائية الاحتياطية لزر الجوال
                                    if blockBtn then ClickGuiElement(blockBtn) end
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                                    task.wait(0.005) -- سرعة نبض فائقة 5 ملي ثانية
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                                    task.wait(0.005)
                                end
                                
                                _G.IsParrying = false
                            end
                        end
                    end
                end
            end)
        else
            CurrentTarget = nil
        end
    end
end)

-- [المسار 2]: الضرب التلقائي المستمر
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm and CurrentTarget and not _G.IsParrying then
            pcall(function()
                local char = Player.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                else
                    VirtualInputManager:SendMouseButtonEvent(10, 10, 0, true, game, 1)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(10, 10, 0, false, game, 1)
                end
            end)
        end
    end
end)

-- [المسار 3]: تفعيل السكلات
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoFarm and _G.AutoSkills then
            if not NativeSkillsActivated then
                ToggleNativeGameSkills(true)
                NativeSkillsActivated = true
            end
            
            if not _G.IsParrying then
                task.spawn(function()
                    PressKey(Enum.KeyCode.Z)
                    task.wait(0.1)
                    PressKey(Enum.KeyCode.X)
                    task.wait(0.1)
                    PressKey(Enum.KeyCode.C)
                end)
            end
        else
            if NativeSkillsActivated then
                ToggleNativeGameSkills(false)
                NativeSkillsActivated = false
            end
        end
    end
end)
