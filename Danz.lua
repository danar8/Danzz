-- ELIXIR 3.5 -- FARM, AUTO, STATUS, TP ONLY
local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait() until player.Character
local playerGui = player:WaitForChild("PlayerGui")

-- ========== VARIABLES ==========
local running = false
local autoSellEnabled = false
local buyAmount = 1
local autoFarmRunning = false
local cookAmount = 5

local buyRemote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("StorePurchase")
if not buyRemote then
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == "StorePurchase" then buyRemote = v break end
    end
end

-- ========== POSITIONS ==========
local npcPos = CFrame.new(510.762817,3.58721066,600.791504)
local tierPos = CFrame.new(1110.18726,4.28433371,117.139168)
local apart1 = CFrame.new(1140.319,10.105,450.252) * CFrame.new(0,2,0)
local apart2 = CFrame.new(1141.391,10.105,422.805) * CFrame.new(0,2,0)
local apart3 = CFrame.new(986.987,10.105,248.435) * CFrame.new(0,2,0)
local apart4 = CFrame.new(986.299,10.105,219.940) * CFrame.new(0,2,0)
local apart5 = CFrame.new(924.781,10.105,41.136) * CFrame.Angles(0,math.rad(90),0)
local apart6 = CFrame.new(896.672,10.105,40.640) * CFrame.Angles(0,math.rad(90),0)
local csn1 = CFrame.new(1178.833,3.95,-227.372)
local csn2 = CFrame.new(1205.088,3.95,-220.542)
local csn3 = CFrame.new(1204.281,3.712,-182.851)
local csn4 = CFrame.new(1178.585,3.712,-189.710)

-- ========== ANTI AFK ==========
pcall(function()
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ========== HELPERS ==========
local function holdE(t)
    vim:SendKeyEvent(true,"E",false,game)
    task.wait(t or 0.8)
    vim:SendKeyEvent(false,"E",false,game)
end

local function equip(name)
    local char = player.Character
    if not char then return false end
    local tool = player.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
    if tool and char:FindFirstChild("Humanoid") then
        char.Humanoid:EquipTool(tool)
        task.wait(0.3)
        return true
    end
    return false
end

local function countItem(name)
    local total = 0
    for _,v in pairs(player.Backpack:GetChildren()) do
        if v.Name == name then total = total + 1 end
    end
    local char = player.Character
    if char then
        for _,v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and v.Name == name then total = total + 1 end
        end
    end
    return total
end

local function vehicleTeleport(cf)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local seat = hum.SeatPart
    if not seat then return end
    local vehicle = seat:FindFirstAncestorOfClass("Model")
    if not vehicle then return end
    if not vehicle.PrimaryPart then vehicle.PrimaryPart = seat end
    vehicle:SetPrimaryPartCFrame(cf)
    task.wait(1)
    pcall(function() seat.Throttle = 1 end)
    task.wait(0.5)
    pcall(function() seat.Throttle = 0 end)
end

-- ========== COLOR PALETTE ==========
local C = {
    bg = Color3.fromRGB(8,7,14), surface = Color3.fromRGB(14,12,24),
    panel = Color3.fromRGB(18,16,30), card = Color3.fromRGB(24,21,40),
    sidebar = Color3.fromRGB(11,9,20), accent = Color3.fromRGB(130,60,240),
    accentDim = Color3.fromRGB(75,35,140), accentGlow = Color3.fromRGB(175,120,255),
    text = Color3.fromRGB(220,215,245), textMid = Color3.fromRGB(145,138,175),
    textDim = Color3.fromRGB(75,68,100), green = Color3.fromRGB(55,200,110),
    red = Color3.fromRGB(220,60,75), border = Color3.fromRGB(38,32,62)
}

-- ========== GUI SETUP ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ELIXIR_3_5"
gui.Parent = playerGui
gui.ResetOnSpawn = false

-- ========== NOTIFICATION ==========
local notifContainer = Instance.new("Frame", gui)
notifContainer.Size = UDim2.new(0, 270, 1, 0)
notifContainer.Position = UDim2.new(1, -280, 0, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 100

local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.Padding = UDim.new(0, 6)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifCount = 0

local function notify(title, msg, ntype)
    notifCount = notifCount + 1
    local color = ntype == "success" and C.green or ntype == "error" and C.red or C.accent
    local card = Instance.new("Frame", notifContainer)
    card.Size = UDim2.new(1, 0, 0, 58)
    card.BackgroundColor3 = C.card
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.ZIndex = 100
    card.LayoutOrder = notifCount
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local t = Instance.new("TextLabel", card)
    t.Position = UDim2.new(0, 14, 0, 7)
    t.Size = UDim2.new(1, -22, 0, 18)
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextColor3 = C.text
    t.TextXAlignment = Enum.TextXAlignment.Left
    local m = Instance.new("TextLabel", card)
    m.Position = UDim2.new(0, 14, 0, 26)
    m.Size = UDim2.new(1, -22, 0, 26)
    m.BackgroundTransparency = 1
    m.Text = msg
    m.Font = Enum.Font.Gotham
    m.TextSize = 11
    m.TextColor3 = C.textMid
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextWrapped = true
    local timerBar = Instance.new("Frame", card)
    timerBar.Position = UDim2.new(0, 3, 1, -2)
    timerBar.Size = UDim2.new(1, -3, 0, 2)
    timerBar.BackgroundColor3 = color
    timerBar.BorderSizePixel = 0
    card.Position = UDim2.new(1, 16, 0, 0)
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(timerBar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0,3,0,2)}):Play()
    task.delay(3.5, function()
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(1,16,0,0)}):Play()
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ========== MAIN WINDOW ==========
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 550)
main.Position = UDim2.new(0.5, -250, 0.5, -275)
main.BackgroundColor3 = C.bg
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- ========== TOP BAR ==========
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 46)
topBar.BackgroundColor3 = C.surface
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Position = UDim2.new(0, 20, 0, 0)
titleLbl.Size = UDim2.new(0, 200, 1, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "ELIXIR 3.5"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 15
titleLbl.TextColor3 = C.text
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(50,15,22)
closeBtn.Text = "x"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = C.red
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ========== SIDEBAR ==========
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 80, 1, -46)
sidebar.Position = UDim2.new(0, 0, 0, 46)
sidebar.BackgroundColor3 = C.sidebar

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 8)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- ========== CONTENT AREA ==========
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -80, 1, -46)
content.Position = UDim2.new(0, 80, 0, 46)
content.BackgroundColor3 = C.panel

-- ========== TAB SYSTEM ==========
local pages = {}
local tabBtns = {}

local tabDefs = {"FARM", "AUTO", "STATUS", "TP"}

for i, name in ipairs(tabDefs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(0, 68, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = C.textDim
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    
    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.Visible = (i == 1)
    page.BorderSizePixel = 0
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    
    pages[name] = page
    tabBtns[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(pages) do
            p.Visible = (n == name)
        end
        for n, b in pairs(tabBtns) do
            b.BackgroundTransparency = (n == name) and 0 or 1
            b.TextColor3 = (n == name) and C.accentGlow or C.textDim
        end
    end)
end

-- ========== UI COMPONENTS ==========
local function card(parent, h)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, h or 46)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", f)
    s.Color = C.border
    s.Thickness = 1
    return f
end

local function makeActionBtn(parent, text, color)
    local f = Instance.new("TextButton", parent)
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = color or C.accentDim
    f.Font = Enum.Font.GothamBold
    f.TextSize = 13
    f.TextColor3 = C.text
    f.Text = text
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    return f
end

local function makeStatusRow(parent, label)
    local f = card(parent, 32)
    local lbl = Instance.new("TextLabel", f)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = C.textMid
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local val = Instance.new("TextLabel", f)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.Size = UDim2.new(0.5, -10, 1, 0)
    val.BackgroundTransparency = 1
    val.Text = "0"
    val.Font = Enum.Font.GothamBold
    val.TextSize = 13
    val.TextColor3 = C.accentGlow
    val.TextXAlignment = Enum.TextXAlignment.Right
    return val
end

local function makeSlider(parent, labelText, minV, maxV, defaultV, callback)
    local wrap = card(parent, 60)
    local lbl = Instance.new("TextLabel", wrap)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    lbl.Size = UDim2.new(1, -80, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextColor3 = C.textMid
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLbl = Instance.new("TextLabel", wrap)
    valLbl.Position = UDim2.new(1, -42, 0, 8)
    valLbl.Size = UDim2.new(0, 32, 0, 18)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultV)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = C.accentGlow
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local track = Instance.new("Frame", wrap)
    track.Position = UDim2.new(0, 12, 0, 38)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.BackgroundColor3 = C.border
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((defaultV - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    -- Simplified: Just show value, no dragging for simplicity
    if callback then callback(defaultV) end
    
    return wrap, valLbl
end

-- ============================================================
-- FARM PAGE
-- ============================================================
local fp = pages["FARM"]

local statusCard = card(fp, 45)
local statusLabel = Instance.new("TextLabel", statusCard)
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 12, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚡ IDLE"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.TextColor3 = C.accentGlow
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local invHeader = card(fp, 30)
local invLabel = Instance.new("TextLabel", invHeader)
invLabel.Size = UDim2.new(1, -20, 1, 0)
invLabel.Position = UDim2.new(0, 12, 0, 0)
invLabel.BackgroundTransparency = 1
invLabel.Text = "📦 INVENTORY"
invLabel.Font = Enum.Font.GothamBold
invLabel.TextSize = 12
invLabel.TextColor3 = C.text
invLabel.TextXAlignment = Enum.TextXAlignment.Left

local waterVal = makeStatusRow(fp, "💧 Water")
local sugarVal = makeStatusRow(fp, "🍬 Sugar")
local gelatinVal = makeStatusRow(fp, "🧴 Gelatin")
local bagVal = makeStatusRow(fp, "👜 Empty Bag")

local ctrlHeader = card(fp, 30)
local ctrlLabel = Instance.new("TextLabel", ctrlHeader)
ctrlLabel.Size = UDim2.new(1, -20, 1, 0)
ctrlLabel.Position = UDim2.new(0, 12, 0, 0)
ctrlLabel.BackgroundTransparency = 1
ctrlLabel.Text = "🎮 CONTROLS"
ctrlLabel.Font = Enum.Font.GothamBold
ctrlLabel.TextSize = 12
ctrlLabel.TextColor3 = C.text
ctrlLabel.TextXAlignment = Enum.TextXAlignment.Left

local buySliderWrap, buyValLbl = makeSlider(fp, "BUY AMOUNT", 1, 25, 1, function(v) buyAmount = v end)
local farmToggleBtn = makeActionBtn(fp, "START FARM", C.accentDim)
local sellToggleBtn = makeActionBtn(fp, "AUTO SELL: OFF", C.card)
local buyNowBtn = makeActionBtn(fp, "BUY NOW", C.card)

-- ============================================================
-- AUTO PAGE
-- ============================================================
local ap = pages["AUTO"]

local autoFarmToggle = makeActionBtn(ap, "AUTO FARM LOOP: OFF", C.card)
local cookSliderWrap, cookValLbl = makeSlider(ap, "COOK AMOUNT", 1, 30, 5, function(v) cookAmount = v end)

-- ============================================================
-- STATUS PAGE
-- ============================================================
local sp = pages["STATUS"]

local playerCard = card(sp, 80)
local avatarImg = Instance.new("ImageLabel", playerCard)
avatarImg.Position = UDim2.new(0, 12, 0.5, -30)
avatarImg.Size = UDim2.new(0, 60, 0, 60)
avatarImg.BackgroundColor3 = C.border
avatarImg.BorderSizePixel = 0
Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 10)

local nameLbl = Instance.new("TextLabel", playerCard)
nameLbl.Position = UDim2.new(0, 85, 0, 12)
nameLbl.Size = UDim2.new(1, -95, 0, 25)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = player.Name
nameLbl.Font = Enum.Font.GothamBlack
nameLbl.TextSize = 18
nameLbl.TextColor3 = C.text
nameLbl.TextXAlignment = Enum.TextXAlignment.Left

local displayLbl = Instance.new("TextLabel", playerCard)
displayLbl.Position = UDim2.new(0, 85, 0, 40)
displayLbl.Size = UDim2.new(1, -95, 0, 20)
displayLbl.BackgroundTransparency = 1
displayLbl.Text = "@" .. player.DisplayName
displayLbl.Font = Enum.Font.Gotham
displayLbl.TextSize = 12
displayLbl.TextColor3 = C.textMid
displayLbl.TextXAlignment = Enum.TextXAlignment.Left

pcall(function()
    local img, _ = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    avatarImg.Image = img
end)

local invHeader2 = card(sp, 30)
local invLabel2 = Instance.new("TextLabel", invHeader2)
invLabel2.Size = UDim2.new(1, -20, 1, 0)
invLabel2.Position = UDim2.new(0, 12, 0, 0)
invLabel2.BackgroundTransparency = 1
invLabel2.Text = "📦 INVENTORY"
invLabel2.Font = Enum.Font.GothamBold
invLabel2.TextSize = 12
invLabel2.TextColor3 = C.text
invLabel2.TextXAlignment = Enum.TextXAlignment.Left

local statWater = makeStatusRow(sp, "💧 Water")
local statSugar = makeStatusRow(sp, "🍬 Sugar")
local statGelatin = makeStatusRow(sp, "🧴 Gelatin")
local statBag = makeStatusRow(sp, "👜 Empty Bag")

-- ============================================================
-- TP PAGE
-- ============================================================
local tp = pages["TP"]

local function tpBtn(label, cf)
    local btn = makeActionBtn(tp, label, C.card)
    btn.MouseButton1Click:Connect(function()
        notify("Teleport", "Menuju " .. label, "info")
        vehicleTeleport(cf)
        notify("Teleport", "Selesai", "success")
    end)
    return btn
end

tpBtn("🏪 NPC Store", npcPos)
tpBtn("🗼 Tier", tierPos)
tpBtn("🏢 Apart 1", apart1)
tpBtn("🏢 Apart 2", apart2)
tpBtn("🏢 Apart 3", apart3)
tpBtn("🏢 Apart 4", apart4)
tpBtn("🏢 Apart 5", apart5)
tpBtn("🏢 Apart 6", apart6)
tpBtn("🔫 CSN 1", csn1)
tpBtn("🔫 CSN 2", csn2)
tpBtn("🔫 CSN 3", csn3)
tpBtn("🔫 CSN 4", csn4)

-- ============================================================
-- FARM LOGIC
-- ============================================================
local function startFarm()
    if running then
        running = false
        farmToggleBtn.Text = "START FARM"
        farmToggleBtn.BackgroundColor3 = C.accentDim
        notify("Farm", "Berhenti", "error")
        return
    end
    running = true
    farmToggleBtn.Text = "STOP FARM"
    farmToggleBtn.BackgroundColor3 = C.red
    notify("Farm", "Memulai...", "info")
    
    task.spawn(function()
        while running do
            statusLabel.Text = "🛒 MEMBELI"
            statusLabel.TextColor3 = C.accentGlow
            
            if buyRemote then
                for i = 1, buyAmount do
                    if not running then break end
                    pcall(function() buyRemote:FireServer("Water") end)
                    task.wait(0.15)
                    pcall(function() buyRemote:FireServer("Sugar") end)
                    task.wait(0.15)
                    pcall(function() buyRemote:FireServer("Gelatin") end)
                    task.wait(0.15)
                    pcall(function() buyRemote:FireServer("Empty Bag") end)
                    task.wait(0.15)
                end
            end
            
            statusLabel.Text = "✅ SELESAI"
            statusLabel.TextColor3 = C.green
            task.wait(3)
        end
    end)
end

farmToggleBtn.MouseButton1Click:Connect(startFarm)

buyNowBtn.MouseButton1Click:Connect(function()
    if buyRemote then
        for i = 1, buyAmount do
            pcall(function() buyRemote:FireServer("Water") end)
            task.wait(0.1)
            pcall(function() buyRemote:FireServer("Sugar") end)
            task.wait(0.1)
            pcall(function() buyRemote:FireServer("Gelatin") end)
            task.wait(0.1)
            pcall(function() buyRemote:FireServer("Empty Bag") end)
            task.wait(0.1)
        end
        notify("Buy", "Berhasil membeli " .. buyAmount .. "x", "success")
    else
        notify("Error", "Remote tidak ditemukan!", "error")
    end
end)

sellToggleBtn.MouseButton1Click:Connect(function()
    autoSellEnabled = not autoSellEnabled
    if autoSellEnabled then
        sellToggleBtn.Text = "AUTO SELL: ON"
        sellToggleBtn.BackgroundColor3 = C.accentDim
        noti
