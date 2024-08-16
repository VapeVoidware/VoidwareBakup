repeat task.wait() until shared.run

local run = shared.run
local GuiLibrary = shared.GuiLibrary
local store = shared.GlobalStore
local bedwars = shared.GlobalBedwars
local entityLibrary = shared.vapeentity
local RunLoops = shared.RunLoops
local VoidwareStore = {
	bedtable = {},
	Tweening = false
}
local gameCamera = workspace.CurrentCamera

local lplr = game:GetService("Players").LocalPlayer

local btext = function(text)
	return text .. ' '
end
local void = function() end
local runservice = game:GetService("RunService")
local newcolor = function() return {Hue = 0, Sat = 0, Value = 0} end
function safearray()
    local array = {}
    local mt = {}
    function mt:__index(index)
        if type(index) == "number" and (index < 1 or index > #array) then
            return nil
        end
        return array[index]
    end
    function mt:__newindex(index, value)
        if type(index) == "number" and index > 0 then
            array[index] = value
        else
            error("Invalid index for safearray", 2)
        end
    end
    function mt:insert(value)
        table.insert(array, value)
    end
    function mt:remove(index)
        if type(index) == "number" and index > 0 and index <= #array then
            table.remove(array, index)
        else
            error("Invalid index for safearray removal", 2)
        end
    end
    function mt:length()
        return #array
	end
    setmetatable(array, mt)
    return array
end
function getrandomvalue(list)
    local count = #list
    if count == 0 then
        return ''
    end
    local randomIndex = math.random(1, count)
    return list[randomIndex]
end

local vapeConnections
if shared.vapeConnections and type(shared.vapeConnections) == "table" then vapeConnections = shared.vapeConnections else vapeConnections = {} shared.vapeConnections = vapeConnections end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

task.spawn(function()
    pcall(function()
        local lplr = game:GetService("Players").LocalPlayer
        local char = lplr.Character or lplr.CharacterAdded:wait()
        local displayName = char:WaitForChild("Head"):WaitForChild("Nametag"):WaitForChild("DisplayNameContainer"):WaitForChild("DisplayName")
        repeat task.wait() until shared.vapewhitelist
        repeat task.wait() until shared.vapewhitelist.loaded
        local tag = shared.vapewhitelist:tag(lplr, "", true)
        if displayName.ClassName == "TextLabel" then
            if not displayName.RichText then displayName.RichText = true end
            displayName.Text = tag..lplr.Name
        end
        displayName:GetPropertyChangedSignal("Text"):Connect(function()
            if displayName.Text ~= tag..lplr.Name then
                displayName.Text = tag..lplr.Name
            end
        end)
    end)
end)

local GetEnumItems = function() return {} end
	GetEnumItems = function(enum)
		local fonts = {}
		for i,v in next, Enum[enum]:GetEnumItems() do 
			table.insert(fonts, v.Name) 
		end
		return fonts
	end

--[[run(function()
	local ChosenPack = {Value = "Realistic Pack"}
	local TexturePacks = {Enabled = false}
	TexturePacks = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = "Texture Packs",
		HoverText = "Replaces the boring sword with a better texture pack.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0
					local function killPlayer(player)
						local character = player.Character
						if character then
							local humanoid = character:FindFirstChildOfClass("Humanoid")
							if humanoid then
								humanoid.Health = 0
							end
						end
					end
					local canRespawn = function() end
					canRespawn = function()
						local success, response = pcall(function() 
							return lplr.leaderstats.Bed.Value == '✅' 
						end)
						return success and response 
					end
					warningNotification("Texture packs", "Reset for the pack to work", 3)
					--if canRespawn() then warningNotification("Texture packs", "Resetting for the texture to get applied", 5) killPlayer(lplr) else warningNotification("Texture packs", "Unable to reset your chatacter! Please do it manually", 3) end
					TexturePacks.Enabled = false 
					TexturePacks.Enabled = true 
					if ChosenPack.Value == "Realistic Pack" then
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14431940695"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "32x Pack" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14421314747"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "16x Pack" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14474879594"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					elseif ChosenPack.Value == "Garbage" then 
						local Services = {
							Storage = game:GetService("ReplicatedStorage"),
							Workspace = game:GetService("Workspace"),
							Players = game:GetService("Players")
						}
						
						local ASSET_ID = "rbxassetid://14336548540"
						local PRIMARY_ROTATION = CFrame.Angles(0, -math.pi/4, 0)
						
						local ToolMaterials = {
							sword = {"wood", "stone", "iron", "diamond", "emerald"},
							pickaxe = {"wood", "stone", "iron", "diamond"},
							axe = {"wood", "stone", "iron", "diamond"}
						}
						
						local Offsets = {
							sword = CFrame.Angles(0, -math.pi/2, -math.pi/2),
							pickaxe = CFrame.Angles(0, -math.pi, -math.pi/2),
							axe = CFrame.Angles(0, -math.pi/18, -math.pi/2)
						}
						
						local ToolIndex = {}
						
						local function initializeToolIndex(asset)
							for toolType, materials in pairs(ToolMaterials) do
								for _, material in ipairs(materials) do
									local identifier = material .. "_" .. toolType
									local toolModel = asset:FindFirstChild(identifier)
						
									if toolModel then
										--print("Found tool in initializeToolIndex:", identifier)
										table.insert(ToolIndex, {
											Name = identifier,
											Offset = Offsets[toolType],
											Model = toolModel
										})
									else
										--warn("Model for " .. identifier .. " not found in initializeToolIndex!")
									end
								end
							end
						end
						
						local function adjustAppearance(part)
							if part:IsA("BasePart") then
								part.Transparency = 1
							end
						end
						
						local function attachModel(target, data, modifier)
							local clonedModel = data.Model:Clone()
							clonedModel.CFrame = target:FindFirstChild("Handle").CFrame * data.Offset * PRIMARY_ROTATION * (modifier or CFrame.new())
							clonedModel.Parent = target
						
							local weld = Instance.new("WeldConstraint", clonedModel)
							weld.Part0 = clonedModel
							weld.Part1 = target:FindFirstChild("Handle")
						end
						
						local function processTool(tool)
							if not tool:IsA("Accessory") then return end
						
							for _, toolData in ipairs(ToolIndex) do
								if toolData.Name == tool.Name then
									for _, child in pairs(tool:GetDescendants()) do
										adjustAppearance(child)
									end
									attachModel(tool, toolData)
						
									local playerTool = Services.Players.LocalPlayer.Character:FindFirstChild(tool.Name)
									if playerTool then
										for _, child in pairs(playerTool:GetDescendants()) do
											adjustAppearance(child)
										end
										attachModel(playerTool, toolData, CFrame.new(0.4, 0, -0.9))
									end
								end
							end
						end
						
						
						local loadedTools = game:GetObjects(ASSET_ID)
						local mainAsset = loadedTools[1]
						mainAsset.Parent = Services.Storage
						
						wait(1)
						
						
						for _, child in pairs(mainAsset:GetChildren()) do
							--print("Found tool in asset:", child.Name)
						end
						
						initializeToolIndex(mainAsset)
						Services.Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(processTool)
					end
				end)
			end
		end
	})
	ChosenPack = TexturePacks.CreateDropdown({
        Name = "Pack",
        List = {
            "Realistic Pack",
            "32x Pack",
            "16x Pack",
            "Garbage",
        },
        Function = function() end,
    })
end)--]]

run(function()
	local PlayerLevelSet = {}
	local PlayerLevel = {Value = 100}
	PlayerLevelSet = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'SetPlayerLevel',
		HoverText = 'Sets your player level to 100 (client sided)',
		Function = function(calling)
			if calling then 
				warningNotification("SetPlayerLevel", "This is client sided (only u will see the new level)", 3)
				game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value)
			end
		end
	})
	PlayerLevel = PlayerLevelSet.CreateSlider({
		Name = 'Sets your desired player level',
		Function = function() game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value) end,
		Min = 1,
		Max = 100,
		Default = 100
	})
end)

run(function()
	local QueueCardMods = {}
	local QueueCardGradientToggle = {}
	local QueueCardGradient = {Hue = 0, Sat = 0, Value = 0}
	local QueueCardGradient2 = {Hue = 0, Sat = 0, Value = 0}
	local queuemodsgradients = {}
	local function patchQueueCard()
		if lplr.PlayerGui:FindFirstChild('QueueApp') then 
			if lplr.PlayerGui.QueueApp:WaitForChild('1'):IsA('Frame') then 
				lplr.PlayerGui.QueueApp['1'].BackgroundColor3 = Color3.fromHSV(QueueCardGradient.Hue, QueueCardGradient.Sat, QueueCardGradient.Value)
			end
			if QueueCardGradientToggle.Enabled then 
				lplr.PlayerGui.QueueApp['1'].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = (lplr.PlayerGui.QueueApp['1']:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', lplr.PlayerGui.QueueApp['1']))
				gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(QueueCardGradient.Hue, QueueCardGradient.Sat, QueueCardGradient.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(QueueCardGradient2.Hue, QueueCardGradient2.Sat, QueueCardGradient2.Value))})
				table.insert(queuemodsgradients, gradient)
			end
		end
	end
	QueueCardMods = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'QueueCardMods',
		HoverText = 'Mods the QueueApp at the end of the game.',
		Function = function(calling) 
			if calling then 
				patchQueueCard()
				table.insert(QueueCardMods.Connections, lplr.PlayerGui.ChildAdded:Connect(patchQueueCard))
			end
		end
	})
	QueueCardGradientToggle = QueueCardMods.CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			pcall(function() QueueCardGradient2.Object.Visible = calling end) 
		end
	})
	QueueCardGradient = QueueCardMods.CreateColorSlider({
		Name = 'Color',
		Function = function()
			pcall(patchQueueCard)
		end
	})
	QueueCardGradient2 = QueueCardMods.CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			pcall(patchQueueCard)
		end
	})
	Credits = QueueCardMods.CreateCredits({
		Name = 'CreditsButtonInstance',
        Credits = 'Render'
	})
end)

run(function()
	task.spawn(function()
		pcall(function()
			GuiLibrary.RemoveObject("SetEmoteOptionsButton")
			local SetEmote = {}
			local SetEmoteList = {Value = ''}
			local oldemote
			local emo2 = {}
			local credits
			SetEmote = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
				Name = 'SetEmote',
				HoverText = "Sets your emote",
				Function = function(calling)
					if calling then
						oldemote = lplr:GetAttribute('EmoteTypeSlot1')
						lplr:SetAttribute('EmoteTypeSlot1', emo2[SetEmoteList.Value])
					else
						if oldemote then 
							lplr:GetAttribute('EmoteTypeSlot1', oldemote)
							oldemote = nil 
						end
					end
					table.insert(SetEmote.Connections, lplr.PlayerGui.ChildAdded:Connect(function(v)
						local anim
						if tostring(v) == 'RoactTree' and isAlive(lplr, true) and not emoting then 
							v:WaitForChild('1'):WaitForChild('1')
							if not v['1']:IsA('ImageButton') then 
								return 
							end
							v['1'].Visible = false
							emoting = true
							bedwars.Client:Get('Emote'):CallServer({emoteType = lplr:GetAttribute('EmoteTypeSlot1')})
							local oldpos = lplr.Character.HumanoidRootPart.Position 
							if tostring(lplr:GetAttribute('EmoteTypeSlot1')):lower():find('nightmare') then 
								anim = Instance.new('Animation')
								anim.AnimationId = 'rbxassetid://9191822700'
								anim = lplr.Character.Humanoid.Animator:LoadAnimation(anim)
								task.spawn(function()
									repeat 
										anim:Play()
										anim.Completed:Wait()
									until not anim
								end)
							end
							repeat task.wait() until ((lplr.Character.HumanoidRootPart.Position - oldpos).Magnitude >= 0.3 or not isAlive(lplr, true))
							pcall(function() anim:Stop() end)
							anim = nil
							emoting = false
							bedwars.Client:Get('EmoteCancelled'):CallServer({emoteType = lplr:GetAttribute('EmoteTypeSlot1')})
						end
					end))
				end
			})
			local emo = {}
			for i,v in pairs(bedwars.EmoteMeta) do 
				table.insert(emo, v.name)
				emo2[v.name] = i
			end
			table.sort(emo, function(a, b) return a:lower() < b:lower() end)
			SetEmoteList = SetEmote.CreateDropdown({
				Name = 'Emote',
				List = emo,
				Function = function(emote)
					if SetEmote.Enabled then 
						lplr:SetAttribute('EmoteTypeSlot1', emo2[emote])
					end
				end
			})
		end)
	end)
end)

run(function()
	local lplr = game.Players.LocalPlayer
	local plrgui = lplr.PlayerGui
	local deathscounter = 0
	local regiondisplay = plrgui:WaitForChild("ServerRegionDisplay").ServerRegionText.Text
	local playerded = false 
	local debouncegaming = false
	local SessionInfo = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = "SessionInfo Custom",
		HoverText = "Customizable session info.",
		Function = function(callback)
			if callback then 
				local function extractnumber(text)
					local number = text:match("<b>(%d+)</b>")
					return tonumber(number)
				end
				local function extracttimer(text)
					local minutes, seconds = text:match("<b>(%d+:%d+)</b>")
					return minutes
				end
				local function extractregion(text)
					local region = text:match("REGION:%s*([^<]+)")
					return region
				end
				
				local Converted = {
					["_SessionInfo"] = Instance.new("ScreenGui");
					["_Background"] = Instance.new("Frame");
					["_UICorner"] = Instance.new("UICorner");
					["_SessionInfoLabel"] = Instance.new("TextLabel");
					["_TimePlayed"] = Instance.new("TextLabel");
					["_Kills"] = Instance.new("TextLabel");
					["_Deaths"] = Instance.new("TextLabel");
					["_Region"] = Instance.new("TextLabel");
					["_DropShadowHolder"] = Instance.new("Frame");
					["_DropShadow"] = Instance.new("ImageLabel");
				}
				
				Converted["_SessionInfo"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				Converted["_SessionInfo"].Name = "SessionInfo"
				Converted["_SessionInfo"].Parent = plrgui
				Converted["_SessionInfo"].ResetOnSpawn = false
				
				Converted["_Background"].BackgroundColor3 = Color3.fromHSV(0, 0, 0)
				Converted["_Background"].BackgroundTransparency = 0.800000011920929
				Converted["_Background"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Background"].BorderSizePixel = 0
				Converted["_Background"].Position = UDim2.new(0.0116598075, 0, 0.375, 0)
				Converted["_Background"].Size = UDim2.new(0.128257886, 0, 0.16310975, 0)
				Converted["_Background"].Name = "Background"
				Converted["_Background"].Parent = Converted["_SessionInfo"]
				
				Converted["_UICorner"].Parent = Converted["_Background"]
				
				Converted["_SessionInfoLabel"].Font = Enum.Font.SourceSansBold
				Converted["_SessionInfoLabel"].Text = "Session Info"
				Converted["_SessionInfoLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SessionInfoLabel"].TextScaled = true
				Converted["_SessionInfoLabel"].TextSize = 14
				Converted["_SessionInfoLabel"].TextWrapped = true
				Converted["_SessionInfoLabel"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_SessionInfoLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_SessionInfoLabel"].BackgroundTransparency = 1
				Converted["_SessionInfoLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_SessionInfoLabel"].BorderSizePixel = 0
				Converted["_SessionInfoLabel"].Position = UDim2.new(0.0374331549, 0, 0, 0)
				Converted["_SessionInfoLabel"].Size = UDim2.new(1, 0, 0.242990658, 0)
				Converted["_SessionInfoLabel"].Name = "SessionInfoLabel"
				Converted["_SessionInfoLabel"].Parent = Converted["_Background"]
				
				Converted["_TimePlayed"].Font = Enum.Font.SourceSans
				Converted["_TimePlayed"].Text = "Time Played: 00:00" 
				Converted["_TimePlayed"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_TimePlayed"].TextScaled = true
				Converted["_TimePlayed"].TextSize = 14
				Converted["_TimePlayed"].TextWrapped = true
				Converted["_TimePlayed"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_TimePlayed"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_TimePlayed"].BackgroundTransparency = 1
				Converted["_TimePlayed"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_TimePlayed"].BorderSizePixel = 0
				Converted["_TimePlayed"].Position = UDim2.new(0.0374331549, 0, 0.275288522, 0)
				Converted["_TimePlayed"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_TimePlayed"].Name = "TimePlayed"
				Converted["_TimePlayed"].Parent = Converted["_Background"]
				
				Converted["_Kills"].Font = Enum.Font.SourceSans
				Converted["_Kills"].Text = "Kills: 0" 
				Converted["_Kills"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Kills"].TextScaled = true
				Converted["_Kills"].TextSize = 14
				Converted["_Kills"].TextWrapped = true
				Converted["_Kills"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_Kills"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Kills"].BackgroundTransparency = 1
				Converted["_Kills"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Kills"].BorderSizePixel = 0
				Converted["_Kills"].Position = UDim2.new(0.0374331549, 0, 0.445024729, 0)
				Converted["_Kills"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_Kills"].Name = "Kills"
				Converted["_Kills"].Parent = Converted["_Background"]
				
				Converted["_Deaths"].Font = Enum.Font.SourceSans
				Converted["_Deaths"].Text = "Deaths: 0"
				Converted["_Deaths"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Deaths"].TextScaled = true
				Converted["_Deaths"].TextSize = 14
				Converted["_Deaths"].TextWrapped = true
				Converted["_Deaths"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_Deaths"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Deaths"].BackgroundTransparency = 1
				Converted["_Deaths"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Deaths"].BorderSizePixel = 0
				Converted["_Deaths"].Position = UDim2.new(0.0374331549, 0, 0.614760935, 0)
				Converted["_Deaths"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_Deaths"].Name = "Deaths"
				Converted["_Deaths"].Parent = Converted["_Background"]
				
				Converted["_Region"].Font = Enum.Font.SourceSans
				Converted["_Region"].Text = "Region: "..extractregion(regiondisplay)
				Converted["_Region"].TextColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Region"].TextScaled = true
				Converted["_Region"].TextSize = 14
				Converted["_Region"].TextWrapped = true
				Converted["_Region"].TextXAlignment = Enum.TextXAlignment.Left
				Converted["_Region"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Converted["_Region"].BackgroundTransparency = 1
				Converted["_Region"].BorderColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_Region"].BorderSizePixel = 0
				Converted["_Region"].Position = UDim2.new(0.0374331549, 0, 0.78298521, 0)
				Converted["_Region"].Size = UDim2.new(1, 0, 0.168224305, 0)
				Converted["_Region"].Name = "Region"
				Converted["_Region"].Parent = Converted["_Background"]
				
				Converted["_DropShadowHolder"].BackgroundTransparency = 1
				Converted["_DropShadowHolder"].BorderSizePixel = 0
				Converted["_DropShadowHolder"].Size = UDim2.new(1, 0, 1, 0)
				Converted["_DropShadowHolder"].ZIndex = 0
				Converted["_DropShadowHolder"].Name = "DropShadowHolder"
				Converted["_DropShadowHolder"].Parent = Converted["_Background"]
				
				Converted["_DropShadow"].Image = "rbxassetid://6014261993"
				Converted["_DropShadow"].ImageColor3 = Color3.fromRGB(0, 0, 0)
				Converted["_DropShadow"].ImageTransparency = 0.5
				Converted["_DropShadow"].ScaleType = Enum.ScaleType.Slice
				Converted["_DropShadow"].SliceCenter = Rect.new(49, 49, 450, 450)
				Converted["_DropShadow"].AnchorPoint = Vector2.new(0.5, 0.5)
				Converted["_DropShadow"].BackgroundTransparency = 1
				Converted["_DropShadow"].BorderSizePixel = 0
				Converted["_DropShadow"].Position = UDim2.new(0.5, 0, 0.5, 0)
				Converted["_DropShadow"].Size = UDim2.new(1, 47, 1, 47)
				Converted["_DropShadow"].ZIndex = 0
				Converted["_DropShadow"].Name = "DropShadow"
				Converted["_DropShadow"].Parent = Converted["_DropShadowHolder"]
				
				local function timerupdate()
					while true do
						wait()
						local timercounter = plrgui.TopBarAppGui.TopBarApp["2"]["5"].Text
						local timergaming = extracttimer(timercounter)
						Converted["_TimePlayed"].Text = "Time Played: " .. timergaming
					end
				end
				
				local function killsupdate()
					while true do
						wait()
						local killscounter = plrgui.TopBarAppGui.TopBarApp["3"]["5"].Text
						local kills = extractnumber(killscounter)
						Converted["_Kills"].Text = "Kills: " .. kills
					end
				end
				
				local function deathcounterfunc()
					local humanoid = lplr.Character:WaitForChild("Humanoid")
					humanoid.HealthChanged:Connect(function(health)
						if not debouncegaming then
							debouncegaming = true
							if health <= 0 and not playerded then
								deathscounter = deathscounter + 1
								Converted["_Deaths"].Text = "Deaths: " .. deathscounter
								playerded = true
								debouncegaming = false
								wait(1) 
							elseif health > 0 and playerded then
								playerded = false
							end
						end
					end)
				end
				
				task.spawn(timerupdate)
				task.spawn(killsupdate)
				task.spawn(deathcounterfunc)	
			else 
				local plrgui = game.Players.LocalPlayer.PlayerGui
				if plrgui:FindFirstChild("SessionInfo") then 
					local sessioninfo = plrgui.SessionInfo
					sessioninfo:Destroy()
				else 
					ErrorWarning("SessionInfo", "Session Info not found, please dm salad about this.", 30)
				end
			end
		end
	})
	SessioninfoBgColor = SessionInfo.CreateColorSlider({
		Name = "Background Color",
		Function = function(h, s, v) 
			if game.Players.LocalPlayer.PlayerGui:FindFirstChild("SessionInfo") then 
				game.Players.LocalPlayer.PlayerGui.SessionInfo.Background.BackgroundColor3 = Color3.fromHSV(h, s, v)
			else
				print("no session info found lol")
			end
		end
	})
end)

run(function()
    local tppos2 = nil
    local TweenSpeed = 0.7
    local HeightOffset = 5
    local BedTP = {}

    local function teleportWithTween(char, destination)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            destination = destination + Vector3.new(0, HeightOffset, 0)
            local currentPosition = root.Position
            if (destination - currentPosition).Magnitude > 0.5 then
                local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local goal = {CFrame = CFrame.new(destination)}
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
                tween.Completed:Wait()
				BedTP.ToggleButton(false)
            end
        end
    end

    local function killPlayer(player)
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end

    local function getEnemyBed(range)
        range = range or math.huge
        local bed = nil
        local player = lplr

        if not isAlive(player, true) then 
            return nil 
        end

        local localPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.zero
        local playerTeam = player:GetAttribute('Team')
        local beds = collectionService:GetTagged('bed')

        for _, v in ipairs(beds) do 
            if v:GetAttribute('PlacedByUserId') == 0 then
                local bedTeam = v:GetAttribute('id'):sub(1, 1)
                if bedTeam ~= playerTeam then 
                    local bedPosition = v.Position
                    local bedDistance = (localPos - bedPosition).Magnitude
                    if bedDistance < range then 
                        bed = v
                        range = bedDistance
                    end
                end
            end
        end

        if not bed then 
            warningNotification("BedTP", 'No enemy beds found. Total beds: '..#beds, 5)
        else
            --warningNotification("BedTP", 'Teleporting to bed at position: '..tostring(bed.Position), 3)
			warningNotification("BedTP", 'Teleporting to bed at position: '..tostring(bed.Position), 3)
        end

        return bed
    end

    BedTP = GuiLibrary["ObjectsThatCanBeSaved"]["TPWindow"]["Api"].CreateOptionsButton({
        ["Name"] = "BedTP",
        ["Function"] = function(callback)
            if callback then
				task.spawn(function()
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled and GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("BedTP", "Please turn off the Invisibility and GamingChair module!", 3)
						BedTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled then
						errorNotification("BedTP", "Please turn off the Invisibility module!", 3)
						BedTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("BedTP", "Please turn off the GamingChair module!", 3)
						BedTP.ToggleButton()
						return
					end
					table.insert(BedTP.Connections, lplr.CharacterAdded:Connect(function(char)
						if tppos2 then 
							task.spawn(function()
								local root = char:WaitForChild("HumanoidRootPart", 9000000000)
								if root and tppos2 then 
									teleportWithTween(char, tppos2)
									tppos2 = nil
								end
							end)
						end
					end))
					local bed = getEnemyBed()
					if bed then 
						tppos2 = bed.Position
						killPlayer(lplr)
					else
						BedTP.ToggleButton(false)
					end
				end)
            end
        end
    })
end)

run(function()
	local TweenService = game:GetService("TweenService")
	local playersService = game:GetService("Players")
	local lplr = playersService.LocalPlayer
	local function warningNotification(title, text, delay)
		local suc, res = pcall(function()
			local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
			frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
			return frame
		end)
		return (suc and res)
	end
	
	local tppos2
	local deathtpmod = {["Enabled"] = false}
	local TweenSpeed = 0.7
	local HeightOffset = 5

	local function teleportWithTween(char, destination)
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			destination = destination + Vector3.new(0, HeightOffset, 0)
			local currentPosition = root.Position
			if (destination - currentPosition).Magnitude > 0.5 then
				local tweenInfo = TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local goal = {CFrame = CFrame.new(destination)}
				local tween = TweenService:Create(root, tweenInfo, goal)
				tween:Play()
				tween.Completed:Wait()
			end
		end
	end

	local function killPlayer(player)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = 0
			end
		end
	end

	local function onCharacterAdded(char)
		if tppos2 then 
			task.spawn(function()
				local root = char:WaitForChild("HumanoidRootPart", 9000000000)
				if root and tppos2 then 
					teleportWithTween(char, tppos2)
					tppos2 = nil
				end
			end)
		end
	end

	vapeConnections[#vapeConnections + 1] = lplr.CharacterAdded:Connect(onCharacterAdded)

	local function setTeleportPosition()
		local UserInputService = game:GetService("UserInputService")
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

		if isMobile then
			warningNotification("DeathTP", "Please tap on the screen to set TP position.", 3)
			local connection
			connection = UserInputService.TouchTapInWorld:Connect(function(inputPosition, processedByUI)
				if not processedByUI then
					local mousepos = lplr:GetMouse().UnitRay
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {workspace.Map, workspace:FindFirstChild("SpectatorPlatform")}
					rayparams.FilterType = Enum.RaycastFilterType.Whitelist
					local ray = workspace:Raycast(mousepos.Origin, mousepos.Direction * 10000, rayparams)
					if ray then 
						tppos2 = ray.Position 
						warningNotification("DeathTP", "Set TP Position. Resetting to teleport...", 3)
						killPlayer(lplr)
					end
					connection:Disconnect()
					deathtpmod["ToggleButton"](false)
				end
			end)
		else
			local mousepos = lplr:GetMouse().UnitRay
			local rayparams = RaycastParams.new()
			rayparams.FilterDescendantsInstances = {workspace.Map, workspace:FindFirstChild("SpectatorPlatform")}
			rayparams.FilterType = Enum.RaycastFilterType.Whitelist
			local ray = workspace:Raycast(mousepos.Origin, mousepos.Direction * 10000, rayparams)
			if ray then 
				tppos2 = ray.Position 
				warningNotification("DeathTP", "Set TP Position. Resetting to teleport...", 3)
				killPlayer(lplr)
			end
			deathtpmod["ToggleButton"](false)
		end
	end

	deathtpmod = GuiLibrary["ObjectsThatCanBeSaved"]["TPWindow"]["Api"].CreateOptionsButton({
		["Name"] = "DeathTP",
		["Function"] = function(calling)
			if calling then
				task.spawn(function()
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled and GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("DeathTP", "Please turn off the Invisibility and GamingChair module!", 3)
						deathtpmod.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled then
						errorNotification("DeathTP", "Please turn off the Invisibility module!", 3)
						deathtpmod.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("DeathTP", "Please turn off the GamingChair module!", 3)
						deathtpmod.ToggleButton()
						return
					end
					local canRespawn = function() end
					canRespawn = function()
						local success, response = pcall(function() 
							return lplr.leaderstats.Bed.Value == '✅' 
						end)
						return success and response 
					end
					if not canRespawn() then 
						warningNotification("DeathTP", "Unable to use DeathTP without bed!", 5)
						deathtpmod.ToggleButton()
					else
						setTeleportPosition()
					end
				end)
			end
		end
	})
end)

run(function()
	local DiamondTP = {}
	local DiamondTPAutoSpeed = {}
	local DiamondTPSpeed = {Value = 200}
	local DiamondTPTeleport = {Value = 'Respawn'}
	local DiamondTPMethod = {Value = 'Linear'}
	local diamondtween 
	local oldmovefunc 
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('diamond')
			if item == nil or not DiamondTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('DiamondTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('DiamondTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(DiamondTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not DiamondTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local item = getItemDrop('diamond')
			if item == nil or not isAlive(lplr, true) then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end
	}
	DiamondTP = GuiLibrary.ObjectsThatCanBeSaved.TPWindow.Api.CreateOptionsButton({
		Name = 'DiamondTP',
		HoverText = 'Tweens you to a nearby diamond drop.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled and GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("DiamondTP", "Please turn off the Invisibility and GamingChair module!", 3)
						DiamondTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled then
						errorNotification("DiamondTP", "Please turn off the Invisibility module!", 3)
						DiamondTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("DiamondTP", "Please turn off the GamingChair module!", 3)
						DiamondTP.ToggleButton()
						return
					end
					if getItemDrop('diamond') then 
						bypassmethods[isAlive(lplr, true) and DiamondTPTeleport.Value or 'Respawn']() 
					end
					if DiamondTP.Enabled then 
						DiamondTP.ToggleButton()
					end 
				end)
			else
				pcall(function() diamondtween:Cancel() end) 
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	DiamondTPTeleport = DiamondTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	DiamondTPAutoSpeed = DiamondTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() DiamondTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() DiamondTPSpeed.Object.Visible = true end) 
			end
		end
	})
	DiamondTPSpeed = DiamondTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	DiamondTPMethod = DiamondTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	DiamondTPSpeed.Object.Visible = false
	local Credits
	Credits = DiamondTP.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

run(function()
	local EmeraldTP = {}
	local EmeraldTPAutoSpeed = {}
	local EmeraldTPSpeed = {Value = 200}
	local EmeraldTPTeleport = {Value = 'Respawn'}
	local EmeraldTPMethod = {Value = 'Linear'}
	local emeraldtween 
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('emerald')
			if item == nil or not EmeraldTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('EmeraldTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('EmeraldTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(EmeraldTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not EmeraldTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local item = getItemDrop('emerald')
			if item == nil or not isAlive(lplr, true) then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end
	}
	EmeraldTP = GuiLibrary.ObjectsThatCanBeSaved.TPWindow.Api.CreateOptionsButton({
		Name = 'EmeraldTP',
		HoverText = 'Tweens you to a nearby emerald drop.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled and GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("EmeraldTP", "Please turn off the Invisibility and GamingChair module!", 3)
						EmeraldTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled then
						errorNotification("EmeraldTP", "Please turn off the Invisibility module!", 3)
						EmeraldTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("EmeraldTP", "Please turn off the GamingChair module!", 3)
						EmeraldTP.ToggleButton()
						return
					end
					if getItemDrop('emerald') then 
						bypassmethods[isAlive(lplr, true) and EmeraldTPTeleport.Value or 'Respawn']() 
					end
					if EmeraldTP.Enabled then 
						EmeraldTP.ToggleButton()
					end 
				end)
			else
				pcall(function() emeraldtween:Cancel() end) 
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	EmeraldTPTeleport = EmeraldTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	EmeraldTPAutoSpeed = EmeraldTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() EmeraldTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() EmeraldTPSpeed.Object.Visible = true end) 
			end
		end
	})
	EmeraldTPSpeed = EmeraldTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	EmeraldTPMethod = EmeraldTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	EmeraldTPSpeed.Object.Visible = false
	local Credits
	Credits = EmeraldTP.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

run(function()
	local PlayerTP = {}
	local PlayerTPTeleport = {Value = 'Respawn'}
	local PlayerTPSort = {Value = 'Distance'}
	local PlayerTPMethod = {Value = 'Linear'}
	local PlayerTPAutoSpeed = {}
	local PlayerTPSpeed = {Value = 200}
	local PlayerTPTarget = {Value = ''}
	local playertween
	local oldmovefunc
	local bypassmethods = {
		Respawn = function() 
			if isEnabled('InfiniteFly') then 
				return 
			end
			if not canRespawn() then 
				return 
			end
			for i = 1, 30 do 
				if isAlive(lplr, true) and lplr.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 470) + 0.001 * 2 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end,
		Instant = function() 
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil then 
				return PlayerTP.ToggleButton()
			end
			lplr.Character.HumanoidRootPart.CFrame = (target.RootPart.CFrame + Vector3.new(0, 5, 0)) 
			PlayerTP.ToggleButton()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return 
			end
			if not bedwars.AbilityController:canUseAbility('recall') then 
				errorNotification('PlayerTP', 'Recall ability not available.', 7)
				return
			end
			pcall(function()
				oldmovefunc = require(lplr.PlayerScripts.PlayerModule).controls.moveFunction 
				require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = function() end
			end)
			bedwars.AbilityController:useAbility('recall')
			local teleported
			table.insert(PlayerTP.Connections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function() teleported = true end))
			repeat task.wait() until teleported or not PlayerTP.Enabled or not isAlive(lplr, true) 
			task.wait()
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not isAlive(lplr, true) or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character.HumanoidRootPart.Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 1000) + 0.001 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end
	}
	PlayerTP = GuiLibrary.ObjectsThatCanBeSaved.TPWindow.Api.CreateOptionsButton({
		Name = 'PlayerTP',
		HoverText = 'Tweens you to a nearby target.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled and GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("PlayerTP", "Please turn off the Invisibility and GamingChair module!", 3)
						PlayerTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled then
						errorNotification("PlayerTP", "Please turn off the Invisibility module!", 3)
						PlayerTP.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("PlayerTP", "Please turn off the GamingChair module!", 3)
						PlayerTP.ToggleButton()
						return
					end
					if GetTarget(nil, PlayerTPSort.Value == 'Health', true).RootPart and shared.VapeFullyLoaded then 
						bypassmethods[isAlive() and PlayerTPTeleport.Value or 'Respawn']() 
					else
						InfoNotification("PlayerTP", "No player/s found!", 3)
					end
					if PlayerTP.Enabled then 
						PlayerTP.ToggleButton()
					end
				end)
			else
				pcall(function() playertween:Disconnect() end)
				if oldmovefunc then 
					pcall(function() require(lplr.PlayerScripts.PlayerModule).controls.moveFunction = oldmovefunc end)
				end
				oldmovefunc = nil
			end
		end
	})
	PlayerTPTeleport = PlayerTP.CreateDropdown({
		Name = 'Teleport Method',
		List = {'Respawn', 'Recall'},
		Function = function() end
	})
	PlayerTPAutoSpeed = PlayerTP.CreateToggle({
		Name = 'Auto Speed',
		HoverText = 'Automatically uses a "good" tween speed.',
		Default = true,
		Function = function(calling) 
			if calling then 
				pcall(function() PlayerTPSpeed.Object.Visible = false end) 
			else 
				pcall(function() PlayerTPSpeed.Object.Visible = true end) 
			end
		end
	})
	PlayerTPSpeed = PlayerTP.CreateSlider({
		Name = 'Tween Speed',
		Min = 20, 
		Max = 350,
		Default = 200,
		Function = function() end
	})
	PlayerTPMethod = PlayerTP.CreateDropdown({
		Name = 'Teleport Method',
		List = GetEnumItems('EasingStyle'),
		Function = function() end
	})
	PlayerTPSpeed.Object.Visible = false
	local Credits
	Credits = PlayerTP.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

--[[run(function()
	local function instawin()
		local player = game.Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		
		for _, part in pairs(game.Workspace:GetDescendants()) do
			if part:IsA("BasePart") then
				for _, child in pairs(part:GetChildren()) do
					if child:IsA("TouchTransmitter") then
						firetouchinterest(humanoidRootPart, part, 0)
						firetouchinterest(humanoidRootPart, part, 1)
					end
				end
			end
		end
	end
    local isEnabled = false
    local credits
    local instaWinExploit = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
        Name = "BridgeduelsInstawin",
        Function = function(callback)
            isEnabled = callback
            if callback then
                task.spawn(function()
                    while isEnabled do
                        instawin()
                        wait(0.1)
                    end
                end)
            end
        end,
        HoverText = "Instantly wins every game for you"
    })
	credits = instaWinExploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        ButtonText = 'Show Credits',
        Credits = 'Vape+ Booster'
    })
end)--]] -- patched eeee

run(function()
	local HotbarMods = {}
	local HotbarRounding = {}
	local HotbarHighlight = {}
	local HotbarColorToggle = {}
	local HotbarHideSlotIcons = {}
	local HotbarSlotNumberColorToggle = {}
	local HotbarRoundRadius = {Value = 8}
	local HotbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarHighlightColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarSlotNumberColor = {Hue = 0, Sat = 0, Value = 0}
	local hotbarsloticons = {}
	local hotbarobjects = {}
	local hotbarcoloricons = {}
	local HotbarModsGradient = {}
	local hotbarslotgradients = {}
	local HotbarModsGradientColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarModsGradientColor2 = {Hue = 0, Sat = 0, Value = 0}
	local function hotbarFunction()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			for i,v in next, inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				if HotbarColorToggle.Enabled and not HotbarModsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
					table.insert(hotbarcoloricons, sloticon.Parent) 
				end
				if HotbarModsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						local gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarMods = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'HotbarVisuals',
		HoverText = 'Add customization to your hotbar.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
			else
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in next, hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarMods.CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarModsGradient = HotbarMods.CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarModsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarModsGradientColor2.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarModsGradientColor = HotbarMods.CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in next, hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarModsGradientColor2 = HotbarMods.CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in next, hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarModsGradientColor.Hue, HotbarModsGradientColor.Sat, HotbarModsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarModsGradientColor2.Hue, HotbarModsGradientColor2.Sat, HotbarModsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarColor = HotbarMods.CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in next, hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarMods.CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarRoundRadius = HotbarMods.CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in next, hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	})
	HotbarHighlight = HotbarMods.CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarHighlightColor = HotbarMods.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in next, hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarMods.CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
	local Credits
	Credits = HotbarMods.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Render'
    })
end)

run(function()
	local HealthbarVisuals = {};
	local HealthbarRound = {};
	local HealthbarColorToggle = {};
	local HealthbarGradientToggle = {};
	local HealthbarGradientColor = {};
	local HealthbarHighlight = {};
	local HealthbarHighlightColor = newcolor();
	local HealthbarGradientRotation = {Value = 0};
	local HealthbarTextToggle = {};
	local HealthbarFontToggle = {};
	local HealthbarTextColorToggle = {};
	local HealthbarBackgroundToggle = {};
	local HealthbarText = {ObjectList = {}};
	local HealthbarInvis = {Value = 0};
	local HealthbarRoundSize = {Value = 4};
	local HealthbarFont = {value = 'LuckiestGuy'};
	local HealthbarColor = newcolor();
	local HealthbarBackground = newcolor();
	local HealthbarTextColor = newcolor();
	local healthbarobjects = safearray();
	local oldhealthbar;
	local healthbarhighlight;
	local textconnection;
	local function healthbarFunction()
		if not HealthbarVisuals.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar;
			healthbar.Transparency = (0.1 * HealthbarInvis.Value);
			healthbar.BackgroundColor3 = (HealthbarColorToggle.Enabled and Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value) or healthbar.BackgroundColor3)
			if HealthbarGradientToggle.Enabled then 
				healthbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = (healthbar:FindFirstChildWhichIsA('UIGradient') or Instance.new('UIGradient', healthbar))
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value)), 
					ColorSequenceKeypoint.new(1, Color3.fromHSV(HealthbarGradientColor.Hue, HealthbarGradientColor.Sat, HealthbarGradientColor.Value))
				})
				gradient.Rotation = HealthbarGradientRotation.Value
				table.insert(healthbarobjects, gradient)
			end
			for i,v in healthbar.Parent:GetChildren() do 
				if v:IsA('Frame') and v:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then
					local corner = Instance.new('UICorner', v);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end
			end
			local healthbarbackground = ({pcall(function() return healthbar.Parent.Parent end)})[2]
			if healthbarbackground and type(healthbarbackground) == 'userdata' then
				healthbar.Transparency = (0.1 * HealthbarInvis.Value);
				if HealthbarHighlight.Enabled then 
					local highlight = Instance.new('UIStroke', healthbarbackground);
					highlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value);
					highlight.Thickness = 1.6; 
					healthbarhighlight = highlight
				end
				if healthbar.Parent.Parent:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					local corner = Instance.new('UICorner', healthbar.Parent.Parent);
					corner.CornerRadius = UDim.new(0, HealthbarRoundSize.Value);
					table.insert(healthbarobjects, corner)
				end 
				if HealthbarBackgroundToggle.Enabled then
					healthbarbackground.BackgroundColor3 = Color3.fromHSV(HealthbarBackground.Hue, HealthbarBackground.Sat, HealthbarBackground.Value)
				end
			end
			local healthbartext = ({pcall(function() return healthbar.Parent.Parent['1'] end)})[2]
			if healthbartext and type(healthbartext) == 'userdata' then 
				local randomtext = getrandomvalue(HealthbarText.ObjectList)
				if HealthbarTextColorToggle.Enabled then
					healthbartext.TextColor3 = Color3.fromHSV(HealthbarTextColor.Hue, HealthbarTextColor.Sat, HealthbarTextColor.Value)
				end
				if HealthbarFontToggle.Enabled then 
					healthbartext.Font = Enum.Font[HealthbarFont.Value]
				end
				if randomtext ~= '' and HealthbarTextToggle.Enabled then 
					healthbartext.Text = randomtext:gsub('<health>', isAlive(lplr, true) and tostring(math.round(lplr.Character:GetAttribute('Health') or 0)) or '0')
				else
					pcall(function() healthbartext.Text = tostring(lplr.Character:GetAttribute('Health')) end)
				end
				if not textconnection then 
					textconnection = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
						local randomtext = getrandomvalue(HealthbarText.ObjectList)
						if randomtext ~= '' then 
							healthbartext.Text = randomtext:gsub('<health>', isAlive() and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
						else
							pcall(function() healthbartext.Text = tostring(math.floor(lplr.Character:GetAttribute('Health'))) end)
						end
					end)
				end
			end
		end
	end
	HealthbarVisuals = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'HealthbarVisuals',
		HoverText = 'Customize the color of your healthbar.\nAdd \'<health>\' to your custom text dropdown (if custom text enabled) to insert your health.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HealthbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							healthbarFunction()
						end
					end))
					healthbarFunction()
				end)
			else
				pcall(function() textconnection:Disconnect() end)
				pcall(function() oldhealthbar.Parent.Parent.BackgroundColor3 = Color3.fromRGB(41, 51, 65) end)
				pcall(function() oldhealthbar.BackgroundColor3 = Color3.fromRGB(203, 54, 36) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Text = tostring(lplr.Character:GetAttribute('Health')) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].TextColor3 = Color3.fromRGB(255, 255, 255) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Font = Enum.Font.LuckiestGuy end)
				oldhealthbar = nil
				textconnection = nil
				for i,v in healthbarobjects do 
					pcall(function() v:Destroy() end)
				end
				table.clear(healthbarobjects);
				pcall(function() healthbarhighlight:Destroy() end);
				healthbarhighlight = nil;
			end
		end
	})
	HealthbarColorToggle = HealthbarVisuals.CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(calling)
			pcall(function() HealthbarColor.Object.Visible = calling end)
			pcall(function() HealthbarGradientToggle.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarGradientToggle = HealthbarVisuals.CreateToggle({
		Name = 'Gradient',
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Main Color',
		Function = function()
			task.spawn(healthbarFunction)
		end
	})
	HealthbarGradientColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Secondary Color',
		Function = function(calling)
			if HealthbarGradientToggle.Enabled then 
				task.spawn(healthbarFunction)
			end
		end
	})
	HealthbarBackgroundToggle = HealthbarVisuals.CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() HealthbarBackground.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarBackground = HealthbarVisuals.CreateColorSlider({
		Name = 'Background Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarTextToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text',
		Function = function(calling)
			pcall(function() HealthbarText.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarText = HealthbarVisuals.CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarTextColorToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() HealthbarTextColor.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarTextColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Text Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarFontToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text Font',
		Function = function(calling)
			pcall(function() HealthbarFont.Object.Visible = calling end)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end 
	})
	HealthbarFont = HealthbarVisuals.CreateDropdown({
		Name = 'Text Font',
		List = GetEnumItems('Font'),
		Function = function(calling)
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarRound = HealthbarVisuals.CreateToggle({
		Name = 'Round',
		Function = function(calling)
			pcall(function() HealthbarRoundSize.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarRoundSize = HealthbarVisuals.CreateSlider({
		Name = 'Corner Size',
		Min = 1,
		Max = 20,
		Default = 5,
		Function = function(value)
			if HealthbarVisuals.Enabled then 
				pcall(function() 
					oldhealthbar.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value);
					oldhealthbar.Parent.Parent:FindFirstChildOfClass('UICorner').CornerRadius = UDim.new(0, value)  
				end)
			end
		end
	})
	HealthbarHighlight = HealthbarVisuals.CreateToggle({
		Name = 'Highlight',
		Function = function(calling)
			pcall(function() HealthbarHighlightColor.Object.Visible = calling end);
			if HealthbarVisuals.Enabled then
				HealthbarVisuals.ToggleButton(false)
				HealthbarVisuals.ToggleButton(false)
			end
		end
	})
	HealthbarHighlightColor = HealthbarVisuals.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function()
			if HealthbarVisuals.Enabled then 
				pcall(function() healthbarhighlight.Color = Color3.fromHSV(HealthbarHighlightColor.Hue, HealthbarHighlightColor.Sat, HealthbarHighlightColor.Value) end)
			end
		end
	})
	HealthbarInvis = HealthbarVisuals.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Function = function(value)
			pcall(function() 
				oldhealthbar.Transparency = (0.1 * value);
				oldhealthbar.Parent.Parent.Transparency = (0.1 * HealthbarInvis.Value); 
			end)
		end
	})
	HealthbarBackground.Object.Visible = false;
	HealthbarText.Object.Visible = false;
	HealthbarTextColor.Object.Visible = false;
	HealthbarFont.Object.Visible = false;
	HealthbarRoundSize.Object.Visible = false;
	HealthbarHighlightColor.Object.Visible = false;
end)

run(function() 
	local AutoBedDefense = {}
	AutoBedDefense = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
		Name = 'AutoBedDefense',
		HoverText = 'Auto puts bed defense the moment u get blocks (useful when someone spams fireballs at ur bed)',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					while task.wait(1) and AutoBedDefense.Enabled do
						--GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.OptionsButtons.BedProtector.ToggleButton(true)
						GuiLibrary.ObjectsThatCanBeSaved.BedProtectorOptionsButton.Api.ToggleButton()
					end
				end)
			end
		end
	})
end)

run(function()
	local ClanDetector = {Enabled = false}
	local alreadyclanchecked = {}
	local blacklistedclans = {}
	local function detectblacklistedclan(plr)
		if not plr:GetAttribute("LobbyConnected") then repeat task.wait() until plr:GetAttribute("LobbyConnected") end
		for i2, v2 in pairs(blacklistedclans.ObjectList) do
			if GetClanTag(plr) == v2 and alreadyclanchecked[plr] == nil then
				warningNotification("ClanDetector", plr.DisplayName.. " is in the "..v2.." clan!", 15)
				alreadyclanchecked[plr] = true
			end
		end
	end
	ClanDetector = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
		Name = "ClanDetector",
		Approved = true,
		Function = function(callback)
			if callback then
				task.spawn(function()
				for i,v in pairs(playersService:GetPlayers()) do
					task.spawn(function()
					 if v ~= lplr then
						 task.spawn(detectblacklistedclan, v)
					 end
					end)
				end
				table.insert(ClanDetector.Connections, playersService.PlayerAdded:Connect(function(v)
					task.spawn(detectblacklistedclan, v)
				end))
			end)
			end
		end,
		HoverText = "detect players in certain clans (customizable)"
	})
	blacklistedclans = ClanDetector.CreateTextList({
		Name = "Clans",
		TempText = "clans to detect",
		AddFunction = function() 
			if ClanDetector.Enabled then
				ClanDetector.ToggleButton(false)
				ClanDetector.ToggleButton(false)
			end
		end
	})
end)

run(function()
    local antiDeath = {}
    local antiDeathConfig = {
        Mode = {},
        BoostMode = {},
        SongId = {},
        Health = {},
        Velocity = {},
        CFrame = {},
        TweenPower = {},
        TweenDuration = {},
        SkyPosition = {},
        AutoDisable = {},
        Sound = {},
        Notify = {}
    }
    local antiDeathState = {}
    local handlers = {}

    function handlers.new()
        local self = {
            boost = false,
            inf = false,
            notify = false,
            id = false,
            hrp = entityLibrary.character.HumanoidRootPart,
            hasNotified = false
        }
        setmetatable(self, { __index = handlers })
        return self
    end

    function handlers:enable()
        RunLoops:BindToHeartbeat('antiDeath', function()
            if not isAlive(lplr, true) then
                self:disable()
                return
            end

            if getHealth() <= antiDeathConfig.Health.Value and getHealth() > 0 then
                if not self.boost then
                    self:activateMode()
                    if not self.hasNotified and antiDeathConfig.Notify.Enabled then
                        self:sendNotification()
                    end
                    self:playNotificationSound()
                    self.boost = true
                end
            else
                self:resetMode()
                self.hrp.Anchored = false
                self.boost = false

                -- Reset the notification state when health is above the threshold
                if self.hasNotified then
                    self.hasNotified = false
                end
            end
        end)
    end

    function handlers:disable()
        RunLoops:UnbindFromHeartbeat('antiDeath')
    end

    function handlers:activateMode()
        local modeActions = {
            Infinite = function() self:enableInfiniteMode() end,
            Boost = function() self:applyBoost() end,
            Sky = function() self:moveToSky() end
        }
        modeActions[antiDeathConfig.Mode.Value]()
    end

    function handlers:enableInfiniteMode()
        if not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
            GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.ToggleButton(true)
            self.inf = true
        end
    end

    function handlers:applyBoost()
        local boostActions = {
            Velocity = function() self.hrp.Velocity += vec3(0, antiDeathConfig.Velocity.Value, 0) end,
            CFrame = function() self.hrp.CFrame += vec3(0, antiDeathConfig.CFrame.Value, 0) end,
            Tween = function()
                tweenService:Create(self.hrp, twinfo(antiDeathConfig.TweenDuration.Value / 10), {
                    CFrame = self.hrp.CFrame + vec3(0, antiDeathConfig.TweenPower.Value, 0)
                }):Play()
            end
        }
        boostActions[antiDeathConfig.BoostMode.Value]()
    end

    function handlers:moveToSky()
        self.hrp.CFrame += vec3(0, antiDeathConfig.SkyPosition.Value, 0)
        self.hrp.Anchored = true
    end

    function handlers:sendNotification()
        InfoNotification('AntiDeath', 'Prevented death. Health is lower than ' .. antiDeathConfig.Health.Value ..
            '. (Current health: ' .. math.floor(getHealth() + 0.5) .. ')', 5)
        self.hasNotified = true
    end

    function handlers:playNotificationSound()
        if antiDeathConfig.Sound.Enabled then
            local soundId = antiDeathConfig.SongId.Value ~= '' and antiDeathConfig.SongId.Value or '7396762708'
            playSound(soundId, false)
        end
    end

    function handlers:resetMode()
        if self.inf then
            if antiDeathConfig.AutoDisable.Enabled then
                if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
                    GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.ToggleButton(false)
                end
            end
            self.inf = false

            -- Reset the notification state when Infinite Fly is disabled
            self.hasNotified = false
        end
    end

    local antiDeathStatus = handlers.new()

    antiDeath = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(callback)
            if callback then
                coroutine.wrap(function()
                    antiDeathStatus:enable()
                end)()
            else
                pcall(function()
                    antiDeathStatus:disable()
                end)
            end
        end,
        Default = false,
        HoverText = btext('Prevents you from dying.\nMade by Specter Solutions.'),
        ExtraText = function()
            return antiDeathConfig.Mode.Value
        end
    })

    antiDeathConfig.Mode = antiDeath.CreateDropdown({
        Name = 'Mode',
        List = { 'Infinite', 'Boost', 'Sky' },
        Default = 'Infinite',
        HoverText = btext('Mode to prevent death.'),
        Function = function(val)
            antiDeathConfig.BoostMode.Object.Visible = val == 'Boost'
            antiDeathConfig.SkyPosition.Object.Visible = val == 'Sky'
            antiDeathConfig.AutoDisable.Object.Visible = val == 'Infinite'
            antiDeathConfig.Velocity.Object.Visible = false
            antiDeathConfig.CFrame.Object.Visible = false
            antiDeathConfig.TweenPower.Object.Visible = false
            antiDeathConfig.TweenDuration.Object.Visible = false
        end
    })

    antiDeathConfig.BoostMode = antiDeath.CreateDropdown({
        Name = 'Boost',
        List = { 'Velocity', 'CFrame', 'Tween' },
        Default = 'Velocity',
        HoverText = btext('Mode to boost your character.'),
        Function = function(val)
            antiDeathConfig.Velocity.Object.Visible = val == 'Velocity'
            antiDeathConfig.CFrame.Object.Visible = val == 'CFrame'
            antiDeathConfig.TweenPower.Object.Visible = val == 'Tween'
            antiDeathConfig.TweenDuration.Object.Visible = val == 'Tween'
        end
    })
    antiDeathConfig.BoostMode.Object.Visible = false

    antiDeathConfig.SongId = antiDeath.CreateTextBox({
        Name = 'SongID',
        TempText = 'Song ID',
        HoverText = 'ID to play the song.',
        FocusLost = function()
            if antiDeath.Enabled then
                antiDeath.ToggleButton()
                antiDeath.ToggleButton()
            end
        end
    })
    antiDeathConfig.SongId.Object.Visible = false

    antiDeathConfig.Health = antiDeath.CreateSlider({
        Name = 'Health Trigger',
        Min = 10,
        Max = 90,
        HoverText = btext('Health at which AntiDeath will perform its actions.'),
        Default = 50,
        Function = function(val) end
    })

    antiDeathConfig.Velocity = antiDeath.CreateSlider({
        Name = 'Velocity Boost',
        Min = 100,
        Max = 600,
        HoverText = btext('Power to get boosted in the air.'),
        Default = 600,
        Function = function(val) end
    })
    antiDeathConfig.Velocity.Object.Visible = false

    antiDeathConfig.CFrame = antiDeath.CreateSlider({
        Name = 'CFrame Boost',
        Min = 100,
        Max = 1000,
        HoverText = btext('Power to get boosted in the air.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.CFrame.Object.Visible = false

    antiDeathConfig.TweenPower = antiDeath.CreateSlider({
        Name = 'Tween Boost',
        Min = 100,
        Max = 1300,
        HoverText = btext('Power to get boosted in the air.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.TweenPower.Object.Visible = false

    antiDeathConfig.TweenDuration = antiDeath.CreateSlider({
        Name = 'Tween Duration',
        Min = 1,
        Max = 10,
        HoverText = btext('Duration of the tweening process.'),
        Default = 4,
        Function = function(val) end
    })
    antiDeathConfig.TweenDuration.Object.Visible = false

    antiDeathConfig.SkyPosition = antiDeath.CreateSlider({
        Name = 'Sky Position',
        Min = 100,
        Max = 1000,
        HoverText = btext('Position to TP in the sky.'),
        Default = 1000,
        Function = function(val) end
    })
    antiDeathConfig.SkyPosition.Object.Visible = false

    antiDeathConfig.AutoDisable = antiDeath.CreateToggle({
        Name = 'Auto Disable',
        HoverText = btext('Automatically disables InfiniteFly after healing.'),
        Function = function(val) end,
        Default = true
    })
    antiDeathConfig.AutoDisable.Object.Visible = false

    antiDeathConfig.Sound = antiDeath.CreateToggle({
        Name = 'Sound',
        HoverText = btext('Plays a sound after preventing death.'),
        Function = function(callback)
            antiDeathConfig.SongId.Object.Visible = callback
        end,
        Default = true
    })

    antiDeathConfig.Notify = antiDeath.CreateToggle({
        Name = 'Notification',
        HoverText = btext('Notifies you when AntiDeath actioned.'),
        Default = true,
        Function = function(callback) end
    })
end)

run(function()
	local AutoUpgradeEra = {}

	local function invokePurchaseEra(eras)
		for _, era in ipairs(eras) do
			local args = {
				[1] = {
					["era"] = era
				}
			}
			game:GetService("ReplicatedStorage")
				:WaitForChild("rbxts_include")
				:WaitForChild("node_modules")
				:WaitForChild("@rbxts")
				:WaitForChild("net")
				:WaitForChild("out")
				:WaitForChild("_NetManaged")
				:WaitForChild("RequestPurchaseEra")
				:InvokeServer(unpack(args))
			task.wait(0.1)  -- Add a small delay to avoid overwhelming the server
		end
	end

	local function invokePurchaseUpgrade(upgrades)
		for _, upgrade in ipairs(upgrades) do
			local args = {
				[1] = {
					["upgrade"] = upgrade
				}
			}
			game:GetService("ReplicatedStorage")
				:WaitForChild("rbxts_include")
				:WaitForChild("node_modules")
				:FindFirstChild("@rbxts")
				:WaitForChild("net")
				:WaitForChild("out")
				:WaitForChild("_NetManaged")
				:WaitForChild("RequestPurchaseTeamUpgrade")
				:InvokeServer(unpack(args))
			task.wait(0.1)  -- Add a small delay to avoid overwhelming the server
		end
	end

	AutoUpgradeEra = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
		Name = 'AutoUpgradeEra',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						task.wait()
						invokePurchaseEra({"iron_era", "diamond_era", "emerald_era"})
						invokePurchaseUpgrade({"altar_i", "bed_defense_i", "destruction_i", "magic_i", "altar_ii", "destruction_ii", "magic_ii", "altar_iii"})
					until not AutoUpgradeEra.Enabled
				end)
			end
		end
	})
end)

run(function()
    local AdetundeExploit = {}
    local AdetundeExploit_List = { Value = "Shield" }

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = game:GetService("ReplicatedStorage")
                :WaitForChild("rbxts_include")
                :WaitForChild("node_modules")
                :WaitForChild("@rbxts")
                :WaitForChild("net")
                :WaitForChild("out")
                :WaitForChild("_NetManaged")
                :WaitForChild("UpgradeFrostyHammer")
                :InvokeServer(unpack(args))
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

    AdetundeExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
        Name = 'AdetundeExploit',
        Function = function(calling)
            if calling then 
                -- Check if in testing mode or equipped kit
                -- if tostring(store.queueType) == "training_room" or store.equippedKit == "adetunde" then
                --     AdetundeExploit["ToggleButton"](false) 
                --     current_upgrador = AdetundeExploit_List.Value
                task.spawn(function()
                    repeat
                        local returning_table = adetunde_remotes[current_upgrador]()
                        
                        if type(returning_table) == "table" then
                            local Speed = returning_table["speed"]
                            local Strength = returning_table["strength"]
                            local Shield = returning_table["shield"]

                            print("Speed: " .. tostring(Speed))
                            print("Strength: " .. tostring(Strength))
                            print("Shield: " .. tostring(Shield))
                            print("Current Upgrador: " .. tostring(current_upgrador))

                            if returning_table[string.lower(current_upgrador)] == 3 then
                                if Strength and Shield and Speed then
                                    if Strength == 3 or Speed == 3 or Shield == 3 then
                                        if (Strength == 3 and Speed == 2 and Shield == 2) or
                                           (Strength == 2 and Speed == 3 and Shield == 2) or
                                           (Strength == 2 and Speed == 2 and Shield == 3) then
                                            warningNotification("AdetundeExploit", "Fully upgraded everything possible!", 7)
                                            hasnt_upgraded_everything = false
                                        else
                                            local things = {}
                                            for i, v in pairs(adetunde_remotes) do
                                                table.insert(things, i)
                                            end
                                            for i, v in pairs(things) do
                                                if things[i] == current_upgrador then
                                                    table.remove(things, i)
                                                end
                                            end
                                            local random = things[math.random(1, #things)]
                                            current_upgrador = random
                                        end
                                    end
                                end
                            end
                        else
                            local things = {}
                            for i, v in pairs(adetunde_remotes) do
                                table.insert(things, i)
                            end
                            for i, v in pairs(things) do
                                if things[i] == current_upgrador then
                                    table.remove(things, i)
                                end
                            end
                            local random = things[math.random(1, #things)]
                            current_upgrador = random
                        end
                        task.wait(0.1)
                    until not AdetundeExploit.Enabled or not hasnt_upgraded_everything
                end)
                -- else
                --     AdetundeExploit["ToggleButton"](false)
                --     warningNotification("AdetundeExploit", "Kit required or you need to be in testing mode", 5)
                -- end
            end
        end
    })

    local real_list = {}
    for i, v in pairs(adetunde_remotes) do
        table.insert(real_list, i)
    end

    AdetundeExploit_List = AdetundeExploit.CreateDropdown({
        Name = 'Preferred Upgrade',
        List = real_list,
        Function = function() end,
        Default = "Shield"
    })
end)

--[[local cooldown = 0
run(function() 
    -- Notification functions
    local redNotification = function() end
    redNotification = function(title, text, delay)
        local success, frame = pcall(function()
            local notification = GuiLibrary.CreateNotification(
                title, 
                text, 
                delay or 6.5, 
                'assets/WarningNotification.png'
            )
            notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
            notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
        end)
        return success and frame
    end
    local function infoNotification(title, text, delay, button_table)
        local suc, res = pcall(function()
            local frame = GuiLibrary.CreateNotification(
                title or "Voidware", 
                text or "Successfully called function", 
                delay or 7, 
                "assets/InfoNotification.png", 
                button_table
            )
            return frame
        end)
        return suc and res
    end
    local ReportDetector = {}
    local DetectionMode = { Value = "Self" }
    local GlobalUsername = { Value = "" }
    local ServerList = { Value = "" }
    local Simplified = { Enabled = true }
    local lplr = game:GetService("Players").LocalPlayer
    local function interactableNotification(data)
        local interactable_buttons_table = {
            [1] = {
                ["Name"] = "Yes",
                ["Function"] = function()
                    local data_to_save = game:GetService("HttpService"):JSONEncode(data)
                    writefile("LoggedReports.txt", data_to_save)
                    local function InfoNotification(title, text, delay, button_table)
                        local suc, res = pcall(function()
                            local frame = GuiLibrary.CreateNotification(
                                title or "Voidware", 
                                text or "Successfully called function", 
                                delay or 7, 
                                "assets/InfoNotification.png", 
                                button_table
                            )
                            return frame
                        end)
                        return suc and res
                    end
                    InfoNotification(
                        "ReportDetector-LogSaver", 
                        "Successfully logged the Reports Data to LoggedReports.txt in your executor's workspace folder!", 
                        7
                    )
                end
            },
            [2] = {
                ["Name"] = "No",
                ["Function"] = function() end
            }
        }

        local function InfoNotification2(title, text, delay, button_table)
            local suc, res = pcall(function()
                local frame = GuiLibrary.CreateInteractableNotification(
                    title or "Voidware", 
                    text or "Successfully called function", 
                    delay or 7, 
                    "assets/InfoNotification.png", 
                    button_table
                )
                return frame
            end)
            return suc and res
        end

        InfoNotification2(
            "ReportDetector-LogSaver", 
            "Would you like to save this log to your files?", 
            100000000, 
            interactable_buttons_table
        )
    end
    local function setCooldown()
        cooldown = 10
        task.spawn(function()
            repeat
                cooldown = cooldown - 1
                task.wait(1)
            until cooldown < 1
            cooldown = 0
        end)
    end
    local function handleError(status_code)
        if status_code then
            warn("StatusCode: " .. tostring(status_code))
        end
        redNotification("ReportDetector", "Error making request! Please wait 10 seconds", 3)
        setCooldown()
    end
    local function getUsername()
        if DetectionMode.Value == "Self" then
            return lplr.Name
        elseif DetectionMode.Value == "Server" then
            if ServerList.Value ~= "" then
                return ServerList.Value
            else
                redNotification("ReportDetector-ServerMode", "Please choose a player on the list!", 3)
                return "error"
            end
        elseif DetectionMode.Value == "Global" then
            if GlobalUsername.Value ~= "" then
                return GlobalUsername.Value
            else
                redNotification("ReportDetector-GlobalMode", "Please specify a username in the textbox!", 3)
                return "error"
            end
        end
    end

    -- ReportDetector button
    ReportDetector = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
        Name = 'ReportDetector',
        Function = function(calling)
            if calling then 
                ReportDetector["ToggleButton"](false) 
                task.spawn(function()
                    if cooldown > 0 then
                        redNotification(
                            "ReportDetector", 
                            "You are on cooldown please wait " .. tostring(cooldown) .. " seconds.", 
                            3
                        )
                    else
                        local username = getUsername()
                        if username == "error" then 
                            setCooldown()
                        else
                            infoNotification(
                                "ReportDetector-Credits", 
                                "API - Systemxvoid, Module implementation - Erchobg", 
                                1.5
                            )
                            infoNotification(
                                "ReportDetector-" .. tostring(DetectionMode.Value), 
                                "Request sent for " .. tostring(username) .. "! Please wait", 
                                4.9
                            )
                            setCooldown()
                            
                            local url = "https://api.renderintents.lol/matchreports?match=" .. username
                            local result = request({ Url = url, Method = 'GET' })

                            if result["StatusCode"] == 200 and result["StatusMessage"] == "OK" then
                                local body_result = game:GetService("HttpService"):JSONDecode(result["Body"])
                                if body_result["success"] == true then
                                    if body_result["result"] and type(body_result["result"]) == "table" then
                                        local table = body_result["result"]
                                        if #table == 0 then
                                            infoNotification(
                                                "ReportDetector-" .. tostring(DetectionMode.Value), 
                                                "No reports found for " .. tostring(username) .. "!", 
                                                3
                                            )
                                        else
                                            if Simplified.Enabled then
                                                redNotification(
                                                    "ReportDetector-" .. tostring(DetectionMode.Value), 
                                                    tostring(#table) .. " were found for " .. tostring(username) .. "!", 
                                                    7
                                                )
                                            else
                                                redNotification(
                                                    "ReportDetector-" .. tostring(DetectionMode.Value), 
                                                    tostring(#table) .. " were found for " .. tostring(username) .. "!", 
                                                    7
                                                )
                                                local full_data = {}
                                                for i, v in pairs(table) do
                                                    if table[i]["reporter"] then
                                                        local senderID = table[i]["reporter"]["id"]
                                                        local senderName = table[i]["reporter"]["username"]
                                                        local message = table[i]["message"]
                                                        local serverID = table[i]["id"]
                                                        if senderID and senderName and message and serverID then
                                                            redNotification(
                                                                "ReportDetector-Report " .. tostring(i) .. " Reporter data", 
                                                                "@" .. tostring(senderName) .. "(UserID:" .. tostring(senderID) .. ")", 
                                                                7
                                                            )
                                                            redNotification(
                                                                "ReportDetector-Report " .. tostring(i) .. " Server data", 
                                                                "ServerID:" .. tostring(serverID) .. " Message: " .. tostring(message), 
                                                                7
                                                            )
                                                            local data_table = {
                                                                ["ReporterData"] = "Username: " .. tostring(senderName) .. " UserID: " .. tostring(senderID),
                                                                ["ServerData"] = "ServerID: " .. tostring(serverID) .. " Message: " .. tostring(message)
                                                            }
                                                            print(full_data)
                                                            print(data_table)
                                                            full_data[tostring(i)] = data_table
                                                        else
                                                            handleError()
                                                        end
                                                    else
                                                        handleError()
                                                    end
                                                end
                                                interactableNotification(full_data)
                                            end
                                        end
                                    else
                                        handleError()
                                    end
                                else
                                    handleError()
                                end
                            else
                                handleError(result["StatusCode"])
                            end
                        end
                    end
                end)
            end
        end
    })

    -- Players list management
    local playerslist = {}
    local Players = game:GetService("Players")

    Players.PlayerAdded:Connect(function(plr)
        table.insert(playerslist, plr.Name)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        for i, v in pairs(playerslist) do
            if playerslist[i] == plr.Name then
                table.remove(playerslist, i)
                break
            end
        end
    end)

    for i, v in pairs(Players:GetChildren()) do
        table.insert(playerslist, Players:GetChildren()[i].Name)
    end

    -- Dropdowns and toggles
    DetectionMode = ReportDetector.CreateDropdown({
        Name = "Mode",
        List = { "Self", "Server", "Global" },
        Function = function(val)
            if val == "Server" then
                ServerList = ReportDetector.CreateDropdown({
                    Name = "Players",
                    List = playerslist,
                    Function = function() end
                })
            elseif val == "Global" then
                GlobalUsername = ReportDetector.CreateTextBox({
                    Name = "Username",
                    TempText = "Type here a username",
                    Function = function() end
                })
            end
        end
    })

    Simplified = ReportDetector.CreateToggle({
        Name = "Simplified",
        Function = function() end,
        Default = true,
        HoverText = "Show simplified data"
    })
end)--]]

run(function()
	function IsAlive(plr)
		plr = plr or lplr
		if not plr.Character then return false end
		if not plr.Character:FindFirstChild("Head") then return false end
		if not plr.Character:FindFirstChild("Humanoid") then return false end
		if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
		return true
	end
	local GodMode = {Enabled = false}
	GodMode = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = "AntiHit/Godmode",
		Function = function(callback)
			if callback then
				spawn(function()
					while task.wait() do
						if (not GodMode.Enabled) then return end
						if (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) then
							for i, v in pairs(game:GetService("Players"):GetChildren()) do
								if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
									if v and v ~= lplr then
										local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
										if TargetDistance < 25 then
											if not lplr.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") then
												repeat task.wait() until shared.GlobalStore.matchState ~= 0
												if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
													lplr.Character.Archivable = true
			
													local Clone = lplr.Character:Clone()
													Clone.Parent = workspace
													Clone.Head:ClearAllChildren()
													gameCamera.CameraSubject = Clone:FindFirstChild("Humanoid")
				
													for i,v in pairs(Clone:GetChildren()) do
														if string.lower(v.ClassName):find("part") and v.Name ~= "HumanoidRootPart" then
															v.Transparency = 1
														end
														if v:IsA("Accessory") then
															v:FindFirstChild("Handle").Transparency = 1
														end
													end
				
													lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,100000,0)
				
													game:GetService("RunService").RenderStepped:Connect(function()
														if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
															Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character.HumanoidRootPart.Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character.HumanoidRootPart.Position.Z)
														end
													end)
				
													task.wait(0.3)
													lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, -1, lplr.Character.HumanoidRootPart.Velocity.Z)
													lplr.Character.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame
													gameCamera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
													Clone:Destroy()
													task.wait(0.15)
												end
											end
										end
									end
								end
							end
						end
					end
				end)
			end
		end
	})
end)

--[[run(function()
	local MelodyExploit = {Enabled = false}
	MelodyExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
		Name = "MelodyExploit",
		Function = function(callback)
			if callback then
				warningNotification("MelodyExploit", "Requires a guitar! Recommended lucky blocks or melody kit", 3)
				RunLoops:BindToHeartbeat("melody",function()			
					if getItem("guitar") then
						if lplr.Character.Humanoid.Health < lplr.Character.Humanoid.MaxHealth then
							bedwars.Client:Get(bedwars.GuitarHealRemote):SendToServer({healTarget = lplr})
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("StopPlayingGuitar"):FireServer()
						else
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("StopPlayingGuitar"):FireServer()
						end
					else
						local args = {
							[1] = {
								["shopItem"] = {
									["lockAfterPurchase"] = true,
									["currency"] = "iron",
									["itemType"] = "guitar",
									["amount"] = 1,
									["price"] = 16,
									["category"] = "Combat",
									["spawnWithItems"] = {
										[1] = "guitar"
									},
									["requiresKit"] = {
										[1] = "melody"
									}
								},
								["shopId"] = "2_item_shop_1"
							}
						}
						
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("BedwarsPurchaseItem"):InvokeServer(unpack(args))
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("melody")
			end
		end
	})

	local Credits
	Credits = MelodyExploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Cat V5 (qwertyui)'
    })
end)--]]

run(function()
	local HannahExploit = {Enabled = false}
	HannahExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
		Name = "HannahExploit",
		Function = function(callback)
			if callback then
				if tostring(store.queueType) == "training_room" or store.equippedKit == "hannah" then
					RunLoops:BindToHeartbeat("hannah",function()
						for i,v in pairs(game.Players:GetChildren()) do
							local args = {
								[1] = {
									["user"] = game:GetService("Players").LocalPlayer,
									["victimEntity"] = v.Character
								}
							}
		
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("HannahPromptTrigger"):InvokeServer(unpack(args))
							task.wait(0.1)
						end
					end)
				else
					HannahExploit["ToggleButton"](false) 
					warningNotification("HannahExploit", "Hannah kit required for this to work!", 7)
				end
			else
				RunLoops:UnbindFromHeartbeat("hannah")
			end
		end,
		HovorText = "Sometimes you will teleport across the map with Hannah"
	})
	local Credits
	Credits = HannahExploit.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'CatV5'
    })
end)

run(function()
	local JellyFishExploit = {}
	JellyFishExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
		Name = 'JellyFishExploit',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait()
						local args = {
							[1] = "electrify_jellyfish"
						}
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer(unpack(args))
					until not JellyFishExploit.Enabled						
				end)
			end
		end
	})
end)

run(function()
	local insta = {Enabled = false}
	insta = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
		Name = "EmberExploit",
		Function = function(callback)
			if callback then
				warningNotification("EmberExploit", "Ember blade is required for this to work", 3)
				task.spawn(function()
					repeat task.wait()
						game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.HellBladeRelease:FireServer({
							["chargeTime"] = 0.999,
							["player"] = game:GetService("Players").LocalPlayer,
							["weapon"] =game:GetService("ReplicatedStorage").Inventories:FindFirstChild(lplr.Name.."infernal_saber"),
						})
					until (not insta.Enabled)
				end)
			end
		end, 
		HoverText = "🔥ember"
	})
end)

run(function()
	local Anime = {}
	local Anime_table = {
		["AnimeWaifu1"] = 18498989965,
		["Anime2"] = {
			["ID"] = 18499238992,
			["Size"] = UDim2.new(0, 150, 0, 200)
		},
		["Anime3"] = {
			["ID"] = 18499361548,
			["Size"] = UDim2.new(0, 150, 0, 200)
		},
		["Anime4"] = 18499384179,
		["Anime5"] = 18499402527
	}
	local default_table = {
		["Size"] = UDim2.new(0, 100, 0, 200),
		["Position"] = UDim2.new(0.9, 0, 0, 0)
	}
	local anime_image_label
	local AnimeSelection = {Value = "AnimeWaifu1"}
	Anime = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = 'AnimeImages',
		Function = function(calling)
			if calling then 
				pcall(function()
					if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI") then game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI"):Destroy() end
				end)

				local chosenid = Anime_table[AnimeSelection.Value]

				local a = Instance.new("ScreenGui")
				a.Name = "ANIMEIMAGESSCREENGUI"
				a.Parent = game:GetService("Players").LocalPlayer.PlayerGui

				local b = Instance.new("ImageLabel")
				b.Parent = a
				b.BackgroundTransparency = 1

				--- CUSTOM ---
				if type(Anime_table[AnimeSelection.Value]) == "table" then
					b.Image = "rbxassetid://"..tostring(chosenid["ID"])
					b.Position = UDim2.new(0.9, 0, 0, 0)
					b.Size = UDim2.new(0, 100, 0, 200)
					for i,v in pairs(chosenid) do
						if i ~= "ID" then
							b[i] = chosenid[i]
						end
					end
				else
					b.Image = "rbxassetid://"..tostring(chosenid)
					b.Position = UDim2.new(0.9, 0, 0, 0)
					b.Size = UDim2.new(0, 100, 0, 200)
				end

				anime_image_label = b

				shared.GuiLibrary.SelfDestructEvent.Event:Connect(function()
					game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI"):Destroy()
				end)
			else
				game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("ANIMEIMAGESSCREENGUI"):Destroy()
			end
		end
	})
	local options = {}
	for i,v in pairs(Anime_table) do table.insert(options, i) end
	AnimeSelection = Anime.CreateDropdown({
		Name = "Selection",
		Function = function()
			if anime_image_label then 
				local chosenid = Anime_table[AnimeSelection.Value]
				if type(Anime_table[AnimeSelection.Value]) == "table" then
					anime_image_label.Image = "rbxassetid://"..tostring(chosenid["ID"])
					anime_image_label.Position = UDim2.new(0.9, 0, 0, 0)
					anime_image_label.Size = UDim2.new(0, 100, 0, 200)
					for i,v in pairs(chosenid) do
						if i ~= "ID" then
							anime_image_label[i] = chosenid[i]
						end
					end
				else
					anime_image_label.Image = "rbxassetid://"..tostring(chosenid)
					anime_image_label.Position = UDim2.new(0.9, 0, 0, 0)
					anime_image_label.Size = UDim2.new(0, 100, 0, 200)
				end
			end
		end,
		List = options
	})
end)

task.spawn(function()
    local tweenmodules = {"BedTP", "EmeraldTP", "DiamondTP", "MiddleTP", "Autowin", "PlayerTP"}
    local tweening = false
    repeat
    for i,v in pairs(tweenmodules) do
        pcall(function()
        if GuiLibrary.ObjectsThatCanBeSaved[v.."OptionsButton"].Api.Enabled then
            tweening = true
        end
        end)
    end
    VoidwareStore.Tweening = tweening
    tweening = false
    task.wait()
  until not vapeInjected
end)
local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
	if not argument then
    local suc, res = pcall(function()
    local notification = GuiLibrary.CreateNotification(title or "Voidware", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
    notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
    notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    if moduledisable and (module and GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.Enabled) then GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.ToggleButton(false) end
    end)
    if hault then while true do task.wait() end end end
end
local function GetMagnitudeOf2Objects(part, part2, bypass)
	local magnitude, partcount = 0, 0
	if not bypass then 
		local suc, res = pcall(function() return part.Position end)
		partcount = suc and partcount + 1 or partcount
		suc, res = pcall(function() return part2.Position end)
		partcount = suc and partcount + 1 or partcount
	end
	if partcount > 1 or bypass then 
		magnitude = bypass and (part - part2).magnitude or (part.Position - part2.Position).magnitude
	end
	return magnitude
end
local function GetTopBlock(position, smart, raycast, customvector)
	position = position or isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position
	if not position then 
		return nil 
	end
	if raycast and not workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
		if newray and smartest then
			lastblock = newray
		else
			break
		end
	end
	return lastblock
end
local function FindEnemyBed(maxdistance, highest)
	local target = nil
	local distance = maxdistance or math.huge
	local whitelistuserteams = {}
	local badbeds = {}
	if not lplr:GetAttribute("Team") then return nil end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr then
			local type, attackable = shared.vapewhitelist:get(v)
			if not attackable then
				whitelistuserteams[v:GetAttribute("Team")] = true
			end
		end
	end
	for i,v in pairs(collectionService:GetTagged("bed")) do
			local bedteamstring = string.split(v:GetAttribute("id"), "_")[1]
			if whitelistuserteams[bedteamstring] ~= nil then
			   badbeds[v] = true
		    end
	    end
	for i,v in pairs(collectionService:GetTagged("bed")) do
		if v:GetAttribute("id") and v:GetAttribute("id") ~= lplr:GetAttribute("Team").."_bed" and badbeds[v] == nil and lplr.Character and lplr.Character.PrimaryPart then
			if v:GetAttribute("NoBreak") or v:GetAttribute("PlacedByUserId") and v:GetAttribute("PlacedByUserId") ~= 0 then continue end
			local magdist = GetMagnitudeOf2Objects(lplr.Character.PrimaryPart, v)
			if magdist < distance then
				target = v
				distance = magdist
			end
		end
	end
	local coveredblock = highest and target and GetTopBlock(target.Position, true)
	if coveredblock then
		target = coveredblock.Instance
	end
	return target
end
local function FindTeamBed()
	local bedstate, res = pcall(function()
		return lplr.leaderstats.Bed.Value
	end)
	return bedstate and res and res ~= nil and res == "✅"
end
local function FindItemDrop(item)
	local itemdist = nil
	local dist = math.huge
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
    for i,v in pairs(collectionService:GetTagged("ItemDrop")) do
		if v and v.Name == item and abletocalculate() then
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v)
			if itemdistance < dist then
			itemdist = v
			dist = itemdistance
		end
		end
	end
	return itemdist
end
local function FindTarget(dist, blockRaycast, includemobs, healthmethod)
	local whitelist = shared.vapewhitelist
	local sort, entity = healthmethod and math.huge or dist or math.huge, {}
	local function abletocalculate() return lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") end
	local sortmethods = {Normal = function(entityroot, entityhealth) return abletocalculate() and GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, entityroot) < sort end, Health = function(entityroot, entityhealth) return abletocalculate() and entityhealth < sort end}
	local sortmethod = healthmethod and "Health" or "Normal"
	local function raycasted(entityroot) return abletocalculate() and blockRaycast and workspace:Raycast(entityroot.Position, Vector3.new(0, -2000, 0), store.blockRaycast) or not blockRaycast and true or false end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr and abletocalculate() and isAlive(v) and v.Team ~= lplr.Team then
			if not ({whitelist:get(v)})[2] then 
				continue
			end
			if sortmethods[sortmethod](v.Character.HumanoidRootPart, v.Character:GetAttribute("Health") or v.Character.Humanoid.Health) and raycasted(v.Character.HumanoidRootPart) then
				sort = healthmethod and v.Character.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.Character.HumanoidRootPart)
				entity.Player = v
				entity.Human = true 
				entity.RootPart = v.Character.HumanoidRootPart
				entity.Humanoid = v.Character.Humanoid
			end
		end
	end
	if includemobs then
		local maxdistance = dist or math.huge
		for i,v in pairs(store.pots) do
			if abletocalculate() and v.PrimaryPart and GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart) < maxdistance then
			entity.Player = {Character = v, Name = "PotEntity", DisplayName = "PotEntity", UserId = 1}
			entity.Human = false
			entity.RootPart = v.PrimaryPart
			entity.Humanoid = {Health = 1, MaxHealth = 1}
			end
		end
		for i,v in pairs(collectionService:GetTagged("DiamondGuardian")) do 
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
				entity.Player = {Character = v, Name = "DiamondGuardian", DisplayName = "DiamondGuardian", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
				entity.Player = {Character = v, Name = "Titan", DisplayName = "Titan", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("Drone")) do
			local plr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
			if plr and plr ~= lplr and plr.Team and lplr.Team and plr.Team ~= lplr.Team and ({VoidwareFunctions:GetPlayerType(plr)})[2] and abletocalculate() and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
					sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
					entity.Player = {Character = v, Name = "Drone", DisplayName = "Drone", UserId = 1}
					entity.Human = false
					entity.RootPart = v.PrimaryPart
					entity.Humanoid = v.Humanoid
				end
			end
		end
		for i,v in pairs(collectionService:GetTagged("Monster")) do
			if v:GetAttribute("Team") ~= lplr:GetAttribute("Team") and abletocalculate() and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, v.PrimaryPart)
				entity.Player = {Character = v, Name = "Monster", DisplayName = "Monster", UserId = 1}
				entity.Human = false
				entity.RootPart = v.PrimaryPart
				entity.Humanoid = v.Humanoid
			end
		end
	end
    end
    return entity
end
run(function()
	local Autowin = {Enabled = false}
	local AutowinNotification = {Enabled = true}
	local bedtween
	local playertween
	Autowin = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = "Autowin",
		ExtraText = function() return store.queueType:find("5v5") and "BedShield" or "Normal" end,
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton
					repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled and GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("Autowin", "Please turn off the Invisibility and GamingChair module!", 3)
						Autowin.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.InvisibilityOptionsButton.Api.Enabled then
						errorNotification("Autowin", "Please turn off the Invisibility module!", 3)
						Autowin.ToggleButton()
						return
					end
					if GuiLibrary.ObjectsThatCanBeSaved.GamingChairOptionsButton.Api.Enabled then
						errorNotification("Autowin", "Please turn off the GamingChair module!", 3)
						Autowin.ToggleButton()
						return
					end
					task.spawn(function()
						if store.matchState == 0 then repeat task.wait() until store.matchState ~= 0 or not Autowin.Enabled end
						if not shared.VapeFullyLoaded then repeat task.wait() until shared.VapeFullyLoaded or not Autowin.Enabled end
						if not Autowin.Enabled then return end
						vapeAssert(not store.queueType:find("skywars"), "Autowin", "Skywars not supported.", 7, true, true, "Autowin")
						if isAlive(lplr, true) then
							lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
							lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
						end
						table.insert(Autowin.Connections, runService.Heartbeat:Connect(function()
							pcall(function()
							if not isnetworkowner(lplr.Character.HumanoidRootPart) and (FindEnemyBed() and GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, FindEnemyBed()) > 75 or not FindEnemyBed()) then
								if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled and not VoidwareStore.GameFinished then
									lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
									lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
								end
							end
						end)
						end))
						table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
							if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
							local bed = FindEnemyBed()
							if bed and (bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") < workspace:GetServerTimeNow() or not bed:GetAttribute("BedShieldEndTime")) then
							bedtween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {CFrame = CFrame.new(bed.Position) + Vector3.new(0, 10, 0)})
							task.wait(0.1)
							bedtween:Play()
							bedtween.Completed:Wait()
							task.spawn(function()
							task.wait(1.5)
							local magnitude = GetMagnitudeOf2Objects(lplr.Character.HumanoidRootPart, bed)
							if magnitude >= 50 and FindTeamBed() and Autowin.Enabled then
								lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
							end
							end)
							if AutowinNotification.Enabled then
								local bedname = VoidwareStore.bedtable[bed] or "unknown"
								task.spawn(InfoNotification, "Autowin", "Destroying "..bedname:lower().." team's bed", 5)
							end
							if not isEnabled("Nuker") then
								--GuiLibrary.ObjectsThatCanBeSaved.NukerOptionsButton.Api.ToggleButton(false)
							end
							repeat task.wait() until FindEnemyBed() ~= bed or not isAlive()
							if FindTarget(45, store.blockRaycast).RootPart and isAlive() then
								if AutowinNotification.Enabled then
									local team = VoidwareStore.bedtable[bed] or "unknown"
									task.spawn(InfoNotification, "Autowin", "Killing "..team:lower().." team's teamates", 5)
								end
								repeat
								local target = FindTarget(45, store.blockRaycast)
								if not target.RootPart then break end
								playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
								playertween:Play()
								task.wait()
								until not FindTarget(45, store.blockRaycast).RootPart or not Autowin.Enabled or not isAlive()
							end
							if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
								lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
							end
							elseif FindTarget(nil, store.blockRaycast).RootPart then
								task.wait()
								local target = FindTarget(nil, store.blockRaycast)
								playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
								playertween:Play()
								if AutowinNotification.Enabled then
									task.spawn(InfoNotification, "Autowin", "Killing "..target.Player.DisplayName.." ("..(target.Player.Team and target.Player.Team.Name or "neutral").." Team)", 5)
								end
								playertween.Completed:Wait()
								if not Autowin.Enabled then return end
									if FindTarget(50, store.blockRaycast).RootPart and isAlive() then
										repeat
										target = FindTarget(50, store.blockRaycast)
										if not target.RootPart or not isAlive() then break end
										playertween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
										playertween:Play()
										task.wait()
										until not FindTarget(50, store.blockRaycast).RootPart or not Autowin.Enabled or not isAlive()
									end
								if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
									lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
									lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
								end
							else
							if VoidwareStore.GameFinished then return end
							lplr.Character.Humanoid:TakeDamage(lplr.Character.Humanoid.Health)
							lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
							end
						end))
						table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
							if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
							if not VoidwareStore.GameFinished then return end
							local oldpos = lplr.Character.HumanoidRootPart.CFrame
							repeat 
							lplr.Character.HumanoidRootPart.CFrame = oldpos
							task.wait()
							until not isAlive(lplr, true) or not Autowin.Enabled
						end))
					end)
				end)
			else
				pcall(function() playertween:Cancel() end)
				pcall(function() bedtween:Cancel() end)
			end
		end,
		HoverText = "best paid autowin 2023!1!!! rel11!11!1"
	})
end)

--[[run(function()
	local function getItemNear(itemName, inv)
        for slot, item in pairs(inv or store.localInventory.inventory.items) do
            if item.itemType == itemName or item.itemType:find(itemName) then
                return item, slot
            end
        end
        return nil
    end
	local Disabler = {Enabled = false}
	local ZephyrSpeed = {Value = 1}
	local DisablerMode = {Value = "Scythe"}
	local mode = "Scythe"
	local sd = false
	local csd = false
	local zd = false
	local fd = false
	local function DeleteClientSidedAnticheat()
		if lplr.PlayerScripts.Modules:FindFirstChild("anticheat") then
			lplr.PlayerScripts.Modules.anticheat:Destroy()
		end
		if lplr.PlayerScripts:FindFirstChild("GameAnalyticsClient") then
			lplr.PlayerScripts.GameAnalyticsClient:Destroy()
		end
		if game:GetService("ReplicatedStorage").Modules:FindFirstChild("anticheat") then
			game:GetService("ReplicatedStorage").Modules:FindFirstChild("anticheat"):Destroy()
		end
	end
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
		Name = "Disabler",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if zd then
							shared.disablerZephyr = true
						else
							shared.disablerZephyr = false
						end
						if fd then
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("TridentUnanchor"):InvokeServer()
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("TridentAnchor"):InvokeServer()
						end
						if sd then
							local item = getItemNear("scythe")
							if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then 
								bedwars.Client:Get("ScytheDash"):SendToServer({direction = lplr.Character.HumanoidRootPart.CFrame.LookVector*9e9})
								if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
									shared.GlobalStore.scythe = tick() + 1
								end
							end
						end
					until (not Disabler.Enabled)
				end)
				if csd then
					DeleteClientSidedAnticheat()
					warningNotification("Cat", "Disabled Client", 3)
				end
			else
				shared.disablerZephyr = false
			end
		end,
		HoverText = "Attempts to help bypass the AntiCheat",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	ClientS = Disabler.CreateToggle({
		Name = "Client Sided",
		Default = true,
		Function = function(callback)
			csd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	Scythe = Disabler.CreateToggle({
		Name = "Scythe",
		Default = true,
		Function = function(callback)
			sd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	Zephyr = Disabler.CreateToggle({
		Name = "Zephyr",
		Default = true,
		Function = function(callback)
			zd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})
	--[[Float = Disabler.CreateToggle({
		Name = "Float (EXPERIMENTAL)",
		Default = true,
		Function = function(callback)
			fd = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end
	})]]--
	--[[ZephyrSpeed = Disabler.CreateSlider({
		Name = "Speed Multiplier",
		Min = 0,
		Max = 2,
		Function = function(callback)
			shared.disablerBoost = callback
			Disabler.ToggleButton(false)
			Disabler.ToggleButton(false)
		end,
		Default = 1
	})
end)--]]

run(function()
	local GetHost = {Enabled = false}
	GetHost = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
		Name = "GetHost",
		HoverText = ":troll:",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					warningNotification("GetHost", "This module is only for show. None of the settings will work.", 5)
					game.Players.LocalPlayer:SetAttribute("CustomMatchRole", "host")
				end)
			end
		end
	})
end)

run(function()
	local lplr = game:GetService("Players").LocalPlayer
	local lplr_gui = lplr.PlayerGui

	local function handle_tablist(ui)
		local frame = ui:FindFirstChild("TabListFrame")
		if frame then
			local plrs_frame = frame:FindFirstChild("4"):FindFirstChild("3"):FindFirstChild("1")
			if plrs_frame then
				local side_1 = plrs_frame:WaitForChild("2")
				local side_2 = plrs_frame:WaitForChild("3")
				local sides = {side_1, side_2}

				for _, side in pairs(sides) do
					if side then
						--print("Processing side:", side.Name)
						local side_teams = {}
						local side_teams_players = {}

						for _, child in pairs(side:GetChildren()) do
							if child:IsA("Frame") then
								table.insert(side_teams, child)
							end
						end

						for _, team in pairs(side_teams) do
							local team_plrs_list = team:WaitForChild("3")
							local plrs = team_plrs_list:GetChildren()

							for _, plr in pairs(plrs) do
								if plr:IsA("Frame") and plr.Name == "PlayerRowContainer" then
									table.insert(side_teams_players, plr)
								end
							end
						end

						for _, player_row in pairs(side_teams_players) do
							local plr_name_frame = player_row:WaitForChild("Content"):WaitForChild("PlayerRow"):WaitForChild("3"):WaitForChild("PlayerNameContainer"):WaitForChild("3"):WaitForChild("2"):FindFirstChild("PlayerName")

							if plr_name_frame then
								local function extract_name(formatted_text)
									local name = formatted_text:match("</font>%s*(.+)")
									return name
								end

								local current_text = plr_name_frame.Text
								local name = extract_name(current_text)
								local streamer_mode = true

								for _, player in pairs(game:GetService("Players"):GetPlayers()) do
									if player.DisplayName == name then
										streamer_mode = false
										break
									end
								end

								if not streamer_mode then
									local needed_plr
									for i,v in pairs(game:GetService("Players"):GetPlayers()) do
										if game:GetService("Players"):GetPlayers()[i].DisplayName == name then
											needed_plr = game:GetService("Players"):GetPlayers()[i]
										end
									end
									if needed_plr then
										local function get_player_rank(player)
											local rank = shared.vapewhitelist:get(player)
											if rank == 1 then
												return "INF"
											elseif rank == 2 then
												return "Owner"
											else
												return "Normal"
											end
										end
										local rank = get_player_rank(needed_plr)
										local function add_colored_text(existing_text, new_text, color3)
											local r = math.floor(color3.R * 255)
											local g = math.floor(color3.G * 255)
											local b = math.floor(color3.B * 255)
											local new_colored_text = string.format('<font color="rgb(%d,%d,%d)">[%s]</font> ', r, g, b, new_text)
											local updated_text = new_colored_text .. existing_text
											return updated_text
										end

										local tag_data = shared.vapewhitelist:tag(needed_plr)
										if tag_data and #tag_data > 0 then
											if tag_data[1]["text"] == "VOIDWARE USER" then rank = "Normal" end
											local tag_text = tag_data[1]["text"].." - "..rank
											local tag_color = tag_data[1]["color"]
											local updated_text = add_colored_text(current_text, tag_text, tag_color)
											
											if updated_text then
												plr_name_frame.Text = updated_text
											end
										else
											print("Tag data missing for player:", name)
										end
									end
								else
									print("Streamer mode is on for player:", name)
								end
							else
								print("PlayerName frame not found for player row")
							end
						end
					else
						print("Side is nil")
					end
				end
			else
				print("Players frame not found")
			end
		else
			print("TabListFrame not found")
		end
	end

	local function handle_new_ui(ui)
		if tostring(ui) == "TabListScreenGui" then
			handle_tablist(ui)
		end
	end

	lplr_gui.ChildAdded:Connect(handle_new_ui)
end)

run(function()
	local HackerDetector = {}
	local HackerDetectorInfFly = {}
	local HackerDetectorTeleport = {}
	local HackerDetectorNuker = {}
	local HackerDetectorFunny = {}
	local HackerDetectorInvis = {}
	local HackerDetectorName = {}
	local HackerDetectorSpeed = {}
	local HackerDetectorFileCache = {}
	local pastesploit
	local detectedusers = {
		InfiniteFly = {},
		Teleport = {},
		Nuker = {},
		AnticheatBypass = {},
		Invisibility = {},
		Speed = {},
		Name = {},
		Cache = {}
	}
	local distances = {
		windwalker = 80
	}
	local function cachedetection(player, detection)
		if not HackerDetectorFileCache.Enabled then 
			return 
		end
		if type(response) ~= 'table' then 
			response = {}
		end
		if response[player.Name] then 
			if table.find(response[player.Name], detection) == nil then 
				table.insert(response[player.Name].Detections, detection) 
			end
		else
			response[player.Name] = {DisplayName = player.DisplayName, UserId = tostring(player.DisplayName), Detections = {detection}}
		end
	end
	local detectionmethods = {
		Teleport = function(plr)
			if table.find(detectedusers.Teleport, plr) then 
				return 
			end
			if store.queueType:find('bedwars') == nil or plr:GetAttribute('Spectator') then 
				return 
			end
			local lastbwteleport = plr:GetAttribute('LastTeleported')
			table.insert(HackerDetector.Connections, plr:GetAttributeChangedSignal('LastTeleported'):Connect(function() lastbwteleport = plr:GetAttribute('LastTeleported') end))
			table.insert(HackerDetector.Connections, plr.CharacterAdded:Connect(function()
				oldpos = Vector3.zero
				if table.find(detectedusers.Teleport, plr) then 
					return 
				end
				 repeat task.wait() until isAlive(plr, true)
				 local oldpos2 = plr.Character.HumanoidRootPart.Position 
				 task.delay(2, function()
					if isAlive(plr, true) then 
						local newdistance = (plr.Character.HumanoidRootPart.Position - oldpos2).Magnitude 
						if newdistance >= 400 and (plr:GetAttribute('LastTeleported') - lastbwteleport) == 0 then 
							InfoNotification('HackerDetector', plr.DisplayName..' is using Teleport Exploit!', 100) 
							table.insert(detectedusers.Teleport, plr)
							cachedetection(plr, 'Teleport')
							whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
							--[[if RenderFunctions.playerTags[plr] == nil then 
								RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
							end--]]
						end 
					end
				 end)
			end))
		end,
		Speed = function(plr) 
			repeat task.wait() until (store.matchState ~= 0 or not HackerDetector.Enabled or not HackerDetectorSpeed.Enabled)
			if table.find(detectedusers.Speed, plr) then 
				return 
			end
			local lastbwteleport = plr:GetAttribute('LastTeleported')
			local oldpos = Vector3.zero 
			table.insert(HackerDetector.Connections, plr:GetAttributeChangedSignal('LastTeleported'):Connect(function() lastbwteleport = plr:GetAttribute('LastTeleported') end)) 
			table.insert(HackerDetector.Connections, plr.CharacterAdded:Connect(function() oldpos = Vector3.zero end))
			repeat 
				if isAlive(plr, true) then 
					local magnitude = (plr.Character.HumanoidRootPart.Position - oldpos).Magnitude
					if (plr:GetAttribute('LastTeleported') - lastbwteleport) ~= 0 and magnitude >= ((distances[plr:GetAttribute('PlayingAsKit') or ''] or 25) + (playerRaycasted(plr, Vector3.new(0, -15, 0)) and 0 or 40)) then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using speed!', 60)
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						--[[if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end--]]
					end
					oldpos = plr.Character.HumanoidRootPart.Position
					task.wait(2.5)
					lastbwteleport = plr:GetAttribute('LastTeleported')
				end
			until not task.wait() or table.find(detectedusers.Speed, plr) or (not HackerDetector.Enabled or not HackerDetectorSpeed.Enabled)
		end,
		InfiniteFly = function(plr) 
			repeat 
				if isAlive(plr, true) then 

					local magnitude = (lplr.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
					if magnitude >= 10000 and playerRaycast(plr) == nil and playerRaycast({Character = {PrimaryPart = {Position = lplr.Character.HumanoidRootPart.Position}}}) then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using InfiniteFly!', 60) 
						cachedetection(plr, 'InfiniteFly')
						table.insert(detectedusers.InfiniteFly, plr)
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						--[[if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end--]]
					end
					task.wait(2.5)
				end
			until not task.wait() or table.find(detectedusers.InfiniteFly, plr) or (not HackerDetector.Enabled or not HackerDetectorInfFly.Enabled)
		end,
		Invisibility = function(plr) 
			if table.find(detectedusers.Invisibility, plr) then 
				return 
			end
			repeat 
				for i,v in next, (isAlive(plr, true) and plr.Character.Humanoid:GetPlayingAnimationTracks() or {}) do 
					if v.Animation.AnimationId == 'http://www.roblox.com/asset/?id=11335949902' or v.Animation.AnimationId == 'rbxassetid://11335949902' then 
						InfoNotification('HackerDetector', plr.DisplayName..' is using Invisibility!', 60) 
						table.insert(detectedusers.Invisibility, plr)
						cachedetection(plr, 'Invisibility')
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						--[[if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end--]]
					end
				end
				task.wait(0.5)
			until table.find(detectedusers.Invisibility, plr) or (not HackerDetector.Enabled or not HackerDetectorInvis.Enabled)
		end,
		Name = function(plr) 
			repeat task.wait() until pastesploit 
			local lines = pastesploit:split('\n') 
			for i,v in next, lines do 
				if v:find('local Owner = ') then 
					local name = lines[i]:gsub('local Owner =', ''):gsub('"', ''):gsub("'", '') 
					if plr.Name == name then 
						InfoNotification('HackerDetector', plr.DisplayName..' is the owner of Godsploit! They\'re is most likely cheating.', 60) 
						cachedetection(plr, 'Name')
						whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
						--[[if RenderFunctions.playerTags[plr] == nil then 
							RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
						end --]]
					end
				end
			end
			for i,v in next, ({'godsploit', 'alsploit', 'renderintents'}) do 
				local user = plr.Name:lower():find(v) 
				local display = plr.DisplayName:lower():find(v)
				if user or display then 
					InfoNotification('HackerDetector', plr.DisplayName..' has "'..v..'" in their '..(user and 'username' or 'display name')..'! They might be cheating.', 20)
					cachedetection(plr, 'Name') 
					return 
				end
			end
		end, 
		Cache = function(plr)
			local success, response = pcall(function()
				return httpService:JSONDecode(readfile('vape/Libraries/exploiters.json')) 
			end) 
			if type(response) == 'table' and response[plr.Name] then 
				InfoNotification('HackerDetector', plr.DisplayName..' is cached on the exploiter database!', 30)
				table.insert(detectedusers.Cached, plr)
				whitelist.customtags[plr.Name] = {{text = 'VAPE USER', color = Color3.new(1, 1, 0)}}
				--[[if RenderFunctions.playerTags[plr] == nil then 
					RenderFunctions:CreatePlayerTag(plr, 'SCRIPT KIDDIE', 'FF0000') 
				end--]]
			end
		end
	}
	local function bootdetections(player)
		local detectiontoggles = {InfiniteFly = HackerDetectorInfFly, Teleport = HackerDetectorTeleport, Nuker = HackerDetectorNuker, Invisibility = HackerDetectorInvis, Speed = HackerDetectorSpeed, Name = HackerDetectorName, Cache = HackerDetectorFileCache}
		for i, detection in next, detectionmethods do 
			if detectiontoggles[i].Enabled then
			   task.spawn(detection, player)
			end
		end
	end
	HackerDetector = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = 'HackerDetector',
		HoverText = 'Notify when someone is\nsuspected of using exploits.',
		ExtraText = function() return 'Vanilla' end,
		Function = function(calling) 
			if calling then 
				for i,v in next, playersService:GetPlayers() do 
					if v ~= lplr then 
						bootdetections(v) 
					end 
				end
				table.insert(HackerDetector.Connections, playersService.PlayerAdded:Connect(bootdetections))
			end
		end
	})
	HackerDetectorTeleport = HackerDetector.CreateToggle({
		Name = 'Teleport',
		Default = true,
		Function = function() end
	})
	HackerDetectorInfFly = HackerDetector.CreateToggle({
		Name = 'InfiniteFly',
		Default = true,
		Function = function() end
	})
	HackerDetectorInvis = HackerDetector.CreateToggle({
		Name = 'Invisibility',
		Default = true,
		Function = function() end
	})
	HackerDetectorNuker = HackerDetector.CreateToggle({
		Name = 'Nuker',
		Default = true,
		Function = function() end
	})
	HackerDetectorSpeed = HackerDetector.CreateToggle({
		Name = 'Speed',
		Default = true,
		Function = function() end
	})
	HackerDetectorName = HackerDetector.CreateToggle({
		Name = 'Name',
		Default = true,
		Function = function() end
	})
	HackerDetectorFileCache = HackerDetector.CreateToggle({
		Name = 'Cached detections',
		HoverText = 'Writes (vape/Libraries/exploiters.json)\neverytime someone is detected.',
		Default = true,
		Function = function() end
	})
end)

run(function()
	local DoubleHighJump = {Enabled = false}
	local DoubleHighJumpHeight = {Value = 500}
	local DoubleHighJumpHeight2 = {Value = 500}
	local jumps = 0
	DoubleHighJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "DoubleHighJump",
		NoSave = true,
		HoverText = "A very interesting high jump.",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if entityLibrary.isAlive and lplr.Character.Humanoid.FloorMaterial == Enum.Material.Air or jumps > 0 then 
						DoubleHighJump.ToggleButton(false) 
						return
					end
					for i = 1, 2 do 
						if not entityLibrary.isAlive then
							DoubleHighJump.ToggleButton(false) 
							return  
						end
						if i == 2 and lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then 
							continue
						end
						lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, i == 1 and DoubleHighJumpHeight.Value or DoubleHighJumpHeight2.Value, 0)
						jumps = i
						task.wait(i == 1 and 1 or 0.3)
					end
					task.spawn(function()
						for i = 1, 20 do 
							if entityLibrary.isAlive then 
								lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
							end
						end
					end)
					task.delay(1.6, function() jumps = 0 end)
					if DoubleHighJump.Enabled then
					   DoubleHighJump.ToggleButton(false)
					end
				end)
			else
				VoidwareStore.jumpTick = tick() + 5
			end
		end
	})
	DoubleHighJumpHeight = DoubleHighJump.CreateSlider({
		Name = "First Jump",
		Min = 50,
		Max = 500,
		Default = 500,
		Function = function() end
	})
	DoubleHighJumpHeight2 = DoubleHighJump.CreateSlider({
		Name = "Second Jump",
		Min = 50,
		Max = 450,
		Default = 450,
		Function = function() end
	})
end)

local staffdetector = {};
run(function()
	local teleport = game:GetService('TeleportService');
	local httpservice = game:GetService("HttpService");
	local players = game:GetService("Players")
    local staffdetectoraction = {Value = 'Uninject'};
    local staffdetectorfamous = {};
    local stafftasks = {};
    local staffconfig = {staffaccounts = {}};
    local knownstaff = {};
    local staffdetectorinitiated;
    local staffdetectionfuncs = setmetatable({}, {
        __newindex = function(self, index, func)
            local newfunc = function(...)
                for taskIndex, taskValue in pairs(stafftasks) do 
                    pcall(task.cancel, taskValue);
                end
                table.clear(stafftasks);
                staffdetectorinitiated = true;
                task.spawn(function()
                    pcall(function() bedwars.QueueController:leaveParty() end);
                end);
                return func(...);
            end
            if rawget(self, index) == nil then 
                return rawset(self, index, newfunc); 
            end
        end
    })
    staffdetectionfuncs.Notify = void;
    staffdetectionfuncs.Uninject = function() 
        GuiLibrary.SelfDestruct()
    end
    staffdetectionfuncs.Lobby = function() 
        teleport:Teleport(6872265039)
    end
    staffdetectionfuncs.Config = function()
        for buttonName, buttonData in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
            if buttonData.Type == 'OptionsButton' and table.find(staffconfig.legitmodules, buttonName:gsub('OptionsButton', '')) == nil then 
                GuiLibrary.SaveSettings = function() end;
                if buttonData.Api.Enabled then
                    buttonData.Api.ToggleButton();
                end
                GuiLibrary.RemoveObject(buttonName);
            end
        end
    end;
	local function NotifyUser(text)
		game:GetService('StarterGui'):SetCore(
			'ChatMakeSystemMessage', 
			{
				Text = text, 
				Color = Color3.fromRGB(255, 0, 0), 
				Font = Enum.Font.GothamBold,
				FontSize = Enum.FontSize.Size24
			}
		)
	end
    local savestaffdata = function(player, detection)
        local success, json = pcall(function() 
            return httpservice:JSONDecode(readfile('vape/Libraries/staffdata.json'))
        end);
        if not success then 
            json = {};
        end;
        table.insert(json, {
            Username = player.Name, 
            DisplayName = player.DisplayName, 
            Detection = detection, 
            Tick = tick()
        });
        if isfolder('vape/Libraries') then 
            writefile('vape/Libraries/staffdata.json', httpservice:JSONEncode(json));
        end
    end;
    local matchtag = function(tag)
        if tag.ClassName ~= 'StringValue' or tag.Value == tag.Parent.Parent:GetAttribute('ClanTag') then 
            return; 
        end
        local lowerTagValue = tag.Value:lower()
        if lowerTagValue:find('mod') or lowerTagValue:find('dev') or lowerTagValue:find('owner') then 
            return true;
        end
        if staffdetectorfamous.Enabled and lowerTagValue:find('famous') then 
            return true;
        end
    end;
    local getfriends = function(player)
        local friends = {};
        local success, page = pcall(players.GetFriendsAsync, players, player.UserId);
        if success then
            repeat
                for _, friend in pairs(page:GetCurrentPage()) do
                    table.insert(friends, friend.UserId);
                end
                if not page.IsFinished then 
                    page:AdvanceToNextPageAsync();
                end
            until page.IsFinished
        end
        return friends;
    end;
    local staffdetectorLoop = function(player)
        local tags
        local newtagconnection
        stafftasks[#stafftasks + 1] = task.spawn(function()
            tags = player:WaitForChild('Tags', math.huge);
            for _, tag in ipairs(tags:GetChildren()) do 
                if matchtag(tag) then
                    savestaffdata(player, 'TAG');
					NotifyUser("[StaffDetector]: "..`A special player has been detected in your match (@{player.DisplayName} [{tag.Value:upper()}]).`)
                    errorNotification('StaffDetector', `A special player has been detected in your match (@{player.DisplayName} [{tag.Value:upper()}]).`, 60);
                    staffdetectionfuncs[staffdetectoraction.Value]();
                end
            end
            newtagconnection = tags.ChildAdded:Connect(function(newTag)
                if matchtag(newTag) then
					NotifyUser("[StaffDetector]: "..`A special player has been detected in your match (@{player.DisplayName} [{newTag.Value:upper()}]).`)
                    errorNotification('StaffDetector', `A special player has been detected in your match (@{player.DisplayName} [{newTag.Value:upper()}]).`, 60);
                    savestaffdata(player, 'TAG');
                    newtagconnection:Disconnect();
                    staffdetectionfuncs[staffdetectoraction.Value]();
                end
            end);
            table.insert(staffdetector.Connections, newtagconnection)
        end)
        repeat 
            if table.find(staffconfig.staffaccounts, player.UserId) or table.find(knownstaff, player.UserId) then 
				NotifyUser("[StaffDetector]: "..`A special player has been detected in your match (@{player.DisplayName} [{v.Value:upper()}]).`)
                errorNotification('StaffDetector', `A special player has been detected in your match (@{player.DisplayName} [{v.Value:upper()}]).`, 60);
                staffdetectionfuncs[staffdetectoraction.Value]();
            end
            task.wait()
        until (not staffdetector.Enabled);
    end;
    staffdetector = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
        Name = 'StaffDetector',
        HoverText = 'Automatically takes action on staff join.',
        Function = function(calling)
            if calling then 
                if staffdetectorinitiated then return end;
                local players = game:GetService("Players")
                for _, player in ipairs(players:GetPlayers()) do 
                    stafftasks[#stafftasks + 1] = task.spawn(staffdetectorLoop, player)
                end;
                table.insert(staffdetector.Connections, players.PlayerAdded:Connect(function(player)
                    stafftasks[#stafftasks + 1] = task.spawn(staffdetectorLoop, player)
                end))
            else 
                for _, taskValue in pairs(stafftasks) do 
                    pcall(task.cancel, taskValue);
                end
                table.clear(stafftasks);
            end
        end
    })
    staffdetectoraction = staffdetector.CreateDropdown({
        Name = 'Action',
        List = {'Uninject', 'Lobby', 'Config', 'Notify'},
        Function = void
    })
    staffdetectorfamous = staffdetector.CreateToggle({
        Name = 'Famous',
        HoverText = 'Detects famous people in bw comm too.',
        Function = void
    })
end);

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not staffdetector.Enabled then
		staffdetector.ToggleButton(false)
	end
end)

--[[local isEnabled = function() return false end
local function isEnabled(module)
	return GuiLibrary.ObjectsThatCanBeSaved[module] and GuiLibrary.ObjectsThatCanBeSaved[module].Api.Enabled and true or false
end
local isAlive = function() return false end
isAlive = function(plr, nohealth) 
	plr = plr or lplr
	local alive = false
	if plr.Character and plr.Character:FindFirstChildWhichIsA('Humanoid') and plr.Character.PrimaryPart and plr.Character:FindFirstChild('Head') then 
		alive = true
	end
	local success, health = pcall(function() return plr.Character:FindFirstChildWhichIsA('Humanoid').Health end)
	if success and health <= 0 and not nohealth then
		alive = false
	end
	return alive
end
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
run(function() 
	local runService = game:GetService("RunService")
	local Invisibility = {}
	local collideparts = {}
	local invisvisual = {}
	local visualrootcolor = {Hue = 0, Sat = 0, Sat = 0}
	local oldcamoffset = Vector3.zero
	local oldcolor
	Invisibility = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = 'Invisibility',
		HoverText = 'Makes your invisible.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
				repeat task.wait() until ((isAlive(lplr, true) or not Invisibility.Enabled) and (isEnabled('Lobby Check', 'Toggle') == false or store.matchState ~= 0))
				if not Invisibility.Enabled then 
					return 
				end
				task.wait(0.5)
				local anim = Instance.new('Animation')
				anim.AnimationId = 'rbxassetid://11360825341'
				local anim2 = lplr.Character.Humanoid.Animator:LoadAnimation(anim) 
				for i,v in next, lplr.Character:GetDescendants() do 
					if v:IsA('BasePart') and v.CanCollide and v ~= lplr.Character.HumanoidRootPart then 
						v.CanCollide = false 
						table.insert(collideparts, v) 
					end 
				end
				table.insert(Invisibility.Connections, runService.Stepped:Connect(function()
					for i,v in next, collideparts do 
						pcall(function() v.CanCollide = false end)
					end
				end))
				repeat 
					if isEnabled('AnimationPlayer') then 
						GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.ToggleButton()
					end
					if isAlive(lplr, true) and isnetworkowner(lplr.Character.HumanoidRootPart) then 
						lplr.Character.HumanoidRootPart.Transparency = (invisvisual.Enabled and 0.6 or 1)
						oldcolor = lplr.Character.HumanoidRootPart.Color
						lplr.Character.HumanoidRootPart.Color = Color3.fromHSV(visualrootcolor.Hue, visualrootcolor.Sat, visualrootcolor.Value)
						anim2:Play(0.1, 9e9, 0.1) 
					elseif Invisibility.Enabled then 
						Invisibility.ToggleButton() 
						break 
					end	
					task.wait()
				until not Invisibility.Enabled
			end)
			else
				for i,v in next, collideparts do 
					pcall(function() v.CanCollide = true end) 
				end
				table.clear(collideparts)
				if isAlive(lplr, true) then 
					lplr.Character.HumanoidRootPart.Transparency = 1 
					lplr.Character.HumanoidRootPart.Color = oldcolor
					task.wait()
				    bedwars.SwordController:swingSwordAtMouse() 
				end
			end
		end
	})
	invisvisual = Invisibility.CreateToggle({
		Name = 'Show Root',
		Function = function(calling)
			pcall(function() visualrootcolor.Object.Visible = calling end) 
		end
	})
	visualrootcolor = Invisibility.CreateColorSlider({
		Name = 'Root Color',
		Function = function() end
	})
	visualrootcolor.Object.Visible = false
end)--]]
local Customisation = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api

run(function()
	local ZoomUnlocker = {Enabled = false}
	local ZoomUnlockerMode = {Value = 'Infinite'}
	local ZoomUnlockerZoom = {Value = 500}
	local ZoomConnection, OldZoom = nil, nil
	ZoomUnlocker = Customisation.CreateOptionsButton({
		Name = 'ZoomUnlocker',
        HoverText = 'Unlocks the abillity to zoom more.',
		Function = function(callback)
			if callback then
				OldZoom = lplr.CameraMaxZoomDistance
				ZoomUnlocker = runService.Heartbeat:Connect(function()
					if ZoomUnlockerMode.Value == 'Infinite' then
						lplr.CameraMaxZoomDistance = 9e9
					else
						lplr.CameraMaxZoomDistance = ZoomUnlockerZoom.Value
					end
				end)
			else
				if ZoomUnlocker then ZoomUnlocker:Disconnect() end
				lplr.CameraMaxZoomDistance = OldZoom
				OldZoom = nil
			end
		end,
        Default = false,
		ExtraText = function()
            return ZoomUnlockerMode.Value
        end
	})
	ZoomUnlockerMode = ZoomUnlocker.CreateDropdown({
		Name = 'Mode',
		List = {
			'Infinite',
			'Custom'
		},
		HoverText = 'Mode to unlock the zoom.',
		Value = 'Infinite',
		Function = function() end
	})
	ZoomUnlockerZoom = ZoomUnlocker.CreateSlider({
		Name = 'Zoom',
		Min = OldZoom or 13,
		Max = 1000,
		HoverText = 'Amount to unlock the zoom.',
		Function = function() end,
		Default = 500
	})
end)

--[[run(function()
	local entityLibrary = shared.vapeentity
    local Headless = {Enabled = false};
    Headless = Customisation.CreateOptionsButton({
		PerformanceModeBlacklisted = true,
        Name = 'Headless',
        HoverText = 'Makes your head transparent.',
        Function = function(callback)
            if callback then
				local old, y = nil, nil;
				local x = old;
                task.spawn(function()
                    repeat task.wait()
						entityLibrary.character.Head.Transparency = 1
						y = entityLibrary.character.Head:FindFirstChild('face');
						if y then
							old = y;
							y.Parent = workspace;
						end;
						for _, v in next, entityLibrary.character:GetChildren() do
							if v:IsA'Accessory' then
								v.Handle.Transparency = 0
							end
						end
                    until not Headless.Enabled;
                end);
            else
                entityLibrary.character.Head.Transparency = 0;
				for _, v in next, entityLibrary.character:GetChildren() do
					if v:IsA'Accessory' then
						v.Handle.Transparency = 0;
					end;
				end;
				if old then
					old.Parent = entityLibrary.character.Head;
					old = x;
				end;
            end;
        end,
        Default = false
    })
end)--]]

--[[run(function()
	local NoNameTag = {Enabled = false}
	NoNameTag = Customisation.CreateOptionsButton({
		PerformanceModeBlacklisted = true,
		Name = 'NoNameTag',
        HoverText = 'Removes your NameTag.',
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat('NoNameTag', function()
					pcall(function()
						lplr.Character.Head.Nametag:Destroy()
					end)
				end)
			else
				RunLoops:UnbindFromHeartbeat('NoNameTag')
			end
		end,
        Default = false
	})
end)--]]

run(function()
    local GuiLibrary = shared.GuiLibrary
	local texture_pack = {};
	texture_pack = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'TexturePack',
		HoverText = 'Customizes your texture pack.',
		Function = function(callback)
			if callback then
				if not shared.VapeSwitchServers then
					warningNotification("TexturePack - Credits", "Credits to melo and star", 1.5)
				end
				if texture_pack_m.Value == 'Noboline' then
					local Players = game:GetService("Players")
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local Workspace = game:GetService("Workspace")
					local objs = game:GetObjects("rbxassetid://13988978091")
					local import = objs[1]
					import.Parent = game:GetService("ReplicatedStorage")
					local index = {
						{
							name = "wood_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Wood_Sword"),
						},
						{
							name = "stone_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Stone_Sword"),
						},
						{
							name = "iron_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Iron_Sword"),
						},
						{
							name = "diamond_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						{
							name = "emerald_sword",
							offset = CFrame.Angles(math.rad(0), math.rad(-100), math.rad(-90)),
							model = import:WaitForChild("Emerald_Sword"),
						},
						{
							name = "wood_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
							model = import:WaitForChild("Wood_Pickaxe"),
						},
						{
							name = "stone_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
							model = import:WaitForChild("Stone_Pickaxe"),
						},
						{
							name = "iron_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-190), math.rad(-95)),
							model = import:WaitForChild("Iron_Pickaxe"),
						},
						{
							name = "diamond_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
							model = import:WaitForChild("Diamond_Pickaxe"),
						},
						{
							name = "wood_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Wood_Axe"),
						},
						{
							name = "stone_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Stone_Axe"),
						},
						{
							name = "iron_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Iron_Axe"),
						},
						{
							name = "diamond_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-95)),
							model = import:WaitForChild("Diamond_Axe"),
						},
					}
					local func = Workspace.Camera.Viewmodel.ChildAdded:Connect(function(tool)
						if not tool:IsA("Accessory") then
							return
						end
						for _, v in ipairs(index) do
							if v.name == tool.Name then
								for _, part in ipairs(tool:GetDescendants()) do
									if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
										part.Transparency = 1
									end
								end
								local model = v.model:Clone()
								model.CFrame = tool.Handle.CFrame * v.offset
								model.CFrame = model.CFrame * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
								model.Parent = tool
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = model
								weld.Part1 = tool.Handle
								weld.Parent = model
								local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
								for _, part in ipairs(tool2:GetDescendants()) do
									if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
										part.Transparency = 1
										if part.Name == "Handle" then
											part.Transparency = 0
										end
									end
								end
							end
						end
					end)
				elseif texture_pack_m.Value == 'Aquarium' then
					local objs = game:GetObjects("rbxassetid://14217388022")
					local import = objs[1]
					
					import.Parent = game:GetService("ReplicatedStorage")
					
					local index = {
					
						{
							name = "wood_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Wood_Sword"),
						},
						
						{
							name = "stone_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Stone_Sword"),
						},
						
						{
							name = "iron_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Iron_Sword"),
						},
						
						{
							name = "diamond_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						
						{
							name = "emerald_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						
						{
							name = "Rageblade",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						
					}
					
					local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
						
						if(not tool:IsA("Accessory")) then return end
						
						for i,v in pairs(index) do
						
							if(v.name == tool.Name) then
							
								for i,v in pairs(tool:GetDescendants()) do
						
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										
										v.Transparency = 1
										
									end
								
								end
							
								local model = v.model:Clone()
								model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
								model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model.Parent = tool
								
								local weld = Instance.new("WeldConstraint",model)
								weld.Part0 = model
								weld.Part1 = tool:WaitForChild("Handle")
								
								local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
								
								for i,v in pairs(tool2:GetDescendants()) do
						
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										
										v.Transparency = 1
										
									end
								
								end
								
								local model2 = v.model:Clone()
								model2.Anchored = false
								model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
								model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model2.CFrame *= CFrame.new(0.4,0,-.9)
								model2.Parent = tool2
								
								local weld2 = Instance.new("WeldConstraint",model)
								weld2.Part0 = model2
								weld2.Part1 = tool2:WaitForChild("Handle")
							
							end
						
						end
						
					end)
				else
					local Players = game:GetService("Players")
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local Workspace = game:GetService("Workspace")
					local objs = game:GetObjects("rbxassetid://14356045010")
					local import = objs[1]
					import.Parent = game:GetService("ReplicatedStorage")
					index = {
						{
							name = "wood_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Wood_Sword"),
						},
						{
							name = "stone_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Stone_Sword"),
						},
						{
							name = "iron_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Iron_Sword"),
						},
						{
							name = "diamond_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Diamond_Sword"),
						},
						{
							name = "emerald_sword",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-90)),
							model = import:WaitForChild("Emerald_Sword"),
						}, 
						{
							name = "rageblade",
							offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
							model = import:WaitForChild("Rageblade"),
						}, 
						   {
							name = "fireball",
									offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Fireball"),
						}, 
						{
							name = "telepearl",
									offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Telepearl"),
						}, 
						{
							name = "wood_bow",
							offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Bow"),
						},
						{
							name = "wood_crossbow",
							offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
							model = import:WaitForChild("Crossbow"),
						},
						{
							name = "tactical_crossbow",
							offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
							model = import:WaitForChild("Crossbow"),
						},
							{
							name = "wood_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import:WaitForChild("Wood_Pickaxe"),
						},
						{
							name = "stone_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import:WaitForChild("Stone_Pickaxe"),
						},
						{
							name = "iron_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(-180), math.rad(-95)),
							model = import:WaitForChild("Iron_Pickaxe"),
						},
						{
							name = "diamond_pickaxe",
							offset = CFrame.Angles(math.rad(0), math.rad(80), math.rad(-95)),
							model = import:WaitForChild("Diamond_Pickaxe"),
						},
					   {
								  
							name = "wood_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Wood_Axe"),
						},
						{
							name = "stone_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Stone_Axe"),
						},
						{
							name = "iron_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-10), math.rad(-95)),
							model = import:WaitForChild("Iron_Axe"),
						 },
						 {
							name = "diamond_axe",
							offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-95)),
							model = import:WaitForChild("Diamond_Axe"),
						 },
					
					
					
					 }
					local func = Workspace:WaitForChild("Camera").Viewmodel.ChildAdded:Connect(function(tool)
						if(not tool:IsA("Accessory")) then return end
						for i,v in pairs(index) do
							if(v.name == tool.Name) then
								for i,v in pairs(tool:GetDescendants()) do
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										v.Transparency = 1
									end
								end
								local model = v.model:Clone()
								model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
								model.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model.Parent = tool
								local weld = Instance.new("WeldConstraint",model)
								weld.Part0 = model
								weld.Part1 = tool:WaitForChild("Handle")
								local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
								for i,v in pairs(tool2:GetDescendants()) do
									if(v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
										v.Transparency = 1
									end
								end
								local model2 = v.model:Clone()
								model2.Anchored = false
								model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
								model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-50),math.rad(0))
								model2.CFrame *= CFrame.new(.7,0,-.8)
								model2.Parent = tool2
								local weld2 = Instance.new("WeldConstraint",model)
								weld2.Part0 = model2
								weld2.Part1 = tool2:WaitForChild("Handle")
							end
						end
					end)
				end
			end
		end
	})
	texture_pack_m = texture_pack.CreateDropdown({
		Name = 'Mode',
		List = {
			'Noboline',
			'Aquarium',
			'Ocean'
		},
		Default = 'Noboline',
		HoverText = 'Mode to render the texture pack.',
		Function = function() end;
	});
	local Credits
	Credits = texture_pack.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Melo and Star'
    })
end)

run(function()
    local GuiLibrary = shared.GuiLibrary
	local size_changer = {};
	local size_changer_d = {};
	local size_changer_h = {};
	local size_changer_v = {};
	size_changer = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'ToolSizeChanger',
		HoverText = 'Changes the size of the tools.',
		Function = function(callback) 
			if callback then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(size_changer_d.Value / 10));
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', size_changer_h.Value / 10);
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', size_changer_v.Value / 10);
					bedwars.ViewmodelController:playAnimation((10 / 2) + 6);
				end)
			else
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', 0);
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', 0);
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', 0);
					bedwars.ViewmodelController:playAnimation((10 / 2) + 6);
					cam.Viewmodel.RightHand.RightWrist.C1 = cam.Viewmodel.RightHand.RightWrist.C1;
				end)
			end;
		end;
	});
	size_changer_d = size_changer.CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 24,
		Function = function(val)
			if size_changer.Enabled then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(val / 10));
				end)
			end;
		end,
		Default = 10;
	});
	size_changer_h = size_changer.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 24,
		Function = function(val)
			if size_changer.Enabled then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (val / 10));
				end)
			end;
		end,
		Default = 10;
	});
	size_changer_v = size_changer.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 24,
		Function = function(val)
			if size_changer.Enabled then
				pcall(function()
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (val / 10));
				end)
			end;
		end,
		Default = 0;
	});
	local Credits
	Credits = size_changer.CreateCredits({
        Name = 'CreditsButtonInstance',
        Credits = 'Velocity'
    })
end)

--[[run(function() 
	local Invisibility = {}
	Invisibility = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = 'Invisibility',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerOptionsButton"]
					repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerSpeedSlider"]
					shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerSpeedSlider"].Api.SetValue(9999999999999999999999999)
					shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerAnimationTextBox"].Api.SetValue("11360825341")
					if not shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerOptionsButton"].Api.Enabled then
						shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerOptionsButton"].Api.ToggleButton()
					end
				end)
			else
				if shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerOptionsButton"].Api.Enabled then
					shared.GuiLibrary.ObjectsThatCanBeSaved["AnimationPlayerOptionsButton"].Api.ToggleButton()
					warningNotification("Invisibility", "You might need to reset for this to disable!", 1.5)
				end
			end
		end
	}) 
end)--]]

--[[prun(function()
	local tween = game:GetService("TweenService")
	local DamageIndicator = {}
	local DamageIndicatorText = {}
	local DamageIndicatorHideStroke = {}
	local DamageIndicatorFont = {}
	local DamageIndicatorStroke = {}
	local DamageIndicatorSize = {Value = 32}
	local DamageIndicatorTextList = {ObjectList = {}}
	local DamageIndicatorFontVal = 'GothamBlack'
	local DamageIndicatorColor = {}
	local DamageIndicatorGradient = {}
	local DamageIndicatorStrokeColor = newcolor()
	local DamageIndicatorColorVal = newcolor()
	local DamageIndicatorColorVal2 = newcolor()
	local indicatorlabels = safearray()
	local indicatorgradients = safearray()
	local oldindicatorsize = (debug.getupvalue(bedwars.DamageIndicator, 2).textSize or 32)
	local oldstrokevisible = (debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness or 1.5)
	local oldtweencreate = tween.Create;
	local defaultindcatortext = {
		'vapevoidware.xyz',
		'voidware is just better',
		'voidware > render',
		'discord.gg/voidware',
		'pro'
	}
	local indicatorFunction = function(self, instance, ...)
		local tweendata = oldtweencreate(tween, instance, ...)
		pcall(function()
			debug.getupvalue(bedwars.DamageIndicator, 2).textSize = DamageIndicatorSize.Value
			debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness = (DamageIndicatorHideStroke.Enabled or oldstrokevisible)
			local indicator = instance.Parent 
			table.insert(indicatorlabels, indicator)
			if DamageIndicatorColor.Enabled then 
				indicator.TextColor3 = Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value)
			end
			if DamageIndicatorFont.Enabled then 
				indicator.Font = DamageIndicatorFontVal.Value
			end
			if DamageIndicatorText.Enabled then 
				indicator.Text = (#DamageIndicatorTextList.ObjectList > 0 and getrandomvalue(DamageIndicatorTextList.ObjectList) or getrandomvalue(defaultindcatortext))
			end
			if DamageIndicatorColor.Enabled and DamageIndicatorGradient.Enabled then 
				indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
				local gradient = Instance.new('UIGradient', indicator)
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value)), 
					ColorSequenceKeypoint.new(1, Color3.fromHSV(DamageIndicatorColorVal2.Hue, DamageIndicatorColorVal2.Sat, DamageIndicatorColorVal2.Value))
				})
				table.insert(indicatorgradients, gradient)
			end
			if DamageIndicatorStroke.Enabled then 
				pcall(function() indicator:FindFirstChildWhichIsA('UIStroke').Color = Color3.fromHSV(DamageIndicatorStrokeColor.Hue, DamageIndicatorStrokeColor.Sat, DamageIndicatorStrokeColor.Value) end)
			end
		end)
		return tweendata
	end
	DamageIndicator = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		PerformanceModeBlacklisted = true,
		Name = 'DamageIndicator',
		HoverText = 'change your damage indicator.',
		Function = function(calling)
			if calling then 
				repeat 
					local createfunc = debug.getupvalue(bedwars.DamageIndicator, 10).Create
					if createfunc ~= indicatorFunction then 
						oldtweencreate = createfunc
						debug.setupvalue(bedwars.DamageIndicator, 10, setmetatable({Create = indicatorFunction}, {
							__index = function(self, index)
								local data = rawget(self, index);
								if data == nil then 
									return tween[index]
								end
								return data
							end
						}))
					end
					task.wait() 
				until (not DamageIndicator.Enabled)
			else
				debug.setupvalue(bedwars.DamageIndicator, 10, tween)
				debug.getupvalue(bedwars.DamageIndicator, 2).textSize = oldindicatorsize
				debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness = oldstrokevisible
			end
		end
	})
	DamageIndicatorColor = DamageIndicator.CreateToggle({
		Name = 'Indicator Coloring',
		Default = true,
		Function = function(calling)
			pcall(function() DamageIndicatorColorVal.Object.Visible = calling end)
			pcall(function() DamageIndicatorGradient.Object.Visible = calling end)
			pcall(function() DamageIndicatorColorVal2.Object.Visible = (calling and DamageIndicatorGradient.Enabled) end)
		end
	})
	DamageIndicatorGradient = DamageIndicator.CreateToggle({
		Name = 'Indicator Gradient',
		Function = function(calling)
			pcall(function() DamageIndicatorColorVal.Object.Visible = (calling and DamageIndicatorColor.Enabled) end)
			pcall(function() DamageIndicatorColorVal2.Object.Visible = (calling and DamageIndicatorColor.Enabled) end)
		end
	})
	DamageIndicatorColorVal = DamageIndicator.CreateColorSlider({
		Name = 'Color',
		Function = function()
			if DamageIndicator.Enabled and DamageIndicatorColor.Enabled and not DamageIndicatorGradient.Enabled then 
				for i,v in indicatorlabels do 
					pcall(function() v.TextColor3 = Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value) end)
				end
			end
		end
	})
	DamageIndicatorColorVal2 = DamageIndicator.CreateColorSlider({
		Name = 'Color 2',
		Function = function()
			if DamageIndicator.Enabled and DamageIndicatorColor.Enabled and DamageIndicatorGradient.Enabled then 
				for i,v in indicatorlabels do 
					pcall(function() 
						v.TextColor3 = Color3.fromRGV(255, 255, 255)
						v.UIGradient.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromHSV(DamageIndicatorColorVal.Hue, DamageIndicatorColorVal.Sat, DamageIndicatorColorVal.Value)), 
							ColorSequenceKeypoint.new(1, Color3.fromHSV(DamageIndicatorColorVal2.Hue, DamageIndicatorColorVal2.Sat, DamageIndicatorColorVal2.Value))
						})
					end)
				end
			end
		end
	})
	DamageIndicatorSize = DamageIndicator.CreateSlider({
		Name = 'Indicator Size',
		Min = 5,
		Max = 0,
		Default = 32,
		Function = function(size) 
			if DamageIndicator.Enabled then 
				debug.getupvalue(bedwars.DamageIndicator, 2).textSize = size
			end
		end
	})
	DamageIndicatorStroke = DamageIndicator.CreateToggle({
		Name = 'Indicator Stroke Color',
		Function = function(calling)
			pcall(function() DamageIndicatorStrokeColor.Object.Visible = (calling and DamageIndicatorHideStroke.Enabled == false) end)
		end
	})
	DamageIndicatorStrokeColor = DamageIndicator.CreateColorSlider({
		Name = 'Stroke Color',
		Function = function()
			if DamageIndicator.Enabled and DamageIndicatorStroke.Enabled then 
				for i,v in indicatorlabels do 
					pcall(function() v:FindFirstChildWhichIsA('UIStroke').Color = Color3.fromHSV(DamageIndicatorStrokeColor.Hue, DamageIndicatorStrokeColor.Sat, DamageIndicatorStrokeColor.Value) end)
				end
			end
		end
	})
	DamageIndicatorHideStroke = DamageIndicator.CreateToggle({
		Name = 'Hide Indicator Stroke',
		Function = function(calling)
			if DamageIndicator.Enabled then 
				pcall(function() DamageIndicatorStroke.Object.Visible = (calling and DamageIndicatorStrokeColor.Object.Visible) end)
				pcall(function() DamageIndicatorStrokeColor.Object.Visible = (calling and DamageIndicatorStrokeColor.Object.Visible) end)
				debug.getupvalue(bedwars.DamageIndicator, 2).strokeThickness = (calling or oldstrokevisible)
			end
		end
	})
	DamageIndicatorFont = DamageIndicator.CreateToggle({
		Name = 'Custom Indicator Font',
		Function = function(calling)
			pcall(function() DamageIndicatorFontVal.Object.Visible = calling end)
		end
	})
	DamageIndicatorFontVal = DamageIndicator.CreateDropdown({
		Name = 'Font',
		List =	GetEnumItems('Font'),
		Function = function(font)
			if DamageIndicator.Enabled and DamageIndicatorFont.Enabled then 
				for i,v in indicatorlabels do 
					pcall(function() v.Font = font end)
				end
			end
		end
	})
	DamageIndicatorText = DamageIndicator.CreateToggle({
		Name = 'Custom Indicator Text',
		Function = function(calling) 
			pcall(function() DamageIndicatorTextList.Object.Visible = calling end)
		end
	})
	DamageIndicatorTextList = DamageIndicator.CreateTextList({
		Name = 'Text',
		TempText = 'custom text',
		AddFunction = function() end
	})
	DamageIndicatorColorVal.Object.Visible = false
	DamageIndicatorColorVal2.Object.Visible = false
	DamageIndicatorFontVal.Object.Visible = false 
	DamageIndicatorTextList.Object.Visible = false
	DamageIndicatorStrokeColor.Object.Visible = false
end)--]]

run(function()
	local invis = {};
	local invisbaseparts = safearray();
	local invisroot = {};
	local invisrootcolor = newcolor();
	local invisanim = Instance.new('Animation');
	local invisrenderstep;
	local invistask;
	local invshumanim;
	local SpiderDisabled = false
	invis = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = 'Invisibility',
		HoverText = 'Plays an animation which makes it harder\nfor targets to see you.',
		Function = function(calling)
			local invisFunction = function()
				pcall(task.cancel, invistask);
				pcall(function() invisrenderstep:Disconnect() end);
				repeat task.wait() until isAlive(lplr, true);
				for i,v in lplr.Character:GetDescendants() do 
					pcall(function()
						if v.ClassName:lower():find('part') and v.CanCollide and v ~= lplr.Character:FindFirstChild('HumanoidRootPart') then 
							v.CanCollide = false;
							table.insert(invisbaseparts, v);
						end 
					end)
				end;
				table.insert(invis.Connections, lplr.Character.DescendantAdded:Connect(function(v)
					pcall(function()
						if v.ClassName:lower():find('part') and v.CanCollide and v ~= lplr.Character:FindFirstChild('HumanoidRootPart') then 
							v.CanCollide = false;
							table.insert(invisbaseparts, v);
						end
					end) 
				end));
				task.spawn(function()
					invisrenderstep = runservice.Stepped:Connect(function()
						for i,v in invisbaseparts do 
							v.CanCollide = false;
						end
					end);
					table.insert(invis.Connections, invisrenderstep);
				end)
				invisanim.AnimationId = 'rbxassetid://11335949902';
				local anim = lplr.Character.Humanoid.Animator:LoadAnimation(invisanim);
				invishumanim = anim;
				repeat 
					task.wait()
					if GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.Enabled then 
						GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.ToggleButton();
					end
					--if isAlive(lplr, true) == false or not isnetworkowner(lplr.Character.PrimaryPart) or not invis.Enabled then 
						pcall(function() 
							anim:AdjustSpeed(0);
							anim:Stop() 
						end)
					--end
					lplr.Character.PrimaryPart.Transparency = invisroot.Enabled and 0.6 or 1;
					lplr.Character.PrimaryPart.Color = Color3.fromHSV(invisrootcolor.Hue, invisrootcolor.Sat, invisrootcolor.Value);
					anim:Play(0.1, 9e9, 0.1);
				until (not invis.Enabled)
			end;
			if calling then
				--[[task.spawn(function()
					repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton
					if shared.GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled then
						shared.GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.ToggleButton(false)
						SpiderDisabled = true
						repeat task.wait() until warningNotification
						warningNotification("Invisibility", "Spider disabled to prevent suffocating. \n Will be re-enabled when invisibility gets disabled!", 10)
					end
				end) --]]
				invistask = task.spawn(invisFunction);
				table.insert(invis.Connections, lplr.CharacterAdded:Connect(invisFunction))
			else 
				--[[task.spawn(function()
					if SpiderDisabled then
						repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton
						if (not shared.GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled) then
							shared.GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.ToggleButton(false)
							SpiderDisabled = false
							repeat task.wait() until warningNotification
							warningNotification("Invisibility", "Spider re-enabled!", 10)
						end
					end
				end)--]]
				pcall(function()
					invishumanim:AdjustSpeed(0);
					invishumanim:Stop();
				end);
				pcall(task.cancel, invistask)
			end
		end
	})
	invisroot = invis.CreateToggle({
		Name = 'Show Root',
		Default = true,
		Function = function(calling)
			pcall(function() invisrootcolor.Object.Visible = calling; end)
		end
	})
	invisrootcolor = invis.CreateColorSlider({
		Name = 'Root Color',
		Function = void
	})
end)

run(function()
	local damagehighlightvisuals = {};
	local highlightcolor = newcolor();
	local highlightinvis = {Value = 4}
	damagehighlightvisuals = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
		Name = 'HighlightVisuals',
		HoverText = 'Changes the color of the damage highlight.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(damagehighlightvisuals.Connections, workspace.DescendantAdded:Connect(function(indicator)
						if indicator.Name == '_DamageHighlight_' and indicator.ClassName == 'Highlight' then 
							repeat 
								indicator.FillColor = Color3.fromHSV(highlightcolor.Hue, highlightcolor.Sat, highlightcolor.Value);
								indicator.FillTransparency = (0.1 * highlightinvis.Value);
								task.wait()
							until (indicator.Parent == nil)
						end;
					end))
				end)
			end
		end
	})
	highlightcolor = damagehighlightvisuals.CreateColorSlider({
		Name = 'Color',
		Function = void
	})
	highlightinvis = damagehighlightvisuals.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Default = 4,
		Function = void
	})
end);