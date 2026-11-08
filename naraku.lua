--[[
    ╔═══════════════════════════════════════════════════════╗
    ║                                                       ║
    ║           NARAKU RIVALS - v8.0 FIXED                  ║
    ║                                                       ║
    ║   ✓ Silent Aim (Fixed)                                ║
    ║   ✓ ESP (Box/Name/Health/Dist/Tracer)                 ║
    ║   ✓ Infinite Jump (Working)                           ║
    ║   ✓ Walk on Water (Fixed - No Freeze)                 ║
    ║   ✓ FOV Circle                                        ║
    ║   ✓ Clean & Modern UI                                 ║
    ╚═══════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════
--                        SERVICES
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════
--                        CONFIG
-- ═══════════════════════════════════════════════════════════
local Config = {
    SilentAim = true,
    SilentAimFOV = 500,
    SilentAimHitchance = 100,
    SilentAimTargetPart = "Head",
    ESP = true,
    ESPBox = true,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracer = true,
    ESPChams = false,
    WalkOnWater = false,
    InfiniteJump = false,
    FOVCircle = true,
    FOVCircleRainbow = true,
}

-- ═══════════════════════════════════════════════════════════
--                        THEME (Anime Clean)
-- ═══════════════════════════════════════════════════════════
local Theme = {
    -- Base Colors
    Bg = Color3.fromRGB(15, 15, 25),
    Sec = Color3.fromRGB(25, 25, 40),
    Ter = Color3.fromRGB(40, 40, 60),
    
    -- Accent Colors
    Acc = Color3.fromRGB(130, 80, 255),      -- Purple
    Acc2 = Color3.fromRGB(255, 80, 200),     -- Pink
    Acc3 = Color3.fromRGB(80, 200, 255),     -- Cyan
    
    -- Status Colors
    Success = Color3.fromRGB(80, 255, 150),
    Danger = Color3.fromRGB(255, 70, 100),
    
    -- Text Colors
    Text = Color3.fromRGB(240, 240, 255),
    Sub = Color3.fromRGB(160, 160, 190),
}

-- ═══════════════════════════════════════════════════════════
--                        UTILITY
-- ═══════════════════════════════════════════════════════════
local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isValidTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character or not plr.Character.Parent then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local head = plr.Character:FindFirstChild("Head")
    if not hum or not head then return false end
    if hum.Health <= 0 then return false end
    return true
end

local function getClosestTarget(fov)
    local closest = nil
    local closestValue = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if isValidTarget(plr) then
            local targetPart = plr.Character:FindFirstChild(Config.SilentAimTargetPart)
                or plr.Character:FindFirstChild("Head")
            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist <= fov then
                        if dist < closestValue then
                            closestValue = dist
                            closest = {plr = plr, part = targetPart}
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ═══════════════════════════════════════════════════════════
--                        UI CREATION
-- ═══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NarakuRivalsV8"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- Floating Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.BackgroundColor3 = Theme.Acc
OpenBtn.Text = "奈"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 24
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.AutoButtonColor = false
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OBC = Instance.new("UICorner")
OBC.CornerRadius = UDim.new(1, 0)
OBC.Parent = OpenBtn

local OBS = Instance.new("UIStroke")
OBS.Color = Color3.fromRGB(255, 255, 255)
OBS.Thickness = 2
OBS.Transparency = 0.2
OBS.Parent = OpenBtn

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, -300, 0.5, -280)
Main.BackgroundColor3 = Theme.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 16)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Theme.Acc
MS.Thickness = 2
MS.Transparency = 0.1
MS.Parent = Main

Main:TweenSize(UDim2.new(0, 600, 0, 550), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Theme.Sec
Header.BorderSizePixel = 0
Header.Parent = Main

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0, 16)
HC.Parent = Header

local HG = Instance.new("UIGradient")
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Acc),
    ColorSequenceKeypoint.new(0.5, Theme.Acc2),
})
HG.Rotation = 45
HG.Parent = Header

local HO = Instance.new("Frame")
HO.Size = UDim2.new(1, 0, 1, 0)
HO.BackgroundColor3 = Theme.Bg
HO.BackgroundTransparency = 0.3
HO.BorderSizePixel = 0
HO.Parent = Header

local HOC = Instance.new("UICorner")
HOC.CornerRadius = UDim.new(0, 16)
HOC.Parent = HO

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "奈 NARAKU RIVALS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -80, 0, 15)
MinBtn.BackgroundColor3 = Theme.Ter
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header

local MNC = Instance.new("UICorner")
MNC.CornerRadius = UDim.new(0, 8)
MNC.Parent = MinBtn

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -42, 0, 15)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✖"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 40)
TabBar.Position = UDim2.new(0, 10, 0, 70)
TabBar.BackgroundColor3 = Theme.Sec
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 10)
TBC.Parent = TabBar

local TBP = Instance.new("UIPadding")
TBP.PaddingLeft = UDim.new(0, 5)
TBP.PaddingRight = UDim.new(0, 5)
TBP.PaddingTop = UDim.new(0, 5)
TBP.PaddingBottom = UDim.new(0, 5)
TBP.Parent = TabBar

local TBL = Instance.new("UIListLayout")
TBL.FillDirection = Enum.FillDirection.Horizontal
TBL.Padding = UDim.new(0, 5)
TBL.Parent = TabBar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -130)
Content.Position = UDim2.new(0, 10, 0, 120)
Content.BackgroundColor3 = Theme.Sec
Content.BorderSizePixel = 0
Content.Parent = Main

local ConC = Instance.new("UICorner")
ConC.CornerRadius = UDim.new(0, 12)
ConC.Parent = Content

-- Tab system
local Tabs = {}

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 135, 1, 0)
    TabBtn.BackgroundColor3 = Theme.Ter
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Theme.Sub
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabBar
    
    local TabC = Instance.new("UICorner")
    TabC.CornerRadius = UDim.new(0, 8)
    TabC.Parent = TabBtn
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Theme.Acc
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Visible = false
    Scroll.Parent = Content
    
    local ScrollPad = Instance.new("UIPadding")
    ScrollPad.PaddingTop = UDim.new(0, 10)
    ScrollPad.PaddingLeft = UDim.new(0, 10)
    ScrollPad.PaddingRight = UDim.new(0, 10)
    ScrollPad.PaddingBottom = UDim.new(0, 10)
    ScrollPad.Parent = Scroll
    
    local ScrollL = Instance.new("UIListLayout")
    ScrollL.Padding = UDim.new(0, 8)
    ScrollL.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollL.Parent = Scroll
    
    Tabs[name] = {Button = TabBtn, Scroll = Scroll}
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Scroll.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme.Ter,
                TextColor3 = Theme.Sub
            }):Play()
        end
        Scroll.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Theme.Acc,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    return Scroll
end

-- ═══════════════════════════════════════════════════════════
--                        UI HELPERS
-- ═══════════════════════════════════════════════════════════

local function CreateSection(parent, text)
    local S = Instance.new("Frame")
    S.Size = UDim2.new(1, 0, 0, 32)
    S.BackgroundColor3 = Theme.Bg
    S.BackgroundTransparency = 0.5
    S.BorderSizePixel = 0
    S.Parent = parent
    
    local SC = Instance.new("UICorner")
    SC.CornerRadius = UDim.new(0, 8)
    SC.Parent = S
    
    local L = Instance.new("Frame")
    L.Size = UDim2.new(0, 4, 0, 18)
    L.Position = UDim2.new(0, 10, 0.5, -9)
    L.BackgroundColor3 = Theme.Acc
    L.BorderSizePixel = 0
    L.Parent = S
    
    local LC = Instance.new("UICorner")
    LC.CornerRadius = UDim.new(1, 0)
    LC.Parent = L
    
    local T = Instance.new("TextLabel")
    T.Size = UDim2.new(1, -30, 1, 0)
    T.Position = UDim2.new(0, 22, 0, 0)
    T.BackgroundTransparency = 1
    T.Text = text
    T.TextColor3 = Theme.Text
    T.TextSize = 13
    T.Font = Enum.Font.GothamBold
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = S
end

local function CreateToggle(parent, name, icon, default, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 48)
    B.BackgroundColor3 = Theme.Ter
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = parent
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = B
    
    local I = Instance.new("TextLabel")
    I.Size = UDim2.new(0, 40, 1, 0)
    I.Position = UDim2.new(0, 5, 0, 0)
    I.BackgroundTransparency = 1
    I.Text = icon
    I.TextSize = 22
    I.Font = Enum.Font.GothamBold
    I.Parent = B
    
    local N = Instance.new("TextLabel")
    N.Size = UDim2.new(1, -120, 1, 0)
    N.Position = UDim2.new(0, 50, 0, 0)
    N.BackgroundTransparency = 1
    N.Text = name
    N.TextColor3 = Theme.Text
    N.TextSize = 14
    N.Font = Enum.Font.GothamBold
    N.TextXAlignment = Enum.TextXAlignment.Left
    N.Parent = B
    
    local Sw = Instance.new("Frame")
    Sw.Size = UDim2.new(0, 44, 0, 24)
    Sw.Position = UDim2.new(1, -54, 0.5, -12)
    Sw.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
    Sw.BorderSizePixel = 0
    Sw.Parent = B
    
    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw
    
    local K = Instance.new("Frame")
    K.Size = UDim2.new(0, 18, 0, 18)
    K.Position = UDim2.new(0, 3, 0.5, -9)
    K.BackgroundColor3 = Color3.fromRGB(220, 215, 240)
    K.BorderSizePixel = 0
    K.Parent = Sw
    
    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = K
    
    local state = default or false
    
    local function updateVisual()
        if state then
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Acc}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -21, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 40, 65)}):Play()
            TweenService:Create(K, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(220, 215, 240)
            }):Play()
        end
    end
    
    updateVisual()
    
    B.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then pcall(callback, state) end
    end)
end

local function CreateSlider(parent, name, min, max, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 60)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 0, 22)
    L.Position = UDim2.new(0, 10, 0, 5)
    L.BackgroundTransparency = 1
    L.Text = name .. ": " .. default
    L.TextColor3 = Theme.Text
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 10)
    Bar.Position = UDim2.new(0, 10, 1, -20)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
    Bar.BorderSizePixel = 0
    Bar.Parent = C
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar
    
    local F = Instance.new("Frame")
    F.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    F.BackgroundColor3 = Theme.Acc
    F.BorderSizePixel = 0
    F.Parent = Bar
    
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
    FC.Parent = F
    
    local val = default
    local drag = false
    
    local function upd(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * pos)
        F.Size = UDim2.new(pos, 0, 1, 0)
        L.Text = name .. ": " .. val
        if callback then pcall(callback, val) end
    end
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(input)
        end
    end)
    
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
end

local function CreateDropdown(parent, name, options, default, callback)
    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, 0, 0, 45)
    C.BackgroundColor3 = Theme.Ter
    C.BorderSizePixel = 0
    C.Parent = parent
    
    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(0, 10)
    CC.Parent = C
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.5, 0, 1, 0)
    L.Position = UDim2.new(0, 10, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = name
    L.TextColor3 = Theme.Text
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = C
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.42, 0, 0, 30)
    Btn.Position = UDim2.new(0.55, 0, 0.5, -15)
    Btn.BackgroundColor3 = Theme.Acc
    Btn.Text = default
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Btn.Parent = C
    
    local BtnC = Instance.new("UICorner")
    BtnC.CornerRadius = UDim.new(0, 6)
    BtnC.Parent = Btn
    
    local index = 1
    for i, v in ipairs(options) do
        if v == default then index = i break end
    end
    
    Btn.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        local currentVal = options[index]
        Btn.Text = currentVal
        if callback then pcall(callback, currentVal) end
    end)
end

-- ═══════════════════════════════════════════════════════════
--                        CREATE TABS
-- ═══════════════════════════════════════════════════════════
local SilentTab = CreateTab("Silent Aim", "👻")
local ESPTab = CreateTab("ESP", "👁️")
local MoveTab = CreateTab("Movement", "💨")
local MiscTab = CreateTab("Misc", "🛠️")

Tabs["Silent Aim"].Scroll.Visible = true
TweenService:Create(Tabs["Silent Aim"].Button, TweenInfo.new(0.15), {
    BackgroundColor3 = Theme.Acc,
    TextColor3 = Color3.fromRGB(255, 255, 255)
}):Play()

-- ═══════════════════════════════════════════════════════════
--                    👻 SILENT AIM TAB
-- ═══════════════════════════════════════════════════════════
CreateSection(SilentTab, "👻 SILENT AIM")

CreateToggle(SilentTab, "Enable Silent Aim", "👻", true, function(v)
    Config.SilentAim = v
end)

CreateDropdown(SilentTab, "Target Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "Head", function(v)
    Config.SilentAimTargetPart = v
end)

CreateSlider(SilentTab, "FOV", 50, 1500, 500, function(v)
    Config.SilentAimFOV = v
end)

CreateSlider(SilentTab, "Hitchance (%)", 0, 100, 100, function(v)
    Config.SilentAimHitchance = v
end)

CreateSection(SilentTab, "⭕ FOV CIRCLE")

CreateToggle(SilentTab, "Show FOV Circle", "⭕", true, function(v)
    Config.FOVCircle = v
end)

CreateToggle(SilentTab, "Rainbow FOV", "🌈", true, function(v)
    Config.FOVCircleRainbow = v
end)

-- ═══════════════════════════════════════════════════════════
--                    👁️ ESP TAB
-- ═══════════════════════════════════════════════════════════
CreateSection(ESPTab, "👁️ ESP")

CreateToggle(ESPTab, "Enable ESP", "👁️", true, function(v)
    Config.ESP = v
    if not v then
        for plr, esp in pairs(ESPs) do
            pcall(function()
                if esp.box then esp.box:Remove() end
                if esp.name then esp.name:Remove() end
                if esp.health then esp.health:Remove() end
                if esp.dist then esp.dist:Remove() end
                if esp.tracer then esp.tracer:Remove() end
                if esp.cham then esp.cham:Destroy() end
            end)
        end
        ESPs = {}
    end
end)

CreateToggle(ESPTab, "Box ESP", "📦", true, function(v) Config.ESPBox = v end)
CreateToggle(ESPTab, "Name ESP", "📝", true, function(v) Config.ESPName = v end)
CreateToggle(ESPTab, "Distance ESP", "📏", true, function(v) Config.ESPDistance = v end)
CreateToggle(ESPTab, "Health ESP", "❤️", true, function(v) Config.ESPHealth = v end)
CreateToggle(ESPTab, "Tracer ESP", "📡", true, function(v) Config.ESPTracer = v end)
CreateToggle(ESPTab, "Chams ESP", "🎨", false, function(v) Config.ESPChams = v end)

-- ═══════════════════════════════════════════════════════════
--                    💨 MOVEMENT TAB
-- ═══════════════════════════════════════════════════════════
CreateSection(MoveTab, "💨 MOVEMENT")

CreateToggle(MoveTab, "Walk on Water", "🌊", false, function(v)
    Config.WalkOnWater = v
end)

CreateToggle(MoveTab, "Infinite Jump", "🦘", false, function(v)
    Config.InfiniteJump = v
end)

-- ═══════════════════════════════════════════════════════════
--                    🛠️ MISC TAB
-- ═══════════════════════════════════════════════════════════
CreateSection(MiscTab, "🛠️ UTILITIES")

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 45)
resetBtn.BackgroundColor3 = Theme.Acc
resetBtn.Text = "🔄 Reset Character"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 14
resetBtn.Font = Enum.Font.GothamBold
resetBtn.AutoButtonColor = false
resetBtn.Parent = MiscTab

local RBC = Instance.new("UICorner")
RBC.CornerRadius = UDim.new(0, 10)
RBC.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    local char = getChar()
    if char then char:BreakJoints() end
end)

-- ═══════════════════════════════════════════════════════════
--                    ⚙️ CORE - SILENT AIM
-- ═══════════════════════════════════════════════════════════
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if Config.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            if math.random(100) <= Config.SilentAimHitchance then
                local target = getClosestTarget(Config.SilentAimFOV)
                if target and target.part then
                    local ray = args[1]
                    if typeof(ray) == "Ray" then
                        local origin = ray.Origin
                        local newDir = target.part.Position - origin
                        args[1] = Ray.new(origin, newDir)
                    end
                end
            end
        end
        
        if Config.SilentAim and method == "Raycast" then
            if math.random(100) <= Config.SilentAimHitchance then
                local target = getClosestTarget(Config.SilentAimFOV)
                if target and target.part then
                    local origin = args[1]
                    local direction = args[2]
                    if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                        args[2] = (target.part.Position - origin).Unit * direction.Magnitude
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))
end)

pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if Config.SilentAim and (key == "Hit" or key == "Target") then
            if typeof(self) == "Instance" and (self == Mouse or self.ClassName == "Mouse") then
                if math.random(100) <= Config.SilentAimHitchance then
                    local target = getClosestTarget(Config.SilentAimFOV)
                    if target and target.part then
                        if key == "Hit" then return target.part.Position end
                        if key == "Target" then return target.part end
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end)

-- ═══════════════════════════════════════════════════════════
--                    FOV CIRCLE
-- ═══════════════════════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(130, 80, 255)
fovCircle.Transparency = 1
fovCircle.NumSides = 64
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    if Config.FOVCircle then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Config.SilentAimFOV
        fovCircle.Visible = true
        if Config.FOVCircleRainbow then
            fovCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    else
        fovCircle.Visible = false
    end
end)

-- ═══════════════════════════════════════════════════════════
--                    ESP
-- ═══════════════════════════════════════════════════════════
ESPs = {}
task.spawn(function()
    while task.wait() do
        if Config.ESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    
                    if hum and root then
                        if not ESPs[plr] then
                            local esp = {}
                
