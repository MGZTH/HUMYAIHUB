--// ตั้งค่าชื่อผู้รับ
local PLRNAME = "G_minoru273"

--// สร้าง GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Button = Instance.new("TextButton", Frame)
local Status = Instance.new("TextLabel", Frame)
local Sound = Instance.new("Sound", ScreenGui)

-- ตั้งเสียง (ID เสียงแจ้งเตือน Roblox)
Sound.SoundId = "rbxassetid://4590662764" -- เสียงติ๊ง
Sound.Volume = 2

Frame.Size = UDim2.new(0, 220, 0, 90)
Frame.Position = UDim2.new(0.4, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1

Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 10)
Button.Text = "▶ เริ่มทำงาน"
Button.TextColor3 = Color3.fromRGB(0, 255, 0)
Button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
Button.Font = Enum.Font.SourceSansBold
Button.TextScaled = true
Button.BorderSizePixel = 0
Button.AutoButtonColor = true

Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 55)
Status.BackgroundTransparency = 1
Status.Text = "รอสั่งงาน..."
Status.TextColor3 = Color3.fromRGB(255, 255, 0)
Status.Font = Enum.Font.SourceSans
Status.TextScaled = true

local running = false

Button.MouseButton1Click:Connect(function()
	if running then return end
	running = true
	Button.Text = "กำลังทำงาน..."
	Button.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
	Status.Text = "กำลังทำงาน..."
	Sound:Play()

	--================= เริ่มโค้ดเดิม =================--
	repeat task.wait() until game.Players.LocalPlayer:GetAttribute("DinoEventOnlineTime") ~= nil
	local args = {"SellAll","All","Pet"}
	game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("PetRE"):FireServer(unpack(args))
	task.wait(1)
	game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("FishingRE"):FireServer("SetEggQuickSell", {
		["1"] = "\255",
		Diamond = false,
		["3"] = true,
		["2"] = false,
		["5"] = false,
		["4"] = false,
		["6"] = false,
		Golden = false,
		Electirc = false,
		Fire = false,
		Dino = false,
		Snow = false
	})
	task.wait(3)
	for _,v in pairs(workspace.PlayerBuiltBlocks:GetChildren()) do
		if v:FindFirstChild("RootPart") and v.RootPart:FindFirstChild("ProximityPrompt") then
			fireproximityprompt(v.RootPart.ProximityPrompt)
			task.wait(0.1)
		end
	end
	task.wait(7)

	local deletePets = {}
	for _, v in pairs(workspace.Pets:GetChildren()) do
		pcall(function()
			if v:IsA("Model") and v:GetAttribute("UserId") == game.Players.LocalPlayer.UserId then
				if not v.RootPart:FindFirstChild("GUI/BigPetGUI") then
					local petspeed = v.RootPart["GUI/IdleGUI"].Speed.Text
					local number = tonumber((petspeed:gsub("%D", "")))
					if number and number >= 300000 then
						table.insert(deletePets, v.Name)
					end
				end
			end
		end)
	end

	for _, petName in ipairs(deletePets) do
		game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("CharacterRE"):FireServer("Del", petName)
	end

	local Blacklist = {"Wolf_E1", "Kangroo_E1", "Rhino_E1", "Lion_E1", "Gorilla_E1", "Seaturtle", "Okapi", "Needlefish", "Panther", "Butterflyfish", "Penguin_E1", "Ostrich_E1", "Baldeagle_E1", "Bee_E1", "Butterfly_E1"}
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[PLRNAME].Character.HumanoidRootPart.CFrame
	task.wait(1)
	for _,v in pairs(game.Players.LocalPlayer.PlayerGui.Data.Pets:GetChildren()) do
		if not table.find(Blacklist, v:GetAttribute("T")) then
			game.ReplicatedStorage.Remote.CharacterRE:FireServer("Focus", v.Name)
			task.wait(0.1)
			game.ReplicatedStorage.Remote.GiftRE:FireServer(game.Players[PLRNAME])
			task.wait(0.3)
		end
	end
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
	--================= จบโค้ดเดิม =================--

	-- แจ้งเตือนตอนเสร็จ
	task.wait(2)
	Status.Text = "✅ เสร็จแล้วรีเกมโว้ย!"
	Status.TextColor3 = Color3.fromRGB(0, 255, 0)
	Button.Text = "✅ เสร็จสิ้น"
	Button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	Sound:Play()
end)
