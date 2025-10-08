local p = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ui = Instance.new("ScreenGui", p.PlayerGui)
local f = Instance.new("Frame", ui)
local t = Instance.new("TextLabel", f)
local b = Instance.new("TextButton", f)
local tog = Instance.new("TextButton", ui)
local msg = Instance.new("TextLabel", ui)
local sfx = Instance.new("Sound", ui)

-- เสียงเอฟเฟกต์
sfx.SoundId = "rbxassetid://12222124"
sfx.Volume = 2

-- หน้าตา UI
f.Size = UDim2.new(0,250,0,150)
f.Position = UDim2.new(0.4,0,0.4,0)
f.BackgroundColor3 = Color3.fromRGB(45,45,45)
t.Size = UDim2.new(1,0,0,30)
t.Text = "Fishing UI"
t.BackgroundColor3 = Color3.fromRGB(80,80,80)
t.TextColor3 = Color3.new(1,1,1)
b.Size = UDim2.new(0.8,0,0,50)
b.Position = UDim2.new(0.1,0,0.5,0)
b.Text = "เริ่มทำ"
b.BackgroundColor3 = Color3.fromRGB(60,200,100)
tog.Size = UDim2.new(0,120,0,40)
tog.Position = UDim2.new(0.05,0,0.1,0)
tog.Text = "Toggle UI"
tog.BackgroundColor3 = Color3.fromRGB(80,80,200)
tog.TextColor3 = Color3.new(1,1,1)

-- กล่องข้อความแจ้งเตือน
msg.Size = UDim2.new(0,280,0,50)
msg.Position = UDim2.new(0.5,-140,0.2,0)
msg.BackgroundColor3 = Color3.fromRGB(0,0,0)
msg.TextColor3 = Color3.new(1,1,1)
msg.TextScaled = true
msg.BackgroundTransparency = 0.3
msg.Visible = false

-- ระบบลาก UI
local UIS = game:GetService("UserInputService")
local drag, dragInput, startPos, startMouse
local function update(i)
	local delta = i.Position - startMouse
	f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
t.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true startMouse = i.Position startPos = f.Position
		i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
	end
end)
t.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end end)
UIS.InputChanged:Connect(function(i) if i == dragInput and drag then update(i) end end)

-- ปุ่มเปิด/ปิด
local show = true
tog.MouseButton1Click:Connect(function() show = not show f.Visible = show end)

-- ปุ่มเริ่มทำงาน
b.MouseButton1Click:Connect(function()
	rs.Remote.FishingRE:FireServer("SetEggQuickSell", {
		["1"] = "\255", ["3"] = true,
		Diamond=false, ["2"]=false, ["4"]=false,
		["5"]=false, ["6"]=false,
		Golden=false, Electirc=false, Fire=false, Dino=false, Snow=false
	})
	sfx:Play()
	msg.Text = "💢 ทำงานแล้วไปเปิดไข่โว้ย!"
	msg.Visible = true
	task.wait(2.5)
	msg.Visible = false
end)
