-- Dino Auto System v2 (Full UI, Dark-Green theme)
-- ฟังก์ชันครบตามเดิม แต่ตัดการรีเซิร์ฟ (Teleport) ออก
-- ใส่ใน LocalScript (executor หรือ StarterGui / CoreGui)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Safety: ถ้ามี GUI เดิมชื่อเดียวกัน ให้ลบทิ้งก่อน
local EXIST = CoreGui:FindFirstChild("DinoAutoSystem_v2")
if EXIST then EXIST:Destroy() end

-- ======= Create GUI =======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DinoAutoSystem_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.AnchorPoint = Vector2.new(0,0)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Title.BorderSizePixel = 0
Title.Text = "🐾 Dino Auto System v2"
Title.TextColor3 = Color3.fromRGB(220, 255, 220)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- Close button
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(240,240,240)
CloseBtn.BackgroundColor3 = Color3.fromRGB(65, 12, 12)
CloseBtn.BorderSizePixel = 0

-- Tabs container
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 40, 0, 40)
TabsFrame.BackgroundTransparency = 1

-- Tab buttons
local function makeTabButton(name, posX)
	local b = Instance.new("TextButton", TabsFrame)
	b.Size = UDim2.new(0, 120, 1, -6)
	b.Position = UDim2.new(0, posX, 0, 4)
	b.Text = name
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.TextColor3 = Color3.fromRGB(200,255,200)
	b.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
	b.BorderSizePixel = 0
	return b
end

local TabMainBtn = makeTabButton("Main", 0.02)
local TabGiftBtn = makeTabButton("Gift", 0.30)
local TabSettingsBtn = makeTabButton("Settings", 0.58)

-- Content frames (one per tab)
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -120)
ContentArea.Position = UDim2.new(0, 10, 0, 90)
ContentArea.BackgroundTransparency = 1

local MainTab = Instance.new("Frame", ContentArea)
MainTab.Size = UDim2.new(1, 0, 1, 0)
MainTab.BackgroundTransparency = 1

local GiftTab = Instance.new("Frame", ContentArea)
GiftTab.Size = UDim2.new(1, 0, 1, 0)
GiftTab.Visible = false
GiftTab.BackgroundTransparency = 1

local SettingsTab = Instance.new("Frame", ContentArea)
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.Visible = false
SettingsTab.BackgroundTransparency = 1

-- Status bar
local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, -20, 0, 34)
Status.Position = UDim2.new(0, 10, 1, -44)
Status.BackgroundTransparency = 1
Status.Text = "🟡 สถานะ: รอคำสั่ง..."
Status.TextColor3 = Color3.fromRGB(200,255,200)
Status.Font = Enum.Font.SourceSans
Status.TextSize = 16
Status.TextXAlignment = Enum.TextXAlignment.Left

-- ======= Main Tab UI =======
local StartBtn = Instance.new("TextButton", MainTab)
StartBtn.Size = UDim2.new(0.45, -10, 0, 48)
StartBtn.Position = UDim2.new(0.03, 0, 0.03, 0)
StartBtn.Text = "▶ เริ่มทำงาน"
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18
StartBtn.TextColor3 = Color3.fromRGB(240,240,240)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 20)
StartBtn.BorderSizePixel = 0

local StopBtn = Instance.new("TextButton", MainTab)
StopBtn.Size = UDim2.new(0.45, -10, 0, 48)
StopBtn.Position = UDim2.new(0.52, 0, 0.03, 0)
StopBtn.Text = "⏹ หยุด"
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18
StopBtn.TextColor3 = Color3.fromRGB(240,240,240)
StopBtn.BackgroundColor3 = Color3.fromRGB(140, 10, 10)
StopBtn.BorderSizePixel = 0

local InfoLabel = Instance.new("TextLabel", MainTab)
InfoLabel.Size = UDim2.new(1, -20, 0, 100)
InfoLabel.Position = UDim2.new(0, 10, 0, 68)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "คำอธิบายการทำงาน:\n- ขายสัตว์เลี้ยงทั้งหมด\n- ตั้ง QuickSell ไข่ตามค่า\n- กด ProximityPrompt รอบตัว\n- ลบสัตว์เลี้ยงใน workspace\n- โฟกัสและส่งของให้เป้าหมาย (ถ้าเปิด)"
InfoLabel.TextWrapped = true
InfoLabel.TextColor3 = Color3.fromRGB(200,255,200)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 14
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ======= Gift Tab UI =======
local TargetBoxLabel = Instance.new("TextLabel", GiftTab)
TargetBoxLabel.Size = UDim2.new(0.95, 0, 0, 20)
TargetBoxLabel.Position = UDim2.new(0.025, 0, 0.02, 0)
TargetBoxLabel.BackgroundTransparency = 1
TargetBoxLabel.Text = "ชื่อผู้เล่นที่จะรับของ (ใส่ชื่อแล้วกด Start):"
TargetBoxLabel.TextColor3 = Color3.fromRGB(200,255,200)
TargetBoxLabel.Font = Enum.Font.SourceSans
TargetBoxLabel.TextSize = 14
TargetBoxLabel.TextXAlignment = Enum.TextXAlignment.Left

local TargetBox = Instance.new("TextBox", GiftTab)
TargetBox.Size = UDim2.new(0.95, 0, 0, 36)
TargetBox.Position = UDim2.new(0.025, 0, 0.08, 0)
TargetBox.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
TargetBox.TextColor3 = Color3.fromRGB(220,255,220)
TargetBox.PlaceholderText = "พิมพ์ชื่อผู้เล่น เช่น Koaksliskx"
TargetBox.Font = Enum.Font.SourceSans
TargetBox.TextSize = 18
TargetBox.ClearTextOnFocus = false

local BlacklistLabel = Instance.new("TextLabel", GiftTab)
BlacklistLabel.Size = UDim2.new(0.95, 0, 0, 20)
BlacklistLabel.Position = UDim2.new(0.025, 0, 0.34, 0)
BlacklistLabel.BackgroundTransparency = 1
BlacklistLabel.Text = "Blacklist (จะไม่ส่งให้): Wolf_E1, Kangroo_E1, Rhino_E1, Lion_E1, Gorilla_E1, Seaturtle, Okapi, Needlefish, Panther, Butterflyfish"
BlacklistLabel.TextWrapped = true
BlacklistLabel.TextColor3 = Color3.fromRGB(200,255,200)
BlacklistLabel.Font = Enum.Font.SourceSans
BlacklistLabel.TextSize = 12
BlacklistLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ======= Settings Tab UI =======
local SettingsTitle = Instance.new("TextLabel", SettingsTab)
SettingsTitle.Size = UDim2.new(1, -10, 0, 20)
SettingsTitle.Position = UDim2.new(0, 10, 0, 4)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = Color3.fromRGB(200,255,200)
SettingsTitle.Font = Enum.Font.SourceSansBold
SettingsTitle.TextSize = 16

local function makeToggle(parent, y, text, default)
	local tlabel = Instance.new("TextLabel", parent)
	tlabel.Size = UDim2.new(0.65, 0, 0, 28)
	tlabel.Position = UDim2.new(0.03, 0, y, 0)
	tlabel.BackgroundTransparency = 1
	tlabel.Text = text
	tlabel.TextXAlignment = Enum.TextXAlignment.Left
	tlabel.TextColor3 = Color3.fromRGB(200,255,200)
	tlabel.Font = Enum.Font.SourceSans
	tlabel.TextSize = 14

	local tbtn = Instance.new("TextButton", parent)
	tbtn.Size = UDim2.new(0.28, 0, 0, 28)
	tbtn.Position = UDim2.new(0.70, 0, y, 0)
	tbtn.Font = Enum.Font.SourceSansBold
	tbtn.TextSize = 14
	tbtn.BorderSizePixel = 0
	tbtn.BackgroundColor3 = default and Color3.fromRGB(0,140,20) or Color3.fromRGB(120,20,20)
	tbtn.TextColor3 = Color3.fromRGB(230,230,230)
	tbtn.Text = default and "เปิด" or "ปิด"
	return tbtn
end

local toggleAutoSell = makeToggle(SettingsTab, 0.08, "Auto Sell (SellAll)", true)
local toggleQuickSell = makeToggle(SettingsTab, 0.20, "Auto QuickSell (SetEggQuickSell)", true)
local toggleDeletePets = makeToggle(SettingsTab, 0.32, "Auto Delete Pets", true)
local toggleProx = makeToggle(SettingsTab, 0.44, "Auto ProximityPrompt", true)
local toggleAutoGift = makeToggle(SettingsTab, 0.56, "Auto Gift to Target", true)

local DelayLabel = Instance.new("TextLabel", SettingsTab)
DelayLabel.Size = UDim2.new(0.5, 0, 0, 22)
DelayLabel.Position = UDim2.new(0.03, 0, 0.72, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Delay ระหว่างคำสั่ง (วินาที):"
DelayLabel.TextColor3 = Color3.fromRGB(200,255,200)
DelayLabel.Font = Enum.Font.SourceSans
DelayLabel.TextSize = 14

local DelayBox = Instance.new("TextBox", SettingsTab)
DelayBox.Size = UDim2.new(0.3, 0, 0, 26)
DelayBox.Position = UDim2.new(0.55, 0, 0.72, 0)
DelayBox.BackgroundColor3 = Color3.fromRGB(30,40,30)
DelayBox.TextColor3 = Color3.fromRGB(220,255,220)
DelayBox.Text = "0.3"
DelayBox.Font = Enum.Font.SourceSans
DelayBox.TextSize = 14
DelayBox.ClearTextOnFocus = false

-- ======= Sounds (placeholder IDs — replace with your own ifต้องการ) =======
local StartSound = Instance.new("Sound", MainFrame)
StartSound.Name = "StartSound"
StartSound.SoundId = "rbxassetid://184352486" -- ตัวอย่าง: เปลี่ยนเป็น ID ที่ชอบ

local DoneSound = Instance.new("Sound", MainFrame)
DoneSound.Name = "DoneSound"
DoneSound.SoundId = "rbxassetid://184352486" -- ตัวอย่าง: เปลี่ยนเป็น ID ที่ชอบ

-- ======= Logic (functions + state) =======
local running = false

local Blacklist = {"Wolf_E1","Kangroo_E1","Rhino_E1","Lion_E1","Gorilla_E1","Seaturtle","Okapi","Needlefish","Panther","Butterflyfish"}

local function setStatus(text, color)
	Status.Text = text
	if color then
		Status.TextColor3 = color
	else
		Status.TextColor3 = Color3.fromRGB(200,255,200)
	end
end

-- toggle button helpers
local function bindToggle(btn)
	local state = (btn.Text == "เปิด")
	btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			btn.Text = "เปิด"
			btn.BackgroundColor3 = Color3.fromRGB(0,140,20)
		else
			btn.Text = "ปิด"
			btn.BackgroundColor3 = Color3.fromRGB(120,20,20)
		end
	end)
	return function() return btn.Text == "เปิด" end
end

local isAutoSell = bindToggle(toggleAutoSell)
local isQuickSell = bindToggle(toggleQuickSell)
local isDeletePets = bindToggle(toggleDeletePets)
local isProx = bindToggle(toggleProx)
local isAutoGift = bindToggle(toggleAutoGift)

-- Tab switching
TabMainBtn.MouseButton1Click:Connect(function()
	MainTab.Visible = true
	GiftTab.Visible = false
	SettingsTab.Visible = false
end)
TabGiftBtn.MouseButton1Click:Connect(function()
	MainTab.Visible = false
	GiftTab.Visible = true
	SettingsTab.Visible = false
end)
TabSettingsBtn.MouseButton1Click:Connect(function()
	MainTab.Visible = false
	GiftTab.Visible = false
	SettingsTab.Visible = true
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ======= Core operation (respects toggles) =======
local function performRoutine()
	-- play start sound
	pcall(function() StartSound:Play() end)
	setStatus("🟢 กำลังทำงาน... โปรดรอ", Color3.fromRGB(140,255,140))
	-- wait for attribute to exist (as original)
	repeat task.wait() until LocalPlayer:GetAttribute("DinoEventOnlineTime") ~= nil or not running
	if not running then
		setStatus("⛔ ถูกยกเลิกก่อนเริ่ม", Color3.fromRGB(255,180,180))
		return
	end

	-- Auto Sell
	if isAutoSell() then
		pcall(function()
			local args = {"SellAll","All","Pet"}
			if ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("PetRE") then
				ReplicatedStorage.Remote.PetRE:FireServer(unpack(args))
			end
		end)
		task.wait(tonumber(DelayBox.Text) or 0.3)
	end

	-- QuickSell eggs
	if isQuickSell() then
		pcall(function()
			if ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("FishingRE") then
				ReplicatedStorage.Remote.FishingRE:FireServer("SetEggQuickSell", {
					["1"] = "\255",
					Diamond = false, ["3"] = true, ["2"] = false, ["5"] = false,
					["4"] = false, ["6"] = false, Golden = false,
					Electirc = false, Fire = false, Dino = false, Snow = false
				})
			end
		end)
		task.wait(tonumber(DelayBox.Text) or 0.3)
	end

	-- Proximity prompts
	if isProx() then
		pcall(function()
			for _,v in pairs(workspace.PlayerBuiltBlocks:GetChildren()) do
				if not running then break end
				if v:FindFirstChild("RootPart") and v.RootPart:FindFirstChild("ProximityPrompt") then
					fireproximityprompt(v.RootPart.ProximityPrompt)
					task.wait(0.08)
				end
			end
		end)
		task.wait(tonumber(DelayBox.Text) or 0.3)
	end

	-- Delete pets (from workspace)
	if isDeletePets() then
		pcall(function()
			local deletePets = {}
			for _, v in pairs(workspace.Pets:GetChildren()) do
				if not running then break end
				pcall(function()
					if v:IsA("Model") and v:GetAttribute("UserId") == LocalPlayer.UserId then
						table.insert(deletePets, v.Name)
					end
				end)
			end
			for _, name in ipairs(deletePets) do
				if not running then break end
				if ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("CharacterRE") then
					ReplicatedStorage.Remote.CharacterRE:FireServer("Del", name)
				end
				task.wait(0.06)
			end
		end)
		task.wait(tonumber(DelayBox.Text) or 0.3)
	end

	-- Auto Gift to target
	if isAutoGift() then
		local targetName = TargetBox.Text or ""
		if targetName ~= "" and Players:FindFirstChild(targetName) then
			local target = Players[targetName]
			-- try teleport to target by setting CFrame (note: may error if character/nil)
			pcall(function()
				if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
				end
			end)
			task.wait(1)
			pcall(function()
				for _, v in pairs(LocalPlayer.PlayerGui.Data.Pets:GetChildren()) do
					if not running then break end
					local petType = v:GetAttribute and v:GetAttribute("T") or nil
					if petType and not table.find(Blacklist, petType) then
						-- focus then gift
						if ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("CharacterRE") then
							ReplicatedStorage.Remote.CharacterRE:FireServer("Focus", v.Name)
						end
						task.wait(0.08)
						if ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("GiftRE") then
							ReplicatedStorage.Remote.GiftRE:FireServer(target)
						end
						task.wait(tonumber(DelayBox.Text) or 0.3)
					end
				end
			end)
		else
			-- no target -> skip gifting
			setStatus("⚠️ ไม่พบผู้เล่นเป้าหมายหรือช่องว่าง — ข้ามการส่งของ", Color3.fromRGB(255,220,120))
		end
	end

	-- finish
	if running then
		pcall(function() DoneSound:Play() end)
		setStatus("✅ เสร็จสิ้นการทำงาน", Color3.fromRGB(140,255,140))
	end
	running = false
end

-- Start / Stop controls
StartBtn.MouseButton1Click:Connect(function()
	if running then
		setStatus("ℹ️ กำลังทำงานอยู่แล้ว...", Color3.fromRGB(255,255,140))
		return
	end
	running = true
	-- spawn the routine so UI remains responsive
	task.spawn(function()
		performRoutine()
	end)
end)

StopBtn.MouseButton1Click:Connect(function()
	if not running then
		setStatus("⛔ ไม่มีการทำงานอยู่", Color3.fromRGB(255,180,180))
		return
	end
	running = false
	setStatus("⛔ หยุดการทำงานโดยผู้ใช้", Color3.fromRGB(255,180,180))
end)

-- Toggle click handlers (ensure UI reflects state)
-- (already handled in bindToggle)

-- Optional: close on Escape (you saidไม่ต้องคีย์ลัด เปิด/ปิด) -> skip

-- Initial status
setStatus("🟡 พร้อมใช้งาน — เลือกแท็บแล้วกด 'เริ่มทำงาน'", Color3.fromRGB(200,255,200))

-- End of script
