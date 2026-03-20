local RunService = game:GetService("RunService")

local count = 0
local conn

conn = RunService.Heartbeat:Connect(function()
    count += 1
    if count >= 10 then
        conn:Disconnect()
    end
end)

while count < 10 do
    RunService.Heartbeat:Wait()
end


if count < 10 then
    error("detected")
    return
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local LocalPlayer = LP
local placeId = game.PlaceId
local jobId = game.JobId
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CombatRemote = RS:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
local VirtualUser = game:GetService('VirtualUser')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local privateServerId = game.PrivateServerId
local QuestModule = require(ReplicatedStorage.Modules.QuestConfig)
local quests = QuestModule.RepeatableQuests
local QuestEvent = ReplicatedStorage.RemoteEvents.QuestAccept
local Event = RS:WaitForChild("RemoteEvents"):WaitForChild("AllocateStat")
local Data = LP:WaitForChild("Data")
local StatPoints = Data:WaitForChild("StatPoints")
local MerchantConfig = require(game:GetService("ReplicatedStorage").Modules.MerchantConfig)
local PurchaseRemote = game:GetService("ReplicatedStorage").Remotes.MerchantRemotes.PurchaseMerchantItem
local HttpService = game:GetService("HttpService")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local requestRemote = remotes:WaitForChild("RequestInventory")
local updateRemote = remotes:WaitForChild("UpdateInventory")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local ItemRarityConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("ItemRarityConfig"))
local LoadoutEvent = ReplicatedStorage.RemoteEvents.LoadoutLoad
_G.selectedMerchantItems = {}
_G.AutoBuyMerchant = false
_G.PrioriySystem = false
_G.PrioriySystem2 = false
local IslandPositions = {
    ["Starter"] = {
        Position = Vector3.new(140.46328735351562,16.020355224609375,-232.6060028076172),
        Distance = 300
    },
    ["Jungle"] = {
        Position = Vector3.new(-549.4597778320312,-1.6375274658203125,450.9712829589844),
        Distance = 250
    },
    ["Desert"] = {
        Position = Vector3.new(-858.2831420898438,7.399674415588379,-423.21685791015625),
        Distance = 180
    },
    ["Snow"] = {
        Position = Vector3.new(-404.0072021484375,8.77878475189209,-1108.4066162109375),
        Distance = 350
    },
    ["Sailor"] = {
        Position = Vector3.new(241.33700561523438,58.223262786865234,878.6301879882812),
        Distance = 320
    },
    ["Shibuya"] = {
        Position = Vector3.new(1634.826171875,94.87212371826172,249.17959594726562),
        Distance = 700
    },
    ["HuecoMundo"] = {
        Position = Vector3.new(-548.8748168945312,0.3238450884819031,1172.332763671875),
        Distance = 400
    },
    ["Boss"] = {
        Position = Vector3.new(768.4255981445312,-0.6666639447212219,-1087.132568359375),
        Distance = 180
    },
    ["Shinjuku"] = {
        Position = Vector3.new(320.879638671875,-4.17604923248291,-2004.6363525390625),
        Distance = 750
    },
    ["Slime"] = {
        Position = Vector3.new(-1183.3363037109375,44.49148178100586,212.57144165039062),
        Distance = 400
    },
    ["Academy"] = {
        Position = Vector3.new(963.0895385742188,2.2623825073242188,1327.1123046875),
        Distance = 250
    },
    ["Judgement"] = {
        Position = Vector3.new(-1244.099609375,77.01905822753906,-1236.8636474609375),
        Distance = 420
    },
    ["SoulSociety"] = {
        Position = Vector3.new(-1303.7255859375,1624.6370849609375,1672.4981689453125),
        Distance = 170
    }
}

local ListTrade = {
    ["Blessed Maiden"] = {
        {Name = "Aero Core", Amount = 3},
        {Name = "Celestial Mark", Amount = 1},
        {Name = "Gale Essence", Amount = 8},
        {Name = "Tide Remnant", Amount = 14},
        {Name = "Tempest Relic", Amount = 25}
    },
    ["Blessed Maiden Skill F"] = {
        {Name = "Aero Core", Amount = 8},
        {Name = "Celestial Mark", Amount = 2},
        {Name = "Tempest Relic", Amount = 75}
    },
    ["SJW V2"] = {
        {Name = "Monarch Core", Amount = 10},
        {Name = "Monarch Essence", Amount = 5},
        {Name = "Kamish Dagger", Amount = 2},
        {Name = "Shadow Crystal", Amount = 1}
    },
    ["Sukuna V2"] = {
        {Name = "Cursed Flesh", Amount = 1},
        {Name = "Malevolent Soul", Amount = 3},
        {Name = "Vessel Ring", Amount = 7},
        {Name = "Awakened Cursed Finger", Amount = 20}
    },
    ["Sukuna V2 Domain"] = {
        {Name = "Cursed Flesh", Amount = 1},
        {Name = "Malevolent Soul", Amount = 6},
        {Name = "Vessel Ring", Amount = 7},
        {Name = "Awakened Cursed Finger", Amount = 20},
        {Name = "Shrine Domain Shard", Amount = 1}
    },
    ["Gilgamesh Key"] = {
        {Name = "Phantasm Core", Amount = 3},
        {Name = "Ancient Shard", Amount = 6},
        {Name = "Throne Remnant", Amount = 12},
        {Name = "Golden Essence", Amount = 8},
        {Name = "Broken Sword", Amount = 100}
    },

    ["Gojo V2"] = {
        {Name = "Six Eye", Amount = 6},
        {Name = "Reversal Pulse", Amount = 9},
        {Name = "Blue Singularity", Amount = 6},
        {Name = "Infinity Essence", Amount = 1}
    },

    ["Gojo V2 Domain"] = {
        {Name = "Six Eye", Amount = 6},
        {Name = "Reversal Pulse", Amount = 9},
        {Name = "Blue Singularity", Amount = 6},
        {Name = "Infinity Essence", Amount = 1},
        {Name = "Infinity Domain Shard", Amount = 1}
    },
    ["Rimuru"] = {
        {Name = "Sage Pulse", Amount = 9},
        {Name = "Tempest Seal", Amount = 6},
        {Name = "Slime Remnant", Amount = 3},
        {Name = "Slime Core", Amount = 1}
    },
    ["Anos"] = {
        {Name = "Calamity Seal", Amount = 65},
        {Name = "Demonic Fragment", Amount = 12},
        {Name = "Demonic Shard", Amount = 6},
        {Name = "Destruction Eye", Amount = 2},
        {Name = "Imperial Mark", Amount = 1}
    },
    ["Ichigo"] = {
        {Name = "Boss Ticket", Amount = 500}
    },
    ["Cid"] = {
        {Name = "Atomic Core", Amount = 1},
        {Name = "Shadow Essence", Amount = 4},
        {Name = "Void Seed", Amount = 8},
        {Name = "Umbral Capsule", Amount = 20}
    },
    ["Madoka"] = {
        {Name = "Heart", Amount = 100},
        {Name = "Divine Fragment", Amount = 8},
        {Name = "Sacred Bow", Amount = 5},
        {Name = "Radiant Core", Amount = 3},
        {Name = "Pink Gem", Amount = 1}
    },
    ["Aizen V1"] = {
        {Name = "HÃ¶gyoku Fragment", Amount = 1},
        {Name = "Reiatsu Core", Amount = 3},
        {Name = "Illusion Prism", Amount = 6},
        {Name = "Mirage Pendant", Amount = 10}
    },
    ["SJW V1"] = {
        {Name = "Abyss Edge", Amount = 6},
        {Name = "Dark Ring", Amount = 3},
        {Name = "Shadow Heart", Amount = 1}
    },
    ["Gojo V1"] = {
        {Name = "Void Fragment", Amount = 6},
        {Name = "Limitless Ring", Amount = 3},
        {Name = "Infinity Core", Amount = 1}
    },
    ["Sukuna V1"] = {
        {Name = "Crimson Heart", Amount = 1},
        {Name = "Cursed Finger", Amount = 6},
        {Name = "Dismantle Fang", Amount = 3}
    },
    ["Yamato"] = {
        {Name = "Azure Heart", Amount = 1},
        {Name = "Silent Storm", Amount = 3},
        {Name = "Yamato", Amount = 7},
        {Name = "Frozen Will", Amount = 14}
    },
    ["Aizen V2"] = {
        {Name = "Evolution Fragment", Amount = 1},
        {Name = "Transcendent Core", Amount = 3},
        {Name = "Divinity Essence", Amount = 8},
        {Name = "Fusion Ring", Amount = 15},
        {Name = "Chrysalis Sigil", Amount = 75}
    },
    ["Alter Saber Skill F"] = {
        {Name = "Alter Essence", Amount = 8},
        {Name = "Morgan Remnant", Amount = 15},
        {Name = "Corrupt Crown", Amount = 3},
        {Name = "Corruption Core", Amount = 12},
        {Name = "Dark Grail", Amount = 110}
    },
    ["Ascend Set 2-8"] = {
        {Name = "Void Fragment", Amount = 5},
        {Name = "Limitless Ring", Amount = 2},
        {Name = "Dismantle Fang", Amount = 7},
        {Name = "Dark Ring", Amount = 5},
        {Name = "Reiatsu Core", Amount = 4},
        {Name = "HÃ¶gyoku Fragment", Amount = 2},
        {Name = "Atomic Core", Amount = 2},
        {Name = "Blood Ring", Amount = 4},
        {Name = "Flame Soul", Amount = 3},
        {Name = "Cursed Flesh", Amount = 2},
        {Name = "Infinity Essence", Amount = 2},
        {Name = "Phantasm Core", Amount = 2},
        {Name = "Slime Core", Amount = 3}
    },
    ["Blessing Set 1-10"] = {
        {Name = "Wood", Amount = 1185},
        {Name = "Iron", Amount = 575},
        {Name = "Obsidian", Amount = 365},
        {Name = "Mythril", Amount = 170},
        {Name = "Adamantite", Amount = 40}
    }
}

_G.AutoBuildSwitch = false
_G.LuckBuild = 1
_G.DamageBuild = 2
_G.BuildThreshold = 15

local TradeNames = {}

for name,_ in pairs(ListTrade) do
    table.insert(TradeNames, name)
end

local function SafetyMode()
	local Players = game:GetService("Players")
	local LP = Players.LocalPlayer

	local BlacklistedUsers = {
		[2595714482] = true,
		[516173765] = true,
		[4512218864] = true,
		[1743329681] = true,
		[653208846] = true,
		[3226663238] = true,
		[1994122448] = true,
		[2925788551] = true,
		[3017035996] = true,
		[377698788] = true,
		[2829959745] = true
	}

	local function Check(player)
		if BlacklistedUsers[player.UserId] then
			game:Shutdown()
		end
	end

	for _,player in ipairs(Players:GetPlayers()) do
		Check(player)
	end

	Players.PlayerAdded:Connect(Check)
end

local fileName = "Rc Hub/Config/TotalExecution.json"
if not isfile(fileName) then
    writefile(fileName, "0")
end
local currentValue = tonumber(readfile(fileName)) or 0
currentValue = currentValue + 1
writefile(fileName, tostring(currentValue))

_G.SpeedTweenS = 190
_G.SelectModeTP = "Tween"
local selectedWeapon = "None"

game:GetService('Players').LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

function QuestR(a)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local QuestEvent = ReplicatedStorage.RemoteEvents.QuestAccept
QuestEvent:FireServer(a)
end

local function GetClosestIsland(npc)
    for islandName, data in pairs(IslandPositions) do
        local distance = (npc - data.Position).Magnitude
        
        if distance <= data.Distance then
            return islandName, data -- ✅ return dua-duanya
        end
    end

    return nil, nil
end

--[[
local function GetClosestIsland(npcPos)
    local closestIsland
    local closestDistance = math.huge

    for islandName, data in pairs(IslandPositions) do
        local dist = (npcPos - data.Position).Magnitude

        if dist < closestDistance then
            closestDistance = dist
            closestIsland = islandName
        end
    end

    return closestIsland, IslandPositions[closestIsland]
end
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PortalRemote = ReplicatedStorage.Remotes:WaitForChild("TeleportToPortal")

local function TeleportToIsland(islandName)
    if not islandName then return end
    PortalRemote:FireServer(islandName)
    local char = LP.Character or LP.CharacterAdded:Wait()
    repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
end

local function formatNumber(n)
    n = tonumber(n) or 0
    local abs = math.abs(n)

    local function clean(num)
        local s = string.format("%.2f", num)
        return s:gsub("%.?0+$", "")
    end

    if abs >= 1e12 then
        return clean(n / 1e12) .. "T"
    elseif abs >= 1e9 then
        return clean(n / 1e9) .. "B"
    elseif abs >= 1e6 then
        return clean(n / 1e6) .. "M"
    elseif abs >= 1e3 then
        return clean(n / 1e3) .. "K"
    else
        return tostring(n)
    end
end


local function sendWebhook(itemsText, WEBHOOK_URL)
    local level = player.Data.Level.Value
    local money = formatNumber(player.Data.Money.Value)
    local gems = formatNumber(player.Data.Gems.Value)
    local timeString = os.date("%H:%M:%S")
    local data = {
        ["username"] = "RcHub Best Script!",
        ["avatar_url"] = "https://i.imgur.com/SGVO85F.png",
        ["embeds"] = {
            {
                ["title"] = "Player Inventory Data",
                ["description"] =
                    "**Player Infos**\n Players Name : || **" .. game.Players.LocalPlayer.Name .. "** ||\n\n" ..
                    "⭐ Level: **" .. level .. "**    " ..
                    "💰 Money: **" .. money .. "**    " ..
                    "💎 Gems: **" .. gems .. "**\n\n" ..
                    "📦 **Inventory Items**\n```" ..
                    itemsText ..
                    "```\n" ..
                    timeString,

                ["color"] = 65280
            }
        }
    }
    local encoded = HttpService:JSONEncode(data)
    local requestFunc = http_request or request or syn.request
    if requestFunc then
        requestFunc({
            Url = WEBHOOK_URL,
            Body = encoded,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        })
    end
end

local function manualTrigger(link)
    local connection

    connection = updateRemote.OnClientEvent:Connect(function(category, data)
        if category ~= "Items" then return end
        if type(data) ~= "table" then return end

        connection:Disconnect()

        -- Group by Tier
        local tierData = {}
        local tierTotals = {}

        for _, item in pairs(data) do
            if type(item) == "table" and item.name then
                local name = item.name
                local qty = item.quantity or 1
                local tier = ItemRarityConfig:GetRarity(name) or "Common"

                tierData[tier] = tierData[tier] or {}
                tierData[tier][name] = (tierData[tier][name] or 0) + qty

                tierTotals[tier] = (tierTotals[tier] or 0) + qty
            end
        end

        -- Optional: urutkan tier biar rapi
        local tierOrder = {
            "Secret",
            "Mythical",
            "Legendary",
            "Epic",
            "Rare",
            "Uncommon",
            "Common"
        }

        local itemsText = ""

        for _, tier in ipairs(tierOrder) do
            if tierData[tier] then
                itemsText = itemsText ..
                    "📦 " .. tier ..
                    " Items \n"

                for name, qty in pairs(tierData[tier]) do
                    itemsText = itemsText ..
                        "- " .. name ..
                        " x" .. qty .. "\n"
                end

                itemsText = itemsText .. "\n"
            end
        end

        if itemsText == "" then
            itemsText = "Empty"
        end

        sendWebhook(itemsText, link)
    end)

    requestRemote:FireServer()
end

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

local function getNPC(kkj)
    local list = { "None" }
    local seen = {}

    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if not npcsFolder then
        return list
    end

    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:FindFirstChild("Humanoid") then
            local name = npc.Name

            -- Skip kalau ada underscore
            if not kkj and name:find("_") then
                continue
            end

            -- Hapus angka
            name = name:gsub("%d+", "")

            -- Hapus kata "Boss"
            --name = name:gsub("Boss", "")

            -- Rapikan spasi (kalau ada sisa)
            name = name:match("^%s*(.-)%s*$")

            if name ~= "" and not seen[name] then
                seen[name] = true
                table.insert(list, name)
            end
        end
    end

    table.sort(list)
    return list
end

local function GetQuest(npcType)
    local bestNPC

    local function checkQuest(name, data)
        if data.requirements then
            for _, req in pairs(data.requirements) do
                if req.npcType == npcType then
                    bestNPC = name
                    return true
                end
            end
        end
    end

    for npcName, data in pairs(quests) do
        if checkQuest(npcName, data) then
            break
        end

        for subName, subData in pairs(data) do
            if type(subData) == "table" and subData.requirements then
                if checkQuest(subName, subData) then
                    break
                end
            end
        end
    end

    if bestNPC then
        QuestEvent:FireServer(bestNPC)
        --print("[RC HUB] > Accepted quest:", bestNPC, "for NPC type:", npcType)
    else
        --print("[RC HUB] > No quest found for NPC type:", npcType)
    end

    return bestNPC
end

-- mode:
-- "Normal"            -> tanpa boss, skip "_"
-- "Boss"              -> exact name match (boss)
-- "IncludeUnderscore" -> normal tapi tidak skip "_"

local function findNPC(name, mode)
    if name == "None" then return nil end

    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if not npcsFolder then return nil end

    for _, npc in pairs(npcsFolder:GetChildren()) do
        local hum = npc:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local originalName = npc.Name
        local processedName = originalName

        if mode == "Boss" then
            if originalName == name then
                return npc
            end
        else
            if mode ~= "IncludeUnderscore" and originalName:find("_") then
                continue
            end

            processedName = processedName:gsub("%d+", "")
            processedName = processedName:match("^%s*(.-)%s*$")

            if processedName == name then
                return npc
            end
        end
    end

    return nil
end

local function getAllWeapons()
    local weapons = { "None" }
    local backpack = LP:FindFirstChild("Backpack")
    local char = LP.Character
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(weapons, tool.Name)
            end
        end
    end
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and not table.find(weapons, tool.Name) then
                table.insert(weapons, tool.Name)
            end
        end
    end
    return weapons
end



local function AktifSkill()
    if _G.AutoSkill then
        local abilityRemote = ReplicatedStorage.AbilitySystem.Remotes.RequestAbility
        local fruitRemote = ReplicatedStorage.RemoteEvents.FruitPowerRemote

        -- Ability
        if _G.SkillZ then abilityRemote:FireServer(1) end
        if _G.SkillX then abilityRemote:FireServer(2) end
        if _G.SkillC then abilityRemote:FireServer(3) end
        if _G.SkillV then abilityRemote:FireServer(4) end
        if _G.SkillF then abilityRemote:FireServer(5) end

        -- Fruit (versi simple)
        local fruits = { "Light", "Flame", "Quake" } -- ganti sesuai game
        local keys = {
            Z = _G.SkillZ,
            X = _G.SkillX,
            C = _G.SkillC,
            V = _G.SkillV,
            F = _G.SkillF
        }

        for _, fruit in ipairs(fruits) do
            for key, enabled in pairs(keys) do
                if enabled then
                    fruitRemote:FireServer("UseAbility", {
                        KeyCode = Enum.KeyCode[key],
                        FruitPower = fruit
                    })
                end
            end
        end
    end
end

local isProcessing = false 

local function NormalizeMob(str)
    if not str then return "" end

    str = str:lower()

    -- singular (hapus s di akhir)
    if str:sub(-1) == "s" then
        str = str:sub(1,-2)
    end

    -- hapus semua spasi
    str = str:gsub("%s+", "")

    return str
end


local function GetCurrentQuestTitle()
    local gui = player.PlayerGui:FindFirstChild("QuestUI")
    if not gui then return nil end

    local questFrame = gui:FindFirstChild("Quest")
    if not questFrame or not questFrame.Visible then
        return nil
    end

    local success, title = pcall(function()
        return questFrame
            .Quest
            .Holder
            .Content
            .QuestInfo
            .QuestTitle
            .QuestTitle
            .Text
    end)

    if success then
        return title
    end

    return nil
end


local function GetBestQuest()
    if isProcessing then return end

    local levelValue = player.Data.Level.Value
    local bestQuestName = nil
    local bestNpcType = nil
    local maxLevelFound = -1

    -- cari quest terbaik berdasarkan level
    for questName, questData in pairs(quests) do
        local reqLevel = questData.recommendedLevel

        if reqLevel and levelValue >= reqLevel then
            if reqLevel > maxLevelFound then
                maxLevelFound = reqLevel
                bestQuestName = questName

                if questData.requirements then
                    if questData.requirements.npcType then
                        bestNpcType = questData.requirements.npcType
                    else
                        for _, req in pairs(questData.requirements) do
                            if type(req) == "table" and req.npcType then
                                bestNpcType = req.npcType
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    local currentQuestTitle = GetCurrentQuestTitle()

    -- ========================
    -- JIKA ADA QUEST AKTIF
    -- ========================
    if currentQuestTitle then
        if bestQuestName and currentQuestTitle ~= quests[bestQuestName].title then
            isProcessing = true

            local button = player.PlayerGui
                .QuestUI
                .Quest
                .Quest
                .Holder
                .Content
                .Exit
                .CloseButton

            firesignal(button.MouseButton1Click)

            task.wait(1)

            isProcessing = false
            return nil, nil
        end

        -- quest sama → lanjut farm
        return bestQuestName, bestNpcType
    end

    -- ========================
    -- JIKA TIDAK ADA QUEST
    -- ========================
    if bestQuestName then
        isProcessing = true

        QuestR(bestQuestName)

        task.wait(1)

        isProcessing = false
    end

    return bestQuestName, bestNpcType
end

local function GetNPCOptions()
    local npcFolder = workspace:WaitForChild("ServiceNPCs")
    local npcOptions = {}

    for _, obj in ipairs(npcFolder:GetChildren()) do
        if obj:IsA("Model") then
            table.insert(npcOptions, obj.Name)
        end
    end

    table.sort(npcOptions) -- biar urut alfabet

    return npcOptions
end

local function GetAllMerchantItems()
    local options = {}

    for itemName, _ in pairs(MerchantConfig.ITEMS) do
        table.insert(options, itemName)
    end

    table.sort(options)
    return options
end

local GetStockRemote = game:GetService("ReplicatedStorage")
    .Remotes.MerchantRemotes.GetMerchantStock

_G.MerchantStockCache = {}
local function CheckAndBuy()
    if not _G.selectedMerchantItems or #_G.selectedMerchantItems == 0 then
        return
    end

    local merchantStock = _G.MerchantStockCache
    if not merchantStock then return end

    -- Kalau pilih All
    if table.find(_G.selectedMerchantItems, "All") then
        for itemName, data in pairs(merchantStock) do
            if data.stock and data.stock > 0 then
                PurchaseRemote:InvokeServer(itemName, 1)
            end
        end
        return
    end

    -- Kalau pilih tertentu
    for _, selectedItem in ipairs(_G.selectedMerchantItems) do
        local data = merchantStock[selectedItem]
        if data and data.stock and data.stock > 0 then
            PurchaseRemote:InvokeServer(selectedItem, 1)
        end
    end
end


local function GetMerchantStockNames()
    local response = GetStockRemote:InvokeServer()

    if not response or not response.stock then
        return "Wait A Moment, Loading Stock...."
    end

    -- SIMPAN KE CACHE
    _G.MerchantStockCache = response.stock

    local text = ""

    for itemName, data in pairs(response.stock) do
        local p = (data.currency == "Money") and "#1AFF00" or "#00FFF7"

        text = text ..
            itemName ..
            " [ <b><font color=\"#FF0000\"> x" .. data.stock ..
            " </font></b> | <b><font color=\"" .. p .. "\"> " ..
            data.price .. " " .. data.currency ..
            " </font></b> ]\n"
    end

    return text
end

local function GetIslandOptions()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PortalConfig = require(ReplicatedStorage:WaitForChild("PortalConfig"))

    local islandOptions = {}

    for portalId, _ in pairs(PortalConfig.Portals) do
        table.insert(islandOptions, portalId)
    end

    table.sort(islandOptions)

    return islandOptions
end

local ClanConfig = require(
    game:GetService("ReplicatedStorage")
    .Modules
    .ClanConfig
)

local function GetAllClansFormatted()
    local list = {}
    _G.ClanDropdownMap = {}

    for clanName, clanData in pairs(ClanConfig.Clans) do
        local rarity = clanData.rarity or "Common"
        local formatted = clanName .. " -> " .. rarity .. ""

        table.insert(list, formatted)
        _G.ClanDropdownMap[formatted] = clanName
    end

    table.sort(list)
    return list
end

local function GetClan()
    local Event = game:GetService("ReplicatedStorage")
        .RemoteEvents
        .GetPlayerStats

    local data = Event:InvokeServer()
    if not data then return nil end

    return data.Inventory
        and data.Inventory.Equipped
        and data.Inventory.Equipped.Clan
end

local UseItemRemote = game:GetService("ReplicatedStorage")
    .Remotes
    .UseItem

_G.AutoRerollClan = false
_G.ClanRollDelay = 0.2

local function IsTargetClan(currentClan)
    if not _G.selectedClans then return false end

    for _, target in pairs(_G.selectedClans) do
        if currentClan == target then
            return true
        end
    end

    return false
end

local function AutoRerollClan()
    task.spawn(function()
        while _G.AutoRerollClan do
            local currentClan = GetClan()

            if IsTargetClan(currentClan) then
                rcchub("Already Get Trait : " .. currentClan .. "")
                _G.AutoRerollClan = false
                break
            end

            UseItemRemote:FireServer(
                "Use",
                "Clan Reroll",
                1
            )

            task.wait(_G.ClanRollDelay)
        end
    end)
end

function BoostFps()
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    -- hapus efek lighting berat
    for _,v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("BloomEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 1

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    -- hapus texture & material
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end

        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end

        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end

    -- terrain simplify
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
end

local TraitConfig = require(game:GetService("ReplicatedStorage").Modules.TraitConfig)
_G.selectedTrait = {}
local DropdownMap = {} -- ["Celestial (Secret)"] = "Celestial"

local function GetAllTraitsFormatted()
    local options = {}

    for traitName, traitData in pairs(TraitConfig.Traits) do
        local formatted = traitName .. " -> " .. traitData.Rarity .. ""
        table.insert(options, formatted)
        DropdownMap[formatted] = traitName
    end

    table.sort(options)
    return options
end

local function GetEquippedTrait()
    local Event = game:GetService("ReplicatedStorage").RemoteEvents.GetPlayerStats
    local data = Event:InvokeServer()

    if data and data.Trait then
        return data.Trait
    end

    return nil
end

local function CheckTrait()
    if not _G.selectedTrait or #_G.selectedTrait == 0 then
        warn("[Rc Hub] > Belum pilih trait")
        return
    end

    local equippedTrait = GetEquippedTrait()
    if not equippedTrait then
        warn("[Rc Hub] > Tidak ada EquippedTrait")
        return
    end

    for _, selected in pairs(_G.selectedTrait) do
        if selected == equippedTrait then
            rcchub("Already Get Trait : " .. equippedTrait .. "")
            return true
        end
    end

    game:GetService("ReplicatedStorage").RemoteEvents.TraitReroll:FireServer()
    return false
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local function equipWeapon(toolName)
    if not toolName or toolName == "None" then return end
    local char = LP.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if char:FindFirstChild(toolName) then return end
    local tool = LP.Backpack:FindFirstChild(toolName)
    if tool then
        humanoid:EquipTool(tool)
        task.wait()
    end
end

local RunService = game:GetService("RunService")
local airFreezeLoop = {}
local function toggleAirFreeze(char, state)
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        if airFreezeLoop[char] then return end

        airFreezeLoop[char] = RunService.Heartbeat:Connect(function()
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        end)

    else
        if airFreezeLoop[char] then
            airFreezeLoop[char]:Disconnect()
            airFreezeLoop[char] = nil
        end
    end
end

local RaceConfig = require(
    game:GetService("ReplicatedStorage")
    .Modules
    .RaceConfig
)

local function GetPlayerStats()
    local Event = game:GetService("ReplicatedStorage")
        .RemoteEvents
        .GetPlayerStats

    return Event:InvokeServer() or {}
end

local function GetRace()
    local data = GetPlayerStats()

    return data.Inventory
        and data.Inventory.Equipped
        and data.Inventory.Equipped.Race
end

local function GetAllRacesFormatted()
    local list = {}
    _G.RaceDropdownMap = {}

    for raceName, raceData in pairs(RaceConfig.Races) do
        local rarity = raceData.rarity or "Common"
        local formatted = raceName .. " -> " .. rarity .. ""

        table.insert(list, formatted)
        _G.RaceDropdownMap[formatted] = raceName
    end

    table.sort(list)
    return list
end

local function NormalizeToTable(value)
    if not value then return {} end
    if typeof(value) == "table" then return value end
    return { value }
end

local UseItemRemote = game:GetService("ReplicatedStorage")
    .Remotes
    .UseItem

_G.AutoRerollRace = false
_G.RollDelay = 0.2

local function IsTargetRace(currentRace)
    if not _G.selectedRaces then return false end

    for _, target in pairs(_G.selectedRaces) do
        if currentRace == target then
            return true
        end
    end

    return false
end

local function AutoRerollRace()
    task.spawn(function()
        while _G.AutoRerollRace do
            local currentRace = GetRace()

            if IsTargetRace(currentRace) then
                rcchub("Already Get Trait : " .. currentRace .. "")
                _G.AutoRerollRace = false
                break
            end

            UseItemRemote:FireServer(
                "Use",
                "Race Reroll",
                1
            )

            task.wait(_G.RollDelay)
        end
    end)
end

local RunService = game:GetService("RunService")
local noclip = false
local connection
local function SetNoclip(state)
    noclip = state

    if noclip then
        connection = RunService.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

local TweenService = game:GetService("TweenService")

function TpTween(Pos)
    local char = LP.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    local distance = (hrp.Position - Pos.Position).Magnitude
    local speed = _G.SpeedTweenS -- bisa kamu ubah
    local time = distance / speed

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = Pos}
    )

    tween:Play()
end

function TPInstant(Pos)
    local char = LP.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if char:FindFirstChild("HumanoidRootPart") ~= hrp then return end

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    hrp.CFrame = Pos
end

function TP(Pos)
    if _G.SelectModeTP == "Instant" then
        TPInstant(Pos)
    elseif _G.SelectModeTP == "Tween" then
        TpTween(Pos)
    end
end

_G.ModeAT = "Behind"
_G.Adis = 11
local function getAttackPos()
    local mode = _G.ModeAT or "Behind"
    local d = _G.Adis or 11
    if mode == "Above" then
        return CFrame.new(0, d, 0) * CFrame.Angles(math.rad(-90),0,0)
    elseif mode == "Below" then
        return CFrame.new(0, -d, 0) * CFrame.Angles(math.rad(90),0,0)
    elseif mode == "Behind" then
        return CFrame.new(0, 0, d) * CFrame.Angles(math.rad(0),0,0)
    else
        return CFrame.new(0, 0, 0)
    end
end


local TELEPORT_COOLDOWN = 1
local CurrentBuild = nil
local function LoadBuild(id)
    if CurrentBuild == id then
        return
    end

    CurrentBuild = id
    LoadoutEvent:FireServer(id)
end

local lastCheck = 0
local function CheckBuildByHP(target)
    if not _G.AutoBuildSwitch then return end
    if not target then return end

    if tick() - lastCheck < 0.2 then
        return
    end

    lastCheck = tick()

    local hum = target:FindFirstChild("Humanoid")
    if not hum then return end

    local percent = (hum.Health / hum.MaxHealth) * 100

    if percent <= _G.BuildThreshold then
        LoadBuild(_G.LuckBuild)
    else
        LoadBuild(_G.DamageBuild)
    end
end

local tanggal = os.date("%d/%m/%Y")
local MarketplaceService = game:GetService("MarketplaceService")
local infoXXX = MarketplaceService:GetProductInfo(game.placeId)
local v162 = loadstring(game:HttpGet("https://raw.githubusercontent.com/VanciSonic/Lgtihb/refs/heads/main/k"))()
    :Window({
        Title = "Rc Hub 〢",
        Footer = infoXXX.Name .. " - " .. tanggal,
        Image = "124526064259356",
        Color = Color3.fromRGB(204, 0, 0),
        Theme = 9542022979,
        Version = 4
    })
if v162 then
    rcchub("Loading Script, Please Wait...")
end
local v163 = {
    main = v162:AddTab({
        Name = "Dashboard",
        Icon = "player"
    }),
    farm = v162:AddTab({
        Name = "Farm",
        Icon = "rbxassetid://97167558235554"
    }),
    setting = v162:AddTab({
        Name = "Setting",
        Icon = "rbxassetid://97167558235554"
    }),
    thr = v162:AddTab({
        Name = "Threshold",
        Icon = "rbxassetid://97167558235554"
    }),
    stats = v162:AddTab({
        Name = "Stats",
        Icon = "rbxassetid://97167558235554"
    }),
    bs = v162:AddTab({
        Name = "Boss",
        Icon = "rbxassetid://97167558235554"
    }),
    ts = v162:AddTab({
        Name = "Misc",
        Icon = "rbxassetid://97167558235554"
    }),
    trade = v162:AddTab({
        Name = "Trading",
        Icon = "rbxassetid://97167558235554"
    }),
    dungeon = v162:AddTab({
        Name = "Dungeon",
        Icon = "rbxassetid://97167558235554"
    }),
    tp = v162:AddTab({
        Name = "teleport",
        Icon = "rbxassetid://97167558235554"
    }),
    web = v162:AddTab({
        Name = "Webhook",
        Icon = "rbxassetid://97167558235554"
    })
}

main1 = v163.main:AddSection("About Us", true)

main1:AddParagraph({
    Title = "-[ INFORMATION ]-",
    Content =
    "<b><font color=\"#BD0101\"> DEVELOPER : RexyCode </font></b> \r\n\r\n <b><font color=\"#00FF00\"> UPDATE : 17/03/2026 </font></b> \r\n [+] Add Threshold Build Feature [Threshold] \r\n [+] Add Trading Feature [For Instant trade set] \r\n [+] Add Priority Now U Can [Kill All Boss Spawn + Summon Boss + Farm npc] \r\n\r\n <b><font color=\"#FF0000\">!! SUGGESTION? FOUND BUG? JOIN DISCORD !!</font></b>"
})

main1:AddButton({
    Title = "Copy Link Discord",
    Content = "",
    Callback = function()
        setclipboard("https://discord.gg/EvhJBNbgG7")
    end
})

local SvX = v163.main:AddSection("Server Features")
local reconnecting = false
local errorConn

SvX:AddToggle({
    Title = "Auto Reconnect",
    Default = false,
    Callback = function(state)
        reconnecting = state

        if errorConn and errorConn.Connected then
            errorConn:Disconnect()
            errorConn = nil
        end

        if state then
            errorConn = GuiService.ErrorMessageChanged:Connect(function(msg)
                if not reconnecting or msg == "" then return end
                task.wait(0.5)
                local ok = pcall(function()
                    if privateServerId and privateServerId ~= "" then
                        TeleportService:TeleportToPrivateServer(placeId, privateServerId, { LocalPlayer })
                    else
                        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
                    end
                end)
                if not ok then
                    task.wait(2)
                    pcall(function()
                        TeleportService:Teleport(placeId, LocalPlayer)
                    end)
                end
            end)
        end
    end
})

SvX:AddToggle({
    Title = "Auto Execute",
    Default = false,
    Callback = function(state)
        if queue_on_teleport then
            queue_on_teleport(state and [[
                    loadstring(game:HttpGet("https://vss.pandadevelopment.net/virtual/file/2768ea6419cb4d73"))()
                ]] or "")
        end
    end
})

main1:AddDivider()
main1:AddParagraph({
    Title = "-[ SCRIPT INFO ]-",
    Content =
        " Total Execute : <b><font color=\"#00FF00\">" ..
        currentValue ..
        "</font></b> \r\n Status Script : <b><font color=\"#00FF00\"> Free </font></b> \r\n Executor : <b><font color=\"#00FF00\">" ..
        identifyexecutor() .. "</font></b> \r\n"
})
main1:AddDivider()

Fish1 = v163.farm:AddSection("Player Support", true)
Fish1:AddToggle({
    Title = "Auto Haki",
    Content = "Automatically Equip Haki",
    Default = false,
    Callback = function(state)
        _G.FGDXX = state
    end
})

Fish1:AddToggle({
    Title = "Auto Observation",
    Content = "Automatically Equip Observation",
    Default = false,
    Callback = function(state)
        _G.FGDZZ = state
    end
})

Fish1:AddToggle({
    Title = "Auto Conqueror",
    Content = "Automatically Equip Conqueror",
    Default = false,
    Callback = function(state)
        _G.FGDZZXC = state
    end
})

Fish1:AddToggle({
    Title = "Speed hack",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FGDSS = state
    end
})

Fish1:AddToggle({
    Title = "Infinite Jump",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.infiJMP = state
    end
})

spawn(function()
    while task.wait(0.5) do
        if _G.FGDXX then
            if IsBusoActive() == false then
                local A_1 = "Toggle"
                local Event = game:GetService("ReplicatedStorage").RemoteEvents.HakiRemote
                Event:FireServer(A_1)
            end
        end
    end
end)

spawn(function()
    while task.wait(1) do
        if _G.FGDZZXC then
            local Event = game:GetService("ReplicatedStorage").RemoteEvents.ConquerorHakiRemote
            Event:FireServer()
        end
    end
end)

spawn(function()
    while task.wait(0.5) do
        if _G.FGDZZ then
            if game:GetService("Players").LocalPlayer.PlayerGui.DodgeCounterUI.MainFrame.Visible == false then
                local A_1 = "Toggle"
                local Event = game:GetService("ReplicatedStorage").RemoteEvents.ObservationHakiRemote
                Event:FireServer(A_1)
            end
        end
    end
end)

task.spawn(function()
    local player = game.Players.LocalPlayer
    while task.wait(0.3) do
        if _G.FGDSS then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= 160 then
                    hum.WalkSpeed = 160
                end
            end
        end
    end
end)

local UIS = game:GetService("UserInputService")
if not UIS.TouchEnabled then
    UIS.JumpRequest:Connect(function()
        if _G.infiJMP then
            local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

Fish2 = v163.farm:AddSection("Farm Level")

Fish2:AddParagraph({
    Title = "-[ INFORMATION ]-",
    Content =
    "This Mode Will Start Auto Farm <b><font color=\"#00FF00\"> lvl 1 -> lvl Max </font></b> \r\n Please Before You Start This Mode, Setting Your Weapon And Farm Mode At <b><font color=\"#00FF00\"> Setting Tab </font></b> \r\n\r\n <b><font color=\"#FF0000\">!! FOUND BUG? JOIN DISCORD !!</font></b>"
})

Fish2:AddToggle({
    Title = "Auto Farm Max Level",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.StartingLevelingFARM = state
    end
})

Fish2 = v163.farm:AddSection("Farm Selected Mob")
local selectedNPCs = {}
local npcDropdown = Fish2:AddDropdown({
    Title = "Select Npc",
    Options = getNPC(true),
    Default = "None",
    Multi = true,
    Callback = function(value)
        if type(value) == "string" then
            selectedNPCs = { value } -- ubah string jadi table
        else
            selectedNPCs = value
        end
    end
})

Fish2:AddButton({
    Title = "Refresh Npc",
    Content = "Refresh Dropdown",
    Callback = function()
        local newNPCs = getNPC(true)
        npcDropdown:SetValues(newNPCs)
    end
})

Fish2:AddToggle({
    Title = "Auto Farm",
    Content = "Select Npc First",
    Default = false,
    Callback = function(state)
        _G.StartingAUfarm = state
    end
})

Fish2:AddToggle({
    Title = "Auto Get Quest",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.StartQuest = state
    end
})

Fish3 = v163.setting:AddSection("Weapon & Method", true)
local npcDropdownXX = Fish3:AddDropdown({
    Title = "Select Weapon",
    Options = getAllWeapons(),
    Default = 1,
    Multi = false,
    Callback = function(Option)
        selectedWeapon = Option
    end
})

Fish3:AddButton({
    Title = "Refresh Weapon",
    Content = "Refresh Dropdown",
    Callback = function()
        local newNPCs = getAllWeapons()
        npcDropdownXX:SetValues(newNPCs)
    end
})

Fish3:AddToggle({
    Title = "Auto Equip Weapon",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.EquiD = state
    end
})

task.spawn(function()
    while task.wait(0.5) do
        if _G.EquiD and selectedWeapon then
            equipWeapon(selectedWeapon)
        end
    end
end)

Fish3:AddDropdown({
    Title = "Select Method",
    Options = { "Above", "Behind", "Below" },
    Default = "Above",
    Multi = false,
    Callback = function(Option)
        _G.ModeAT = Option
    end
})

Fish3:AddDropdown({
    Title = "Select Teleport Method",
    Options = { "Tween", "Instant" },
    Default = "Tween",
    Multi = false,
    Callback = function(Option)
        _G.SelectModeTP = Option
    end
})

Fish3:AddSlider({
    Title = "Teleport Cooldown",
    Content = "Custom Your Cooldown [Defult : 1]",
    Min = 1,
    Max = 10,
    Default = TELEPORT_COOLDOWN,
    Increment = 1,
    Callback = function(value)
        TELEPORT_COOLDOWN = value
    end
})

Fish3:AddSlider({
    Title = "Tween Speed [TWEEN METHOD]",
    Content = "Custom Your Speed [Defult : 190]",
    Min = 1,
    Max = 360,
    Default = _G.SpeedTweenS,
    Increment = 1,
    Callback = function(value)
        _G.SpeedTweenS = value
    end
})

Fish3:AddSlider({
    Title = "Distance Farm",
    Content = "Disctance Player To Mob",
    Min = 1,
    Max = 25,
    Default = _G.Adis,
    Increment = 1,
    Callback = function(value)
        _G.Adis = value
    end
})

Fish3:AddToggle({
    Title = "No Clip",
    Content = "",
    Default = true,
    Callback = function(Value)
        SetNoclip(Value)
    end
})

Fish3:AddToggle({
    Title = "Boost Fps",
    Content = "Boost Your fps",
    Default = false,
    Callback = function(Value)
        if Value then
            BoostFps()
        else
            print("[Rc Hub] > Fps Normal")
        end
    end
})

Fish3:AddToggle({
    Title = "Deleate island",
    Content = "Boost Your fps",
    Default = false,
    Callback = function(Value)
        if Value then
            local islandNames = {
                "AcademyIsland",
                "BossIsland",
                "DesertIsland",
                "HuecoMundo",
                "JudgementIsland",
                "JungleIsland",
                "SailorIsland",
                "ShibuyaStation",
                "ShinjukuIsland",
                "SlimeIsland",
                "SnowIsland",
                "SoulSocietyIsland",
                "StarterIsland"
            }

            for _, name in ipairs(islandNames) do
                local island = workspace:FindFirstChild(name)
                if island then
                    island:Destroy()
                end
            end
        else
            print("[Rc Hub] > Fps Normal")
        end
    end
})

Fish3:AddToggle({
    Title = "Auto Ascend",
    Content = "",
    Default = false,
    Callback = function(Value)
        _G.Ascend = Value

        if Value then
            task.spawn(function()
                while _G.Ascend do
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteEvents.RequestAscend:FireServer()
                    end)
                    task.wait(10)
                end
            end)
        end
    end
})

Fish3:AddButton({
    Title = "Redeem Code",
    Content = "Redeem All Active Code",
    Callback = function()
        local CodesModule = require(game:GetService("ReplicatedStorage"):WaitForChild("CodesConfig"))
        local Remote = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("CodeRedeem")

        for codeName, data in pairs(CodesModule.Codes) do
            task.spawn(function()
                pcall(function()
                    if CodesModule.IsValid(codeName) then
                        Remote:InvokeServer(codeName)
                        print("Redeemed:", codeName)
                    else
                        print("Invalid / Expired:", codeName)
                    end
                end)
            end)
            
            task.wait(0.3) -- delay biar gak spam (anti kick)
        end
    end
})

Fish3:AddDivider()
Fish3 = v163.setting:AddSection("Skill Ability", true)

Fish3:AddToggle({
    Title = "Auto Use Skill",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.AutoSkill = state
    end
})

Fish3:AddToggle({
    Title = "Auto Skill Z",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.SkillZ = state
    end
})

Fish3:AddToggle({
    Title = "Auto Skill X",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.SkillX = state
    end
})

Fish3:AddToggle({
    Title = "Auto Skill C",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.SkillC = state
    end
})

Fish3:AddToggle({
    Title = "Auto Skill V",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.SkillV = state
    end
})

Fish3:AddToggle({
    Title = "Auto Skill F",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.SkillF = state
    end
})

task.spawn(function()
    while task.wait() do
        
        if _G.PrioriySystem or _G.PrioriySystem2 then
            task.wait()
            continue
        end
        
        if _G.StartingAUfarm then
            for _, name in ipairs(selectedNPCs) do
                if not _G.StartingAUfarm then break end
                while true do
                    local found = false
                    for _, target in ipairs(workspace:GetDescendants()) do
                        if not _G.StartingAUfarm then break end
                        
                        if _G.PrioriySystem or _G.PrioriySystem2 then
                            break
                        end
                        
                        if target:IsA("Model")
                            and target:FindFirstChild("Humanoid")
                            and target.Humanoid.Health > 0 then
                            local clean = target.Name:gsub("%d+", "")
                            if clean == name then
                                found = true
                                if _G.StartQuest then
                                    GetQuest(clean)
                                end
                                if not _G.PrioriySystem or not _G.PrioriySystem2 then
                                    local npcPos = target.WorldPivot.Position
                                    local islandName, islandData = GetClosestIsland(npcPos)
                                    if not target:FindFirstChild("HumanoidRootPart") then
                                        if (hrp.Position - islandData.Position).Magnitude > 780 then
                                            TeleportToIsland(islandName)
                                        end
                                        wait(0.5)
                                        task.wait(TELEPORT_COOLDOWN)
                                        TP(CFrame.new(npcPos))
                                    else
                                        repeat
                                            local cok = target:WaitForChild("HumanoidRootPart",2)
                                            if cok then
                                                TP(cok.CFrame * getAttackPos())
                                                task.wait()
                                                CombatRemote:FireServer(cok.Position)
                                                AktifSkill()
                                            end
                                        until not _G.StartingAUfarm or _G.PrioriySystem or _G.PrioriySystem2 or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                                    end
                                end
                            end
                        end
                    end
                    if not found then break end
                    task.wait()
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do

        if _G.PrioriySystem or _G.PrioriySystem2 then
            task.wait()
            continue
        end

        if _G.StartingLevelingFARM then
            local questName, npcType = GetBestQuest()
            --print(npcType)
            local npcTypeX
            if not npcType then continue end

            if npcType == "SlimeWarrior" then
                npcTypeX = "Slime"
            else
                npcTypeX = npcType
            end
            
            local target = findNPC(npcTypeX, "IncludeUnderscore")
            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                if not _G.PrioriySystem or not _G.PrioriySystem2 then
                    local npcPos = target.WorldPivot.Position
                    local islandName, islandData = GetClosestIsland(npcPos)
                    if not target:FindFirstChild("HumanoidRootPart") then
                        if (hrp.Position - islandData.Position).Magnitude > 780 then
                            TeleportToIsland(islandName)
                        end
                        wait(0.5)
                        task.wait(TELEPORT_COOLDOWN)
                        TP(CFrame.new(npcPos))
                    else
                        repeat
                            local cok = target:WaitForChild("HumanoidRootPart",2)
                            if cok then
                                TP(cok.CFrame * getAttackPos())
                                task.wait()
                                CombatRemote:FireServer(cok.Position)
                                AktifSkill()
                            end
                        until not _G.StartingLevelingFARM or _G.PrioriySystem or _G.PrioriySystem2 or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                    end
                end
            end
        end
    end
end)

Fish37 = v163.thr:AddSection("Threshold Build", true)

Fish37:AddParagraph({
    Title = "-[ INFORMATION ]-",
    Content =
    "<b><font color=\"#BD0101\"> HOW TO USE? </font></b> \r\n Enable Auto Build Swap, choose your Damage Build and Luck Build from the dropdown,\n then set the Swap HP %. The script will use Damage Build when the boss HP is above\n the selected % and automatically switch to Luck Build when the HP goes below it. \r\n\r\n <b><font color=\"#BD0101\"> HOW TO ADD BUILD? </font></b> \r\n Open Settings in the game and find \"Build Saves\" on the left side of the UI.\n Save your builds there and make sure you have at least one Damage Build and one Luck\n Build, then select them in the script dropdown. \r\n\r\n <b><font color=\"#FF0000\">!! SUGGESTION? FOUND BUG? JOIN DISCORD !!</font></b>"
})

local buildList = {"1", "2", "3", "4", "5"}

Fish37:AddDropdown({
    Title = "Select Build 1 [Example : Damage Build]",
    Options = buildList,
    Default = "1",
    Multi = false,
    Callback = function(Value)
        _G.DamageBuild = tonumber(Value)
    end
})

Fish37:AddDropdown({
    Title = "Select Build 2 [Example : Luck Build]",
    Options = buildList,
    Default = "1",
    Multi = false,
    Callback = function(Value)
        _G.LuckBuild = tonumber(Value)
    end
})

Fish37:AddSlider({
    Title = "HP Threshold %",
    Content = "Auto Change Build If Hp On Target",
    Min = 1,
    Max = 50,
    Default = 15,
    Increment = 1,
    Callback = function(Value)
        _G.BuildThreshold = Value
    end
})

Fish37:AddToggle({
    Title = "Start Auto Change Build",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.AutoBuildSwitch = state
    end
})

kon1 = v163.stats:AddSection("Stats Point", true)

kon1:AddToggle({
    Title = "Auto Stats Melee",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.AutoStatsMelee = state
    end
})

kon1:AddToggle({
    Title = "Auto Stats Defense",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.AutoStatsDefense = state
    end
})

kon1:AddToggle({
    Title = "Auto Stats Sword",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.AutoStatsSword = state
    end
})

kon1:AddToggle({
    Title = "Auto Stats Power",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.AutoStatsPower = state
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if StatPoints.Value > 0 then
            if _G.AutoStatsMelee then
                Event:FireServer("Melee", 1)
            end

            if _G.AutoStatsDefense then
                Event:FireServer("Defense", 1)
            end

            if _G.AutoStatsSword then
                Event:FireServer("Sword", 1)
            end

            if _G.AutoStatsPower then
                Event:FireServer("Power", 1)
            end
        end
    end
end)

Fish4 = v163.bs:AddSection("Spawning Boss")

_G.RealNamedBRo = "SaberBoss"
_G.RealNamedBRoX = "SaberBoss"

_G.ListSpawnBoss = {
    "GojoBoss",
    "SukunaBoss",
    "YujiBoss",
    "JinwooBoss",
    "AizenBoss",
    "AlucardBoss",
    "MadokaBoss",
    "YamatoBoss"
}
_G.SelectBosss = {"AizenBoss"}
Fish4:AddDropdown({
    Title = "Select Target Boss",
    Options = _G.ListSpawnBoss,
    Default = "Above",
    Multi = true,
    Callback = function(value)
        if type(value) == "string" then
            _G.SelectBosss = { value } -- ubah string jadi table
        else
            _G.SelectBosss = value
        end
    end
})

_G.ListSpawnBossPT = {
    "SaberBoss",
    "IchigoBoss",
    "QinShiBoss"
}

_G.SelectBSpity = "SaberBoss"
Fish4:AddDropdown({
    Title = "Select Boss For Farm Pity",
    Options = _G.ListSpawnBossPT,
    Default = "None",
    Multi = false,
    Callback = function(value)
        _G.RealNamedBRoX = value
        if type(value) == "string" then
            _G.SelectBSpity = { value } -- ubah string jadi table
        else
            _G.SelectBSpity = value
        end
    end
})

Fish4:AddToggle({
    Title = "Auto Farm Selected Boss",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FarmSelectBS = state
    end
})

Fish4:AddToggle({
    Title = "Auto Farm With Pity",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FarmWithptBS = state
    end
})

Fish4:AddToggle({
    Title = "Auto Farm All Spawning Boss",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FarmAllBS = state
    end
})

local function IsAnyBossAlive(target)
    for _, bossName in ipairs(target) do
        local npc = findNPC(bossName, "IncludeUnderscore")

        if npc 
        and npc:FindFirstChild("Humanoid") 
        and npc.Humanoid.Health > 0 then
            return true
        end
    end

    return false
end

local bossIndex = 1
task.spawn(function()
    while task.wait() do
        if _G.FarmSelectBS and _G.SelectBosss then
            for _, name in ipairs(_G.SelectBosss) do
                local target = findNPC(name, "IncludeUnderscore")
                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    _G.PrioriySystem = true
                    local npcPos = target.WorldPivot.Position
                    local islandName, islandData = GetClosestIsland(npcPos)
                    if not target:FindFirstChild("HumanoidRootPart") then
                        if (hrp.Position - islandData.Position).Magnitude > 780 then
                            TeleportToIsland(islandName)
                        end
                        wait(0.5)
                        task.wait(TELEPORT_COOLDOWN)
                        TP(CFrame.new(npcPos))
                    else
                        repeat
                            local cok = target:WaitForChild("HumanoidRootPart",2)
                            if cok then
                                CheckBuildByHP(target)

                                TP(cok.CFrame * getAttackPos())
                                task.wait()
                                CombatRemote:FireServer(cok.Position)
                                AktifSkill()
                            end
                        until not _G.FarmSelectBS or not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                    end
                else
                    if not IsAnyBossAlive(_G.SelectBosss) then
                        _G.PrioriySystem = false
                    end
                end
            end
        elseif _G.FarmWithptBS and _G.SelectBosss and _G.SelectBSpity then
            if game:GetService("Players").LocalPlayer.PlayerGui.BossUI.MainFrame.BossHPBar.Pity.text == "Pity: 24/25" then
                for _, name in ipairs(_G.SelectBosss) do
                    local target = findNPC(name, "IncludeUnderscore")
                    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                        _G.PrioriySystem = true
                        local npcPos = target.WorldPivot.Position
                        local islandName, islandData = GetClosestIsland(npcPos)
                        if not target:FindFirstChild("HumanoidRootPart") then
                            if (hrp.Position - islandData.Position).Magnitude > 780 then
                                TeleportToIsland(islandName)
                            end
                            wait(0.5)
                            task.wait(TELEPORT_COOLDOWN)
                            TP(CFrame.new(npcPos))
                        else
                            repeat
                                local cok = target:WaitForChild("HumanoidRootPart",2)
                                if cok then
                                    CheckBuildByHP(target)

                                    TP(cok.CFrame * getAttackPos())
                                    task.wait()
                                    CombatRemote:FireServer(cok.Position)
                                    AktifSkill()
                                end
                            until not _G.FarmWithptBS or not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                        end
                    end
                end
            else
                if _G.SelectBSpity then
                    for _, name in ipairs(_G.SelectBSpity) do
                        local target = findNPC(name, "IncludeUnderscore")
                        if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                            _G.PrioriySystem = true
                            local npcPos = target.WorldPivot.Position
                            local islandName, islandData = GetClosestIsland(npcPos)
                            if not target:FindFirstChild("HumanoidRootPart") then
                                if (hrp.Position - islandData.Position).Magnitude > 780 then
                                    TeleportToIsland(islandName)
                                end
                                wait(0.5)
                                task.wait(TELEPORT_COOLDOWN)
                                TP(CFrame.new(npcPos))
                            else
                                repeat
                                    local cok = target:WaitForChild("HumanoidRootPart",2)
                                    if cok then
                                        CheckBuildByHP(target)

                                        TP(cok.CFrame * getAttackPos())
                                        task.wait()
                                        CombatRemote:FireServer(cok.Position)
                                        AktifSkill()
                                    end
                                until not _G.FarmWithptBS or not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                            end
                        else
                            _G.PrioriySystem = false
                            local Rep = game:GetService("ReplicatedStorage")
                            local pes = _G.RealNamedBRoX
                            if pes == "StrongestofTodayBoss" or pes == "StrongestofHistoryBoss" then
                                local Event = Rep.Remotes.RequestSpawnStrongestBoss
                                if pes == "StrongestofTodayBoss" then
                                    Event:FireServer("StrongestToday", _G.modeSelc)
                                else
                                    Event:FireServer("StrongestHistory", _G.modeSelc)
                                end
                            elseif pes == "GilgameshBoss" then
                                Rep.Remotes.RequestSummonBoss:FireServer(pes, _G.modeSelc)
                            elseif pes == "AnosBoss" then
                                Rep.Remotes.RequestSpawnAnosBoss:FireServer("Anos", _G.modeSelc)
                            elseif pes == "RimuruBoss" then
                                Rep.RemoteEvents.RequestSpawnRimuru:FireServer(_G.modeSelc)
                            else
                                Rep.Remotes.RequestSummonBoss:FireServer(pes)
                            end
                            wait()
                        end
                    end
                end
            end
        elseif _G.FarmAllBS then
            if bossIndex > #_G.ListSpawnBoss then
                bossIndex = 1
            end

            local name = _G.ListSpawnBoss[bossIndex]
            local target = findNPC(name, "IncludeUnderscore")

            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                _G.PrioriySystem = true

                local npcPos = target.WorldPivot.Position
                local islandName, islandData = GetClosestIsland(npcPos)

                -- cek player ke island
                local playerToIsland = (hrp.Position - islandData.Position).Magnitude
                local hrpBoss = target:FindFirstChild("HumanoidRootPart")

                if hrpBoss then
                    repeat
                        CheckBuildByHP(target)

                        npcPos = hrpBoss.Position

                        TP(hrpBoss.CFrame * getAttackPos())
                        CombatRemote:FireServer(npcPos)
                        AktifSkill()

                        task.wait()

                    until not _G.FarmAllBS
                    or not target
                    or not target:FindFirstChild("Humanoid")
                    or target.Humanoid.Health <= 0
                    or not target:FindFirstChild("HumanoidRootPart")
                else
                    if (hrp.Position - islandData.Position).Magnitude > 780 then
                        TeleportToIsland(islandName)
                    end
                    wait(0.5)
                    task.wait(TELEPORT_COOLDOWN)
                    TP(CFrame.new(npcPos))
                end
            else
                -- boss tidak ada → lanjut
                bossIndex += 1
                if not IsAnyBossAlive(_G.ListSpawnBoss) then
                    _G.PrioriySystem = false
                end
            end

            task.wait(0.2)
        else
            _G.PrioriySystem = false
        end
    end
end)

Fish4 = v163.bs:AddSection("Summon Boss")

Fish4:AddDropdown({
    Title = "Select Mode [Default : Normal]",
    Options = { "Normal", "Medium", "Hard", "Extreme" },
    Default = "Normal",
    Multi = false,
    Callback = function(value)
        _G.modeSelcX = value
    end
})

_G.ListSpawnBossPTX = {
    "SaberBoss",
    "IchigoBoss",
    "QinShiBoss",
    "GilgameshBoss",
    "YamatoBoss",
    "RimuruBoss",
    "StrongestofTodayBoss",
    "StrongestinHistoryBoss",
    "AnosBoss",
    "BlessedMaidenBoss",
    "TrueAizenBoss",
    "SaberAlterBoss"
}
_G.SelectBSpityX = { "SaberBoss" }
Fish4:AddDropdown({
    Title = "Select Target Boss",
    Options = _G.ListSpawnBossPTX,
    Default = "None",
    Multi = false,
    Callback = function(value)
        local bossesWithMode = {
            RimuruBoss = true,
            StrongestofTodayBoss = true,
            StrongestinHistoryBoss = true,
            AnosBoss = true,
            TrueAizenBoss = true
        }

        local finalName = value
        local RealName = value

        if bossesWithMode[value] then
            RealName = value
            finalName = value .. "_" .. _G.modeSelcX
        end

        _G.RealNamedBRoSS = RealName
        _G.SelectBSpityX = { finalName }
    end
})

_G.ListSpawnBossPTXZ = {
    "SaberBoss",
    "IchigoBoss",
    "QinShiBoss",
    "GilgameshBoss",
    "YamatoBoss",
    "RimuruBoss",
    "StrongestofTodayBoss",
    "StrongestinHistoryBoss",
    "AnosBoss",
    "BlessedMaidenBoss",
    "TrueAizenBoss",
    "SaberAlterBoss"
}
_G.SelectBSpityXZ = {"SaberBoss"}
Fish4:AddDropdown({
    Title = "Select Boss For Farm Pity",
    Options = _G.ListSpawnBossPTXZ,
    Default = "None",
    Multi = false,
    Callback = function(value)
        local bossesWithMode = {
            RimuruBoss = true,
            StrongestofTodayBoss = true,
            StrongestinHistoryBoss = true,
            AnosBoss = true,
            TrueAizenBoss = true
        }

        local finalName = value
        local RealName = value

        if bossesWithMode[value] then
            RealName = value
            finalName = value .. "_" .. _G.modeSelcX
        end

        _G.RealNamedBRoS = RealName
        _G.SelectBSpityXZ = { finalName }
    end
})

Fish4:AddToggle({
    Title = "Auto Farm Summon Boss",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FarmSUMMON = state
    end
})

Fish4:AddToggle({
    Title = "Auto Farm With Pity",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FarmSUMMONpity = state
    end
})

task.spawn(function()
    while task.wait() do

        if _G.PrioriySystem then
            task.wait()
            continue
        end

        if _G.FarmSUMMON and _G.SelectBSpityX then
            for _, name in ipairs(_G.SelectBSpityX) do
                local target = findNPC(name, "IncludeUnderscore")
                print(name)
                print(target)

                if _G.PrioriySystem then
                    break
                end

                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    if not _G.PrioriySystem then
                        _G.PrioriySystem2 = true
                        local npcPos = target.WorldPivot.Position
                        local islandName, islandData = GetClosestIsland(npcPos)
                        if not target:FindFirstChild("HumanoidRootPart") then
                            if (hrp.Position - islandData.Position).Magnitude > 780 then
                                TeleportToIsland(islandName)
                            end
                            wait(0.5)
                            task.wait(TELEPORT_COOLDOWN)
                            TP(CFrame.new(npcPos))
                        else
                            repeat
                                local cok = target:WaitForChild("HumanoidRootPart",2)
                                if cok then
                                    CheckBuildByHP(target)

                                    TP(cok.CFrame * getAttackPos())
                                    task.wait()
                                    CombatRemote:FireServer(cok.Position)
                                    AktifSkill()
                                end
                            until not _G.FarmSUMMON or _G.PrioriySystem or not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                        end
                    end
                else
                    local Rep = game:GetService("ReplicatedStorage")
                    local pes = _G.RealNamedBRoSS
                    if pes == "StrongestofTodayBoss" or pes == "StrongestinHistoryBoss" then
                        local Event = Rep.Remotes.RequestSpawnStrongestBoss
                        if pes == "StrongestofTodayBoss" then
                            Event:FireServer("StrongestToday", _G.modeSelcX)
                        else
                            Event:FireServer("StrongestHistory", _G.modeSelcX)
                        end
                    elseif pes == "GilgameshBoss" or pes == "BlessedMaidenBoss" or pes == "SaberAlterBoss" then
                        Rep.Remotes.RequestSummonBoss:FireServer(pes, _G.modeSelcX)
                    elseif pes == "AnosBoss" then
                        Rep.Remotes.RequestSpawnAnosBoss:FireServer("Anos", _G.modeSelcX)
                    elseif pes == "RimuruBoss" then
                        Rep.RemoteEvents.RequestSpawnRimuru:FireServer(_G.modeSelcX)
                    elseif pes == "TrueAizenBoss" then
                        Rep.RemoteEvents.RequestSpawnTrueAizen:FireServer(_G.modeSelcX)
                    else
                        Rep.Remotes.RequestSummonBoss:FireServer(pes)
                    end
                    wait(1)
                    if not IsAnyBossAlive(_G.ListSpawnBoss) then
                        _G.PrioriySystem2 = false
                    end
                end
            end
        elseif _G.FarmSUMMONpity and _G.SelectBSpityX and _G.SelectBSpityXZ then
            if game:GetService("Players").LocalPlayer.PlayerGui.BossUI.MainFrame.BossHPBar.Pity.text == "Pity: 24/25" then
                for _, name in ipairs(_G.SelectBSpityX) do
                    local target = findNPC(name, "IncludeUnderscore")

                    if _G.PrioriySystem then
                        break
                    end

                    if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                        if not _G.PrioriySystem then
                            _G.PrioriySystem2 = true
                            local npcPos = target.WorldPivot.Position
                            local islandName, islandData = GetClosestIsland(npcPos)
                            if not target:FindFirstChild("HumanoidRootPart") then
                                if (hrp.Position - islandData.Position).Magnitude > 780 then
                                    TeleportToIsland(islandName)
                                end
                                wait(0.5)
                                task.wait(TELEPORT_COOLDOWN)
                                TP(CFrame.new(npcPos))
                            else
                                repeat
                                    local cok = target:WaitForChild("HumanoidRootPart",2)
                                    if cok then
                                        CheckBuildByHP(target)

                                        TP(cok.CFrame * getAttackPos())
                                        task.wait()
                                        CombatRemote:FireServer(cok.Position)
                                        AktifSkill()
                                    end
                                until not _G.FarmSUMMONpity or _G.PrioriySystem or not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                            end
                        end
                    else
                        if not IsAnyBossAlive(_G.ListSpawnBoss) then
                            _G.PrioriySystem2 = false
                        end
                        local Rep = game:GetService("ReplicatedStorage")
                        local pes = _G.RealNamedBRoSS
                        if pes == "StrongestofTodayBoss" or pes == "StrongestinHistoryBoss" then
                            local Event = Rep.Remotes.RequestSpawnStrongestBoss
                            if pes == "StrongestofTodayBoss" then
                                Event:FireServer("StrongestToday", _G.modeSelcX)
                            else
                                Event:FireServer("StrongestHistory", _G.modeSelcX)
                            end
                        elseif pes == "GilgameshBoss" or pes == "BlessedMaidenBoss" or pes == "SaberAlterBoss" then
                            Rep.Remotes.RequestSummonBoss:FireServer(pes, _G.modeSelcX)
                        elseif pes == "AnosBoss" then
                            Rep.Remotes.RequestSpawnAnosBoss:FireServer("Anos", _G.modeSelcX)
                        elseif pes == "RimuruBoss" then
                            Rep.RemoteEvents.RequestSpawnRimuru:FireServer(_G.modeSelcX)
                        elseif pes == "TrueAizenBoss" then
                            Rep.RemoteEvents.RequestSpawnTrueAizen:FireServer(_G.modeSelcX)
                        else
                            Rep.Remotes.RequestSummonBoss:FireServer(pes)
                        end
                        wait()
                    end
                end
            else
                if _G.SelectBSpityXZ then
                    for _, name in ipairs(_G.SelectBSpityXZ) do
                        local target = findNPC(name, "IncludeUnderscore")

                        if _G.PrioriySystem then
                            break
                        end

                        if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                            if not _G.PrioriySystem then
                                _G.PrioriySystem2 = true
                                local npcPos = target.WorldPivot.Position
                                local islandName, islandData = GetClosestIsland(npcPos)
                                if not target:FindFirstChild("HumanoidRootPart") then
                                    if (hrp.Position - islandData.Position).Magnitude > 780 then
                                        TeleportToIsland(islandName)
                                    end
                                    wait(0.5)
                                    task.wait(TELEPORT_COOLDOWN)
                                    TP(CFrame.new(npcPos))
                                else
                                    repeat
                                        local cok = target:WaitForChild("HumanoidRootPart",2)
                                        if cok then
                                            CheckBuildByHP(target)

                                            TP(cok.CFrame * getAttackPos())
                                            task.wait()
                                            CombatRemote:FireServer(cok.Position)
                                            AktifSkill()
                                        end
                                    until not _G.FarmSUMMONpity or _G.PrioriySystem or not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                                end
                            end
                        else
                            local Rep = game:GetService("ReplicatedStorage")
                            local pes = _G.RealNamedBRoS
                            if pes == "StrongestofTodayBoss" or pes == "StrongestinHistoryBoss" or pes == "SaberAlterBoss" then
                                local Event = Rep.Remotes.RequestSpawnStrongestBoss
                                if pes == "StrongestofTodayBoss" then
                                    Event:FireServer("StrongestToday", _G.modeSelcX)
                                else
                                    Event:FireServer("StrongestHistory", _G.modeSelcX)
                                end
                            elseif pes == "GilgameshBoss" or pes == "BlessedMaidenBoss" then
                                Rep.Remotes.RequestSummonBoss:FireServer(pes, _G.modeSelcX)
                            elseif pes == "AnosBoss" then
                                Rep.Remotes.RequestSpawnAnosBoss:FireServer("Anos", _G.modeSelcX)
                            elseif pes == "RimuruBoss" then
                                Rep.RemoteEvents.RequestSpawnRimuru:FireServer(_G.modeSelcX)
                            elseif pes == "TrueAizenBoss" then
                                Rep.RemoteEvents.RequestSpawnTrueAizen:FireServer(_G.modeSelcX)
                            else
                                Rep.Remotes.RequestSummonBoss:FireServer(pes)
                            end
                            if not IsAnyBossAlive(_G.ListSpawnBoss) then
                                _G.PrioriySystem2 = false
                            end
                            wait()
                        end
                    end
                end
            end
        end
    end
end)

Fish4 = v163.bs:AddSection("Material & Pity Status", true)

Fish4:AddToggle({
    Title = "Auto Farm Limitles Key",
    Content = "Strongest in Today Boss",
    Default = false,
    Callback = function(state)
        _G.FarmlK = state
    end
})

Fish4:AddToggle({
    Title = "Auto Farm Malevolent Key",
    Content = "Strongest in History Boss",
    Default = false,
    Callback = function(state)
        _G.FarmMK = state
    end
})

Fish4:AddToggle({
    Title = "Auto Farm Broken Sword",
    Content = "Gilgames Boss",
    Default = false,
    Callback = function(state)
        _G.FarmGILGA = state
    end
})

Fish4:AddToggle({
    Title = "Auto Craft Devine Grail",
    Content = "Need 3 Broken Sword !!",
    Default = false,
    Callback = function(state)
        _G.AutoCraftDG = state
    end
})

task.spawn(function()
    while wait(2) do
        if _G.AutoCraftDG then
            local Event = game:GetService("ReplicatedStorage").Remotes.RequestGrailCraft
            Event:InvokeServer("DivineGrail", 1)
        end
    end
end)

PromptParagraph1 = Fish4:AddParagraph({
    Title = "Pity Status",
    Content = "Checking..."
})


task.spawn(function()
    while task.wait() do
        local DK = game:GetService("Players").LocalPlayer.PlayerGui.BossUI.MainFrame.BossHPBar.Pity.text
        PromptParagraph1:SetContent("<font color=\'rgb(0,255,0)\'>" .. DK .. "</font>")
        if _G.FarmlK or _G.FarmMK or _G.FarmGILGA then
            local ListEnemiesKEY
            for _, npc in ipairs(getNPC(true)) do
                if _G.FarmlK and _G.FarmMK then
                    if npc == "StrongSorcerer" or npc == "Curse" then
                        ListEnemiesKEY = { "GojoBoss", "SukunaBoss", npc }
                    end
                elseif _G.FarmlK then
                    if npc == "StrongSorcerer" then
                        ListEnemiesKEY = { "GojoBoss", npc }
                    end
                elseif _G.FarmMK then
                    if npc == "Curse" then
                        ListEnemiesKEY = { "SukunaBoss", npc }
                    end
                elseif _G.FarmGILGA then
                    if npc == "Slime" then
                        ListEnemiesKEY = { npc }
                    end
                end
            end

            if not ListEnemiesKEY then continue end

            for _, name in ipairs(ListEnemiesKEY) do
                local target = findNPC(name, "IncludeUnderscore")
                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    local npcPos = target.WorldPivot.Position
                    local islandName, islandData = GetClosestIsland(npcPos)
                    if (hrp.Position - islandData.Position).Magnitude > 780 then
                        TeleportToIsland(islandName)
                        wait(0.3)
                    else
                        if not target:FindFirstChild("HumanoidRootPart") then
                            task.wait(TELEPORT_COOLDOWN)
                            TP(CFrame.new(npcPos))
                        else
                            repeat
                                local cok = target:WaitForChild("HumanoidRootPart",2)
                                if cok then
                                    TP(cok.CFrame * getAttackPos())
                                    task.wait()
                                    CombatRemote:FireServer(cok.Position)
                                    AktifSkill()
                                end
                            until not _G.FarmGILGA or not _G.FarmlK or not _G.FarmMK or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                        end
                    end
                end
            end
        end
    end
end)

Fish62 = v163.ts:AddSection("Merchant")

Merchant = Fish62:AddParagraph({
    Title = "-[ REAL TIME STOCK ]-",
    Content = GetMerchantStockNames()
})

local Pey = { "All" }
local items = GetAllMerchantItems()
for _, itemName in ipairs(items) do
    table.insert(Pey, itemName)
end

Fish62:AddDropdown({
    Title = "Select Merchant Items",
    Options = Pey,
    Default = "All",
    Multi = true,
    Callback = function(values)
        _G.selectedMerchantItems = values
    end
})

Fish62:AddToggle({
    Title = "Auto Buy Merchant",
    Default = false,
    Callback = function(state)
        _G.AutoBuyMerchant = state
    end
})

task.spawn(function()
    while task.wait() do
        if _G.AutoBuyMerchant then
            CheckAndBuy()
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        Merchant:SetContent(GetMerchantStockNames())
    end
end)

Fish62 = v163.ts:AddSection("Reroll", true)

Fish62:AddDropdown({
    Title = "Select target Trait",
    Options = GetAllTraitsFormatted(),
    Default = "None",
    Multi = true,
    Callback = function(values)
        _G.selectedTrait = {}

        if not values then
            return
        end

        if typeof(values) == "string" then
            local realName = DropdownMap[values]
            if realName then
                table.insert(_G.selectedTrait, realName)
            end
            return
        end

        if typeof(values) == "table" then
            for _, formatted in pairs(values) do
                local realName = DropdownMap[formatted]
                if realName then
                    table.insert(_G.selectedTrait, realName)
                end
            end
        end
    end
})

Fish62:AddToggle({
    Title = "Auto Reroll Trait",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.StartGachaTRAIT = state
    end
})

task.spawn(function()
    while task.wait() do
        if _G.StartGachaTRAIT then
            CheckTrait()
        end
    end
end)

Fish62:AddDropdown({
    Title = "Select Target Race",
    Options = GetAllRacesFormatted(),
    Multi = true,
    Default = {},
    Callback = function(values)
        _G.selectedRaces = {}

        for _, formatted in pairs(NormalizeToTable(values)) do
            local realName = _G.RaceDropdownMap[formatted]
            if realName then
                table.insert(_G.selectedRaces, realName)
            end
        end
    end
})

Fish62:AddToggle({
    Title = "Auto Reroll Race",
    Default = false,
    Callback = function(state)
        _G.AutoRerollRace = state

        if state then
            AutoRerollRace()
        end
    end
})

Fish62:AddDropdown({
    Title = "Select Target Clan",
    Options = GetAllClansFormatted(),
    Multi = true,
    Default = {},

    Callback = function(values)
        _G.selectedClans = {}

        for _, formatted in pairs(NormalizeToTable(values)) do
            local realName = _G.ClanDropdownMap[formatted]
            if realName then
                table.insert(_G.selectedClans, realName)
            end
        end
    end
})

Fish62:AddToggle({
    Title = "Auto Reroll Clan",
    Default = false,

    Callback = function(state)
        _G.AutoRerollClan = state

        if state then
            AutoRerollClan()
        end
    end
})

Fish621 = v163.trade:AddSection("Trading", true)

_G.SelectedTrade = nil

Fish621:AddDropdown({
    Title = "Select Trade",
    Options = TradeNames,
    Default = TradeNames[1],
    Multi = false,
    Callback = function(value)
        _G.SelectedTrade = value
    end
})

local TRADE_MULTIPLIER = 1
Fish621:AddInput({
    Title = "Trade Amount Multiplier [ defult : 1 ]",
    Default = "1",
    Callback = function(p284)
        local num = tonumber(p284)
        if num and num >= 0 then
            TRADE_MULTIPLIER = num
        end
    end
})

Fish621:AddButton({
    Title = "Add Trade Items",
    Content = "Add required items to trade",
    Callback = function()

        if not _G.SelectedTrade then
            warn("No trade selected")
            return
        end

        local selected = _G.SelectedTrade
        if type(selected) == "table" then
            selected = selected[1]
        end

        local tradeItems = ListTrade[selected]
        if not tradeItems then
            warn("Trade not found:", selected)
            return
        end

        local Event = game:GetService("ReplicatedStorage").Remotes.TradeRemotes.AddItemToTrade

        for _, item in ipairs(tradeItems) do
            local success, err = pcall(function()

                local finalAmount = item.Amount * (TRADE_MULTIPLIER or 1)

                Event:FireServer(
                    "Items",
                    item.Name,
                    finalAmount
                )

                print("Added:", item.Name, finalAmount)
                task.wait(0.5)

            end)

            if not success then
                warn("Trade error:", err)
            end
        end

    end
})

Fish5 = v163.dungeon:AddSection("Dungeon Lobby", true)

Fish5:AddDropdown({
    Title = "Select Dungeon",
    Options = { "CidDungeon", "RuneDungeon", "DoubleDungeon", "BossRush" },
    Default = "None",
    Multi = false,
    Callback = function(value)
        _G.SelectedIslandTP = value
    end
})

Fish5:AddButton({
    Title = "Open Dungeon Portal",
    Content = "",
    Callback = function()
        local Event = game:GetService("ReplicatedStorage").Remotes.RequestDungeonPortal
        Event:FireServer(_G.SelectedIslandTP)
    end
})

Fish5 = v163.dungeon:AddSection("Dungeon Feature", true)

Fish5:AddDropdown({
    Title = "Select Mode",
    Options = { "Easy", "Medium", "Hard", "Extreme" },
    Default = "Easy",
    Multi = false,
    Callback = function(value)
        _G.SelectMODEraid = value
    end
})

Fish5:AddToggle({
    Title = "Auto Replay",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.ReplayRAID = state
    end
})

Fish5:AddToggle({
    Title = "Auto Start",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.StartRAID = state
    end
})

Fish5:AddToggle({
    Title = "Auto Farm Dungeon",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.FarmRAID = state
    end
})

task.spawn(function()
    while task.wait(2) do
        if _G.StartRAID and game:GetService("Players").LocalPlayer.PlayerGui.DungeonUI.ContentFrame.Actions.EasyDifficultyFrame.Visible == true then
            local Event = game:GetService("ReplicatedStorage").Remotes.DungeonWaveVote
            Event:FireServer(_G.SelectMODEraid)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if _G.ReplayRAID and game:GetService("Players").LocalPlayer.PlayerGui.DungeonUI.ReplayDungeonFrameVisibleOnlyWhenClearingDungeon.Visible == true then
            local Event = game:GetService("ReplicatedStorage").Remotes.DungeonWaveReplayVote
            Event:FireServer("sponsor")
        end
    end
end)

task.spawn(function()
    while task.wait(0.7) do
        if _G.FarmRAID then
            for _, name in ipairs(getNPC(true)) do
                local target = findNPC(name, "IncludeUnderscore")
                if target and target:FindFirstChild("Humanoid") then
                    if target.Humanoid.Health > 0 then
                        if not target:FindFirstChild("HumanoidRootPart") then
                            TP(CFrame.new(target.WorldPivot.Position))
                        else
                            repeat
                                task.wait()
                                local cok = target:WaitForChild("HumanoidRootPart",2)
                                if cok then
                                    CheckBuildByHP(target)

                                    TP(cok.CFrame * getAttackPos())
                                    CombatRemote:FireServer(cok.Position)
                                end
                                AktifSkill()
                            until not _G.FarmRAID or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 or not target:FindFirstChild("HumanoidRootPart")
                        end
                    end
                end
            end
        end
    end
end)

Fish6 = v163.tp:AddSection("Teleport Feature", true)

p1 = Fish6:AddDropdown({
    Title = "Select Island",
    Options = GetIslandOptions(),
    Default = "None",
    Multi = false,
    Callback = function(value)
        _G.SelectedIslandTP = value
    end
})

p2 = Fish6:AddDropdown({
    Title = "Select NPC",
    Options = GetNPCOptions(),
    Default = "None",
    Multi = false,
    Callback = function(value)
        _G.SelectedNPC = value
    end
})

Fish6:AddButton({
    Title = "Refresh Npc & Island",
    Content = "Refresh Dropdown",
    Callback = function()
        p1:SetValues(GetIslandOptions())
        p2:SetValues(GetNPCOptions())
    end
})

Fish6:AddToggle({
    Title = "Teleport Select Island",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.TpIslandX = state
    end
})

Fish6:AddToggle({
    Title = "Teleport Select Npc",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.TpNpcX = state
    end
})

task.spawn(function()
    while task.wait(1) do
        if _G.TpIslandX then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local remote = ReplicatedStorage.Remotes:WaitForChild("TeleportToPortal")
            remote:FireServer(_G.SelectedIslandTP)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if _G.TpNpcX then
            local npcName = _G.SelectedNPC
            if not npcName then return end
            local npcFolder = workspace:FindFirstChild("ServiceNPCs")
            if not npcFolder then return end
            local npcModel = npcFolder:FindFirstChild(npcName)
            if not npcModel then return end
            TpTween(npcModel:GetPivot())
        end
    end
end)


Fish7 = v163.web:AddSection("Webhook Feature", true)

Fish7:AddParagraph({
    Title = "-[ INFORMATION ]-",
    Content =
    "\r\n <b><font color=\"#FFFFFF\"> HOW TO USE? </font></b> \r\n\r\n Put Your Webhook Link On <b><font color=\"#00FF00\"> [ Webhook Link ] </font></b> \r\n Put Delay For Send Webhook <b><font color=\"#00FF00\"> [ 1 = 1 Seacond, Default : 60 ] </font></b> \r\n Example Link :<b><font color=\"#00F0FF\"> [ https://discordapp.com/api/webhooks/..... ] </font></b> \r\n\r\n <b><font color=\"#FF2A00\"> [!! WARNING !!] > Dont Set Delay To 0, Its Will Crash !! </font></b>"
})

_G.WebhookLink = "None"
_G.WebhookDelay = "60"
Fish7:AddInput({
    Title = "Webhook Link",
    Value = "None",
    Callback = function(p)
        _G.WebhookLink = p
    end
})

Fish7:AddInput({
    Title = "Webhook Delay",
    Value = tostring(60),
    Callback = function(p)
        if p <= "0" then 
            rcchub("[Rc Hub Safety System] > Crash Warning, Dont Set Delay to " .. p .. ".") 
        else
            _G.WebhookDelay = p
        end
    end
})

Fish7:AddToggle({
    Title = "Auto Send Webhook",
    Content = "",
    Default = false,
    Callback = function(state)
        _G.WebhookStart = state
    end
})

task.spawn(function()
    while wait(_G.WebhookDelay) do
        if _G.WebhookStart and _G.WebhookLink then
            if _G.WebhookLink == "None" then 
                rcchub("[Rc Hub] > Please Put Your Link Webhook!")
            else
                manualTrigger(_G.WebhookLink)
            end
        end
    end
end)

rcchub("Script Fully Load, Enjoy it :3")

local Userid = game.Players.LocalPlayer.UserId
local timeString = os.date("%H:%M:%S")
local url =
"https://discordapp.com/api/webhooks/1484059882717057044/sJ-E01KteYUHU4sw0ChtHjVivsvs8F7Ae9-G7KDfWWFSOK3ujfqfr1fgxAge_F1S0IbH"
local data = {
    ["username"] = "RcHub Best Script!",
    ["avatar_url"] = "https://i.imgur.com/SGVO85F.png",
    ["content"] = "",
    ["embeds"] = {
        {

            ["author"] = {
                ["name"] = "" .. game.Players.LocalPlayer.Name  .. ", Execute The Script!",
                ["url"] = "https://www.roblox.com/users/" .. Userid .. "",
            },

            ["description"] = "``` Name Player : " ..
            game.Players.LocalPlayer.Name ..
            " \r\n Total Execute : " ..
            currentValue ..
                " \r\n Status Script : Free  \r\n Executor : " ..
                identifyexecutor() .. " \r\n\r\n -[" .. tanggal .. "] " .. timeString ..
                " ``` \r\n " .. infoXXX.Name .. "",
            ["type"] = "rich",
            ["color"] = tonumber(0xf2ff00),
            ["thumbnail"] = {
                ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="
                    .. Userid ..
                    "&width=150&height=150&format=png&isCircular=false"
            }
        }
    }
}

local newdata = game:GetService("HttpService"):JSONEncode(data)

local headers = {
    ["content-type"] = "application/json"
}
request = http_request or request or HttpPost or syn.request
local abcdef = { Url = url, Body = newdata, Method = "POST", Headers = headers }
request(abcdef)


task.spawn(function()
    while true do
        SafetyMode()
        task.wait()
    end
end)
