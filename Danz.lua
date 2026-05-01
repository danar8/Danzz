-- TELEPORT SCRIPT - FIXED (TIDAK JATUH KE TANAH)
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 350)
frame.Position = UDim2.new(0.5, -125, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(130, 60, 240)
title.Text = "📍 SOUTH BRONX TP"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local close = Instance.new("TextButton", title)
close.Size = UDim2.new(0, 30, 1, 0)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.Size = UDim2.new(1, -20, 1, -55)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- TELEPORT FUNCTION dengan auto-raise (naik 8 unit)
local function teleportTo(pos)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Naikkan 8 unit agar tidak jatuh ke tanah
        local newPos = CFrame.new(pos.X, pos.Y + 8, pos.Z)
        hrp.CFrame = newPos
    end
end

-- DAFTAR LOKASI (Y sudah disesuaikan)
local tps = {
    {"🏪 NPC Store", CFrame.new(510.762817, 11.587, 600.791504)},
    {"🗼 Tier", CFrame.new(1110.18726, 12.284, 117.139168)},
    {"🏢 Apart 1", CFrame.new(1140.319, 18.105, 450.252)},
    {"🏢 Apart 2", CFrame.new(1141.391, 18.105, 422.805)},
    {"🏢 Apart 3", CFrame.new(986.987, 18.105, 248.435)},
    {"🏢 Apart 4", CFrame.new(986.299, 18.105, 219.940)},
    {"🏢 Apart 5", CFrame.new(924.781, 18.105, 41.136)},
    {"🏢 Apart 6", CFrame.new(896.672, 18.105, 40.640)},
    {"🔫 CSN 1", CFrame.new(1178.833, 11.95, -227.372)},
    {"🔫 CSN 2", CFrame.new(1205.088, 11.95, -220.542)},
    {"🔫 CSN 3", CFrame.new(1204.281, 11.712, -182.851)},
    {"🔫 CSN 4", CFrame.new(1178.585, 11.712, -189.710)},
}

for _, tp in pairs(tps) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = tp[1]
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(220, 215, 245)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        teleportTo(tp[2])
        local notif = Instance.new("TextLabel", gui)
        notif.Text = "✅ Teleport ke " .. tp[1]
        notif.Size = UDim2.new(0, 200, 0, 30)
        notif.Position = UDim2.new(0.5, -100, 1, -40)
        notif.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        notif.TextColor3 = Color3.fromRGB(130, 230, 130)
        notif.Font = Enum.Font.GothamBold
        notif.TextSize = 12
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
        task.wait(2)
        notif:Destroy()
    end)
end
