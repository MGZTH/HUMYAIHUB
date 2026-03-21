repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- 📡 Remote
local abilityRemote = ReplicatedStorage:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")
local spawnBossRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestAutoSpawn")
local portalRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal")

-- ⚙️ ตั้งค่า
local WEAPON_NAME = "Strongest In History"
local HEIGHT = 15

-- 📍 จุด
local POSITIONS = {
    {portal = "Slime", pos = CFrame.new(-1124.75, 19.70, 371.23)},
    {portal = "Academy", pos = CFrame.new(1072.38, 1.76, 1275.86)},
    {portal = "Boss", pos = CFrame.new(776.71, -0.39, -1091.70)},
    {portal = "Shinjuku", pos = CFrame.new(666.20, 1.85, -1695.58)},
    {portal = "Shinjuku", pos = CFrame.new(-18.39, 2.46, -1845.56)}
}

--------------------------------------------------
-- 🥊 Equip
local function EquipWeapon()
    local char = player.Character or player.CharacterAdded:Wait()
    local tool = player.Backpack:FindFirstChild(WEAPON_NAME)

    if tool and not char:FindFirstChild(WEAPON_NAME) then
        tool.Parent = char
    end
end

--------------------------------------------------
-- 🌀 Portal
local function UsePortal(name)
    pcall(function()
        portalRemote:FireServer(name)
    end)
end

--------------------------------------------------
-- 🔒 วาปนิ่ง
local function TP(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    hrp.Anchored = true
    hrp.CFrame = cf + Vector3.new(0, HEIGHT, 0)

    task.wait(0.2)

    hrp.Anchored = false
end

--------------------------------------------------
-- 🛡️ กันเด้ง
local function Stabilize()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end
end

--------------------------------------------------
-- ⚔️ Skill
local function UseSkill()
    pcall(function()
        abilityRemote:FireServer(2)
    end)
end

--------------------------------------------------
-- 🔁 สถานะ
local running = true
local paused = false
local bossSpawned = false

--------------------------------------------------
-- 🔁 Loop ฟาร์ม
task.spawn(function()
    while true do
        if running and not paused then
            EquipWeapon()
            Stabilize()

            if not bossSpawned then
                pcall(function()
                    spawnBossRemote:FireServer("SaberBoss")
                end)
                bossSpawned = true
            end

            for _, data in ipairs(POSITIONS) do
                if not running then break end
                while paused do task.wait() end

                EquipWeapon()

                UsePortal(data.portal)
                task.wait(0.3)

                TP(data.pos)
                task.wait(0.5)

                UseSkill()

                task.wait(0.3)
            end
        else
            task.wait(0.1)
        end
    end
end)

--------------------------------------------------
-- 🔥 AUTO HAKI (เพิ่มกลับแล้ว)
_G.AutoBuso = true
_G.AutoObservation = true
_G.AutoConqueror = true

-- ✅ เช็ค Buso
local function IsBusoActive()
    local char = player.Character
    if not char then return false end

    local parts = {
        char:FindFirstChild("Right Arm"),
        char:FindFirstChild("Left Arm"),
    }

    for _, part in ipairs(parts) do
        if part and part:IsA("Part") then
            local c = part.Color
            if c.R == 0 and c.G == 0 and c.B == 0 then
                return true
            end
        end
    end

    return false
end

-- 🔥 Buso
task.spawn(function()
    while task.wait(0.5) do
        if running and _G.AutoBuso then
            if not IsBusoActive() then
                ReplicatedStorage.RemoteEvents.HakiRemote:FireServer("Toggle")
            end
        end
    end
end)

-- 👁️ Observation
task.spawn(function()
    while task.wait(0.5) do
        if running and _G.AutoObservation then
            local gui = player:FindFirstChild("PlayerGui")
            if gui and gui:FindFirstChild("DodgeCounterUI") then
                if not gui.DodgeCounterUI.MainFrame.Visible then
                    ReplicatedStorage.RemoteEvents.ObservationHakiRemote:FireServer("Toggle")
                end
            end
        end
    end
end)

-- ⚡ Conqueror
task.spawn(function()
    while task.wait(1) do
        if running and _G.AutoConqueror then
            ReplicatedStorage.RemoteEvents.ConquerorHakiRemote:FireServer()
        end
    end
end)

--------------------------------------------------
-- 🛡️ กัน AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--------------------------------------------------
-- 🎮 UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- ⏸️ Pause
local PauseBtn = Instance.new("TextButton", ScreenGui)
PauseBtn.Size = UDim2.new(0, 200, 0, 50)
PauseBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
PauseBtn.Text = "PAUSE ⏸️"
PauseBtn.BackgroundColor3 = Color3.fromRGB(80,80,0)
PauseBtn.TextColor3 = Color3.new(1,1,1)
PauseBtn.TextScaled = true

PauseBtn.MouseButton1Click:Connect(function()
    paused = not paused
    PauseBtn.Text = paused and "RESUME ▶️" or "PAUSE ⏸️"
end)

-- 🛑 Stop
local StopBtn = Instance.new("TextButton", ScreenGui)
StopBtn.Size = UDim2.new(0, 200, 0, 50)
StopBtn.Position = UDim2.new(0.02, 0, 0.42, 0)
StopBtn.Text = "STOP 🛑"
StopBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
StopBtn.TextColor3 = Color3.new(1,1,1)
StopBtn.TextScaled = true

StopBtn.MouseButton1Click:Connect(function()
    running = false
    StopBtn.Text = "STOPPED ❌"
end)
