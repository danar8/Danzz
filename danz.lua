-- ELIXIR 3.5 -- REDESIGNED: DEEP PURPLE THEME + TEXT SIDEBAR
local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")
local ContextActionService = game:GetService("ContextActionService")
local VirtualUser = game:GetService("VirtualUser")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

repeat task.wait() until player.Character

local playerGui = player:WaitForChild("PlayerGui")

local running = false
local autoSellEnabled = false
local buyAmount = 1

local autoFarmRunning = false
local autoFarmStopping = false
local cookAmount = 5

local buyRemote = game:GetService("ReplicatedStorage").RemoteEvents.StorePurchase

local npcPos = CFrame.new(510.762817,3.58721066,600.791504)
local tierPos = CFrame.new(1110.18726,4.28433371,117.139168)

-- ============================================================
-- ANTI AFK
-- ============================================================
player.Idled:Connect(function()
   VirtualUser:CaptureController()
   VirtualUser:ClickButton2(Vector2.new())
end)

-- ============================================================
-- HELPERS
-- ============================================================
local function holdE(t)
   vim:SendKeyEvent(true,"E",false,game)
   task.wait(t)
   vim:SendKeyEvent(false,"E",false,game)
end

local function equip(name)
   local char = player.Character
   local tool = player.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
   if tool then
      char.Humanoid:EquipTool(tool)
      task.wait(.3)
      return true
   end
end

local function countItem(name)
   local total = 0
   for _,v in pairs(player.Backpack:GetChildren()) do
      if v.Name == name then total += 1 end
   end
   for _,v in pairs(player.Character:GetChildren()) do
      if v:IsA("Tool") and v.Name == name then total += 1 end
   end
   return total
end

local function vehicleTeleport(cf)
   local char = player.Character
   if not char then return end
   local humanoid = char:FindFirstChild("Humanoid")
   if not humanoid then return end
   local seat = humanoid.SeatPart
   if not seat then return end
   local vehicle = seat:FindFirstAncestorOfClass("Model")
   if not vehicle then return end
   if not vehicle.PrimaryPart then vehicle.PrimaryPart = seat end
   vehicle:SetPrimaryPartCFrame(cf)
   task.wait(1)
   seat.Throttle = 1
   task.wait(0.5)
   seat.Throttle = 0
end

local function fill(bar, time)
   bar.Size = UDim2.new(0,0,1,0)
   bar:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, time, true)
   task.delay(time, function() bar.Size = UDim2.new(0,0,1,0) end)
end

-- ============================================================
-- GUI SETUP
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ELIXIR_3_5"
gui.Parent = playerGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================================
-- COLOR PALETTE (redesigned - deep purple, not AI-looking)
-- ============================================================
local C = {
   bg        = Color3.fromRGB(8,  7,  14),
   surface   = Color3.fromRGB(14, 12, 24),
   panel     = Color3.fromRGB(18, 16, 30),
   card      = Color3.fromRGB(24, 21, 40),
   sidebar   = Color3.fromRGB(11,  9, 20),
   accent    = Color3.fromRGB(130, 60, 240),
   accentDim = Color3.fromRGB(75,  35, 140),
   accentGlow= Color3.fromRGB(175, 120, 255),
   accentSoft= Color3.fromRGB(100, 55, 190),
   text      = Color3.fromRGB(220, 215, 245),
   textMid   = Color3.fromRGB(145, 138, 175),
   textDim   = Color3.fromRGB(75,  68, 100),
   green     = Color3.fromRGB(55,  200, 110),
   red       = Color3.fromRGB(220, 60,  75),
   border    = Color3.fromRGB(38,  32,  62),
   borderAct = Color3.fromRGB(100, 55, 190),
}

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local notifContainer = Instance.new("Frame", gui)
notifContainer.Size = UDim2.new(0, 270, 1, 0)
notifContainer.Position = UDim2.new(1, -280, 0, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 100

local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.Padding = UDim.new(0, 6)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifPadding = Instance.new("UIPadding", notifContainer)
notifPadding.PaddingBottom = UDim.new(0, 14)
notifPadding.PaddingRight = UDim.new(0, 8)

local notifCount = 0

local function notify(title, msg, ntype)
   notifCount += 1
   local color = ntype == "success" and C.green or ntype == "error" and C.red or C.accent

   local card = Instance.new("Frame", notifContainer)
   card.Size = UDim2.new(1, 0, 0, 58)
   card.BackgroundColor3 = C.card
   card.BorderSizePixel = 0
   card.ClipsDescendants = true
   card.ZIndex = 100
   card.LayoutOrder = notifCount

   Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

   local stroke = Instance.new("UIStroke", card)
   stroke.Color = color
   stroke.Thickness = 1
   stroke.Transparency = 0.5

   local bar_left = Instance.new("Frame", card)
   bar_left.Size = UDim2.new(0, 3, 1, 0)
   bar_left.BackgroundColor3 = color
   bar_left.BorderSizePixel = 0
   bar_left.ZIndex = 101

   local t = Instance.new("TextLabel", card)
   t.Position = UDim2.new(0, 14, 0, 7)
   t.Size = UDim2.new(1, -22, 0, 18)
   t.BackgroundTransparency = 1
   t.Text = title
   t.Font = Enum.Font.GothamBold
   t.TextSize = 13
   t.TextColor3 = C.text
   t.TextXAlignment = Enum.TextXAlignment.Left
   t.ZIndex = 101

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
   m.ZIndex = 101

   local timerBar = Instance.new("Frame", card)
   timerBar.Position = UDim2.new(0, 3, 1, -2)
   timerBar.Size = UDim2.new(1, -3, 0, 2)
   timerBar.BackgroundColor3 = color
   timerBar.BorderSizePixel = 0
   timerBar.ZIndex = 101

   card.Position = UDim2.new(1, 16, 0, 0)
   TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()
   TweenService:Create(timerBar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Size = UDim2.new(0,3,0,2)}):Play()

   task.delay(3.5, function()
      TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(1,16,0,0)}):Play()
      task.wait(0.3)
      card:Destroy()
   end)
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 660, 0, 430)
main.Position = UDim2.new(0.5, -330, 0.5, -215)
main.BackgroundColor3 = C.bg
main.Active = true
main.Draggable = true
main.ClipsDescendants = false

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = C.border
mainStroke.Thickness = 1

-- subtle inner glow top
local topGlow = Instance.new("Frame", main)
topGlow.Size = UDim2.new(1, 0, 0, 1)
topGlow.BackgroundColor3 = C.accentSoft
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 5
topGlow.BackgroundTransparency = 0.3

-- ============================================================
-- TOP BAR
-- ============================================================
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 46)
topBar.BackgroundColor3 = C.surface
topBar.ZIndex = 2

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topBarFix = Instance.new("Frame", topBar)
topBarFix.Size = UDim2.new(1, 0, 0, 12)
topBarFix.Position = UDim2.new(0, 0, 1, -12)
topBarFix.BackgroundColor3 = C.surface
topBarFix.BorderSizePixel = 0

-- accent line under topbar
local topAccentLine = Instance.new("Frame", topBar)
topAccentLine.Size = UDim2.new(1, 0, 0, 1)
topAccentLine.Position = UDim2.new(0, 0, 1, -1)
topAccentLine.BackgroundColor3 = C.border
topAccentLine.BorderSizePixel = 0

-- small accent square
local accentSquare = Instance.new("Frame", topBar)
accentSquare.Size = UDim2.new(0, 4, 0, 20)
accentSquare.Position = UDim2.new(0, 16, 0.5, -10)
accentSquare.BackgroundColor3 = C.accent
accentSquare.BorderSizePixel = 0
Instance.new("UICorner", accentSquare).CornerRadius = UDim.new(0, 2)

local titleLbl = Instance.new("TextLabel", topBar)
titleLbl.Position = UDim2.new(0, 28, 0, 0)
titleLbl.Size = UDim2.new(0, 160, 1, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "ELIXIR 3.5"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 15
titleLbl.TextColor3 = C.text
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- version badge
local badge = Instance.new("Frame", topBar)
badge.Size = UDim2.new(0, 38, 0, 18)
badge.Position = UDim2.new(0, 190, 0.5, -9)
badge.BackgroundColor3 = C.accentDim
badge.BorderSizePixel = 0
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)

local badgeTxt = Instance.new("TextLabel", badge)
badgeTxt.Size = UDim2.new(1,0,1,0)
badgeTxt.BackgroundTransparency = 1
badgeTxt.Text = "v3.5"
badgeTxt.Font = Enum.Font.GothamBold
badgeTxt.TextSize = 10
badgeTxt.TextColor3 = C.accentGlow

-- close button
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 15, 22)
closeBtn.Text = "x"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = C.red
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
   running = false
   autoSellEnabled = false
   notify("Elixir", "Script dihentikan.", "error")
   task.wait(0.4)
   gui:Destroy()
end)

-- minimize button
local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -72, 0.5, -14)
minBtn.BackgroundColor3 = C.card
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = C.textMid
minBtn.BorderSizePixel = 0
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- ============================================================
-- TEXT SIDEBAR
-- ============================================================
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 80, 1, -46)
sidebar.Position = UDim2.new(0, 0, 0, 46)
sidebar.BackgroundColor3 = C.sidebar
sidebar.ZIndex = 2
sidebar.ClipsDescendants = false

-- right border line (parented to main so it doesn't join the layout)
local sidebarLine = Instance.new("Frame", main)
sidebarLine.Size = UDim2.new(0, 1, 1, -46)
sidebarLine.Position = UDim2.new(0, 79, 0, 46)
sidebarLine.BackgroundColor3 = C.border
sidebarLine.BorderSizePixel = 0
sidebarLine.ZIndex = 3

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 10)

-- ============================================================
-- CONTENT AREA
-- ============================================================
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -80, 1, -46)
content.Position = UDim2.new(0, 80, 0, 46)
content.BackgroundColor3 = C.panel
content.ClipsDescendants = true
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 0)

local contentFix = Instance.new("Frame", content)
contentFix.Size = UDim2.new(0, 12, 1, 0)
contentFix.BackgroundColor3 = C.panel
contentFix.BorderSizePixel = 0

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local pages = {}
local tabBtns = {}
local currentTab = nil

local tabDefs = {
   {label = "FARM",    order = 1},
   {label = "AUTO",    order = 2},
   {label = "STATUS",  order = 3},
   {label = "TP",      order = 4},
   {label = "ESP",     order = 5},
   {label = "RESPAWN", order = 6},
}

local function switchTab(name)
   for n, p in pairs(pages) do
      p.Visible = (n == name)
   end
   for n, b in pairs(tabBtns) do
      if n == name then
         b.BackgroundColor3 = C.accentDim
         b.BackgroundTransparency = 0
         b.TextColor3 = C.accentGlow
      else
         b.BackgroundTransparency = 1
         b.TextColor3 = C.textDim
      end
   end
   currentTab = name
end

for i, def in ipairs(tabDefs) do
   local btn = Instance.new("TextButton", sidebar)
   btn.Size = UDim2.new(0, 68, 0, 36)
   btn.BackgroundTransparency = 1
   btn.Text = def.label
   btn.Font = Enum.Font.GothamBold
   btn.TextSize = 11
   btn.TextColor3 = C.textDim
   btn.BorderSizePixel = 0
   btn.LayoutOrder = def.order
   Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

   -- active indicator line on left
   local indicator = Instance.new("Frame", btn)
   indicator.Size = UDim2.new(0, 2, 0, 18)
   indicator.Position = UDim2.new(0, 0, 0.5, -9)
   indicator.BackgroundColor3 = C.accent
   indicator.BorderSizePixel = 0
   indicator.Visible = false
   Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)

   local page = Instance.new("ScrollingFrame", content)
   page.Size = UDim2.new(1, 0, 1, 0)
   page.BackgroundTransparency = 1
   page.ScrollBarThickness = 3
   page.ScrollBarImageColor3 = C.accentSoft
   page.Visible = false
   page.BorderSizePixel = 0

   local layout = Instance.new("UIListLayout", page)
   layout.Padding = UDim.new(0, 7)
   layout.SortOrder = Enum.SortOrder.LayoutOrder

   local pad = Instance.new("UIPadding", page)
   pad.PaddingTop = UDim.new(0, 14)
   pad.PaddingLeft = UDim.new(0, 12)
   pad.PaddingRight = UDim.new(0, 12)
   pad.PaddingBottom = UDim.new(0, 14)

   pages[def.label] = page
   tabBtns[def.label] = btn

   btn.MouseButton1Click:Connect(function()
      switchTab(def.label)
      -- toggle indicators
      for _, b2 in pairs(tabBtns) do
         local ind = b2:FindFirstChild("Frame")
         if ind then
            ind.Visible = (b2 == btn)
         end
      end
   end)
end

-- ============================================================
-- UI COMPONENT BUILDERS
-- ============================================================
local function sectionLabel(parent, text, order)
   local wrap = Instance.new("Frame", parent)
   wrap.Size = UDim2.new(1, 0, 0, 22)
   wrap.BackgroundTransparency = 1
   wrap.LayoutOrder = order or 0

   local lbl = Instance.new("TextLabel", wrap)
   lbl.Size = UDim2.new(1, 0, 1, 0)
   lbl.BackgroundTransparency = 1
   lbl.Text = text:upper()
   lbl.Font = Enum.Font.GothamBold
   lbl.TextSize = 9
   lbl.TextColor3 = C.textDim
   lbl.TextXAlignment = Enum.TextXAlignment.Left
   lbl.LayoutOrder = order or 0

   local line = Instance.new("Frame", wrap)
   line.Size = UDim2.new(1, 0, 0, 1)
   line.Position = UDim2.new(0, 0, 1, -1)
   line.BackgroundColor3 = C.border
   line.BorderSizePixel = 0

   return wrap
end

local function card(parent, h, order)
   local f = Instance.new("Frame", parent)
   f.Size = UDim2.new(1, 0, 0, h or 46)
   f.BackgroundColor3 = C.card
   f.BorderSizePixel = 0
   f.LayoutOrder = order or 0
   Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
   local s = Instance.new("UIStroke", f)
   s.Color = C.border
   s.Thickness = 1
   return f
end

local function makeToggleBtn(parent, text, order)
   local f = card(parent, 38, order)
   local btn = Instance.new("TextButton", f)
   btn.Size = UDim2.new(1, 0, 1, 0)
   btn.BackgroundTransparency = 1
   btn.Font = Enum.Font.GothamSemibold
   btn.TextSize = 12
   btn.TextColor3 = C.text
   btn.Text = text
   btn.BorderSizePixel = 0

   local pill = Instance.new("Frame", f)
   pill.Size = UDim2.new(0, 28, 0, 14)
   pill.Position = UDim2.new(1, -40, 0.5, -7)
   pill.BackgroundColor3 = C.textDim
   pill.BorderSizePixel = 0
   Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

   local knob = Instance.new("Frame", pill)
   knob.Size = UDim2.new(0, 10, 0, 10)
   knob.Position = UDim2.new(0, 2, 0.5, -5)
   knob.BackgroundColor3 = Color3.new(1,1,1)
   knob.BorderSizePixel = 0
   Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

   local state = false
   local function setToggle(on)
      state = on
      if on then
         TweenService:Create(pill, TweenInfo.new(0.18), {BackgroundColor3 = C.accent}):Play()
         TweenService:Create(knob, TweenInfo.new(0.18), {Position = UDim2.new(1, -12, 0.5, -5)}):Play()
         btn.TextColor3 = C.accentGlow
      else
         TweenService:Create(pill, TweenInfo.new(0.18), {BackgroundColor3 = C.textDim}):Play()
         TweenService:Create(knob, TweenInfo.new(0.18), {Position = UDim2.new(0, 2, 0.5, -5)}):Play()
         btn.TextColor3 = C.text
      end
   end

   btn.MouseButton1Click:Connect(function()
      setToggle(not state)
   end)

   return btn, f, setToggle
end

local function makeActionBtn(parent, text, color, order)
   local f = Instance.new("TextButton", parent)
   f.Size = UDim2.new(1, 0, 0, 36)
   f.BackgroundColor3 = color or C.accentDim
   f.Font = Enum.Font.GothamBold
   f.TextSize = 12
   f.TextColor3 = C.text
   f.Text = text
   f.BorderSizePixel = 0
   f.LayoutOrder = order or 0
   Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
   local s = Instance.new("UIStroke", f)
   s.Color = C.border
   s.Thickness = 1
   f.MouseEnter:Connect(function()
      TweenService:Create(f, TweenInfo.new(0.12), {BackgroundColor3 = C.accent}):Play()
   end)
   f.MouseLeave:Connect(function()
      TweenService:Create(f, TweenInfo.new(0.12), {BackgroundColor3 = color or C.accentDim}):Play()
   end)
   return f
end

-- ============================================================
-- FARM PAGE
-- ============================================================
local fp = pages["FARM"]

sectionLabel(fp, "Status", 1)

local statusCard = card(fp, 36, 2)
local statusLabel = Instance.new("TextLabel", statusCard)
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 12, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "IDLE"
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.TextColor3 = C.textMid
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

sectionLabel(fp, "Inventory", 3)

local waterVal, _ = makeStatusRow(fp, "Water", 4)
local sugarVal, _ = makeStatusRow(fp, "Sugar Block Bag", 5)
local gelatinVal,_ = makeStatusRow(fp, "Gelatin", 6)
local bagVal, _ = makeStatusRow(fp, "Empty Bag", 7)

sectionLabel(fp, "Controls", 8)

local buySliderWrap, buyValLbl = makeSlider(fp, "BUY AMOUNT", 1, 25, 1, 9, function(v)
   buyAmount = v
end)

local farmToggleBtn = makeActionBtn(fp, "START FARM", C.accentDim, 10)
local sellToggleBtn = makeActionBtn(fp, "AUTO SELL : OFF", C.card, 11)
local buyNowBtn = makeActionBtn(fp, "BUY NOW", C.card, 12)

sectionLabel(fp, "Cook Progress", 13)

local function makeProgressCard(label, order)
   local f = card(fp, 34, order)
   local lbl3 = Instance.new("TextLabel", f)
   lbl3.Position = UDim2.new(0, 10, 0, 5)
   lbl3.Size = UDim2.new(0.6, 0, 0, 13)
   lbl3.BackgroundTransparency = 1
   lbl3.Text = label
   lbl3.Font = Enum.Font.GothamSemibold
   lbl3.TextSize = 10
   lbl3.TextColor3 = C.textMid
   lbl3.TextXAlignment = Enum.TextXAlignment.Left

   local bg2 = Instance.new("Frame", f)
   bg2.Position = UDim2.new(0, 10, 0, 22)
   bg2.Size = UDim2.new(1, -20, 0, 5)
   bg2.BackgroundColor3 
