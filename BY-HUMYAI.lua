task.wait(10)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- CONFIG
_G.Run = true
_G.AutoEquip = true
_G.SmartHit = true

-- Remote
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SpawnRimuru = RemoteEvents:WaitForChild("RequestSpawnRimuru")
local SpawnStrongest = Remotes:WaitForChild("RequestSpawnStrongestBoss")
local SpawnBoss = Remotes:WaitForChild("RequestSummonBoss")

local TeleportRemote = Remotes:WaitForChild("TeleportToPortal")
local CombatRemote = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
local HakiRemote = RemoteEvents:WaitForChild("HakiRemote")

-- Anti AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(60)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- 🛡️ Auto Buso (ครั้งเดียว)
pcall(function()
    HakiRemote:FireServer("Toggle")
end)

-- ⚔️ Auto Equip (Blessed Maiden)
local function equip()
    if not _G.AutoEquip then return end
    local char = player.Character
    if not char then return end

    local tool = player.Backpack:FindFirstChild("Blessed Maiden")
    if tool and not char:FindFirstChild("Blessed Maiden") then
        tool.Parent = char
    end
end

-- 🧠 หา boss ใกล้
local function getBossNear()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Humanoid.Health > 0 then
                if (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 60 then
                    return v
                end
            end
        end
    end
end

-- ⚡ Smart Hit
task.spawn(function()
    while task.wait(math.random(12,18)/100) do
        if not _G.SmartHit then continue end

        local boss = getBossNear()
        if boss then
            local root = boss:FindFirstChild("HumanoidRootPart")
            local hum = boss:FindFirstChild("Humanoid")

            if root and hum then
                equip()

                if hum.Health < hum.MaxHealth * 0.8 then
                    for i = 1, 2 do
                        CombatRemote:FireServer(root.Position)
                        task.wait(0.05)
                    end
                else
                    CombatRemote:FireServer(root.Position)
                end
            end
        end
    end
end)

-- หา boss ตามชื่อ
local function findBoss(name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                return v
            end
        end
    end
end

-- ⚡ Tween (สปีด 140)
local function tween(cf)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / 140

    local t = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = cf})
    t:Play()
    t.Completed:Wait()
end

-- ⏳ Wait Boss
local function waitBoss(name)
    local t = 0
    repeat
        task.wait(0.5)
        t += 0.5
    until findBoss(name) or t > 12
end

-- ⚔️ Kill (Tween)
local function killTween(name)
    local boss = findBoss(name)
    if not boss then return end

    local root = boss:FindFirstChild("HumanoidRootPart")
    if not root then return end

    repeat
        tween(root.CFrame * CFrame.new(0,0,10))
        equip()
        task.wait(0.2)
    until not _G.Run or boss.Humanoid.Health <= 0
end

-- 🌍 วาป
local function go(name)
    pcall(function()
        TeleportRemote:FireServer(name)
    end)
    task.wait(1.7)
end

-- 📍 NPC
local NPC = CFrame.new(
    392.87, -2.22, -2177.80,
    -0.91, 0, -0.40,
    0, 1, 0,
    0.40, 0, -0.91
)

-- 🔁 LOOP
task.spawn(function()
    while task.wait(0.5) do
        if not _G.Run then break end

        -- Rimuru
        go("Slime")
        SpawnRimuru:FireServer("Normal")
        waitBoss("RimuruBoss_Normal")
        killTween("RimuruBoss_Normal")

        -- Ichigo + Gilgamesh
        go("Boss")

        SpawnBoss:FireServer("IchigoBoss")
        waitBoss("IchigoBoss")
        killTween("IchigoBoss")

        SpawnBoss:FireServer("GilgameshBoss","Normal")
        waitBoss("GilgameshBoss")
        killTween("GilgameshBoss")

        -- Strongest
        go("Shinjuku")
        tween(NPC)

        SpawnStrongest:FireServer("StrongestToday","Normal")
        waitBoss("StrongestofTodayBoss_Normal")
        killTween("StrongestofTodayBoss_Normal")

        SpawnStrongest:FireServer("StrongestHistory","Normal")
        waitBoss("StrongestinHistoryBoss_Normal")
        killTween("StrongestinHistoryBoss_Normal")
    end
end)
