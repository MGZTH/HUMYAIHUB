-- FINAL FAST (No Delay / Instant Move)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
_G.Run = true

-- 🔥 Remote
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SpawnRimuru = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local SpawnStrongest = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local SpawnBoss = Remotes:WaitForChild("RequestSummonBoss")

local TeleportRemote = Remotes:WaitForChild("TeleportToPortal")
local CombatRemote = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
local HakiRemote = RemoteEvents:WaitForChild("HakiRemote")

-- =========================
-- 💤 Anti AFK
-- =========================
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- =========================
-- 🛡️ Auto Buso
-- =========================
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            HakiRemote:FireServer("Toggle")
        end)
    end
end)

-- =========================
-- ⚔️ Equip
-- =========================
local function equip()
    local char = player.Character
    if not char then return end

    local tool = player.Backpack:FindFirstChild("Strongest In History")
    if tool and not char:FindFirstChild("Strongest In History") then
        tool.Parent = char
    end
end

-- =========================
-- ⚡ Tween (เร็วขึ้น)
-- =========================
local function tweenTo(cf)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / 110 -- 🔥 เร็วขึ้น

    local t = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = cf})
    t:Play()
end

local function tweenToBoss(boss)
    local root = boss:FindFirstChild("HumanoidRootPart")
    if root then
        tweenTo(root.CFrame * CFrame.new(0,0,8))
    end
end

-- =========================
-- 🔍 หา boss
-- =========================
local function findBoss(name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                return v
            end
        end
    end
end

-- =========================
-- ⚔️ Kill (เริ่มทันที)
-- =========================
local function kill(name)
    local boss

    -- 🔥 หาแบบเร็ว
    for i = 1, 40 do
        boss = findBoss(name)
        if boss then break end
        task.wait(0.2)
    end

    if not boss then return end

    local root = boss:FindFirstChild("HumanoidRootPart")
    local hum = boss:FindFirstChild("Humanoid")
    if not root or not hum then return end

    -- 🔥 Tween เฉพาะตัวหลัก
    if name == "RimuruBoss_Normal"
    or name == "StrongestofTodayBoss_Normal"
    or name == "StrongestinHistoryBoss_Normal" then
        tweenToBoss(boss)
    end

    -- 🔥 เข้าโจมตีทันที
    while hum.Health > 0 and _G.Run do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0,0,8)
        end

        equip()
        CombatRemote:FireServer(root.Position)

        task.wait(0.1) -- 🔥 เร็วขึ้น
    end
end

-- =========================
-- 🌍 วาป (ไวขึ้น)
-- =========================
local function go(name)
    TeleportRemote:FireServer(name)
    task.wait(1.2) -- 🔥 ลดดีเลย์
end

-- =========================
-- 📍 NPC
-- =========================
local NPC = CFrame.new(
    392.87, -2.22, -2177.80,
    -0.91, 0, -0.40,
    0, 1, 0,
    0.40, 0, -0.91
)

-- =========================
-- 🔁 LOOP
-- =========================
while _G.Run do

    -- 🟢 Rimuru
    go("Slime")
    SpawnRimuru:FireServer("Normal")
    kill("RimuruBoss_Normal")

    -- 🔴 Ichigo + Gilgamesh
    go("Boss")

    SpawnBoss:FireServer("IchigoBoss")
    kill("IchigoBoss")

    SpawnBoss:FireServer("GilgameshBoss","Normal")
    kill("GilgameshBoss")

    -- 🟣 Strongest
    go("Shinjuku")

    tweenTo(NPC) -- 🔥 วิ่งทันที ไม่ wait
    task.wait(0.3)

    SpawnStrongest:FireServer("StrongestToday","Normal")
    kill("StrongestofTodayBoss_Normal")

    SpawnStrongest:FireServer("StrongestHistory","Normal")
    kill("StrongestinHistoryBoss_Normal")

end
