repeat task.wait() until game:IsLoaded()
repeat task.wait() until shared.GuiLibrary

local function run(func)
	task.spawn(function()
		local suc, err = pcall(function() func() end)
		if err then warn("[VW687224481.lua Module Error]: "..tostring(debug.traceback(err))) end
	end)
end
local GuiLibrary = shared.GuiLibrary
local store = shared.GlobalStore
local bedwars = shared.GlobalBedwars
local playersService = game:GetService("Players")
if (not shared.GlobalBedwars) or (shared.GlobalBedwars and type(shared.GlobalBedwars) ~= "table") or (not shared.GlobalStore) or (shared.GlobalStore and type(shared.GlobalStore) ~= "table") then
	errorNotification("VW-BEDWARS", "Critical! Important connection is missing! Please report this bug to erchodev#0", 10)
	pcall(function()
		GuiLibrary.SaveSettings = function() warningNotification("GuiLibrary.SaveSettings", "Profiles saving is disabled due to error in the code!", 1) end
	end)
	local delfile = delfile or function(file) writefile(file, "") end
	if isfile('vape/CustomModules/6872274481.lua') then delfile('vape/CustomModules/6872274481.lua') end
end
local entityLibrary = shared.vapeentity
local RunLoops = shared.RunLoops
local VoidwareStore = {
	bedtable = {},
	Tweening = false
}

VoidwareFunctions.GlobaliseObject("lplr", game:GetService("Players").LocalPlayer)
VoidwareFunctions.LoadFunctions("Bedwars")

local function BedwarsInfoNotification(mes)
    local bedwars = shared.GlobalBedwars
	local NotificationController = bedwars.NotificationController
	NotificationController:sendInfoNotification({
		message = tostring(mes),
		image = "rbxassetid://18518244636"
	});
end
getgenv().BedwarsInfoNotification = BedwarsInfoNotification
local function BedwarsErrorNotification(mes)
    local bedwars = shared.GlobalBedwars
	local NotificationController = bedwars.NotificationController
	NotificationController:sendErrorNotification({
		message = tostring(mes),
		image = "rbxassetid://18518244636"
	});
end
getgenv().BedwarsErrorNotification = BedwarsErrorNotification

VoidwareFunctions.LoadFunctions("Bedwars")

local gameCamera = game.Workspace.CurrentCamera

local lplr = game:GetService("Players").LocalPlayer

local btext = function(text)
	return text..' '
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
local whitelist = shared.vapewhitelist

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
		Function = function() if PlayerLevelSet.Enabled then game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value) end end,
		Min = 1,
		Max = 100,
		Default = 100
	})
end)

run(function()
    local QueueDisplayConfig = {
        ActiveState = false,
        GradientControl = {Enabled = true},
        ColorSettings = {
            Gradient1 = {Hue = 0, Saturation = 0, Brightness = 1},
            Gradient2 = {Hue = 0, Saturation = 0, Brightness = 0.8}
        },
        Animation = {Speed = 0.5, Progress = 0}
    }

    local DisplayUtils = {
        createGradient = function(parent)
            local gradient = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient")
            gradient.Parent = parent
            return gradient
        end,
        updateColor = function(gradient, config)
            local time = tick() * config.Animation.Speed
            local interp = (math.sin(time) + 1) / 2
            local h = config.ColorSettings.Gradient1.Hue + (config.ColorSettings.Gradient2.Hue - config.ColorSettings.Gradient1.Hue) * interp
            local s = config.ColorSettings.Gradient1.Saturation + (config.ColorSettings.Gradient2.Saturation - config.ColorSettings.Gradient1.Saturation) * interp
            local b = config.ColorSettings.Gradient1.Brightness + (config.ColorSettings.Gradient2.Brightness - config.ColorSettings.Gradient1.Brightness) * interp
            gradient.Color = ColorSequence.new(Color3.fromHSV(h, s, b))
        end
    }

	local CoreConnection
	local CoreConnection2

    local function enhanceQueueDisplay()
		pcall(function() 
			CoreConnection:Disconnect()
		end)
        local success, err = pcall(function()
            if not lplr.PlayerGui:FindFirstChild('QueueApp') then return end
            
            for attempt = 1, 3 do
                if QueueDisplayConfig.GradientControl.Enabled then
                    local queueFrame = lplr.PlayerGui.QueueApp['1']
                    queueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    
                    local gradient = DisplayUtils.createGradient(queueFrame)
                    gradient.Rotation = 180
                
                    CoreConnection = game:GetService("RunService").RenderStepped:Connect(function()
                        if QueueDisplayConfig.ActiveState and QueueDisplayConfig.GradientControl.Enabled then
                            DisplayUtils.updateColor(gradient, QueueDisplayConfig)
                        end
                    end)
                end
                task.wait(0.1)
            end
        end)
        
        if not success then
            warn("Queue display enhancement failed: " .. tostring(err))
        end
    end

    local QueueDisplayEnhancer
    QueueDisplayEnhancer = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
        Name = 'QueueCardMods',
       	HoverText = 'Enhances the QueueApp display with dynamic gradients',
        Function = function(enabled)
            QueueDisplayConfig.ActiveState = enabled
            if enabled then
                enhanceQueueDisplay()
                CoreConnection2 = lplr.PlayerGui.ChildAdded:Connect(enhanceQueueDisplay)
			else
				pcall(function() 
					CoreConnection:Disconnect()
				end)
				pcall(function()
					CoreConnection2:Disconnect()
				end)
			end
        end
    })

   	QueueDisplayEnhancer.CreateSlider({
        Name = "Animation Speed",
        Function = function(speed)
            QueueDisplayConfig.Animation.Speed = math.clamp(speed, 0.1, 5)
        end,
        Min = 1,
        Max = 5,
        Default = 5
    })

    QueueDisplayEnhancer.CreateColorSlider({
        Name = "Color 1",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient1 = {Hue = h, Saturation = s, Brightness = v}
        end
    })

    QueueDisplayEnhancer.CreateColorSlider({
        Name = "Color 2",
        Function = function(h, s, v)
            QueueDisplayConfig.ColorSettings.Gradient2 = {Hue = h, Saturation = s, Brightness = v}
        end
    })
end)

run(function()
	task.spawn(function()
		pcall(function()
			GuiLibrary.RemoveObject("SetEmoteOptionsButton")
			--[[local SetEmote = {}
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
							local oldpos = lplr.Character:WaitForChild("HumanoidRootPart").Position 
							if tostring(lplr:GetAttribute('EmoteTypeSlot1')):lower():find('nightmare') then 
								anim = Instance.new('Animation')
								anim.AnimationId = 'rbxassetid://9191822700'
								anim = lplr.Character:WaitForChild("Humanoid").Animator:LoadAnimation(anim)
								task.spawn(function()
									repeat 
										anim:Play()
										anim.Completed:Wait()
									until not anim
								end)
							end
							repeat task.wait() until ((lplr.Character:WaitForChild("HumanoidRootPart").Position - oldpos).Magnitude >= 0.3 or not isAlive(lplr, true))
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
			})--]]
		end)
	end)
end)

--[[if shared.TestingMode then
	pcall(function()
		run(function()
			local SessionInfo = {Enabled = false}
			local BackgroundColor = {Hue = 0, Sat = 0, Value = 0}
			local lplr = game:GetService("Players").LocalPlayer
			local plrgui = lplr.PlayerGui
			local deathCount = 0
			local regionDisplayText = plrgui:WaitForChild("ServerRegionDisplay").ServerRegionText.Text
			local playerDead = false 
			local debounce = false
		
			SessionInfo = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
				Name = "SessionInfo Custom",
				HoverText = "Customizable session info.",
				Function = function(call)
					if call then 
						local function extractValue(text, pattern)
							return text:match(pattern)
						end

						local components = {
							Gui = Instance.new("ScreenGui"),
							Background = Instance.new("Frame"),
							UICorner = Instance.new("UICorner"),
							SessionInfoLabel = Instance.new("TextLabel"),
							TimePlayed = Instance.new("TextLabel"),
							Kills = Instance.new("TextLabel"),
							Deaths = Instance.new("TextLabel"),
							Region = Instance.new("TextLabel"),
							DropShadowHolder = Instance.new("Frame"),
							DropShadow = Instance.new("ImageLabel")
						}
						
						local function setupLabel(label, text, positionY)
							label.Font = Enum.Font.SourceSans
							label.Text = text
							label.TextColor3 = Color3.fromRGB(255, 255, 255)
							label.TextScaled = true
							label.TextWrapped = true
							label.TextXAlignment = Enum.TextXAlignment.Left
							label.BackgroundTransparency = 1
							label.Position = UDim2.new(0.04, 0, positionY, 0)
							label.Size = UDim2.new(1, 0, 0.17, 0)
							label.Parent = components.Background
						end
		
						components.Gui.Name = "SessionInfo"
						components.Gui.Parent = plrgui
						components.Gui.ResetOnSpawn = false
		
						components.Background.Name = "Background"
						components.Background.Parent = components.Gui
						components.Background.BackgroundColor3 = Color3.fromHSV(0, 0, 0)
						components.Background.BackgroundTransparency = 0.8
						components.Background.Size = UDim2.new(0.13, 0, 0.16, 0)
						components.Background.Position = UDim2.new(0.01, 0, 0.38, 0)
						components.UICorner.Parent = components.Background
		
						setupLabel(components.SessionInfoLabel, "Session Info", 0)
						setupLabel(components.TimePlayed, "Time Played: 00:00", 0.28)
						setupLabel(components.Kills, "Kills: 0", 0.45)
						setupLabel(components.Deaths, "Deaths: 0", 0.62)
						setupLabel(components.Region, "Region: " .. extractValue(regionDisplayText, "REGION:%s*([^<]+)"), 0.79)
		
						components.DropShadowHolder.Parent = components.Background
						components.DropShadowHolder.BackgroundTransparency = 1
						components.DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
						components.DropShadow.Name = "DropShadow"
						components.DropShadow.Parent = components.DropShadowHolder
						components.DropShadow.Image = "rbxassetid://6014261993"
						components.DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
						components.DropShadow.ImageTransparency = 0.5
						components.DropShadow.ScaleType = Enum.ScaleType.Slice
						components.DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
						components.DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
						components.DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
						components.DropShadow.Size = UDim2.new(1, 47, 1, 47)
		
						local function updateTimer()
							while enabled do
								wait()
								local timerText = plrgui.TopBarAppGui.TopBarApp["2"]["5"].Text
								components.TimePlayed.Text = "Time Played: " .. extractValue(timerText, "<b>(%d+:%d+)</b>")
							end
						end
		
						local function updateKills()
							while enabled do
								wait()
								local killsText = plrgui.TopBarAppGui.TopBarApp["3"]["5"].Text
								components.Kills.Text = "Kills: " .. extractValue(killsText, "<b>(%d+)</b>")
							end
						end
		
						local function trackDeaths()
							lplr.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
								if debounce then return end
								debounce = true
								if health <= 0 and not playerDead then
									deathCount += 1
									components.Deaths.Text = "Deaths: " .. deathCount
									playerDead = true
								elseif health > 0 then
									playerDead = false
								end
								debounce = false
							end)
						end
						
						task.spawn(updateTimer)
						task.spawn(updateKills)
						task.spawn(trackDeaths)
						
					else
						if plrgui:FindFirstChild("SessionInfo") then 
							plrgui.SessionInfo:Destroy()
						else 
							errorNotification("SessionInfo", "Session Info not found, please DM erchodev#0 about this.", 3)
						end
					end
				end
			})
		
			BackgroundColor = SessionInfo.CreateColorSlider({
				Name = "Background Color",
				Function = function(h, s, v) 
					local sessionInfo = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SessionInfo")
					if sessionInfo then 
						sessionInfo.Background.BackgroundColor3 = Color3.fromHSV(h, s, v)
					else
						print("No SessionInfo found.")
					end
				end
			})
		end)		
	end)
else
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
end--]]

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
					rayparams.FilterDescendantsInstances = {game.Workspace.Map, game.Workspace:FindFirstChild("SpectatorPlatform")}
					rayparams.FilterType = Enum.RaycastFilterType.Whitelist
					local ray = game.Workspace:Raycast(mousepos.Origin, mousepos.Direction * 10000, rayparams)
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
			rayparams.FilterDescendantsInstances = {game.Workspace.Map, game.Workspace:FindFirstChild("SpectatorPlatform")}
			rayparams.FilterType = Enum.RaycastFilterType.Whitelist
			local ray = game.Workspace:Raycast(mousepos.Origin, mousepos.Direction * 10000, rayparams)
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
				if isAlive(lplr, true) and lplr.Character:WaitForChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
					lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('diamond')
			if item == nil or not DiamondTP.Enabled then 
				return
			end
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			diamondtween:Play() 
			diamondtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character:WaitForChild("Humanoid").FloorMaterial == Enum.Material.Air then 
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
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (DiamondTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (DiamondTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (DiamondTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[DiamondTPTeleport.Value])
			diamondtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
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
				if isAlive(lplr, true) and lplr.Character:WaitForChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
					lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local item = getItemDrop('emerald')
			if item == nil or not EmeraldTP.Enabled then 
				return
			end
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
			emeraldtween:Play() 
			emeraldtween.Completed:Wait()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character:WaitForChild("Humanoid").FloorMaterial == Enum.Material.Air then 
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
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (EmeraldTPAutoSpeed.Enabled and ((item.Position - localposition).Magnitude / 470) + 0.001 * 2 or (EmeraldTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (EmeraldTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[EmeraldTPTeleport.Value])
			emeraldtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = item.CFrame}) 
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
				if isAlive(lplr, true) and lplr.Character:WaitForChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Dead then
					lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
					lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				end
			end
			lplr.CharacterAdded:Wait()
			repeat task.wait() until isAlive(lplr, true) 
			task.wait(0.1)
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil or not PlayerTP.Enabled then 
				return
			end
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 470) + 0.001 * 2 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
			playertween:Play() 
			playertween.Completed:Wait()
		end,
		Instant = function() 
			local target = GetTarget(nil, PlayerTPSort.Value == 'Health', true)
			if target.RootPart == nil then 
				return PlayerTP.ToggleButton()
			end
			lplr.Character:WaitForChild("HumanoidRootPart").CFrame = (target.RootPart.CFrame + Vector3.new(0, 5, 0)) 
			PlayerTP.ToggleButton()
		end,
		Recall = function()
			if not isAlive(lplr, true) or lplr.Character:WaitForChild("Humanoid").FloorMaterial == Enum.Material.Air then 
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
			local localposition = lplr.Character:WaitForChild("HumanoidRootPart").Position
			local tweenspeed = (PlayerTPAutoSpeed.Enabled and ((target.RootPart.Position - localposition).Magnitude / 1000) + 0.001 or (PlayerTPSpeed.Value / 1000) + 0.1)
			local tweenstyle = (PlayerTPAutoSpeed.Enabled and Enum.EasingStyle.Linear or Enum.EasingStyle[PlayerTPMethod.Value])
			playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(tweenspeed, tweenstyle), {CFrame = target.RootPart.CFrame}) 
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
					if GetTarget(nil, PlayerTPSort.Value == 'Health', true) and GetTarget(nil, PlayerTPSort.Value == 'Health', true).RootPart and shared.VapeFullyLoaded then 
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
	local GuiSync = {Enabled = false}
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
				if GuiSync.Enabled then 
					if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
						sloticon.Parent.BackgroundColor3 = GuiLibrary.GUICoreColor
						GuiLibrary.GUICoreColorChanged.Event:Connect(function()
							pcall(function()
								sloticon.Parent.BackgroundColor3 = GuiLibrary.GUICoreColor
							end)
						end)
					else
						local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
						sloticon.Parent.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
						VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
							color = {Hue = h, Sat = s, Value = v}
							sloticon.Parent.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
						end))
					end
				end
				if HotbarModsGradient.Enabled and not GuiSync.Enabled then 
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
					if GuiSync.Enabled then
						if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
							highlight.Color = GuiLibrary.GUICoreColor
							GuiLibrary.GUICoreColorChanged.Event:Connect(function()
								highlight.Color = GuiLibrary.GUICoreColor
							end)
						else
							local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
							highlight.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
							VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
								color = {Hue = h, Sat = s, Value = v}
								highlight.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
							end))
						end
					else
						highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					end
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
	HotbarMods.Restart = function() if HotbarMods.Enabled then HotbarMods.ToggleButton(false); HotbarMods.ToggleButton(false) end end
	local function refreshGUI()
		repeat task.wait() until HotbarColorToggle.Object and HotbarModsGradient.Object and HotbarModsGradientColor.Object and HotbarModsGradientColor2.Object and HotbarColor.Object
		HotbarColorToggle.Object.Visible = (not GuiSync.Enabled)
		HotbarModsGradient.Object.Visible = (not GuiSync.Enabled)
		HotbarModsGradientColor.Object.Visible = HotbarModsGradient.Enabled and (not GuiSync.Enabled)
		HotbarModsGradientColor2.Object.Visible = HotbarModsGradient.Enabled and (not GuiSync.Enabled)
		HotbarColor.Object.Visible = (not GuiSync.Enabled)
	end
	GuiSync = HotbarMods.CreateToggle({
		Name = "GUI Color Sync",
		Function = function()
			HotbarMods.Restart()
			task.spawn(refreshGUI)
		end
	})
	HotbarColorToggle = HotbarMods.CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			HotbarMods.Restart()
			task.spawn(refreshGUI)
		end
	})
	HotbarModsGradient = HotbarMods.CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarModsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarModsGradientColor2.Object.Visible = calling end)
			HotbarMods.Restart()
			task.spawn(refreshGUI)
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
			HotbarMods.Restart()
			task.spawn(refreshGUI)
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
			HotbarMods.Restart()
			task.spawn(refreshGUI)
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
			HotbarMods.Restart()
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
end)

run(function()
	local HealthbarVisuals = {Enabled = false, Connections = {}};
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
	local GUISync = {Enabled = false}
	local function healthbarFunction()
		if not HealthbarVisuals.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar;
			healthbar.Transparency = (0.1 * HealthbarInvis.Value);
			if (not GUISync.Enabled) then
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
			else
				if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
					healthbar.BackgroundColor3 = GuiLibrary.GUICoreColor
					table.insert(HealthbarVisuals.Connections, GuiLibrary.GUICoreColorChanged.Event:Connect(function()
						if HealthbarVisuals.Enabled then
							healthbar.BackgroundColor3 = GuiLibrary.GUICoreColor
						end
					end))
				else
					local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
					healthbar.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
					VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
						if HighlightVisuals.Enabled then
							color = {Hue = h, Sat = s, Value = v}
							healthbar.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
						end
					end))
				end
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
	HealthbarVisuals.Restart = function() if HealthbarVisuals.Enabled then HealthbarVisuals.ToggleButton(false); HealthbarVisuals.ToggleButton(false) end end
	local function refreshGUIObjects()
		task.spawn(function()
			repeat task.wait() until HealthbarColorToggle.Object and HealthbarColor.Object and HealthbarGradientColor.Object and HealthbarGradientToggle.Object and HealthbarBackgroundToggle.Object and HealthbarBackground.Object and HealthbarHighlight.Object and HealthbarHighlightColor.Object and GUISync.Object
			local a, b, c, d, e, f, g, h, i = HealthbarColorToggle, HealthbarColor, HealthbarGradientColor, HealthbarGradientToggle, HealthbarBackgroundToggle, HealthbarBackground, HealthbarHighlight, HealthbarHighlightColor, GUISync
			a.Object.Visible = not i.Enabled
			b.Object.Visible = a.Enabled and not i.Enabled
			c.Object.Visible = d.Enabled and not i.Enabled
			d.Object.Visible = not i.Enabled
			e.Object.Visible = not i.Enabled
			f.Object.Visible = e.Enabled and not i.Enabled
			g.Object.Visible = not i.Enabled
			h.Object.Visible = g.Enabled and not i.Enabled
		end)
	end
	GUISync = HealthbarVisuals.CreateToggle({
		Name = "GUI Color Sync",
		Function = function(call)
			refreshGUIObjects()
			HealthbarVisuals.Restart()
		end
	})
	HealthbarColorToggle = HealthbarVisuals.CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(calling)
			pcall(function() HealthbarColor.Object.Visible = calling end)
			pcall(function() HealthbarGradientToggle.Object.Visible = calling end)
			HealthbarVisuals.Restart()
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
	HealthbarGradientColor.Object.Visible = false
	HealthbarGradientToggle = HealthbarVisuals.CreateToggle({
		Name = 'Gradient',
		Function = function(call)
			HealthbarGradientColor.Object.Visible = call
			HealthbarVisuals.Restart()
		end
	})
	HealthbarBackgroundToggle = HealthbarVisuals.CreateToggle({
		Name = 'Background Color',
		Function = function(calling)
			pcall(function() HealthbarBackground.Object.Visible = calling end)
			HealthbarVisuals.Restart()
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
			HealthbarVisuals.Restart()
		end 
	})
	HealthbarText = HealthbarVisuals.CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = HealthbarVisuals.Restart,
		RemoveFunction = HealthbarVisuals.Restart
	})
	HealthbarTextColorToggle = HealthbarVisuals.CreateToggle({
		Name = 'Text Color',
		Function = function(calling)
			pcall(function() HealthbarTextColor.Object.Visible = calling end)
			HealthbarVisuals.Restart()
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
			HealthbarVisuals.Restart()
		end 
	})
	HealthbarFont = HealthbarVisuals.CreateDropdown({
		Name = 'Text Font',
		List = GetEnumItems('Font'),
		Function = HealthbarVisuals.Restart
	})
	HealthbarRound = HealthbarVisuals.CreateToggle({
		Name = 'Round',
		Function = function(calling)
			pcall(function() HealthbarRoundSize.Object.Visible = calling end);
			HealthbarVisuals.Restart()
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
			HealthbarVisuals.Restart()
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
		if antiDeathConfig.Mode.Value == "Infinite" then return end
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
            Velocity = function() self.hrp.Velocity += Vector3.new(0, antiDeathConfig.Velocity.Value, 0) end,
            CFrame = function() self.hrp.CFrame += Vector3.new(0, antiDeathConfig.CFrame.Value, 0) end,
            Tween = function()
                tweenService:Create(self.hrp, twinfo(antiDeathConfig.TweenDuration.Value / 10), {
                    CFrame = self.hrp.CFrame + Vector3.new(0, antiDeathConfig.TweenPower.Value, 0)
                }):Play()
            end
        }
        boostActions[antiDeathConfig.BoostMode.Value]()
    end

    function handlers:moveToSky()
        self.hrp.CFrame += Vector3.new(0, antiDeathConfig.SkyPosition.Value, 0)
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
        HoverText = btext('Prevents you from dying.'),
        ExtraText = function()
            return antiDeathConfig.Mode.Value
        end
    })

    antiDeathConfig.Mode = antiDeath.CreateDropdown({
        Name = 'Mode',
        List = {'Infinite', 'Boost', 'Sky' },
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
			task.wait(0.1) 
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
			task.wait(0.1) 
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
	local AdetundeRemote
	local function upgrade(args)
		if not AdetundeRemote then
			AdetundeRemote = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("UpgradeFrostyHammer")
		end
		return AdetundeRemote:InvokeServer(unpack(args))
	end
    local AdetundeExploit = {}
    local AdetundeExploit_List = { Value = "Shield" }

    local adetunde_remotes = {
        ["Shield"] = function()
            local args = { [1] = "shield" }
            local returning = upgrade(args)
            return returning
        end,

        ["Speed"] = function()
            local args = { [1] = "speed" }
            local returning = upgrade(args)
            return returning
        end,

        ["Strength"] = function()
            local args = { [1] = "strength" }
            local returning = upgrade(args)
            return returning
        end
    }

    local current_upgrador = "Shield"
    local hasnt_upgraded_everything = true
    local testing = 1

	local function getItem(itemName, inv)
		store.localInventory = store.localInventory or store.inventory
		for slot, item in (inv or store.localInventory.inventory.items) do
			if item.itemType == itemName then
				return item, slot
			end
		end
		return nil
	end

    AdetundeExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
        Name = 'AdetundeExploit',
        Function = function(calling)
            if calling then 
				--[[task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if store.equippedKit ~= "adetunde" then
						warningNotification("AdetundeExploit", "Adetunde kit required!", 3)
						if AdetundeExploit.Enabled then
							AdetundeExploit.ToggleButton(false)
						end
					end
				end)--]]
                task.spawn(function()
                    repeat
						if not getItem("frosty_hammer") then return end
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
                        "Successfully logged the Reports Data to LoggedReports.txt in your executor's game.Workspace folder!", 
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
	local Slowmode = {Value = 2}
	local CoreConnection
	GodMode = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AntiHit/Godmode",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait()
						local res, msg = pcall(function()
							if (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) then
								for i, v in pairs(game:GetService("Players"):GetChildren()) do
									if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
										if v and v ~= lplr then
											local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
											if TargetDistance < 25 then
												if not lplr.Character:WaitForChild("HumanoidRootPart"):FindFirstChildOfClass("BodyVelocity") then
													repeat task.wait() until shared.GlobalStore.matchState ~= 0
													if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
														lplr.Character.Archivable = true
				
														local Clone = lplr.Character:Clone()
														Clone.Parent = game.Workspace
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
					
														lplr.Character:WaitForChild("HumanoidRootPart").CFrame = lplr.Character:WaitForChild("HumanoidRootPart").CFrame + Vector3.new(0,100,0)
					
														CoreConnection = game:GetService("RunService").RenderStepped:Connect(function()
															if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
																Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character:WaitForChild("HumanoidRootPart").Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character:WaitForChild("HumanoidRootPart").Position.Z)
															end
														end)
					
														task.wait(Slowmode.Value/10)
														lplr.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(lplr.Character:WaitForChild("HumanoidRootPart").Velocity.X, -1, lplr.Character:WaitForChild("HumanoidRootPart").Velocity.Z)
														lplr.Character:WaitForChild("HumanoidRootPart").CFrame = Clone.HumanoidRootPart.CFrame
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
						end)
						if not res then warn(msg) end
					until (not GodMode.Enabled)
				end)
			else
				pcall(function()
					CoreConnection:Disconnect()
				end)
			end
		end
	})
	Slowmode = GodMode.CreateSlider({
		Name = "Slowmode",
		Function = function() end,
		Default = 2,
		Min = 1,
		Max = 25
	})
end)

local EntityNearPosition = shared.EntityNearPosition

run(function()
	local AntiHit = {}
	local physEngine = game:GetService("RunService")
	local worldSpace = game.Workspace
	local camView = worldSpace.CurrentCamera
	local plyr = lplr
	local entSys = entityLibrary
	local queryutil = {}
	function queryutil:setQueryIgnored(part, index)
		if index == nil then index = true end
		if part then part:SetAttribute("gamecore_GameQueryIgnore", index) end
	end
	local utilPack = {QueryUtil = queryutil}

	local dupeNode, altHeight, initOk, sysOk = nil, nil, false, true
	shared.anchorBase = nil
	shared.evadeFlag = false

	local trigSet = {p = true, n = false, w = false}
	local shiftMode = "Up"
	local scanRad = 30

	local function genTwin()
		if entSys.isAlive and entSys.character.Humanoid.Health > 0 and entSys.character.HumanoidRootPart then
			altHeight = entSys.character.Humanoid.HipHeight
			shared.anchorBase = entSys.character.HumanoidRootPart
			utilPack.QueryUtil:setQueryIgnored(shared.anchorBase, true)
			if not plyr.Character or not plyr.Character.Parent then return false end

			plyr.Character.Parent = game
			dupeNode = shared.anchorBase:Clone()
			dupeNode.Parent = plyr.Character
			shared.anchorBase.Parent = camView
			dupeNode.CFrame = shared.anchorBase.CFrame

			plyr.Character.PrimaryPart = dupeNode
			entSys.character.HumanoidRootPart = dupeNode
			entSys.character.RootPart = dupeNode
			plyr.Character.Parent = worldSpace

			for _, x in plyr.Character:GetDescendants() do
				if x:IsA('Weld') or x:IsA('Motor6D') then
					if x.Part0 == shared.anchorBase then x.Part0 = dupeNode end
					if x.Part1 == shared.anchorBase then x.Part1 = dupeNode end
				end
			end
			return true
		end
		return false
	end

	local function resetCore()
		if not entSys.isAlive or not shared.anchorBase or not shared.anchorBase:IsDescendantOf(game) then
			shared.anchorBase = nil
			dupeNode = nil
			return false
		end

		if not plyr.Character or not plyr.Character.Parent then return false end

		plyr.Character.Parent = game

		shared.anchorBase.Parent = plyr.Character
		shared.anchorBase.CanCollide = true
		shared.anchorBase.Velocity = Vector3.zero 
		shared.anchorBase.Anchored = false 

		plyr.Character.PrimaryPart = shared.anchorBase
		entSys.character.HumanoidRootPart = shared.anchorBase
		entSys.character.RootPart = shared.anchorBase

		for _, x in plyr.Character:GetDescendants() do
			if x:IsA('Weld') or x:IsA('Motor6D') then
				if x.Part0 == dupeNode then x.Part0 = shared.anchorBase end
				if x.Part1 == dupeNode then x.Part1 = shared.anchorBase end
			end
		end

		local prevLoc = dupeNode and dupeNode.CFrame or shared.anchorBase.CFrame
		if dupeNode then
			dupeNode:Destroy()
			dupeNode = nil
		end

		plyr.Character.Parent = worldSpace
		shared.anchorBase.CFrame = prevLoc

		if entSys.character.Humanoid then
			entSys.character.Humanoid.HipHeight = altHeight or 2
		end

		shared.anchorBase = nil
		shared.evadeFlag = false
		altHeight = nil

		return true
	end

	local function shiftPos()
		if not entSys.isAlive or not shared.anchorBase or not AntiHit.on then return end

		local hits = {EntityNearPosition(scanRad, trigSet.n)}

		if #hits > 0 and not shared.evadeFlag then
			local base = entSys.character.HumanoidRootPart
			if base then
				shared.evadeFlag = true
				local targetY = shiftMode == "Up" and 150 or 0
				shared.anchorBase.CFrame = CFrame.new(base.CFrame.X, targetY, base.CFrame.Z)
				task.wait(0.15)
				shared.anchorBase.CFrame = base.CFrame
				task.wait(0.05)
				shared.evadeFlag = false
			end
		end
	end

	function AntiHit:engage()
		if self.on then return end
		self.on = true

		initOk = genTwin()
		if not initOk then
			self:disengage()
			return
		end

		self.physHook = physEngine.PreSimulation:Connect(function(dt)
			if entSys.isAlive and shared.anchorBase and entSys.character.RootPart then
				local currBase = entSys.character.RootPart
				local currPos = currBase.CFrame

				if not isnetworkowner(shared.anchorBase) then
					currBase.CFrame = shared.anchorBase.CFrame
					currBase.Velocity = shared.anchorBase.Velocity
					return
				end
				if not shared.evadeFlag then
					shared.anchorBase.CFrame = currPos
				end
				shared.anchorBase.Velocity = Vector3.zero
				shared.anchorBase.CanCollide = false
				shiftPos()
			else
				self:disengage() 
			end
		end)

		self.respawnHook = lplr.CharacterAdded:Connect(function(_)
			if self.on then
				self:disengage() 
				task.wait(0.1) 
				self:engage() 
			end
		end)
	end

	local Antihit_core = {Enabled = false}

	function AntiHit:disengage()
		self.on = false
		local success, err = pcall(resetCore)
		if not success then
			warn("AntiHit resetCore failed: " .. tostring(err))
		end
		if self.physHook then
			self.physHook:Disconnect()
			self.physHook = nil
		end
		if self.respawnHook then
			self.respawnHook:Disconnect()
			self.respawnHook = nil
		end
	end

	Antihit_core = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AntiHit V2",
		Function = function(active)
			if active then
				warningNotification("Antihit V2", "Warning: this is still experimental!", 3)
			end
			task.spawn(function()
				repeat task.wait() until store.matchState > 0 or not Antihit_core.Enabled
				if not Antihit_core.Enabled then return end
				if active then
					AntiHit:engage()
				else
					AntiHit:disengage()
				end
			end)
		end,
		HoverText = "Dodges attacks."
	})

	--[[Antihit_core:CreateTargets({
		Players = true,
		NPCs = false
	})--]]
	Antihit_core:CreateDropdown({
		Name = "Shift Type",
		List = {"Up", "Down"},
		Value = "Up",
		Function = function(opt) shiftMode = opt end
	})
	Antihit_core:CreateSlider({
		Name = "Scan Perimeter",
		Min = 1,
		Max = 30,
		Default = 30,
		Suffix = function(v) return v == 1 and "span" or "spans" end,
		Function = function(v) scanRad = v end
	})
end)

run(function()
	local ExploitUser = {Enabled = false}
	local ExploitConfig = {
		TrainWhistle = false,
		PartyPopper = false,
		SkyScythe = false
	}
	local function getItem(itemName, inv)
		for slot, item in (inv or store.localInventory.inventory.items) do
			if item.itemType == itemName then
				return item, slot
			end
		end
		return nil
	end
	local ExploitTable = {
		TrainWhistle = function()
			bedwars.AbilityController:useAbility('TRAIN_WHISTLE')
		end,
		PartyPopper = function()
			bedwars.AbilityController:useAbility('PARTY_POPPER')
		end,
		SkyScythe = function()
			if getItem("sky_scythe") then
				bedwars.Client:Get('SkyScytheSpin'):SendToServer()
			end
		end
	}
	ExploitUser = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ExploitUser",
		Function = function(call)
			if call then
				task.spawn(function()
					repeat task.wait();
						for i,v in pairs(ExploitTable) do
							if ExploitConfig[v] then 
								pcall(v) 
							end
						end
					until (not ExploitUser.Enabled)
				end)
			end
		end
	})
	for i,v in pairs(ExploitTable) do
		ExploitUser.CreateToggle({
			Name = tostring(i).."Exploit",
			Function = function(call) ExploitConfig[i] = call end
		})
	end
end)

run(function()
	local cheat = {57,84,142,96,195,198,254,218,104,79,208,20,197,34,10,112,20,53,226,37,133,215,119,171,130,96,107,239,245,109,145,250}
	if shared.EGGHUNTCHATTINGCONNECTION then
		pcall(function() shared.EGGHUNTCHATTINGCONNECTION:Disconnect() end)
	end
	shared.EGGHUNTCHATTINGCONNECTION = lplr.Chatted:Connect(function(msg)
		if (msg:split(" "))[1] == "/eggclaim" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules["@rbxts"].net.out._NetManaged.EggHunt2025_CheatcodeActivatedFromClient:FireServer({
				hash = cheat
			})
			game:GetService('StarterGui'):SetCore('SendNotification', {
				Title = 'Voidware',
				Text = 'Successfully claimed the Cheatcode Egg!',
				Duration = 10,
			})
			pcall(function() shared.EGGHUNTCHATTINGCONNECTION:Disconnect() end)
		end
	end)
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
						if lplr.Character:WaitForChild("Humanoid").Health < lplr.Character:WaitForChild("Humanoid").MaxHealth then
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

--[[run(function()
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
end)--]]

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

--[[run(function()
	local insta = {Enabled = false}
	insta = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
		Name = "EmberInstakill",
		Function = function(callback)
			if callback then
				warningNotification("EmberInstakill", "Ember blade is required for this to work", 3)
				task.spawn(function()
					repeat task.wait() until getItem("infernal_saber")
					repeat 
						pcall(function()
							local args = {
								[1] = {
									["chargeTime"] = 1.3664593696594238,
									["player"] = game:GetService("Players").LocalPlayer,
									["weapon"] = getItem("infernal_saber")
								}
							}
							game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("HellBladeRelease"):FireServer(unpack(args))
						end)
						task.wait(0.1)
					until (not insta.Enabled)
				end)
			end
		end, 
		HoverText = "🔥ember"
	})
end)--]]

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
	position = position or isAlive(lplr, true) and lplr.Character:WaitForChild("HumanoidRootPart").Position
	if not position then 
		return nil 
	end
	if raycast and not game.Workspace:Raycast(position, Vector3.new(0, -2000, 0), store.blockRaycast) then
	    return nil
    end
	local lastblock = nil
	for i = 1, 500 do 
		local newray = game.Workspace:Raycast(lastblock and lastblock.Position or position, customvector or Vector3.new(0.55, 999999, 0.55), store.blockRaycast)
		local smartest = newray and smart and game.Workspace:Raycast(lastblock and lastblock.Position or position, Vector3.new(0, 5.5, 0), store.blockRaycast) or not smart
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
			local itemdistance = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v)
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
	local sortmethods = {Normal = function(entityroot, entityhealth) return abletocalculate() and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), entityroot) < sort end, Health = function(entityroot, entityhealth) return abletocalculate() and entityhealth < sort end}
	local sortmethod = healthmethod and "Health" or "Normal"
	local function raycasted(entityroot) return abletocalculate() and blockRaycast and game.Workspace:Raycast(entityroot.Position, Vector3.new(0, -2000, 0), store.blockRaycast) or not blockRaycast and true or false end
	for i,v in pairs(playersService:GetPlayers()) do
		if v ~= lplr and abletocalculate() and isAlive(v) and v.Team ~= lplr.Team then
			if not ({whitelist:get(v)})[2] then 
				continue
			end
			if sortmethods[sortmethod](v.Character.HumanoidRootPart, v.Character:GetAttribute("Health") or v.Character.Humanoid.Health) and raycasted(v.Character.HumanoidRootPart) then
				sort = healthmethod and v.Character.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.Character.HumanoidRootPart)
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
			if abletocalculate() and v.PrimaryPart and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart) < maxdistance then
			entity.Player = {Character = v, Name = "PotEntity", DisplayName = "PotEntity", UserId = 1}
			entity.Human = false
			entity.RootPart = v.PrimaryPart
			entity.Humanoid = {Health = 1, MaxHealth = 1}
			end
		end
		for i,v in pairs(collectionService:GetTagged("DiamondGuardian")) do 
			if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health and abletocalculate() then
				if sortmethods[sortmethod](v.PrimaryPart, v.Humanoid.Health) and raycasted(v.PrimaryPart) then
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
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
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
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
					sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
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
				sort = healthmethod and v.Humanoid.Health or GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), v.PrimaryPart)
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
local function isVulnerable(plr) return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField") end
VoidwareFunctions.GlobaliseObject("isVulnarable", isVulnarable)
local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
				if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
				end
			end
		end
		if not ignore then
			for i, v in pairs(game.Workspace:GetChildren()) do
				if v.Name == "Void Enemy Dummy" or v.Name == "Emerald Enemy Dummy" or v.Name == "Diamond Enemy Dummy" or v.Name == "Leather Enemy Dummy" or v.Name == "Regular Enemy Dummy" or v.Name == "Iron Enemy Dummy" then
					if v.PrimaryPart then
						local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
						if overridepos and mag > distance then
							mag = (overridepos - v2.PrimaryPart.Position).magnitude
						end
						if mag <= closestMagnitude then
							closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
						end
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GuardianOfDream")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i,v in pairs(game.Workspace:GetChildren()) do
				if v.Name == "InfectedCrateEntity" and v.ClassName == "Model" and v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "InfectedCrateEntity", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(store.pots) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Pot", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end
VoidwareFunctions.GlobaliseObject("EntityNearPosition", EntityNearPosition)
--[[run(function()
	local Autowin = {Enabled = false}
	local AutowinNotification = {Enabled = true}
	local bedtween
	local playertween
	Autowin = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = "Autowin",
		ExtraText = function() return shared.GlobalStore and shared.GlobalStore.queueType:find("5v5") and "BedShield" or "Normal" end,
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
							lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
							lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
						end
						table.insert(Autowin.Connections, runService.Heartbeat:Connect(function()
							pcall(function()
								if not isnetworkowner(lplr.Character:WaitForChild("HumanoidRootPart")) and (FindEnemyBed() and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), FindEnemyBed()) > 75 or not FindEnemyBed()) then
									if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled and store.matchState < 2 then
										lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
										lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
									end
								end
							end)
						end))
						table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
							if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
							local bed = FindEnemyBed()
							if bed and (bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") < game.Workspace:GetServerTimeNow() or not bed:GetAttribute("BedShieldEndTime")) then
								bedtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {CFrame = CFrame.new(bed.Position) + Vector3.new(0, 10, 0)})
								task.wait(0.1)
								bedtween:Play()
								bedtween.Completed:Wait()
								task.spawn(function()
									task.wait(1.5)
									if lplr.Character:FindFirstChild("HumanoidRootPart") then
										local magnitude = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), bed)
										if magnitude >= 50 and FindTeamBed() and Autowin.Enabled then
											lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
											lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
										end
									end
								end)
								if AutowinNotification.Enabled then
									local function get_bed_team(id)
										local teamName = "Unknown"
										for i,v in pairs(game:GetService("Players"):GetPlayers()) do
											if v ~= game:GetService("Players").LocalPlayer then
												if v:GetAttribute("Team") and tostring(v:GetAttribute("Team")) == tostring(id) then
													teamName = tostring(v.Team)
												end
											end
										end
										return false, teamName
									end
									local suc, bedname = get_bed_team(bed:GetAttribute("TeamId"))
									task.spawn(InfoNotification, "Autowin", "Destroying "..bedname:lower().." team's bed", 5)
								end
								repeat task.wait() until FindEnemyBed() ~= bed or not isAlive()
								if EntityNearPosition(45) and EntityNearPosition(45).RootPart and isAlive() then
									if AutowinNotification.Enabled then
										local team = VoidwareStore.bedtable[bed] or "unknown"
										task.spawn(InfoNotification, "Autowin", "Killing "..team:lower().." team's teamates", 5)
									end
									repeat
										local target = EntityNearPosition(45)
										if not target.RootPart then break end
										playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
										playertween:Play()
										task.wait()
									until not (EntityNearPosition(45) and EntityNearPosition(45).RootPart) or not Autowin.Enabled or not isAlive()
								end
								if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
									lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
									lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
								end
							elseif EntityNearPosition(45) and EntityNearPosition(45).RootPart then
								local target = EntityNearPosition(45)
								playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
								playertween:Play()
								if AutowinNotification.Enabled then
									task.spawn(InfoNotification, "Autowin", "Killing "..target.Player.DisplayName.." ("..(target.Player.Team and target.Player.Team.Name or "neutral").." Team)", 5)
								end
								playertween.Completed:Wait()
								if not Autowin.Enabled then return end
								if EntityNearPosition(50) and EntityNearPosition(50).RootPart and isAlive() then
									repeat
										target = EntityNearPosition(50)
										if not target.RootPart or not isAlive() then break end
										playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
										playertween:Play()
										task.wait()
									until not (EntityNearPosition(45) and EntityNearPosition(45).RootPart) or not Autowin.Enabled or not isAlive()
								end
								if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
									lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
									lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
								end
							elseif GetTarget(nil, false, true) and GetTarget(nil, false, true).RootPart then
								local target = GetTarget(nil, false, true)
								playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.75, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
								playertween:Play()
								if AutowinNotification.Enabled then task.spawn(InfoNotification, "Autowin", "Killing "..target.Player.DisplayName.." ("..(target.Player.Team and target.Player.Team.Name or "neutral").." Team)", 5) end
								playertween.Completed:Wait()
								if not Autowin.Enabled then return end
								if EntityNearPosition(50) and EntityNearPosition(50).RootPart and isAlive() then
									repeat
										target = EntityNearPosition(50)
										if not target.RootPart or not isAlive() then break end
										playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.75), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
										playertween:Play()
										task.wait()
									until not (EntityNearPosition(45) and EntityNearPosition(45).RootPart) or not Autowin.Enabled or not isAlive()
								end
								if isAlive(lplr, true) and GetTarget(nil, false, true) and GetTarget(nil, false, true).RootPart and Autowin.Enabled then
									lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
									lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
								end
							else
								if shared.GlobalStore.matchState == 2 then return end
								InfoNotification("Autowin", "No targets found! Retrying...", 1)
								lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
								lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
							end
						end))
						table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
							if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
							if not store.matchState == 2 then return end
							local oldpos = lplr.Character:WaitForChild("HumanoidRootPart").CFrame
							repeat 
							lplr.Character:WaitForChild("HumanoidRootPart").CFrame = oldpos
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
end)--]]

--[[run(function()
	local Autowin = {Enabled = false}
	local AutowinNotification = {Enabled = true}
	local bedtween
	local playertween
	Autowin = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Autowin",
		ExtraText = function() return store.queueType:find("5v5") and "BedShield" or "Normal" end,
		Function = function(callback)
			if callback then
				task.spawn(function()
					if store.matchState == 0 then repeat task.wait() until store.matchState ~= 0 or not Autowin.Enabled end
					if not shared.VapeFullyLoaded then repeat task.wait() until shared.VapeFullyLoaded or not Autowin.Enabled end
					if not Autowin.Enabled then return end
					vapeAssert(not store.queueType:find("skywars"), "Autowin", "Skywars not supported.", 7, true, true, "Autowin")
					if isAlive(lplr, true) then
						lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
					end
					table.insert(Autowin.Connections, runService.Heartbeat:Connect(function()
						pcall(function()
							if not isnetworkowner(lplr.Character:WaitForChild("HumanoidRootPart")) and (FindEnemyBed() and GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), FindEnemyBed()) > 75 or not FindEnemyBed()) then
								if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled and (not store.matchState == 2) then
									lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
									lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
								end
							end
						end)
					end))
					table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
						if not isAlive(lplr, true) then repeat task.wait() until isAlive(lplr, true) end
						local bed = FindEnemyBed()
						if bed and (bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") < workspace:GetServerTimeNow() or not bed:GetAttribute("BedShieldEndTime")) then
						bedtween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.65, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0), {CFrame = CFrame.new(bed.Position) + Vector3.new(0, 10, 0)})
						task.wait(0.1)
						bedtween:Play()
						bedtween.Completed:Wait()
						task.spawn(function()
						task.wait(1.5)
						local magnitude = GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), bed)
						if magnitude >= 50 and FindTeamBed() and Autowin.Enabled then
							lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
							lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						end
						end)
						if AutowinNotification.Enabled then
							local bedname = VoidwareStore.bedtable[bed] or "unknown"
							task.spawn(InfoNotification, "Autowin", "Destroying "..bedname:lower().." team's bed", 5)
						end
						if not isEnabled("Nuker") then
							GuiLibrary.ObjectsThatCanBeSaved.NukerOptionsButton.Api.ToggleButton(false)
						end
						repeat task.wait() until FindEnemyBed() ~= bed or not isAlive()
						if FindTarget(45, store.blockRaycast) and FindTarget(45, store.blockRaycast).RootPart and isAlive() then
							if AutowinNotification.Enabled then
								local team = VoidwareStore.bedtable[bed] or "unknown"
								task.spawn(InfoNotification, "Autowin", "Killing "..team:lower().." team's teamates", 5)
							end
							repeat
							local target = FindTarget(45, store.blockRaycast)
							if not target.RootPart then break end
							playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.30), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
							playertween:Play()
							task.wait()
							until not (FindTarget(45, store.blockRaycast) and FindTarget(45, store.blockRaycast).RootPart) or not Autowin.Enabled or not isAlive()
						end
						if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
							lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
							lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						end
						elseif FindTarget(nil, store.blockRaycast) and FindTarget(nil, store.blockRaycast).RootPart then
							task.wait()
							local target = FindTarget(nil, store.blockRaycast)
							playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(GetMagnitudeOf2Objects(lplr.Character:WaitForChild("HumanoidRootPart"), target.RootPart) / 23.4 / 35, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
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
									playertween = tweenService:Create(lplr.Character:WaitForChild("HumanoidRootPart"), TweenInfo.new(0.30), {CFrame = target.RootPart.CFrame + Vector3.new(0, 3, 0)})
									playertween:Play()
									task.wait()
									until not (FindTarget(50, store.blockRaycast) and FindTarget(50, store.blockRaycast).RootPart) or (not Autowin.Enabled) or (not isAlive())
								end
							if isAlive(lplr, true) and FindTeamBed() and Autowin.Enabled then
								lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
								lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
							end
						else
						if store.matchState == 2 then return end
						lplr.Character:WaitForChild("Humanoid"):TakeDamage(lplr.Character:WaitForChild("Humanoid").Health)
						lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
						end
					end))
					table.insert(Autowin.Connections, lplr.CharacterAdded:Connect(function()
						if (not isAlive(lplr, true)) then repeat task.wait() until isAlive(lplr, true) end
						if (not store.matchState == 2) then return end
						local oldpos = lplr.Character:WaitForChild("HumanoidRootPart").CFrame
						repeat 
						lplr.Character:WaitForChild("HumanoidRootPart").CFrame = oldpos
						task.wait()
						until (not isAlive(lplr, true)) or (not Autowin.Enabled)
					end))
				end)
			else
				pcall(function() playertween:Cancel() end)
				pcall(function() bedtween:Cancel() end)
			end
		end,
		HoverText = "best paid autowin 2023!1!!! rel11!11!1"
	})
end)--]]

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
								bedwars.Client:Get("ScytheDash"):SendToServer({direction = lplr.Character:WaitForChild("HumanoidRootPart").CFrame.LookVector*9e9})
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
			local plrs_frame = frame:FindFirstChild("4"):FindFirstChild("1")
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

--[[run(function()
	local isAlive = function(plr, healthblacklist)
		plr = plr or lplr
		local alive = false 
		if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
			alive = true
		end
		if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
			alive = false
		end
		return alive
	end

	local playerRaycasted = function(player, direction)
		if not isAlive(player, true) then
			return false
		end

		local root = player.Character.HumanoidRootPart
		local rayOrigin = root.Position
		local rayDirection = direction or Vector3.new(0, -15, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {player.Character}
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		return raycastResult ~= nil
	end

	local ExploitDetectionSystemConfig = {
		Enabled = false,
		DetectionThresholds = {
			TeleportDistance = 400,
			SpeedDistance = 25,
			FlyDistance = 10000,
			CheckInterval = 2.5
		},
		DetectedPlayers = {
			Teleport = {},
			Speed = {},
			InfiniteFly = {},
			Invisibility = {},
			NameSuspicious = {},
			Cached = {}
		},
		CacheEnabled = true,
		TeleportDetection = false,
		InfiniteFlyDetection = false,
		InvisibilityDetection = false,
		NukerDetection = false,
		SpeedDetection = false,
		NameDetection = false,
		Connections = {}
	}

	local DetectionCore = {
		updateCache = function(player, detectionType)
			if not ExploitDetectionSystemConfig.CacheEnabled then return end
			
			local success, cache = pcall(function()
				local file = readfile('vape/Libraries/exploiters.json')
				return file and httpService:JSONDecode(file) or {}
			end)
			
			cache = cache or {}
			cache[player.Name] = cache[player.Name] or {
				DisplayName = player.DisplayName,
				UserId = tostring(player.UserId),
				Detections = {}
			}
			
			if not table.find(cache[player.Name].Detections, detectionType) then
				table.insert(cache[player.Name].Detections, detectionType)
				pcall(function()
					writefile('vape/Libraries/exploiters.json', httpService:JSONEncode(cache))
				end)
			end
		end,

		isValidTarget = function(player)
			return player ~= lplr and not player:GetAttribute('Spectator') and store.queueType:find('bedwars') ~= nil
		end,

		notify = function(title, message, duration)
			InfoNotification('HackerDetector', message, duration)
			whitelist.customtags[title] = {{text = 'VAPE USER', color = Color3.fromRGB(255, 255, 0)}}
		end
	}

	local DetectionMethods = {
		Teleport = function(player)
			local lastTeleport = player:GetAttribute('LastTeleported') or 0
			local lastPosition = Vector3.zero
			
			table.insert(ExploitDetectionSystemConfig.Connections, player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
				lastTeleport = player:GetAttribute('LastTeleported')
			end))
			
			table.insert(ExploitDetectionSystemConfig.Connections, player.CharacterAdded:Connect(function()
				task.spawn(function()
					repeat task.wait() until isAlive(player, true)
					lastPosition = player.Character.HumanoidRootPart.Position
					
					task.delay(ExploitDetectionSystemConfig.DetectionThresholds.CheckInterval, function()
						if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.Teleport, player) then
							local distance = (player.Character.HumanoidRootPart.Position - lastPosition).Magnitude
							if distance >= ExploitDetectionSystemConfig.DetectionThresholds.TeleportDistance and 
							   (player:GetAttribute('LastTeleported') - lastTeleport) == 0 then
								DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Teleport!', 100)
								table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Teleport, player)
								DetectionCore.updateCache(player, 'Teleport')
							end
						end
					end)
				end)
			end))
		end,

		Speed = function(player)
			local lastTeleport = player:GetAttribute('LastTeleported') or 0
			local lastPosition = Vector3.zero
			
			table.insert(ExploitDetectionSystemConfig.Connections, player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
				lastTeleport = player:GetAttribute('LastTeleported')
			end))
			
			task.spawn(function()
				repeat
					if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.Speed, player) then
						local magnitude = (player.Character.HumanoidRootPart.Position - lastPosition).Magnitude
						local kitDistance = ExploitDetectionSystemConfig.DetectionThresholds.SpeedDistance
						local threshold = kitDistance + (playerRaycasted(player, Vector3.new(0, -15, 0)) and 0 or 40)
						
						if magnitude >= threshold and (player:GetAttribute('LastTeleported') - lastTeleport) ~= 0 then
							DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Speed!', 60)
							table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Speed, player)
							DetectionCore.updateCache(player, 'Speed')
						end
						lastPosition = player.Character.HumanoidRootPart.Position
						task.wait(ExploitDetectionSystemConfig.DetectionThresholds.CheckInterval)
					end
				until not ExploitDetectionSystemConfig.Enabled or not ExploitDetectionSystemConfig.SpeedDetection
			end)
		end,

		InfiniteFly = function(player)
			task.spawn(function()
				repeat
					if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.InfiniteFly, player) then
						local distance = (lplr.Character:WaitForChild("HumanoidRootPart").Position - player.Character.HumanoidRootPart.Position).Magnitude
						if distance >= ExploitDetectionSystemConfig.DetectionThresholds.FlyDistance and 
						   not playerRaycasted(player) then
							DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Infinite Fly!', 60)
							table.insert(ExploitDetectionSystemConfig.DetectedPlayers.InfiniteFly, player)
							DetectionCore.updateCache(player, 'InfiniteFly')
						end
						task.wait(ExploitDetectionSystemConfig.DetectionThresholds.CheckInterval)
					end
				until not ExploitDetectionSystemConfig.Enabled or not ExploitDetectionSystemConfig.InfiniteFlyDetection
			end)
		end,

		Invisibility = function(player)
			task.spawn(function()
				repeat
					if isAlive(player, true) and not table.find(ExploitDetectionSystemConfig.DetectedPlayers.Invisibility, player) then
						for _, track in pairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
							local animId = track.Animation.AnimationId
							if animId == 'http://www.roblox.com/asset/?id=11335949902' or animId == 'rbxassetid://11335949902' then
								DetectionCore.notify(player.Name, player.DisplayName .. ' detected using Invisibility!', 60)
								table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Invisibility, player)
								DetectionCore.updateCache(player, 'Invisibility')
							end
						end
						task.wait(0.5)
					end
				until not ExploitDetectionSystemConfig.Enabled or not ExploitDetectionSystemConfig.InvisibilityDetection
			end)
		end,

		NameCheck = function(player)
			task.spawn(function()
				local suspiciousNames = {'godsploit', 'alsploit', 'renderintents'}
				local nameLower = player.Name:lower()
				local displayLower = player.DisplayName:lower()
				
				for _, term in ipairs(suspiciousNames) do
					if nameLower:find(term) or displayLower:find(term) then
						DetectionCore.notify(player.Name, player.DisplayName .. ' has suspicious ' .. (nameLower:find(term) and 'username' or 'display name') .. ' "' .. term .. '"!', 20)
						DetectionCore.updateCache(player, 'SuspiciousName')
						return
					end
				end
			end)
		end,

		CacheCheck = function(player)
			local success, cache = pcall(function()
				return httpService:JSONDecode(readfile('vape/Libraries/exploiters.json'))
			end)
			
			if success and cache[player.Name] then
				DetectionCore.notify(player.Name, player.DisplayName .. ' found in exploiter cache!', 30)
				table.insert(ExploitDetectionSystemConfig.DetectedPlayers.Cached, player)
			end
		end
	}

	local function initializeDetections(player)
		local toggles = {
			Teleport = ExploitDetectionSystemConfig.TeleportDetection,
			Speed = ExploitDetectionSystemConfig.SpeedDetection,
			InfiniteFly = ExploitDetectionSystemConfig.InfiniteFlyDetection,
			Invisibility = ExploitDetectionSystemConfig.InvisibilityDetection,
			NameCheck = ExploitDetectionSystemConfig.NameDetection,
			CacheCheck = ExploitDetectionSystemConfig.CacheEnabled
		}
		
		for detection, method in pairs(DetectionMethods) do
			if toggles[detection] then
				task.spawn(method, player)
			end
		end
	end

	local CORE_CONNECTIONS = {}

	local function clean(con)
		table.insert(CORE_CONNECTIONS, con)
	end

	local ExploitDetectionSystem = {
		Enabled = false,
		ToggleButton = function() end,
		Toggle = function(self, enabled)
			ExploitDetectionSystemConfig.Enabled = enabled
			if enabled then
				for _, player in pairs(playersService:GetPlayers()) do
					if player ~= lplr then
						initializeDetections(player)
					end
				end
				clean(playersService.PlayerAdded:Connect(initializeDetections))
			else
				for _, conn in pairs(ExploitDetectionSystemConfig.Connections) do
					conn:Disconnect()
				end
				table.clear(ExploitDetectionSystemConfig.Connections)
				for _, conn in pairs(CORE_CONNECTIONS) do
					conn:Disconnect()
				end
				table.clear(CORE_CONNECTIONS)
			end
		end
	}

	local module = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = 'HackerDetector',
		HoverText = 'Advanced exploit detection system for monitoring suspicious player behavior',
		ExtraText = function() return 'Enhanced' end,
		Function = function(enabled)
			ExploitDetectionSystem:Toggle(enabled)
		end
	})

	module.CreateToggle({
		Name = 'Teleport',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.TeleportDetection = call
		end	
	})
	
	module.CreateToggle({
		Name = 'InfiniteFly',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.InfiniteFlyDetection = call
		end
	})
	
	module.CreateToggle({
		Name = 'Invisibility',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.InvisibilityDetection = call
		end
	})
	
	module.CreateToggle({
		Name = 'Nuker',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.NukerDetection = call
		end
	})
	
	module.CreateToggle({
		Name = 'Speed',
		Default = true,
		Function = function(call) 
			ExploitDetectionSystemConfig.SpeedDetection = call
		end
	})
	
	module.CreateToggle({
		Name = 'Name',
		Default = true,
		Function = function(call)
			ExploitDetectionSystemConfig.NameDetection = call
		end
	})
	
	module.CreateToggle({
		Name = 'Cached detections',
		HoverText = 'Manages detection cache in vape/Libraries/exploiters.json',
		Default = true,
		Function = function(state) 
			ExploitDetectionSystemConfig.CacheEnabled = state 
		end
	})
end)--]]

--[[run(function()
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
					if entityLibrary.isAlive and lplr.Character:WaitForChild("Humanoid").FloorMaterial == Enum.Material.Air or jumps > 0 then 
						DoubleHighJump.ToggleButton(false) 
						return
					end
					for i = 1, 2 do 
						if not entityLibrary.isAlive then
							DoubleHighJump.ToggleButton(false) 
							return  
						end
						if i == 2 and lplr.Character:WaitForChild("Humanoid").FloorMaterial ~= Enum.Material.Air then 
							continue
						end
						lplr.Character:WaitForChild("HumanoidRootPart").Velocity = Vector3.new(0, i == 1 and DoubleHighJumpHeight.Value or DoubleHighJumpHeight2.Value, 0)
						jumps = i
						task.wait(i == 1 and 1 or 0.3)
					end
					task.spawn(function()
						for i = 1, 20 do 
							if entityLibrary.isAlive then 
								lplr.Character:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Landed)
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
end)--]]

--[[local StaffDetector = {Enabled = false}
run(function()
	local StaffDetector_Functions = {}
	local StaffDetector_Table = {
		Friends = {}
	}
	local StaffDetector_Action = {
		DropdownValue = {Value = "Uninject"},
		FunctionsTable = {
			["Uninject"] = function()
				GuiLibrary.SelfDestruct()
			end, 
			["Panic"] = function() 
				task.spawn(function()
					coroutine.close(shared.saveSettingsLoop)
				end)
				GuiLibrary.SaveSettings()
				function GuiLibrary.SaveSettings()
					return warningNotification("StaffDetector", "Saving Settings has been prevented from staff detector!", 1.5)
				end
				warningNotification("StaffDetector", "Saving settings has been disabled!", 1.5)
				task.spawn(function()
					repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.PanicOptionsButton
					shared.GuiLibrary.ObjectsThatCanBeSaved.PanicOptionsButton.Api.ToggleButton(false)
				end)
			end,
			["Lobby"] = function() 
				TPService:Teleport(6872265039)
			end
		},
	}
	local StaffDetector_CustomBlacklist = {
		Toggle = {Enabled = false},
		TextList = {ObjectList = {}},
		YoutuberToggle = {Enabled = false}
	}
	local StaffDetector_ReadStaffData = {Enabled = false}
	local StaffDetector_Connections = {}
	local TPService = game:GetService('TeleportService')
	local HTTPService = game:GetService("HttpService")
	local Players = game:GetService("Players")
	function StaffDetector_Functions.SaveStaffData(staff, detection_type)
		local suc, err = pcall(function()
			return HTTPService:JSONDecode(readfile('vape/Libraries/StaffData.json'))
		end)
		local json = {}
		if suc then
			json = err
		end
		table.insert(json,{
			StaffName = staff.DisplayName.."(@"..staff.Name..")",
			Time = os.time(),
			DetectionType = detection_type
		})
		if (not isfolder('vape/Libraries')) then makefolder('vape/Libraries') end
		writefile('vape/Libraries/StaffData.json', HTTPService:JSONEncode(json))
	end
	function StaffDetector_Functions.Notify(text)
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
	function StaffDetector_Functions.Trigger(plr, det_type, addInfo)
		StaffDetector_Functions.SaveStaffData(plr, det_type)
		local text = plr.DisplayName.."(@"..plr.Name..") has been detected as staff via "..det_type.." detection type! "..StaffDetector_Action.DropdownValue.." action type will be used shortly."
		if addInfo then text = text.." Additonal Info: "..addInfo end
		StaffDetector_Functions.Notify(text)
		StaffDetector_Action.FunctionsTable[StaffDetector_Action.DropdownValue]()
	end
	function StaffDetector_Functions.Log_User_Friends(plr)
		pcall(function()
			local function iterPageItems(pages)
				return coroutine.wrap(function()
					local pagenum = 1
					while true do
						for _, item in ipairs(pages:GetCurrentPage()) do
							coroutine.yield(item, pagenum)
						end
						if pages.IsFinished then
							break
						end
						pages:AdvanceToNextPageAsync()
						pagenum = pagenum + 1
					end
				end)
			end
			local friendPages = Players:GetFriendsAsync(plr.UserId)
			for i,v in iterPageItems(friendPages) do
				StaffDetector_Table.Friends[plr.UserId] = StaffDetector_Table.Friends[plr.UserId] or {}
				table.insert(StaffDetector_Table.Friends[plr.UserId], i.Username)
			end
		end)
	end
	function StaffDetector_Functions.isFriend(plr)
		local target = plr.Name
		local state, friendOf = false, nil
		for i,v in pairs(StaffDetector_Table.Friends) do
			for i2, v2 in pairs(v) do
				if v2 == target then
					friendOf = Players:GetNameFromUserIdAsync(i)
					state = true
				end
			end
		end
		return state, friendOf
	end
	function StaffDetector_Functions.groupCheck(plr)
		local plrRank = plr:GetRankInGroup(5774246)
		local state, Type = false, nil
		local Rank_Table = {
			[79029254] = "AC MOD",
			[86172137] = "Lead AC MOD (chase :D)", -- lead ac mod :D luv u chase
			[43926962] = "Developer",
			[37929139] = "Developer",
			[87049509] = "Owner",
			[37929138] = "Owner"
		}
		if StaffDetector_CustomBlacklist.YoutuberToggle.Enabled then
			Rank_Table[42378457] = "Youtuber/Famous"
		end
		if Rank_Table[plrRank] then state = true; Type = Rank_Table[plrRank] end
		return state, Type
	end
	function StaffDetector_Functions.CheckAndTrackPlrTags(plr)
		local blacklisted_tags = {
			["Normal"] = {"AC MOD", "LEAD AC MOD", "DEV"},
			["Clan"] = {}
		}
		if StaffDetector_CustomBlacklist.YoutuberToggle.Enabled then
			table.insert(blacklisted_tags, "FAMOUS")
		end
		local blacklisted_clan_tags = {}
		if StaffDetector_CustomBlacklist.Toggle.Enabled then
			for i,v in pairs(StaffDetector_CustomBlacklist.TextList.ObjectList) do
				table.insert(blacklisted_tags, v)
			end
		end
		local function isBlacklisted(tag)
			for i,v in pairs(blacklisted_tags.Normal) do
				if v == tag then 
					return true, "Normal"
				end
			end
			for i,v in pairs(blacklisted_tags.Clan) do
				if v == tag then 
					return true, "Clan"
				end
			end
			return false, nil
		end
		local function checkTags(tagsFolder)
			pcall(function()
				for i,v in pairs(tagsFolder:GetChildren()) do
					if v.Text then
						local state, Type = isBlacklisted(v.Text)
						if state then
							local add_on = "TagName: "..v.Text
							if Type == "Clan" then add_on = add_on.." Type: "..Type end
							StaffDetector_Functions.Trigger(plr, "TAG", add_on)
						end
					end
				end
			end)
		end
		local tags = plr:FindFirstChild("Tags")
		if tags then
			checkTags(tags)
			local con = tags.ChildAdded:Connect(function() checkTags(tags) end)
			table.insert(StaffDetector_Connections, con)
		else
			local con1 = plr.ChildAdded:Connect(function(child)
				if child.Name == "Tags" and child.ClassName == "Folder" then
					checkTags(child)
					local con2 = child.ChildAdded:Connect(function() checkTags(child) end)
					table.insert(StaffDetector_Connections, con2)
				end
			end)
			table.insert(StaffDetector_Connections, con1)
		end
	end
	local function checkUser(plr)
		StaffDetector_Functions.Log_User_Friends(plr)
		pcall(function()
			StaffDetector_Functions.CheckAndTrackPlrTags(plr)
		end)
		task.spawn(function()
			repeat task.wait() until plr.Character
			if tostring(plr.Team) == "Spectators" then
				local state, friendOf = StaffDetector_Functions.isFriend(plr)
				if (not state) then
					StaffDetector_Functions.Trigger(plr, "TeamCheck")
				end
			else
				local state, Type = StaffDetector_Functions.groupCheck(plr)
				if state then
					StaffDetector_Functions.Trigger(plr, "GroupRoleCheck", "RoleDetected: "..Type)
				end
			end
		end)
	end
	StaffDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "1[NEW] StaffDetector",
		Function = function(callback)
			if callback then
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v ~= game:GetService("Players").LocalPlayer then
						checkUser(v)
					end
				end
				local con = game:GetService("Players").PlayerAdded:Connect(function(plr)
					checkUser(plr)
				end)
				table.insert(StaffDetector_Connections, con)
			else
				for i, v in pairs(StaffDetector_Connections) do
                    if v.Disconnect then pcall(function() v:Disconnect() end) continue end
                    if v.disconnect then pcall(function() v:disconnect() end) continue end
                end
			end
		end,
		HoverText = "Detects staffs"
	})
	local list = {}
	for i,v in pairs(StaffDetector_Action.FunctionsTable) do table.insert(list, i) end
	StaffDetector_Action.DropdownValue = StaffDetector.CreateDropdown({
        Name = 'Action',
        List = list,
        Function = function() end
    })
	StaffDetector_CustomBlacklist.TextList = StaffDetector.CreateTextList({
		Name = "Blacklisted Clans",
		TempText = "Clan Tag",
		AddFunction = function()
			if StaffDetector.Enabled then 
				StaffDetector.ToggleButton(false)
				StaffDetector.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if StaffDetector.Enabled then 
				StaffDetector.ToggleButton(false)
				StaffDetector.ToggleButton(false)
			end
		end
	})
	StaffDetector_CustomBlacklist.TextList.Object.Visible = false
	StaffDetector_CustomBlacklist.Toggle = StaffDetector.CreateToggle({
		Name = "CustomBlacklist",
		Function = function(callback)
			if callback then
				StaffDetector_CustomBlacklist.TextList.Object.Visible = true
			else
				StaffDetector_CustomBlacklist.TextList.Object.Visible = false
			end
		end
	})
	StaffDetector_CustomBlacklist.YoutuberToggle = StaffDetector.CreateToggle({
		Name = "Youtuber/Famous blacklist",
		Function = function(callback)
			StaffDetector.ToggleButton(false)
			StaffDetector.ToggleButton(false)
		end,
		Default = true
	})
	StaffDetector_ReadStaffData = StaffDetector.CreateToggle({
		Name = "Read Current Staff Data",
		Function = function(callback)
			if callback then
				pcall(function()
					StaffDetector_ReadStaffData.ToggleButton(false)
					local suc, err = pcall(function()
						return HTTPService:JSONDecode(readfile('vape/Libraries/StaffData.json'))
					end)
					local json = {}
					if suc then json = err end
					if #json > 0 then
						for i,v in pairs(json) do
							local Staff_Name = v.StaffName
							local Time = v.Time
							local Detection_Type = v.DetectionType
							if Staff_Name and Time and Detection_Type then
								warningNotification("StaffDetector - Log "..tostring(i), "StaffName: "..Staff_Name.." Time_Of_Detection: "..tostring(Time).."\n Detection_Type: "..Detection_Type, 5)
							end
						end
					else
						warningNotification("StaffDetector", "No staff data was found!", 3)
					end
				end)
			end
		end
	})
end)
--]]

shared.restore_function = shared.GuiLibrary.SelfDestruct

pcall(function()
	local StaffDetector = {Enabled = false}
	run(function()
		local TeleportService = game:GetService('TeleportService')
		local HttpService = game:GetService("HttpService")
		local PlayersService = game:GetService("Players")
		
		local StaffDetectionConfig = {
			Connections = {},
			Blacklist = {
				Users = {
					"chasemaser", "OrionYeets", "lIllllllllllIllIIlll", "AUW345678",
					"GhostWxstaken", "throughthewindow009", "YT_GoraPlays",
					"IllIIIIlllIlllIlIIII", "celisnix", "7SlyR", "DoordashRP",
					"IlIIIIIlIIIIIIIllI", "lIIlIlIllllllIIlI", "IllIIIIIIlllllIIlIlI",
					"asapzyzz", "WhyZev", "sworduserpro332", "Muscular_Gorilla",
					"Typhoon_Kang"
				},
				GroupRanks = {
					[79029254] = "AC MOD",
					[86172137] = "Lead AC MOD",
					[43926962] = "Developer",
					[37929139] = "Developer",
					[87049509] = "Owner",
					[37929138] = "Owner"
				}
			},
			Actions = {
				Current = "Uninject",
				Options = {
					Uninject = function()
						shared.restore_function(shared.GuiLibrary)
					end,
					Panic = function()
						task.spawn(function()
							if shared.saveSettingsLoop then
								coroutine.close(shared.saveSettingsLoop)
							end
						end)
						GuiLibrary.SaveSettings()
						local originalSave = GuiLibrary.SaveSettings
						GuiLibrary.SaveSettings = function()
							warningNotification("GuiLibrary", "Saving settings blocked by Panic mode!", 1.5)
						end
						warningNotification("StaffDetector", "Panic mode activated - settings save disabled!", 1.5)
						task.spawn(function()
							repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.PanicOptionsButton
							shared.GuiLibrary.ObjectsThatCanBeSaved.PanicOptionsButton.Api.ToggleButton(false)
						end)
					end,
					Lobby = function()
						TeleportService:Teleport(6872265039)
					end
				}
			},
			JoinNotifier = {Enabled = false},
			LeaveParty = {Enabled = false}
		}

		local DetectionUtils = {
			notify = function() end,
			saveStaffRecord = function() end,
			triggerAction = function() end
		}
	
		DetectionUtils = {
			saveStaffRecord = function(player, detectionMethod)
				local success, data = pcall(function()
					return HttpService:JSONDecode(readfile('vape/Libraries/StaffData.json') or '[]')
				end)
				
				data = success and data or {}
				table.insert(data, {
					StaffName = player.DisplayName .. "(@" .. player.Name .. ")",
					Time = os.time(),
					DetectionMethod = detectionMethod
				})
				
				if not isfolder('vape/Libraries') then
					makefolder('vape/Libraries')
				end
				pcall(function()
					writefile('vape/Libraries/StaffData.json', HttpService:JSONEncode(data))
				end)
			end,
	
			notify = function(message, duration)
				warningNotification("StaffDetector", message, duration or 30)
				game:GetService('StarterGui'):SetCore('ChatMakeSystemMessage', {
					Text = message,
					Color = Color3.fromRGB(255, 0, 0),
					Font = Enum.Font.GothamBold,
					FontSize = Enum.FontSize.Size24
				})
			end,
	
			triggerAction = function(player, detectionType, extraInfo)
				local message = string.format("%s (@%s) detected as staff via %s! Executing %s action...", player.DisplayName, player.Name, detectionType, StaffDetectionConfig.Actions.Current)
				if extraInfo then
					message = message .. " Info: " .. extraInfo
				end
				
				DetectionUtils.notify(message)
				DetectionUtils.saveStaffRecord(player, detectionType)
				if StaffDetectionConfig.LeaveParty and StaffDetectionConfig.LeaveParty.Enabled then
					game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty"):FireServer()
					DetectionUtils.notify("Left party")
				end
				StaffDetectionConfig.Actions.Options[StaffDetectionConfig.Actions.Current]()
			end
		}

		local DetectionMethods = {
			checkBlacklist = function() end,
			checkGroupRank = function() end,
			checkPermissions = function() end,
			scanPlayer = function() end
		}
	
		DetectionMethods = {
			checkBlacklist = function(player)
				if table.find(StaffDetectionConfig.Blacklist.Users, player.Name) then
					DetectionUtils.triggerAction(player, "Blacklist")
				end
			end,
	
			checkGroupRank = function(player)
				local success, rank = pcall(function() return player:GetRankInGroup(5774246) end)
				rank = success and rank or 0
				
				local rankInfo = StaffDetectionConfig.Blacklist.GroupRanks[rank]
				if rankInfo then
					DetectionUtils.triggerAction(player, "GroupRank", "Role: " .. rankInfo)
				elseif StaffDetector.YoutuberToggle and StaffDetector.YoutuberToggle.Enabled and rank == 42378457 then
					DetectionUtils.triggerAction(player, "GroupRank", "Role: Youtuber/Famous")
				end
			end,
	
			checkPermissions = function(player)
				local success, KnitClient = pcall(function()
					return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 9)
				end)
				
				if success then
					local permissionController
					repeat
						permissionController = KnitClient.Controllers.PermissionController
						task.wait()
					until permissionController

					if shared.ACMODVIEWENABLED then return end
					if player == game:GetService("Players").LocalPlayer then return end
					if permissionController:isStaffMember(player) then
						DetectionUtils.triggerAction(player, "Permissions")
					end
				end
			end,
	
			scanPlayer = function(player)
				if player == PlayersService.LocalPlayer then return end
				task.spawn(function() pcall(DetectionMethods.checkBlacklist, player) end)
				task.spawn(function() pcall(DetectionMethods.checkGroupRank, player) end)
				task.spawn(function() pcall(DetectionMethods.checkPermissions, player) end)
			end
		}
	
		StaffDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
			Name = "StaffDetector [Enhanced]",
			Function = function(enabled)
				StaffDetector.Enabled = enabled
				if enabled then
					for _, player in pairs(PlayersService:GetPlayers()) do
						if player == PlayersService.LocalPlayer then continue end
						DetectionMethods.scanPlayer(player)
					end
					
					local connection = PlayersService.PlayerAdded:Connect(function(player)
						if StaffDetector.Enabled then
							DetectionMethods.scanPlayer(player)
							if StaffDetectionConfig.JoinNotifier.Enabled and store.matchState > 0 then
								DetectionUtils.notify(player.Name .. " has joined the game!", 3)
							end
						end
					end)
					table.insert(StaffDetectionConfig.Connections, connection)
				else
					for _, conn in pairs(StaffDetectionConfig.Connections) do
						pcall(function() conn:Disconnect() end)
					end
					table.clear(StaffDetectionConfig.Connections)
				end
			end,
			Default = true
		})
	
		StaffDetector.Restart = function()
			if StaffDetector.Enabled then
				StaffDetector.ToggleButton(false)
				task.wait(0.1)
				StaffDetector.ToggleButton(true)
			end
		end
	
		local actionList = {}
		for action in pairs(StaffDetectionConfig.Actions.Options) do
			table.insert(actionList, action)
		end
		StaffDetectionConfig.Actions.Dropdown = StaffDetector.CreateDropdown({
			Name = 'Action',
			List = actionList,
			Function = function(value)
				StaffDetectionConfig.Actions.Current = value
			end
		})
	
		StaffDetectionConfig.LeaveParty = StaffDetector.CreateToggle({
			Name = "Leave Party",
			Function = function(enabled)
				StaffDetectionConfig.LeaveParty.Enabled = enabled
				StaffDetector.Restart()
			end,
			Default = true
		})

		StaffDetectionConfig.JoinNotifier = StaffDetector.CreateToggle({
			Name = "Join Notifier",
			Function = function(enabled)
				StaffDetectionConfig.JoinNotifier.Enabled = enabled
				StaffDetector.Restart()
			end,
			Default = true
		})
	
		StaffDetector.YoutuberToggle = StaffDetector.CreateToggle({
			Name = "Youtuber Detection",
			Function = StaffDetector.Restart,
			Default = false
		})
	end)
	
	--[[task.spawn(function()
		pcall(function()
			repeat task.wait() until shared.VapeFullyLoaded
			if (not StaffDetector.Enabled) then StaffDetector.ToggleButton(false) end
		end)
	end)--]]
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
				local anim2 = lplr.Character:WaitForChild("Humanoid").Animator:LoadAnimation(anim) 
				for i,v in next, lplr.Character:GetDescendants() do 
					if v:IsA('BasePart') and v.CanCollide and v ~= lplr.Character:WaitForChild("HumanoidRootPart") then 
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
					if isAlive(lplr, true) and isnetworkowner(lplr.Character:WaitForChild("HumanoidRootPart")) then 
						lplr.Character:WaitForChild("HumanoidRootPart").Transparency = (invisvisual.Enabled and 0.6 or 1)
						oldcolor = lplr.Character:WaitForChild("HumanoidRootPart").Color
						lplr.Character:WaitForChild("HumanoidRootPart").Color = Color3.fromHSV(visualrootcolor.Hue, visualrootcolor.Sat, visualrootcolor.Value)
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
					lplr.Character:WaitForChild("HumanoidRootPart").Transparency = 1 
					lplr.Character:WaitForChild("HumanoidRootPart").Color = oldcolor
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
	local TexturePacks = {["Enabled"] = false}
	local packselected = {["Value"] = "OldBedwars"}

	local toolFunction = function() end
	local con

	local packfunctions = {
		SeventhPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14033898270")
				local import = objs[1]
				import.Parent = ReplicatedStorage
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
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.5, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -.9)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.09)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		EighthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14078540433")
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
						offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
				}
				toolFunction = function(tool)
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
							model2.CFrame *= CFrame.new(.5,0,-.8)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		SixthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")

				local objs = game:GetObjects("rbxassetid://13780890894")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				
				local swordIndex = {
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
				}
				
				local pickaxeIndex = {
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
				}

				local swordFunction = function(tool)
					if not tool:IsA("Accessory") then
						return
					end
					
					for _, v in pairs(swordIndex) do
						if v.name == tool.Name then
							for _, v in pairs(tool:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							
							local model = v.model:Clone()
							model.CFrame = tool.Handle.CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool
							
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool.Handle
							
							local tool2 = Players.LocalPlayer.Character[tool.Name]
							
							for _, v in pairs(tool2:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2.Handle.CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model2.CFrame *= CFrame.new(0.4, 0, -0.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2.Handle
						end
					end
				end

				local pickaxeFunction = function(tool)
					if not tool:IsA("Accessory") then
						return
					end

					for _, v in pairs(pickaxeIndex) do
						if v.name == tool.Name then
							for _, v in pairs(tool:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool.Handle.CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool.Handle
							local tool2 = Players.LocalPlayer.Character[tool.Name]
							for _, v in pairs(tool2:GetDescendants()) do
								if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
									v.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2.Handle.CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model2.CFrame *= CFrame.new(-0.2, 0, -0.08)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2.Handle
						end
					end
				end

				toolFunction = function(tool)
					task.spawn(function() swordFunction(tool) end)
					task.spawn(function() pickaxeFunction(tool) end)
				end
			end)
		end,
		FifthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				
				local objs = game:GetObjects("rbxassetid://13802020264")
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
					
					
				}
				
				toolFunction = function(tool)
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
							model2.CFrame *= CFrame.new(0.8,0,-.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")			
						end
					end
				end
			end)
		end,
		FourthPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				
				local objs = game:GetObjects("rbxassetid://13801509384")
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
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-270)),
						model = import:WaitForChild("Rageblade"),
					},
					
					
				}

				toolFunction = function(tool)
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
				end
			end)
		end,
		SecondPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://13801616054")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(100),math.rad(-270)),
						model = import:WaitForChild("Rageblade"),
					},
					
					
				}

				toolFunction = function(tool)
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
							model2.CFrame *= CFrame.new(0.8,0,-.9)
							model2.Parent = tool2
							
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
		FirstPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://13783192680")
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
					
					
				}
				toolFunction = function(tool)
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
				end
			end)
		end,
		CottonCandy = function() 
			task.spawn(function() 
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14161283331")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
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
						offset = CFrame.Angles(math.rad(0), math.rad(-18033), math.rad(-95)),
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
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -1)                           
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("iron") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") then
								model2.CFrame *= CFrame.new(0, .027, 0)
							elseif v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, .001, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.29, .1, -.2)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.6, 0, 0)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.2)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end   
			end)
		end,
		EgirlPack = function() 
			task.spawn(function() 	
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14126814481")
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
						offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
				}
				toolFunction = function(tool)
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
							model2.CFrame *= CFrame.new(.6,0,-1)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end             
			end)
		end,
		GlizzyPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://13804645310")
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
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(-270)),
						model = import:WaitForChild("Rageblade"),
					},
				}
				toolFunction = function(tool)
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
							model.CFrame *= CFrame.Angles(math.rad(0),math.rad(100),math.rad(0))
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
							model2.CFrame *= CFrame.Angles(math.rad(0),math.rad(-105),math.rad(0))
							model2.CFrame *= CFrame.new(-0.4,0,-0.10)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
        end,
		PrivatePack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14161283331")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
					{
						name = "rageblade",
						offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
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
						offset = CFrame.Angles(math.rad(0), math.rad(-18033), math.rad(-95)),
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
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -1)                           
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("iron") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") then
								model2.CFrame *= CFrame.new(0, .027, 0)
							elseif v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, .001, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.29, .1, -.2)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.6, 0, 0)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.2)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end          
			end)
        end,
		DemonSlayerPack = function() 
			task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14241215869")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},	
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
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
						offset = CFrame.Angles(math.rad(0), math.rad(90), math.rad(-95)),
						model = import:WaitForChild("Diamond_Pickaxe"),
					},	
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},	
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_dao",
						offset = CFrame.Angles(math.rad(0), math.rad(89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
				}
				toolFunction = function(tool)	
					if not tool:IsA("Accessory") then return end	
					for _, v in ipairs(index) do	
						if v.name == tool.Name then		
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1
								end			
							end		
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool			
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")			
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)			
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then				
									part.Transparency = 1				
								end			
							end			
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -.7)                           
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.2, 0, -.8)
							elseif v.name:match("dao") then
								model2.CFrame *= CFrame.new(.7, 0, -1.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("diamond_pickaxe") then
								model2.CFrame *= CFrame.new(.2, 0, -.26)
							elseif v.name:match("iron") and not v.name:match("iron_pickaxe") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") or v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, -.03, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.2, .1, -.05)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, .05)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.35, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.0, 0, -.06)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
			end)
		end,
        FirstHighResPack = function() 
            task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14224565815")
				local import = objs[1]
				import.Parent = ReplicatedStorage
				local index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0), math.rad(-89), math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
          			{
                        name = "rageblade",
                        offset = CFrame.Angles(math.rad(0),math.rad(-100),math.rad(90)),
                        model = import:WaitForChild("Rageblade"),
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
						offset = CFrame.Angles(math.rad(0), math.rad(90), math.rad(-95)),
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
					{
						name = "fireball",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Fireball"),
					},
					{
						name = "telepearl",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Telepearl"),
					},
					{
						name = "diamond",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Diamond"),
					},
					{
						name = "iron",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Iron"),
					},
					{
						name = "gold",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(90)),
						model = import:WaitForChild("Gold"),
					},
					{
						name = "emerald",
						offset = CFrame.Angles(math.rad(0), math.rad(-90), math.rad(-90)),
						model = import:WaitForChild("Emerald"),
					},
					{
						name = "wood_bow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "wood_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)),
						model = import:WaitForChild("Bow"),
					},
					{
						name = "tactical_crossbow",
						offset = CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90)),
						model = import:WaitForChild("Bow"),
					},
				}
				toolFunction = function(tool)
					if not tool:IsA("Accessory") then return end
					for _, v in ipairs(index) do
						if v.name == tool.Name then
							for _, part in ipairs(tool:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
									part.Transparency = 1
								end
							end
							local model = v.model:Clone()
							model.CFrame = tool:WaitForChild("Handle").CFrame * v.offset
							model.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							model.Parent = tool
							local weld = Instance.new("WeldConstraint", model)
							weld.Part0 = model
							weld.Part1 = tool:WaitForChild("Handle")
							local tool2 = Players.LocalPlayer.Character:WaitForChild(tool.Name)
							for _, part in ipairs(tool2:GetDescendants()) do
								if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
									part.Transparency = 1
								end
							end
							local model2 = v.model:Clone()
							model2.Anchored = false
							model2.CFrame = tool2:WaitForChild("Handle").CFrame * v.offset
							model2.CFrame *= CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0))
							if v.name:match("rageblade") then
								model2.CFrame *= CFrame.new(0.7, 0, -1)
							elseif v.name:match("sword") or v.name:match("blade") then
								model2.CFrame *= CFrame.new(.6, 0, -1.1) - Vector3.new(0, 0, -.3)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and v.name:match("diamond") then
								model2.CFrame *= CFrame.new(.08, 0, -1.1) - Vector3.new(0, 0, -1.1)
							elseif v.name:match("axe") and not v.name:match("pickaxe") and not v.name:match("diamond") then
								model2.CFrame *= CFrame.new(-.2, 0, -2.4) + Vector3.new(0, 0, 2.12)
							elseif v.name:match("diamond_pickaxe") then
								model2.CFrame *= CFrame.new(.2, 0, -.26)
							elseif v.name:match("iron") and not v.name:match("iron_pickaxe") then
								model2.CFrame *= CFrame.new(0, -.24, 0)
							elseif v.name:match("gold") then
								model2.CFrame *= CFrame.new(0, .03, 0)
							elseif v.name:match("diamond") or v.name:match("emerald") then
								model2.CFrame *= CFrame.new(0, -.03, 0)
							elseif v.name:match("telepearl") then
								model2.CFrame *= CFrame.new(.1, 0, .1)
							elseif v.name:match("fireball") then
								model2.CFrame *= CFrame.new(.28, .1, 0)
							elseif v.name:match("bow") and not v.name:match("crossbow") then
								model2.CFrame *= CFrame.new(-.2, .1, -.05)
							elseif v.name:match("wood_crossbow") and not v.name:match("tactical_crossbow") then
								model2.CFrame *= CFrame.new(-.5, 0, .05)
							elseif v.name:match("tactical_crossbow") and not v.name:match("wood_crossbow") then
								model2.CFrame *= CFrame.new(-.35, 0, -1.2)
							else
								model2.CFrame *= CFrame.new(.2, 0, -.24)
							end
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint", model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
           end)
		end,
        RandomPack = function() 
            task.spawn(function()  
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14282106674")
				local import = objs[1]
				import.Parent = game:GetService("ReplicatedStorage")
				index = {
					{
						name = "wood_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Wood_Sword"),
					},
					{
						name = "stone_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Stone_Sword"),
					},
					{
						name = "iron_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Iron_Sword"),
					},
					{
						name = "diamond_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Diamond_Sword"),
					},
					{
						name = "emerald_sword",
						offset = CFrame.Angles(math.rad(0),math.rad(-89),math.rad(-90)),
						model = import:WaitForChild("Emerald_Sword"),
					},
				}
				toolFunction = function(tool)
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
							model2.CFrame *= CFrame.new(0.6,0,-.9)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end  
           end)
		end,
		SecondHighResPack = function() 
            task.spawn(function()
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local Workspace = game:GetService("Workspace")
				local objs = game:GetObjects("rbxassetid://14078540433")
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
						offset = CFrame.Angles(math.rad(0),math.rad(-90),math.rad(90)),
						model = import:WaitForChild("Rageblade"),
					}, 
				}
				toolFunction = function(tool)
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
							model2.CFrame *= CFrame.new(.5,0,-.8)
							model2.Parent = tool2
							local weld2 = Instance.new("WeldConstraint",model)
							weld2.Part0 = model2
							weld2.Part1 = tool2:WaitForChild("Handle")
						end
					end
				end
           end)
		end
	}

	if (not TexturePacks.Enabled) then toolFunction = function() end end

	local function refresh()
		pcall(function() con:Disconnect() end)
		con = game:GetService("Workspace"):WaitForChild("Camera").Viewmodel.ChildAdded:Connect(toolFunction)
		for i,v in pairs(game:GetService("Workspace"):WaitForChild("Camera").Viewmodel:GetChildren()) do toolFunction(v) end
	end

	TexturePacks = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		["Name"] = "TexturePacksV3",
		["Function"] = function(callback) 
			if callback then 
				packfunctions[packselected["Value"]]()
				refresh()
            else 
				toolFunction = function() end
				refresh()
			end
		end
	})
	local list = {}
	for i,v in pairs(packfunctions) do table.insert(list, tostring(i)) end
	packselected = TexturePacks.CreateDropdown({
		["Name"] = "Pack",
		["Function"] = function() if TexturePacks.Enabled then packfunctions[packselected["Value"]](); refresh() end end,
		["List"] = list
	})
end)

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
							y.Parent = game.Workspace;
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
	texture_pack = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
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
    local TexturePacksV2 = {Enabled = false}
    local TexturePacksV2_Connections = {}
    local TexturePacksV2_GUI_Elements = {
        Material = {Value = "Forcefield"},
        Color = {Hue = 0, Sat = 0, Value = 0},
        GuiSync = {Enabled = false}
    }

    local function refreshChild(child, children)
        if (not child) then return warn("[refreshChild]: invalid child!") end
        if (not table.find(children, child)) then table.insert(children, child) end
        if child.ClassName == "Accessory" then
            for i, v in pairs(child:GetChildren()) do
                if v.ClassName == "MeshPart" then
                    --v.Material = Enum.Material[TexturePacksV2_GUI_Elements.Material.Value]
					v.Material = Enum.Material.ForceField
                    if TexturePacksV2_GUI_Elements.GuiSync.Enabled and TexturePacksV2.Enabled then
                        if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
                            v.Color = GuiLibrary.GUICoreColor
                            GuiLibrary.GUICoreColorChanged.Event:Connect(function()
                                if TexturePacksV2_GUI_Elements.GuiSync.Enabled then v.Color = GuiLibrary.GUICoreColor end
                            end)
                        else
                            local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
                            v.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
                            VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h, s, v)
                                if TexturePacksV2_GUI_Elements.GuiSync.Enabled and TexturePacksV2.Enabled then
                                    local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
                                    v.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
                                    if TexturePacksV2.Enabled then
                                        color = {Hue = h, Sat = s, Value = v}
                                        v.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
                                    end
                                end
                            end))
                        end
                    else
                        v.Color = Color3.fromHSV(TexturePacksV2_GUI_Elements.Color.Hue, TexturePacksV2_GUI_Elements.Color.Sat, TexturePacksV2_GUI_Elements.Color.Value)
                    end
                end
            end
        end
    end

    local function refreshChildren()
        local children = gameCamera and gameCamera:FindFirstChild("Viewmodel") and gameCamera:FindFirstChild("Viewmodel").ClassName and gameCamera:FindFirstChild("Viewmodel").ClassName == "Model" and gameCamera:FindFirstChild("Viewmodel"):GetChildren() or {}
        for i, v in pairs(children) do refreshChild(v, children) end
    end

    TexturePacksV2 = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = "TexturePacksV2",
        Function = function(call)
            if call then
                task.spawn(function()
                    repeat
                        refreshChildren()
                        task.wait()
                    until (not TexturePacksV2.Enabled)
                end)
            else
                for i, v in pairs(TexturePacksV2_Connections) do
                    pcall(function() v:Disconnect() end)
                end
            end
        end
    })

    TexturePacksV2.Restart = function()
        if TexturePacksV2.Enabled then
            TexturePacksV2.ToggleButton(false)
            TexturePacksV2.ToggleButton(false)
        end
    end

    TexturePacksV2_GUI_Elements.Material = TexturePacksV2.CreateDropdown({
        Name = "Material",
        Function = refreshChildren,
        List = GetEnumItems("Material"),
        Default = "Forcefield"
    })
	TexturePacksV2_GUI_Elements.Material.Object.Visible = false

    TexturePacksV2_GUI_Elements.Color = TexturePacksV2.CreateColorSlider({
        Name = "Color",
        Function = refreshChildren
    })

    TexturePacksV2_GUI_Elements.GuiSync = TexturePacksV2.CreateToggle({
        Name = "GUI Color Sync",
        Function = TexturePacksV2.Restart,
        Default = true
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
    local InvisibilitySystem = {
        Enabled = false
    }
	local InvisibilitySystemConnections = {}
	local InvisibilitySystemConfig = {
		ShowRoot = true,
		RootColor = {Hue = 0, Sat = 0, Val = 1}
	}
	local InvisibilitySystemParts = {}
	local InvisibilitySystemAnimation = nil

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local lplr = Players.LocalPlayer

    local InvisUtils = {
        disableCollisions = function(character)
            InvisibilitySystemParts = {}
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide and part ~= character:FindFirstChild("HumanoidRootPart") then
                    part.CanCollide = false
                    table.insert(InvisibilitySystemParts, part)
                end
            end
        end,

        setupAnimation = function(character)
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://11335949902"
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                InvisibilitySystemAnimation = animator:LoadAnimation(anim)
                return InvisibilitySystemAnimation
            end
            return nil
        end,

        updateRootAppearance = function(rootPart)
            if rootPart then
                rootPart.Transparency = InvisibilitySystemConfig.ShowRoot and 0.6 or 1
                rootPart.Color = Color3.fromHSV(
                    InvisibilitySystemConfig.RootColor.Hue,
                    InvisibilitySystemConfig.RootColor.Sat,
                    InvisibilitySystemConfig.RootColor.Val
                )
            end
        end,

        toggleSpider = function(enable)
            local spiderButton = GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton
            if not spiderButton then return end
            
            if enable and spiderButton.Api.Enabled then
                spiderButton.Api.ToggleButton(false)
                task.spawn(function()
                    repeat task.wait(0.1) until warningNotification
                    warningNotification("Invisibility", "Spider disabled to prevent suffocation.\nRe-enabled when invisibility ends!", 10)
                end)
                return true
            elseif not enable and not spiderButton.Api.Enabled then
                spiderButton.Api.ToggleButton(true)
                task.spawn(function()
                    repeat task.wait(0.1) until warningNotification
                    warningNotification("Invisibility", "Spider re-enabled!", 10)
                end)
            end
            return false
        end
    }

    local function applyInvisibility()
        local character = lplr.Character
        if not isAlive(lplr, true) or not character then return end

        InvisUtils.disableCollisions(character)
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local anim = InvisibilitySystemAnimation or InvisUtils.setupAnimation(character)

        table.insert(InvisibilitySystemConnections, character.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") and part.CanCollide and part ~= rootPart then
                part.CanCollide = false
                table.insert(InvisibilitySystemParts, part)
            end
        end))

        local stepConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(InvisibilitySystemParts) do
                part.CanCollide = false
            end
        end)
        table.insert(InvisibilitySystemConnections, stepConnection)

        while InvisibilitySystem.Enabled and isAlive(lplr, true) and anim do
            if GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.Enabled then
                GuiLibrary.ObjectsThatCanBeSaved.AnimationPlayerOptionsButton.Api.ToggleButton(false)
            end
            
            InvisUtils.updateRootAppearance(rootPart)
            anim:Play(0.1, 9e9, 0.1)
            task.wait(0.1)
        end

        if anim then
            anim:Stop()
            anim:AdjustSpeed(0)
        end
        stepConnection:Disconnect()
    end

    InvisibilitySystem = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
        Name = "Invisibility",
        HoverText = "Renders you less visible via animation and transparency",
        Function = function(enabled)
            InvisibilitySystem.Enabled = enabled
            if enabled then
				if store.queueType == "halloween_2025_event_pve" then 
					warningNotification("Invisibility", "Disabled in halloween event!", 3)
					Invisibility.ToggleButton(false)
					return
				end
                local spiderWasDisabled = InvisUtils.toggleSpider(true)
                
                local taskHandle = task.spawn(applyInvisibility)
                table.insert(InvisibilitySystemConnections, lplr.CharacterAdded:Connect(function()
                    task.cancel(taskHandle)
                    taskHandle = task.spawn(applyInvisibility)
                end))

                InvisibilitySystem.Cleanup = function()
                    if spiderWasDisabled then
                        InvisUtils.toggleSpider(false)
                    end
                    if InvisibilitySystemAnimation then
                        InvisibilitySystemAnimation:Stop()
                        InvisibilitySystemAnimation:AdjustSpeed(0)
                    end
                    for _, conn in pairs(InvisibilitySystemConnections) do
                        pcall(conn.Disconnect, conn)
                    end
                    table.clear(InvisibilitySystemConnections)
                    InvisibilitySystemParts = {}
                end
            else
                if InvisibilitySystem.Cleanup then
                    InvisibilitySystem.Cleanup()
                    InvisibilitySystem.Cleanup = nil
                end
            end
        end
    })

    InvisibilitySystem.RootToggle = InvisibilitySystem.CreateToggle({
        Name = "Show Root Part",
        Default = true,
        Function = function(enabled)
			pcall(function()
				InvisibilitySystemConfig.ShowRoot = enabled
				InvisibilitySystem.RootColor.Object.Visible = enabled
			end)
        end,
        HoverText = "Toggles visibility of the root part"
    })

    InvisibilitySystem.RootColor = InvisibilitySystem.CreateColorSlider({
        Name = "Root Color",
        Function = function(hue, sat, val)
            InvisibilitySystemConfig.RootColor = {Hue = hue, Sat = sat, Val = val}
        end,
        Default = {Hue = 0, Sat = 0, Val = 1},
        HoverText = "Sets the color of the root part when visible"
    })

    InvisibilitySystem.RootColor.Object.Visible = InvisibilitySystemConfig.ShowRoot
end)

run(function()
    local DamageHighlightSystem = {
        Enabled = false
    }
	local DamageHighlightSystemConnections = {}
	local DamageHighlightSystemConfig = {
		FillColor = {Hue = 0, Sat = 0, Val = 1},
		Transparency = 0.4,
		SyncWithGUI = false
	}

    local HighlightUtils = {
        applyHighlightStyle = function(highlight)
            local color = DamageHighlightSystemConfig.SyncWithGUI and DamageHighlightSystemConfig.GUISyncColor or DamageHighlightSystemConfig.FillColor
            highlight.FillColor = Color3.fromHSV(color.Hue, color.Sat, color.Val)
            highlight.FillTransparency = DamageHighlightSystemConfig.Transparency
        end,

        updateGUISyncColor = function()
            if shared.RiseMode and GuiLibrary.GUICoreColor then
                DamageHighlightSystemConfig.GUISyncColor = {
                    Hue = GuiLibrary.GUICoreColor:ToHSV().X,
                    Sat = GuiLibrary.GUICoreColor:ToHSV().Y,
                    Val = GuiLibrary.GUICoreColor:ToHSV().Z
                }
            else
                local guiColor = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
                DamageHighlightSystemConfig.GUISyncColor = {
                    Hue = guiColor.Hue,
                    Sat = guiColor.Sat,
                    Val = guiColor.Value
                }
            end
        end
    }

    DamageHighlightSystem = GuiLibrary.ObjectsThatCanBeSaved.CustomisationWindow.Api.CreateOptionsButton({
        Name = 'HighlightVisuals',
        HoverText = 'Customizes damage highlight appearance with color and transparency options',
        Function = function(enabled)
            DamageHighlightSystem.Enabled = enabled
            if enabled then
                task.spawn(function()
                    local connection = game.Workspace.DescendantAdded:Connect(function(descendant)
                        if descendant.Name == '_DamageHighlight_' and descendant.ClassName == 'Highlight' then
                            local highlight = descendant
                            
                            HighlightUtils.applyHighlightStyle(highlight)
                            
                            if DamageHighlightSystemConfig.SyncWithGUI then
                                if shared.RiseMode and GuiLibrary.GUICoreColorChanged then
                                    table.insert(DamageHighlightSystemConnections, 
                                        GuiLibrary.GUICoreColorChanged.Event:Connect(function()
                                            if DamageHighlightSystem.Enabled then
                                                HighlightUtils.updateGUISyncColor()
                                                HighlightUtils.applyHighlightStyle(highlight)
                                            end
                                        end)
                                    )
                                elseif VoidwareFunctions and VoidwareFunctions.Controllers then
                                    table.insert(DamageHighlightSystemConnections,
                                        VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h, s, v)
                                            if DamageHighlightSystem.Enabled then
                                                DamageHighlightSystemConfig.GUISyncColor = {Hue = h, Sat = s, Val = v}
                                                HighlightUtils.applyHighlightStyle(highlight)
                                            end
                                        end)
                                    )
                                end
                            end
                            
                           	spawn(function()
                                repeat task.wait() until not highlight.Parent or not DamageHighlightSystem.Enabled
                            end)
                        end
                    end)
                    table.insert(DamageHighlightSystemConnections, connection)
                end)
            else
                for _, conn in pairs(DamageHighlightSystemConnections) do
                    pcall(function() conn:Disconnect() end)
                end
                table.clear(DamageHighlightSystemConnections)
            end
        end
    })

    DamageHighlightSystem.Restart = function()
        if DamageHighlightSystem.Enabled then
            DamageHighlightSystem.ToggleButton(false)
            task.wait(0.1)
            DamageHighlightSystem.ToggleButton(true)
        end
    end

    DamageHighlightSystem.ColorControl = DamageHighlightSystem.CreateColorSlider({
        Name = 'Highlight Color',
        Function = function(hue, sat, val)
            DamageHighlightSystemConfig.FillColor = {Hue = hue, Sat = sat, Val = val}
            if not DamageHighlightSystemConfig.SyncWithGUI then
                DamageHighlightSystem.Restart()
            end
        end
    })

    DamageHighlightSystem.SyncToggle = DamageHighlightSystem.CreateToggle({
        Name = "Sync with GUI",
        Function = function(enabled)
            DamageHighlightSystemConfig.SyncWithGUI = enabled
            DamageHighlightSystem.ColorControl.Object.Visible = not enabled
            if enabled then
                HighlightUtils.updateGUISyncColor()
            end
            DamageHighlightSystem.Restart()
        end
    })

    DamageHighlightSystem.TransparencyControl = DamageHighlightSystem.CreateSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 10,
        Default = 4,
        Function = function(value)
            DamageHighlightSystemConfig.Transparency = value * 0.1
            DamageHighlightSystem.Restart()
        end
    })
end)

run(function() 
	local TPExploit = {}
	TPExploit = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = "EmptyGameTP",
		Function = function(calling)
			if calling then 
				TPExploit.ToggleButton()
				local TeleportService = game:GetService("TeleportService")
				local e2 = TeleportService:GetLocalPlayerTeleportData()
				game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer, e2)
			end
		end,
		WhitelistRequired = 1
	}) 
end)

local GuiLibrary = shared.GuiLibrary
shared.slowmode = 0
run(function()
    local HttpService = game:GetService("HttpService")
    local StaffDetectionSystem = {
        Enabled = false
    }
    local StaffDetectionSystemConfig = {
        GameMode = "Bedwars",
        CustomGroupEnabled = false,
        IgnoreOnline = false,
        AutoCheck = false,
        MemberLimit = 50,
        CustomGroupId = "",
        CustomRoles = {}
    }
    local StaffDetectionSystemStaffData = {
        Games = {
            Bedwars = {groupId = 5774246, roles = {79029254, 86172137, 43926962, 37929139, 87049509, 37929138}},
            PS99 = {groupId = 5060810, roles = {33738740, 33738765}}
        },
        Detected = {}
    }

    local DetectionUtils = {
        resetSlowmode = function() end,
        fetchUsersInRole = function() end,
        fetchUserPresence = function() end,
        fetchGroupRoles = function() end,
        getDetectionConfig = function() end,
        scanStaff = function() end
    }

    DetectionUtils = {
        resetSlowmode = function()
            task.spawn(function()
                while shared.slowmode > 0 do
                    shared.slowmode = shared.slowmode - 1
                    task.wait(1)
                end
                shared.slowmode = 0
            end)
        end,

        fetchUsersInRole = function(groupId, roleId, cursor)
            local url = string.format("https://groups.roblox.com/v1/groups/%d/roles/%d/users?limit=%d%s", groupId, roleId, StaffDetectionSystemConfig.MemberLimit, cursor and "&cursor=" .. cursor or "")
            local success, response = pcall(function()
                return request({Url = url, Method = "GET"})
            end)
            return success and HttpService:JSONDecode(response.Body) or {}
        end,

        fetchUserPresence = function(userIds)
            local success, response = pcall(function()
                return request({
                    Url = "https://presence.roblox.com/v1/presence/users",
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({userIds = userIds})
                })
            end)
            return success and HttpService:JSONDecode(response.Body) or {userPresences = {}}
        end,

        fetchGroupRoles = function(groupId)
            local success, response = pcall(function()
                return request({
                    Url = "https://groups.roblox.com/v1/groups/" .. groupId .. "/roles",
                    Method = "GET"
                })
            end)
            if success and response.StatusCode == 200 then
                local roles = {}
                for _, role in pairs(HttpService:JSONDecode(response.Body).roles) do
                    table.insert(roles, role.id)
                end
                return true, roles
            end
            return false, nil, "Failed to fetch roles: " .. (success and response.StatusCode or "Network error")
        end,

        getDetectionConfig = function()
            if StaffDetectionSystemConfig.CustomGroupEnabled then
                if not StaffDetectionSystemConfig.CustomGroupId or StaffDetectionSystemConfig.CustomGroupId == "" then
                    return false, nil, "Custom Group ID not specified", false, nil, "Custom"
                end
                if #StaffDetectionSystemConfig.CustomRoles == 0 then
                    return true, tonumber(StaffDetectionSystemConfig.CustomGroupId), nil, false, nil, "Custom roles not specified"
                end
                local success, roles, error = DetectionUtils.fetchGroupRoles(StaffDetectionSystemConfig.CustomGroupId)
                return true, tonumber(StaffDetectionSystemConfig.CustomGroupId), nil, success, roles, error, "Custom"
            else
                local gameData = StaffDetectionSystemStaffData.Games[StaffDetectionSystemConfig.GameMode]
                return true, gameData.groupId, nil, true, gameData.roles, nil, "Normal"
            end
        end,

        scanStaff = function(groupId, roleId)
            local users, userIds = {}, {}
            local cursor = nil
            repeat
                local data = DetectionUtils.fetchUsersInRole(groupId, roleId, cursor)
                for _, user in pairs(data.data or {}) do
                    table.insert(users, user)
                    table.insert(userIds, user.userId)
                end
                cursor = data.nextPageCursor
            until not cursor

            local presenceData = DetectionUtils.fetchUserPresence(userIds)
            for _, user in pairs(users) do
                for _, presence in pairs(presenceData.userPresences) do
                    if user.userId == presence.userId then
                        user.presenceType = presence.userPresenceType
                        user.lastLocation = presence.lastLocation
                        break
                    end
                end
            end
            return users
        end
    }

    local function processStaffCheck()
        if shared.slowmode > 0 and not StaffDetectionSystemConfig.AutoCheck then
            errorNotification("StaffDetector", "Slowmode active! Wait " .. shared.slowmode .. " seconds", shared.slowmode)
            return
        end

        shared.slowmode = 5
        DetectionUtils.resetSlowmode()
        InfoNotification("StaffDetector", "Checking staff presence...", 5)

        local groupSuccess, groupId, groupError, rolesSuccess, roles, rolesError, mode = DetectionUtils.getDetectionConfig()
        if not groupSuccess or not rolesSuccess then
            shared.slowmode = 0
            if groupError then errorNotification("StaffDetector", groupError, 5) end
            if rolesError then errorNotification("StaffDetector", rolesError, 5) end
            return
        end

        local detectedStaff, uniqueIds = {}, {}
        for _, roleId in pairs(roles) do
            for _, user in pairs(DetectionUtils.scanStaff(groupId, roleId)) do
                local status = ({
                    [0] = "Offline",
                    [1] = "Online",
                    [2] = "In Game",
                    [3] = "In Studio"
                })[user.presenceType or 0]

                if (status == "In Game" or (not StaffDetectionSystemConfig.IgnoreOnline and status == "Online")) and
                   not table.find(uniqueIds, user.userId) then
                    table.insert(uniqueIds, user.userId)
                    local userData = {UserID = tostring(user.userId), Username = user.username, Status = status}
                    if not table.find(detectedStaff, userData) then
                        table.insert(detectedStaff, userData)
                        errorNotification("StaffDetector", "@" .. userData.Username .. "(" .. userData.UserID .. ") is " .. status, 7)
                    end
                end
            end
        end
        InfoNotification("StaffDetector", #detectedStaff .. " staff members detected online/in-game!", 7)
    end

    StaffDetectionSystem = GuiLibrary.ObjectsThatCanBeSaved.VoidwareWindow.Api.CreateOptionsButton({
        Name = 'StaffFetcher - Roblox',
        Function = function(enabled)
            StaffDetectionSystem.Enabled = enabled
            if enabled then
                if StaffDetectionSystemConfig.AutoCheck then
                    task.spawn(function()
                        repeat
                            processStaffCheck()
                            task.wait(30)
                        until not StaffDetectionSystem.Enabled or not StaffDetectionSystemConfig.AutoCheck
                        StaffDetectionSystem["ToggleButton"](false)
                    end)
                else
                    processStaffCheck()
                    StaffDetectionSystem["ToggleButton"](false)
                end
            end
        end
    })

    local StaffDetectionSystemUI = {}

    local gameList = {}
    for game in pairs(StaffDetectionSystemStaffData.Games) do table.insert(gameList, game) end
    StaffDetectionSystemUI.GameSelector = StaffDetectionSystem.CreateDropdown({
        Name = "Game Mode",
        Function = function(value) StaffDetectionSystemConfig.GameMode = value end,
        List = gameList
    })

    StaffDetectionSystemUI.RolesList = StaffDetectionSystem.CreateTextList({
        Name = "Custom Roles",
        TempText = "Role ID (number)",
        Function = function(values) StaffDetectionSystemConfig.CustomRoles = values end
    })

    StaffDetectionSystemUI.GroupIdInput = StaffDetectionSystem.CreateTextBox({
        Name = "Custom Group ID",
        TempText = "Group ID (number)",
        Function = function(value) StaffDetectionSystemConfig.CustomGroupId = value end
    })

    StaffDetectionSystem.CreateToggle({
        Name = "Custom Group",
        Function = function(enabled)
            StaffDetectionSystemConfig.CustomGroupEnabled = enabled
            StaffDetectionSystemUI.GroupIdInput.Object.Visible = enabled
            StaffDetectionSystemUI.RolesList.Object.Visible = enabled
            StaffDetectionSystemUI.GameSelector.Object.Visible = not enabled
        end,
        HoverText = "Use a custom staff group",
        Default = false
    })

    StaffDetectionSystem.CreateToggle({
        Name = "Ignore Online Staff",
        Function = function(enabled) StaffDetectionSystemConfig.IgnoreOnline = enabled end,
        HoverText = "Only show in-game staff, ignoring online staff",
        Default = false
    })

    StaffDetectionSystem.CreateSlider({
        Name = "Member Limit",
        Min = 1,
        Max = 100,
        Function = function(value) StaffDetectionSystemConfig.MemberLimit = value end,
        Default = 50
    })

    StaffDetectionSystem.CreateToggle({
        Name = "Auto Check",
        Function = function(enabled)
            StaffDetectionSystemConfig.AutoCheck = enabled
            if enabled and shared.slowmode > 0 then
                errorNotification("StaffDetector", "Disable Auto Check to use manually during slowmode!", 5)
            end
        end,
        HoverText = "Automatically check every 30 seconds",
        Default = false
    })

    StaffDetectionSystemUI.GroupIdInput.Object.Visible = false
    StaffDetectionSystemUI.RolesList.Object.Visible = false
end)

task.spawn(function()
	repeat task.wait() until shared.vapewhitelist.loaded
	if shared.vapewhitelist:get(game:GetService("Players").LocalPlayer) > 0 then
		--[[run(function()
			local ItemSpawner = {Enabled = false}
			local Choice = {Value = "Chicken"}
			local CustomChoice = {Enabled = false}
			local ItemIds = {
				["Dagger"] = 1,
				["Scythe"] = 2,
				["Hammer"] = 3,
				["Gauntlet"] = 4,
				["Chicken"] = 7
			}
			local function spawnItem()
				local a
				if CustomChoice.Enabled then a = ItemIds[Choice.Value] else a = ItemIds["Chicken"] end
				local args = {
					[1] = {
						["forgeUpgrade"] = a
					}
				}
				game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("SetForgeSelectMechanic"):FireServer(unpack(args))
			end
			ItemSpawner = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
				Name = "1[OP] ChickenExploit",
				Function = function(callback)
					if callback then
						spawnItem()
						if CustomChoice.Enabled then
							warningNotification("ItemSpawner", "Spawned "..Choice.Value, 3)
						else
							warningNotification("ItemSpawner", "Spawned Chicken", 3)
						end
						ItemSpawner.ToggleButton(false)
					end
				end
			})
			GuiLibrary.ObjectsThatCanBeSaved["1[OP] ChickenExploitOptionsButton"].Object.ButtonText.TextSize = 15
			local real_list = {}
			for i,v in pairs(ItemIds) do table.insert(real_list, i) end
			Choice = ItemSpawner.CreateDropdown({
				Name = "ItemChoice",
				Function = function() end,
				List = real_list,
				Default = "Chicken"
			})
			Choice.Object.Visible = false
			CustomChoice = ItemSpawner.CreateToggle({
				Name = "CustomItem",
				Function = function(callback)
					if callback then
						Choice.Object.Visible = true
					else
						Choice.Object.Visible = false
					end
				end
			})
		end)--]]
		--[[run(function()
			local BeamExploit = {Enabled = false}
			BeamExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
				Name = "BeamExploit",
				Function = function(callback)
					if callback then
						task.spawn(function()
							repeat
								local lplr = game:GetService("Players").LocalPlayer
								local localPlayer = lplr
								local Players = game:GetService("Players")
								repeat task.wait() until lplr.Character:FindFirstChild("HumanoidRootPart")
								local nearestPlayer
								local minDistance = math.huge
								for _, player in ipairs(Players:GetPlayers()) do
									if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
										local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude
										if distance < minDistance then
											minDistance = distance
											nearestPlayer = player
										end
									end
								end
								local targetPosition = nearestPlayer and nearestPlayer.Character.HumanoidRootPart.Position or Vector3.new(999999, 999999, 999999)
								local Random = Random.new()
								local args = {
									[1] = {
										["laserIsOn"] = true,
										["targetBlockPos"] = targetPosition
									}
								}
								game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.LaserPickaxeStartSpinningFromClient:FireServer(unpack(args))
								task.wait(0.01)
							until (not BeamExploit.Enabled)
						end)
					end
				end
			})
		end)--]]
		--- credits for both go to private leaker
	end
end)

--[[local vapeInjected = true
GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
end)
local collectionService = game:GetService("CollectionService")
run(function()
    local ScytheExploit = {Enabled = false}
	local autobuy = false
	local firewallbypass = false
    ScytheExploit = GuiLibrary.ObjectsThatCanBeSaved.ExploitsWindow.Api.CreateOptionsButton({
        Name = "ScytheExploit",
        Function = function(callback)
            if callback then 
				local entityLibrary = shared.vapeentity
				local id = "1_item_shop"
				local bedwarsshopnpcs = {}
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not vapeInjected
					for i,v in pairs(collectionService:GetTagged("BedwarsItemShop")) do
						table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
					end
					for i,v in pairs(collectionService:GetTagged("TeamUpgradeShopkeeper")) do
						table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
					end
				end)
				local function nearNPC(range)
					local npc, npccheck, enchant, newid = nil, false, false, nil
					if entityLibrary.isAlive then
						local enchanttab = {}
						for i,v in pairs(collectionService:GetTagged("broken-enchant-table")) do
							table.insert(enchanttab, v)
						end
						for i,v in pairs(collectionService:GetTagged("enchant-table")) do
							table.insert(enchanttab, v)
						end
						for i,v in pairs(enchanttab) do
							if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
								if ((not v:GetAttribute("Team")) or v:GetAttribute("Team") == lplr:GetAttribute("Team")) then
									npc, npccheck, enchant = true, true, true
								end
							end
						end
						for i, v in pairs(bedwarsshopnpcs) do
							if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
								npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
								newid = v.TeamUpgradeNPC and v.Id or newid
							end
						end
					end
					return npc, not npccheck, enchant, newid
				end
                task.spawn(function()
					pcall(function()
						task.spawn(function()
							repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.AutoBuyOptionsButton
							if GuiLibrary.ObjectsThatCanBeSaved.AutoBuyOptionsButton.Api.Enabled then
								autobuy = true
								GuiLibrary.ObjectsThatCanBeSaved.AutoBuyOptionsButton.Api.ToggleButton(false)
								warningNotification("ScytheExploit", "Autobuy disabled to prevent it from overriding the scythe!", 3)
							end
						end)
						task.spawn(function()
							repeat task.wait() until GuiLibrary.ObjectsThatCanBeSaved.FirewallBypassOptionsButton
							if (not GuiLibrary.ObjectsThatCanBeSaved.FirewallBypassOptionsButton.Api.Enabled) then
								firewallbypass = true
								GuiLibrary.ObjectsThatCanBeSaved.FirewallBypassOptionsButton.Api.ToggleButton(false)
								warningNotification("ScytheExploit", "ScytheDisabler (FirewallBypass) has been auto enabled!", 3)
							end
						end)
					end)
					if (not getItemNear("scythe")) then
						warningNotification("ScytheExploit", "Waiting to purchase a scythe... (20 iron needed)!", 3)
					end
                    repeat
						task.wait(0.2)
						local found, npctype, enchant, newid = nearNPC(100)
						if found then
							id = newid
							if (not getItemNear("scythe")) then
								local args = {[1] = {["shopItem"] = {["lockAfterPurchase"] = true, ["itemType"] = "stone_scythe", ["price"] = 20, ["requireInInventoryToTierUp"] = true, ["nextTier"] = "iron_scythe", ["superiorItems"] = {[1] = "iron_scythe"}, ["currency"] = "iron", ["category"] = "Combat", ["ignoredByKit"] = {[1] = "barbarian", [2] = "dasher", [3] = "frost_hammer_kit", [4] = "tinker", [5] = "summoner", [6] = "ice_queen", [7] = "ember", [8] = "lumen", [9] = "summoner"}, ["disabledInQueue"] = {[1] = "tnt_wars", [2] = "bedwars_og_to4"}, ["spawnWithItems"] = {[1] = "wood_scythe"}, ["amount"] = 1}, ["shopId"] = tostring(id)}}
								game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.BedwarsPurchaseItem:InvokeServer(unpack(args))
							end
						end
                    until (not ScytheExploit.Enabled) or (getItemNear("scythe"))
                end)
            else
				task.spawn(function()
					pcall(function()
						if autobuy then
							if (not GuiLibrary.ObjectsThatCanBeSaved.AutoBuyOptionsButton.Api.Enabled) then
								autobuy = false
								GuiLibrary.ObjectsThatCanBeSaved.AutoBuyOptionsButton.Api.ToggleButton(false)
								warningNotification("ScytheExploit", "Autobuy re-enabled!", 3)
							end
						end
						if firewallbypass then
							if GuiLibrary.ObjectsThatCanBeSaved.FirewallBypassOptionsButton.Api.Enabled then
								firewallbypass = false
								GuiLibrary.ObjectsThatCanBeSaved.FirewallBypassOptionsButton.Api.ToggleButton(false)
								warningNotification("ScytheExploit", "ScytheDisabler (FirewallBypass) has been re-disabled!", 3)
							end
						end
					end)
				end)
			end
        end
    })
end)--]]

--[[task.spawn(function()
	repeat task.wait() until shared.vapewhitelist.loaded
	if shared.vapewhitelist:get(game:GetService("Players").LocalPlayer) < 1 then return end
	run(function()
		local KaidaInstaKill = {Enabled = false}
		local Range = {Value = 40}
		local MaxEntities = {Value = 1}
		KaidaInstaKill = GuiLibrary.ObjectsThatCanBeSaved.FunnyWindow.Api.CreateOptionsButton({
			Name = "KaidaInstaKill",
			Function = function(call) 
				if call then
					if store.queueType ~= "training_room" and store.equippedKit ~= "summoner" then warningNotification("KaidaInstakill", "Kaida kit is required!", 1.5); return KaidaInstaKill.ToggleButton(false); end
					local npcsortmethods = {
						Distance = function(a, b)
							local check1 = a.HumanoidRootPart
							local check2 = b.HumanoidRootPart
							if a:FindFirstChild("RootPart") then check1 = a.RootPart end
							if b:FindFirstChild("RootPart") then check2 = b.RootPart end
							return (check1.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (check2.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
						end
					}
					local lplr = game:GetService("Players").LocalPlayer
					local function sendRequest(entity)
						local targetPosition = entity.HumanoidRootPart.Position
						local direction = (targetPosition - lplr.Character:WaitForChild("HumanoidRootPart").Position).unit
						local args = {
							[1] = {
								["clientTime"] = tick(),
								["direction"] = direction,
								["position"] = targetPosition
							}
						}
						return game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SummonerClawAttackRequest:FireServer(unpack(args))
					end
					repeat task.wait();
						if entityLibrary.isAlive and store.matchState > 0 then
							local res = AllNearPosition(Range.Value, MaxEntities.Value, npcsortmethods["Distance"], nil, true)
							for i,v in pairs(res) do
								local req_res = sendRequest(v)
							end
						end
					until (not KaidaInstaKill.Enabled)
				end
			end
		})
		Range = KaidaInstaKill.CreateSlider({
			Name = "Aura Range",
			Min = 30,
			Max = 50,
			Function = function(val) end,
			Default = 50
		})
		MaxEntities = KaidaInstaKill.CreateSlider({
			Name = "Max Entities",
			Min = 10,
			Max = 15,
			Function = function(val) end,
			Default = 10,
			HoverText = "Max entities to attack \n at the same time"
		})
	end)
end)--]]

local ReportDetector_Cooldown = 0
run(function()
    local ReportDetector = {Enabled = false}
    local HttpService = game:GetService("HttpService")
    local ReportDetector_GUIObjects = {}
    local ReportDetector_Connections = {}

    local function fetchReports(username)
        if not username then return {Suc = false, Error = "Username not specified!"} end
        local url = 'https://detections.vapevoidware.xyz/reportdetector?user=' .. tostring(username)
        local res = request({Url = url, Method = "GET"})

        if res and res.StatusCode == 200 then
            return {Suc = true, Data = res.Body}
        else
            return {Suc = false, Error = "HTTP Error: " .. tostring(res.StatusCode) .. " | " .. tostring(res.Body), StatusCode = res.StatusCode, Body = res.Body}
        end
    end

    local function resolveData(data)
        if not data then return {Suc = false, Error = "No data to resolve"} end
        local suc, decodedData = pcall(function() return HttpService:JSONDecode(data) end)
        if not suc then return {Suc = false, Error = "Failed to decode JSON"} end

        local resolvedReports = {}
        for _, guildData in pairs(decodedData) do
            if guildData.guild_id and guildData.Reports then
                for reportID, report in pairs(guildData.Reports) do
                    table.insert(resolvedReports, {
                        Message = report.content or "No message",
                        AuthorData = {
                            UserID = report.author.id or "Unknown",
                            Username = report.author.username or "Unknown",
                            ReporterHashNumber = report.author.discriminator or "Unknown"
                        },
                        ChannelID = report.channel.id or "Unknown",
                        GuildID = guildData.guild_id
                    })
                end
            end
        end
        return {Suc = true, ResolvedReports = resolvedReports}
    end

    local function convertData(data)
        local convertedData = {}
        for i, v in ipairs(data) do
            table.insert(convertedData, {
                ReportNumber = tostring(i),
                TotalReports = tostring(#data),
                Notifications = {
                    {Title = "ReportInfo - Message/Sender", Message = "[Sender:" .. v.AuthorData.Username .. "#" .. v.AuthorData.ReporterHashNumber .. "] - [Message:" .. v.Message .. "]           ", Duration = 7},
                    {Title = "ReportInfo - ServerInfo", Message = "[ServerID:" .. v.GuildID .. "] - [ChannelID:" .. v.ChannelID .. "]           ", Duration = 7}
                }
            })
        end
        return convertedData
    end

    local function handleError(res)
        local ErrorHandling = {
            ["404"] = "Critical error in the API endpoint!",
            ["400"] = "No username specified! Contact erchodev#0 on discord.",
            ["500"] = "Critical server error! Try again later.",
            ["429"] = "You are being rate-limited. Please wait."
        }
        local message = ErrorHandling[tostring(res.StatusCode)] or "Unknown error! StatusCode: " .. tostring(res.StatusCode)
        errorNotification("ReportDetector_ErrorHandler ["..tostring(res.StatusCode).."]", message, 10)
    end

    local function getPlayers()
        local plrs = {}
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            table.insert(plrs, player.Name)
        end
        return plrs
    end

    local function createGUIElement(api, argsTbl)
        local name = argsTbl.GUI_Name
        local creationType = argsTbl.GUI_Args.Type
        local creationArgs = argsTbl.GUI_Args.Creation_Args

        ReportDetector_GUIObjects[name] = api[creationType](creationArgs)
    end

	local function getObject(name)
		return ReportDetector_GUIObjects[name] and ReportDetector_GUIObjects[name].Object
	end

    local Methods_Functions = {
        ["Self"] = function() getObject("ServerUsername").Visible = false; getObject("CustomUsername").Visible = false end,
        ["Server"] = function() getObject("ServerUsername").Visible = true; getObject("CustomUsername").Visible = false end,
        ["Global"] = function() getObject("ServerUsername").Visible = false; getObject("CustomUsername").Visible = true end,
    }

	local function getUsername()
		local CorresponderTable = {
			["Self"] = nil,
			["Server"] = "ServerUsername",
			["Global"] = "CustomUsername"
		}
		local val = ReportDetector_GUIObjects["Mode"].Value
		local function verifyVal(value) if value ~= nil and value ~= "" then return true, value else return false, value end end
		if val ~= "Self" then 
			local suc, res = verifyVal(ReportDetector_GUIObjects[CorresponderTable[val]].Value)
			if suc then return res else return nil, {Step = 1, ErrorInfo = "Invalid value!", Debug = {Type = val, Res = tostring(res)}} end
		else
			return game:GetService("Players").LocalPlayer.Name
		end
	end

	ReportDetector = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ReportDetector",
		Function = function(call)
			if call then
				ReportDetector.ToggleButton(false)
				local targetUsername, errorInfo = getUsername()
				if (not targetUsername) then return errorNotification("ReportDetector_ErrorHandler_V2", game:GetService("HttpService"):JSONEncode(errorInfo), 10) end
				warningNotification("ReportDetector", "Request sent to VW API for user: "..tostring(targetUsername).."!           ", 3)
				local res = fetchReports(targetUsername)
				if res.Suc then
					local resolvedData = resolveData(res.Data)
					if resolvedData.Suc then
						local convertedData = convertData(resolvedData.ResolvedReports)
                        local saveTable = {}
						for _, report in ipairs(convertedData) do
							for _, notification in ipairs(report.Notifications) do
                                saveTable["[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "]"] = saveTable["[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "]"] or {}
                                table.insert(saveTable["[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "]"], {
                                    Title = notification.Title,
                                    Message = notification.Message
                                })
								warningNotification("[Report #" .. report.ReportNumber .. "/" .. report.TotalReports .. "] " .. notification.Title, notification.Message, notification.Duration)
							end
						end
						if #convertedData < 1 then warningNotification("ReportDetector", "No reports found for " .. targetUsername .. "!", 10) end
                        writefile("ReportDetectorLog.json", game:GetService("HttpService"):JSONEncode(saveTable))
                        warningNotification("ReportDetector_LogSaver", "Successfully saved the report logs to ReportDetectorLog.json in your \n executor's game.Workspace folder!", 10)
					else
						errorNotification("ReportDetector", "Data sorting failed: " .. resolvedData.Error, 10)
					end
				else
					handleError(res)
					errorNotification("ReportDetector", "Failed to fetch reports: " .. res.Error, 10)
				end
			end
		end,
		HoverText = "Detects if anyone has reported you."
	})
	local GUI_Elements = {
		{GUI_Name = "Mode", GUI_Args = {Type = "CreateDropdown", Arg = {Value = "Self"}, Creation_Args = {Name = "Mode", List = {"Self", "Server", "Global"}, Function = function(val) Methods_Functions[val]() end}}},
		{GUI_Name = "ServerUsername", GUI_Args = {Type = "CreateDropdown", Arg = {Value = game:GetService("Players").LocalPlayer.Name}, Creation_Args = {Name = "Players", List = getPlayers(), Function = function() end}}},
		{GUI_Name = "CustomUsername", GUI_Args = {Type = "CreateTextBox", Arg = {Value = game:GetService("Players").LocalPlayer.Name}, Creation_Args = {Name = "Username", TempText = "Type here a username", Function = function() end}}}
	}

	for _, element in ipairs(GUI_Elements) do
		createGUIElement(ReportDetector, element)
	end
end)

run(function()
	local PlayerChanger = {Enabled = false}
	if GuiLibrary.ObjectsThatCanBeSaved["PlayerChangerOptionsButton"] then
		PlayerChanger = GuiLibrary.ObjectsThatCanBeSaved["PlayerChangerOptionsButton"]
		local API = PlayerChanger.Api
		local PlayerChanger_Functions = shared.PlayerChanger_Functions
		local PlayerName = {Value = "Nigger"}
		PlayerName = API.CreateTextBox({
			Name = "Player Name",
			TempText = "Type here a name",
			Function = function(val)
				if GuiLibrary.ObjectsThatCanBeSaved["PlayerChangerOptionsButton"].Api.Enabled then
					local targetUser = shared.PlayerChanger_GUI_Elements_PlayersDropdown_Value
					local plr = PlayerChanger_Functions.getPlayerFromUsername(targetUser)
					if plr then
						local char = PlayerChanger_Functions.getPlayerCharacter(plr)
						if char then
                            local displayName = char:WaitForChild("Head"):WaitForChild("Nametag"):WaitForChild("DisplayNameContainer"):WaitForChild("DisplayName")
                            if displayName.ClassName == "TextLabel" then
                                if not displayName.RichText then displayName.RichText = true end
                                displayName.Text = val
                            end
                            table.insert(vapeConnections, displayName:GetPropertyChangedSignal("Text"):Connect(function()
                                if displayName.Text ~= val and targetUser == shared.PlayerChanger_GUI_Elements_PlayersDropdown_Value then
                                    displayName.Text = val
                                end
                            end))
						else warn("Error fetching player CHARACTER! Player: "..tostring(targetUser).." Character Result: "..tostring(char)) end
					else warn("Error fetching player! Player: "..tostring(targetUser)) end
				end
			end
		})
	else warn("PlayerChangerOptionsButton NOT found!") end
end)

run(function()
    local DamageIndicatorSystem = {
        Enabled = false
    }
	local DamageIndicatorSystemConstants = {
		Messages = {
			"Pow!", "Pop!", "Hit!", "Smack!", "Bang!", "Boom!", "Whoop!",
			"Damage!", "-9e9!", "Whack!", "Crash!", "Slam!", "Zap!",
			"Snap!", "Thump!"
		},
		RainbowColors = {
			Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0),
			Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
			Color3.fromRGB(148, 0, 211)
		},
		RainbowCycleSpeed = 5,
		RainbowIndex = 1
	}
	local DamageIndicatorSystemConfig = {
		ColorMode = "Rainbow",
		RainbowStyle = "Gradient",
		TextMode = "Multiple",
		CustomColor = {Hue = 0, Sat = 0, Val = 0},
		CustomText = {},
		Font = "GothamBlack",
		ColorEnabled = false,
		TextEnabled = false,
		FontEnabled = false
	}
	local DamageIndicatorSystemConnections = {}

    local RunService = game:GetService("RunService")

    local IndicatorUtils = {
        getRandomText = function(list)
            return #list > 0 and list[math.random(1, #list)] or "VW on top!"
        end,

        applyColor = function(label)
            local config = DamageIndicatorSystemConfig
            if not config.ColorEnabled then return end

            if config.ColorMode == "Rainbow" then
                if config.RainbowStyle == "Gradient" then
                    label.TextColor3 = Color3.fromHSV(tick() % DamageIndicatorSystemConstants.RainbowCycleSpeed / DamageIndicatorSystemConstants.RainbowCycleSpeed, 1, 1)
                else
                    label.TextColor3 = DamageIndicatorSystemConstants.RainbowColors[DamageIndicatorSystemConstants.RainbowIndex]
                end
            elseif config.ColorMode == "Custom" then
                label.TextColor3 = Color3.fromHSV(config.CustomColor.Hue, config.CustomColor.Sat, config.CustomColor.Val)
            elseif config.ColorMode == "GUI Sync" then
                if shared.RiseMode and GuiLibrary.GUICoreColor then
                    label.TextColor3 = GuiLibrary.GUICoreColor
                else
                    local guiColor = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
                    label.TextColor3 = Color3.fromHSV(guiColor.Hue, guiColor.Sat, guiColor.Value)
                end
            else
                label.TextColor3 = Color3.fromRGB(127, 0, 255)
            end
        end,

        applyText = function(label)
            local config = DamageIndicatorSystemConfig
            if not config.TextEnabled then return end

            if config.TextMode == "Custom" then
                label.Text = IndicatorUtils.getRandomText(config.CustomText)
            elseif config.TextMode == "Multiple" then
                label.Text = DamageIndicatorSystemConstants.Messages[math.random(1, #DamageIndicatorSystemConstants.Messages)]
            else 
                label.Text = "Lunar Strike!"
            end
        end,

        applyFont = function(label)
            if DamageIndicatorSystemConfig.FontEnabled then
                label.Font = Enum.Font[DamageIndicatorSystemConfig.Font]
            end
        end
    }

    DamageIndicatorSystem = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = 'DamageIndicator',
        Function = function(enabled)
            DamageIndicatorSystem.Enabled = enabled
            if enabled then
                task.spawn(function()
                    local connection = game.Workspace.DescendantAdded:Connect(function(descendant)
                        if descendant.Name ~= 'DamageIndicatorPart' then return end
                        
                        local success, label = pcall(function()
                            return descendant:FindFirstChildWhichIsA('BillboardGui'):FindFirstChildWhichIsA('Frame'):FindFirstChildWhichIsA('TextLabel')
                        end)
                        
                        if success and label then
                            IndicatorUtils.applyColor(label)
                            IndicatorUtils.applyText(label)
                            IndicatorUtils.applyFont(label)

                            if DamageIndicatorSystemConfig.ColorMode == "Rainbow" and DamageIndicatorSystemConfig.RainbowStyle == "Paint" then
                                local stepConnection = RunService.Stepped:Connect(function()
                                    DamageIndicatorSystemConstants.RainbowIndex = (DamageIndicatorSystemConstants.RainbowIndex % #DamageIndicatorSystemConstants.RainbowColors) + 1
                                    IndicatorUtils.applyColor(label)
                                end)
                                table.insert(DamageIndicatorSystemConnections, stepConnection)
                            elseif DamageIndicatorSystemConfig.ColorMode == "GUI Sync" then
                                if shared.RiseMode and GuiLibrary.GUICoreColorChanged then
                                    table.insert(DamageIndicatorSystemConnections, GuiLibrary.GUICoreColorChanged.Event:Connect(function()
                                        if DamageIndicatorSystem.Enabled then
                                            IndicatorUtils.applyColor(label)
                                        end
                                    end))
                                elseif VoidwareFunctions and VoidwareFunctions.Controllers then
                                    table.insert(DamageIndicatorSystemConnections, VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h, s, v)
                                        if DamageIndicatorSystem.Enabled then
                                            IndicatorUtils.applyColor(label)
                                        end
                                    end))
                                end
                            end

                            spawn(function()
                                repeat task.wait() until not descendant.Parent or not DamageIndicatorSystem.Enabled
                                for _, conn in pairs(DamageIndicatorSystemConnections) do
                                    if conn.Connected then conn:Disconnect() end
                                end
                            end)
                        end
                    end)
                    table.insert(DamageIndicatorSystemConnections, connection)
                end)
            else
                for _, conn in pairs(DamageIndicatorSystemConnections) do
                    pcall(function() conn:Disconnect() end)
                end
                table.clear(DamageIndicatorSystemConnections)
            end
        end
    })

    DamageIndicatorSystem.CreateDropdown({
        Name = 'Color Mode',
        List = {'Rainbow', 'Custom', 'GUI Sync'},
        HoverText = 'Selects the coloring mode for damage indicators',
        Value = 'Rainbow',
        Function = function(value) DamageIndicatorSystemConfig.ColorMode = value end
    })

    DamageIndicatorSystem.CreateDropdown({
        Name = 'Rainbow Style',
        List = {'Gradient', 'Paint'},
        HoverText = 'Chooses the rainbow animation style',
        Value = 'Gradient',
        Function = function(value) DamageIndicatorSystemConfig.RainbowStyle = value end
    })

   	DamageIndicatorSystem.CreateDropdown({
        Name = 'Text Mode',
        List = {'Custom', 'Multiple', 'Lunar'},
        HoverText = 'Sets the text display mode for indicators',
        Value = 'Multiple',
        Function = function(value) DamageIndicatorSystemConfig.TextMode = value end
    })

    DamageIndicatorSystem.CreateToggle({
        Name = 'Enable Custom Color',
        Function = function(enabled)
			pcall(function()
				DamageIndicatorSystemConfig.ColorEnabled = enabled
				DamageIndicatorSystem.ColorSlider.Object.Visible = enabled
			end)
        end
    })

    local ColorSlider = DamageIndicatorSystem.CreateColorSlider({
        Name = 'Indicator Color',
        Function = function(hue, sat, val)
            DamageIndicatorSystemConfig.CustomColor = {Hue = hue, Sat = sat, Val = val}
        end
    })

   	DamageIndicatorSystem.CreateToggle({
        Name = 'Enable Custom Text',
        HoverText = 'Enables custom text messages for indicators',
        Function = function(enabled)
			pcall(function()
				DamageIndicatorSystemConfig.TextEnabled = enabled
				DamageIndicatorSystem.TextList.Object.Visible = enabled
			end)
        end
    })

   	local TextList = DamageIndicatorSystem.CreateTextList({
        Name = 'Custom Text',
        TempText = 'Enter indicator text',
        AddFunction = function(values) DamageIndicatorSystemConfig.CustomText = values end
    })

    DamageIndicatorSystem.CreateToggle({
        Name = 'Enable Custom Font',
        Function = function(enabled)
			pcall(function()
				DamageIndicatorSystemConfig.FontEnabled = enabled
				DamageIndicatorSystem.FontDropdown.Object.Visible = enabled
			end)
        end
    })

    local FontDropdown = DamageIndicatorSystem.CreateDropdown({
        Name = 'Font Style',
        List = GetEnumItems('Font'),
        Function = function(value) DamageIndicatorSystemConfig.Font = value end,
        Value = 'GothamBlack'
    })

    ColorSlider.Object.Visible = DamageIndicatorSystemConfig.ColorEnabled
    TextList.Object.Visible = DamageIndicatorSystemConfig.TextEnabled
    FontDropdown.Object.Visible = DamageIndicatorSystemConfig.FontEnabled
end)

--[[run(function() -- someday this will come back up :(
	local ProjectileAura = {}
	local ProjectileAuraSort = {Value = 'Distance'}
	local ProjectileAuraMobs = {}
	local ProjectileAuraRangeSlider = {Value = 50}
	local ProjectileAuraRange = {}
	local ProjectileAuraBlacklist = {ObjectList = {}}
	local ProjectileMobIgnore = {'spear'}
	local ProjectileAuraDelay = {Value = 0}
	local ProjectileAuraSwitchDelay = {Value = 0}
	local crackerdelay = tick()
	local specialprojectiles = {
		rainbow_bow = 'rainbow_arrow',
		orions_belt_bow = 'star',
		fireball = 'fireball',
		frosted_snowball = 'frosted_snowball',
		snowball = 'snowball',
		spear = 'spear',
		carrot_cannon = 'carrot_rocket',
		light_sword = 'sword_wave1',
		firecrackers = 'firecrackers'
	}
	local biggestTargets = {
		spirit_assassin = 1,
		hannah = 2,
		melody = 3,
		kaliyah = 4
	}
	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local sortfunctions = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b)
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b)
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute("PlayingAsKit")] or 0) > (kitpriolist[b.Player:GetAttribute("PlayingAsKit")] or 0)
		end
	}
	local httpService = game:GetService("HttpService")
	local function betterswitch(item)
		if tostring(item) == 'firecrackers' then 
			if crackerdelay > tick() then 
				return 
			else 
				crackerdelay = tick() + 3.5 
			end 
		end
		if tick() > store.switchdelay then 
			switchItem(item) 
		end
		local oldval = ProjectileAuraSwitchDelay.Value
		local valdelay = (tick() + ProjectileAuraSwitchDelay.Value)
		repeat task.wait() until (tick() > valdelay or ProjectileAuraSwitchDelay.Value ~= oldval)
	end
	local function getarrow()
		for i,v in next, store.localInventory.inventory.items do  
			if v.itemType:find('arrow') then 
				return v 
			end
		end
	end
	local function getammo(item)
		if (item.itemType:find('bow') or item.itemType:find('headhunter')) and specialprojectiles[item.itemType] == nil then 
			return getarrow() or {} 
		end
		if item.itemType:find('ninja_chakram') then 
			return getItem(item.itemType) 
		end
		if item.itemType == 'light_sword' then 
			return {tool = 'sword_wave1'} 
		end
		local special = specialprojectiles[item.itemType]
		for i,v in next, ProjectileAuraBlacklist.ObjectList do 
			if item.itemType:find(v:lower()) then 
				return {} 
			end 
		end 
		if special then 
			return getItem(special) or {} 
		end
		return {}
	end
	local function tweenInProgress() return false end
	ProjectileAura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots hostile projectiles\nwithout aiming.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					repeat 
						local range = (ProjectileAuraRange.Enabled and ProjectileAuraRangeSlider.Value or 9e9)
						local target = AllNearPosition(range, 1, sortfunctions[ProjectileAuraSort.Value])
						if target.RootPart and target.RootPart.Parent:FindFirstChildWhichIsA('ForceField') == nil then 
							for i,v in next, store.localInventory.inventory.items do 
								local ammo = getammo(v)
								if target.Human == nil and table.find(ProjectileMobIgnore, v.itemType) or tweenInProgress() then 
									continue 
								end 
								if store.matchState ~= 0 and store.equippedKit == 'dragon_sword' then 
									bedwars.Client:Get('DragonSwordFire'):SendToServer({target = target.RootPart.Parent}) 
								end
								if ammo.tool then 
									betterswitch(v.tool)
									bedwars.Client:Get(bedwars.ProjectileRemote):CallServerAsync(v.tool, tostring(ammo.tool), tostring(ammo.tool) == 'star' and 'star_projectile' or tostring(ammo.tool) == 'mage_spell_base' and target.RootPart.Position + Vector3.new(0, 3, 0) or tostring(ammo.tool), target.RootPart.Position + Vector3.new(0, 3, 0), target.RootPart.Position + Vector3.new(0, 3, 0), Vector3.new(0, -1, 0), httpService:GenerateGUID(), {drawDurationSeconds = 1}, game.Workspace:GetServerTimeNow(), target)
								end
							end
						end
						store.switchdelay += (ProjectileAuraDelay.Value * 0.2)
						if tonumber(math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))) > 1000 then 
							store.switchdelay += (store.switchdelay + 8)
						end
						task.wait(getItem('star') and 0 or killauraNearPlayer and 0.25 or ProjectileAuraDelay.Value + 0.15)
					until not ProjectileAura.Enabled
				end)
			end
		end
	})
	ProjectileAuraBlacklist = ProjectileAura.CreateTextList({
		Name = 'Blacklisted Projectiles',
		TempText = 'blacklisted items',
		AddFunction = function() end
	})
	ProjectileAuraSort = ProjectileAura.CreateDropdown({
		Name = 'Sort',
		List = dumptable(sortfunctions, 1),
		Function = function(method)
			pcall(function() ProjectileAuraRange.Object.Visible = (method == 'Distance') end) 
			pcall(function() ProjectileAuraRangeSlider.Object.Visible = (method == 'Distance' and ProjectileAuraRange.Enabled) end) 
			pcall(function() ProjectileAuraMobs.Object.Visible = (method ~= 'Kit') end)
		end
	})
	ProjectileAuraDelay = ProjectileAura.CreateSlider({
		Name = 'Target Delay',
		Min = 0,
		Max = 60,
		Function = function() 
			store.switchdelay = tick() 
		end
	})
	ProjectileAuraSwitchDelay = ProjectileAura.CreateSlider({
		Name = 'Switch Delay',
		Min = 0,
		Max = 60,
		Function = function() 
			store.switchdelay = tick() 
		end
	})
	ProjectileAuraRange = ProjectileAura.CreateToggle({
		Name = 'Range Check',
		Function = function(calling) 
			pcall(function() ProjectileAuraRangeSlider.Object.Visible = calling end)
		end 
	}) 
	ProjectileAuraRangeSlider = ProjectileAura.CreateSlider({
		Name = 'Range',
		Min = 5,
		Max = 80,
		Default = 75,
		Function = function() end
	})
	ProjectileAuraMobs = ProjectileAura.CreateToggle({
		Name = 'NPC',
		HoverText = 'Targets NPCs too.',
		Function = function() end 
	})
	ProjectileAuraRange.Object.Visible = false
	ProjectileAuraRangeSlider.Object.Visible = false
	ProjectileAuraMobs.Object.Visible = false
end)--]]

run(function()
	local ItemSpawner = {Enabled = false}
	local spawnedItems = {}
	local chattedConnection
	local function getInv(plr) return plr.Character and plr.Character:FindFirstChild("InventoryFolder") and plr.Character:FindFirstChild("InventoryFolder").Value end
	local ArmorIncluded = {Enabled = false}
	local ProjectilesIncluded = {Enabled = false}
	local ItemsIncluded = {Enabled = false}
	local StrictMatch = {Enabled = false}
	local function getRepItems()
		local tbl = {"Armor", "Projectiles"}
		local a = ItemsIncluded.Enabled and game:GetService("ReplicatedStorage"):FindFirstChild("Items") and game:GetService("ReplicatedStorage"):FindFirstChild("Items"):GetChildren() or {}
		local b = ArmorIncluded.Enabled and game:GetService("ReplicatedStorage"):FindFirstChild("Assets") and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[1]) and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[1]):GetChildren() or {}
		local c = ProjectilesIncluded.Enabled and game:GetService("ReplicatedStorage"):FindFirstChild("Assets") and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[2]) and game:GetService("ReplicatedStorage"):FindFirstChild("Assets"):FindFirstChild(tbl[2]):GetChildren() or {}
		
		local fullTbl = {}
		local d = {a,b,c}
		for i,v in pairs(d) do for i2,v2 in pairs(v) do table.insert(fullTbl, v2) end end
		return fullTbl
	end
	local inv, repItems
	local function getRepItem(name)
		repItems = getRepItems()
		for i,v in pairs(repItems) do if v.Name and ((StrictMatch.Enabled and v.Name == name) or ((not StrictMatch.Enabled) and string.find(v.Name, name))) then return v end end
		return nil
	end
	local function getSpawnedItem(name)
		for i,v in pairs(spawnedItems) do if v.Name and ((StrictMatch.Enabled and v.Name == name) or ((not StrictMatch.Enabled) and string.find(v.Name, name))) then return v end end
		return nil
	end
	ItemSpawner = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ItemSpawner (CS)",
		Function = function(call)
			if call then
				task.spawn(function() repeat task.wait(0.1); inv = getInv(game:GetService("Players").LocalPlayer) until inv end)
				task.spawn(function() repeat task.wait(0.1); repItems = getRepItems() until repItems end)
				chattedConnection = game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
					local parts = string.split(msg, " ")
					if parts[1] == "/e" then
						if parts[2] == "spawn" then
							inv, repItems = getInv(game:GetService("Players").LocalPlayer), getRepItems()
							if parts[3] then
								local item = getRepItem(parts[3])
								if item then
									local amount, newItem = tonumber(parts[4]) or 1, item:Clone()
									newItem.Parent = inv
									pcall(function() newItem:SetAttribute("Amount", amount) end)
									pcall(function() newItem:SetAttribute("CustomSpawned", true) end)
									pcall(function() bedwars.StoreController:updateLocalInventory() end)
									table.insert(spawnedItems, newItem)
								else errorNotification("ItemSpawner", tostring(parts[3]).." is not a valid item name!", 3) end
							end
						elseif parts[2] == "despawn" then
							inv, repItems = getInv(game:GetService("Players").LocalPlayer), getRepItems()
							if parts[3] then
								local item = getSpawnedItem(parts[3])
								if item then 
									table.remove(spawnedItems, table.find(spawnedItems, item))
									pcall(function() item:Destroy() end)
									pcall(function() bedwars.StoreController:updateLocalInventory() end)
								end
							else errorNotification("ItemSpawner", tostring(parts[3]).." is not a valid item name!", 3) end
						end
					end
				end)
			else
				pcall(function() chattedConnection:Disconnect() end)
				pcall(function() chattedConnection:Disconnect() end)
				for i,v in pairs(spawnedItems) do pcall(function() v:Destroy() end) end
			end
		end
	})
	ItemSpawner.Restart = function() if ItemSpawner.Enabled then ItemSpawner.ToggleButton(false); ItemSpawner.ToggleButton(false) end end
	StrictMatch = ItemSpawner.CreateToggle({ Name = "StrictMatch", Function = ItemSpawner.Restart, Default = true})
	ItemsIncluded = ItemSpawner.CreateToggle({Name = "ItemsIncluded", Function = ItemSpawner.Restart, Default = true})
	ProjectilesIncluded = ItemSpawner.CreateToggle({Name = "ProjectilesIncluded", Function = ItemSpawner.Restart, Default = true})
	ArmorIncluded = ItemSpawner.CreateToggle({Name = "ArmorIncluded", Function = ItemSpawner.Restart, Default = true})
end)

run(function()
    local WeatherSystem = {
        Enabled = false
    }
	local WeatherSystemParticleObjects = {}
	local WeatherSystemConfig = {
		WeatherType = "Snow",
		Spread = 35,
		Rate = 28,
		Height = 100,
		WindEnabled = true,
		Color = Color3.fromRGB(255, 255, 255)
	}

    local WeatherUtils = {
        createSnowEmitter = function(parent, withWind)
            local emitter = Instance.new("ParticleEmitter")
            emitter.RotSpeed = NumberRange.new(withWind and 100 or 300)
            emitter.VelocitySpread = WeatherSystemConfig.Spread
            emitter.Rate = WeatherSystemConfig.Rate
            emitter.Texture = "rbxassetid://8158344433"
            emitter.Rotation = NumberRange.new(110)
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.169399, 0),
                NumberSequenceKeypoint.new(0.23366, 0.628415, 0.371585),
                NumberSequenceKeypoint.new(0.562091, 0.387978, 0.277139),
                NumberSequenceKeypoint.new(0.905773, 0.519126, 0),
                NumberSequenceKeypoint.new(1, 1, 0)
            })
            emitter.Lifetime = NumberRange.new(8, 14)
            emitter.Speed = NumberRange.new(8, 18)
            emitter.EmissionDirection = Enum.NormalId.Bottom
            emitter.SpreadAngle = Vector2.new(35, 35)
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0, 0),
                NumberSequenceKeypoint.new(0.0397603, 1.31148, 0.327869),
                NumberSequenceKeypoint.new(0.755447, 0.983607, 0.440386),
                NumberSequenceKeypoint.new(1, 0, 0)
            })
            emitter.Color = ColorSequence.new(WeatherSystemConfig.Color)
            if withWind then
                emitter.Acceleration = Vector3.new(0, 0, 1)
            end
            emitter.Parent = parent
            return emitter
        end,

        updateEmitter = function(emitter)
            emitter.VelocitySpread = WeatherSystemConfig.Spread
            emitter.Rate = WeatherSystemConfig.Rate
            emitter.Color = ColorSequence.new(WeatherSystemConfig.Color)
        end,

        removeWeatherEffects = function()
            for _, obj in pairs(WeatherSystemParticleObjects) do
                if obj and obj.Parent then
                    obj:Destroy()
                end
            end
            table.clear(WeatherSystemParticleObjects)
        end
    }

    WeatherSystem = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = 'WeatherMods',
        HoverText = 'Customizes in-game weather effects',
        Function = function(enabled)
            WeatherSystem.Enabled = enabled
            if enabled then
                task.spawn(function()
                    local snowBase = Instance.new("Part")
                    snowBase.Size = Vector3.new(240, 0.5, 240)
                    snowBase.Name = "WeatherEffectBase"
                    snowBase.Transparency = 1
                    snowBase.CanCollide = false
                    snowBase.Anchored = true
                    snowBase.Parent = game.Workspace
                    table.insert(WeatherSystemParticleObjects, snowBase)

                    local snowEmitter = WeatherUtils.createSnowEmitter(snowBase, false)
                    local windEmitter = WeatherUtils.createSnowEmitter(snowBase, true)
                    table.insert(WeatherSystemParticleObjects, snowEmitter)
                    table.insert(WeatherSystemParticleObjects, windEmitter)

                    while WeatherSystem.Enabled and shared.VapeExecuted and entityLibrary.isAlive do
                        snowBase.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, WeatherSystemConfig.Height, 0)
                        WeatherUtils.updateEmitter(snowEmitter)
                        WeatherUtils.updateEmitter(windEmitter)
                        task.wait(0.1)
                    end

                    WeatherUtils.removeWeatherEffects()
                end)
            else
                WeatherUtils.removeWeatherEffects()
            end
        end
    })

    WeatherSystem.CreateSlider({
        Name = "Spread",
        Min = 1,
        Max = 100,
        Function = function(value) WeatherSystemConfig.Spread = value end,
        Default = 35,
        HoverText = "Controls the spread of weather particles"
    })

    WeatherSystem.CreateSlider({
        Name = "Rate",
        Min = 1,
        Max = 100,
        Function = function(value) WeatherSystemConfig.Rate = value end,
        Default = 28,
        HoverText = "Sets the emission rate of particles"
    })

   	WeatherSystem.CreateSlider({
        Name = "Height",
        Min = 1,
        Max = 200,
        Function = function(value) WeatherSystemConfig.Height = value end,
        Default = 100,
        HoverText = "Adjusts the height of the weather effect"
    })

   	WeatherSystem.CreateToggle({
        Name = "Wind Effect",
        Function = function(enabled) WeatherSystemConfig.WindEnabled = enabled end,
        Default = true,
        HoverText = "Enables wind-driven particle movement"
    })

	WeatherSystem.CreateColorSlider({
        Name = "Particle Color",
        Function = function(hue, sat, val)
            WeatherSystemConfig.Color = Color3.fromHSV(hue, sat, val)
        end,
        Default = {Hue = 0, Sat = 0, Val = 1},
        HoverText = "Customizes the color of weather particles"
    })
end)

run(function()
    local AutoUpgradeSystem = {
        Enabled = false
    }
	local AutoUpgradeSystemConnections = {}
	local AutoUpgradeSystemNPCs = {}
	local AutoUpgradeSystemConfig = {
		Range = 20,
		PreferredUpgrade = "Damage",
		CheckGui = false
	}
	local AutoUpgradeSystemUpgrades = {
		Armor = {ID = "ARMOR", Costs = {4, 8, 20}, Level = 0},
		Damage = {ID = "DAMAGE", Costs = {5, 10, 18}, Level = 0},
		DiamondGen = {ID = "DIAMOND_GENERATOR", Costs = {4, 8, 12}, Level = 0},
		TeamGen = {ID = "TEAM_GENERATOR", Costs = {4, 8, 16}, Level = 0}
	}

    local Players = game:GetService("Players")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local UpgradeUtils = {
        getDiamondCount = function()
            local inv = store.localInventory.inventory
            if not inv.items or type(inv.items) ~= "table" then return 0 end
            
            for _, item in pairs(inv.items) do
                if item.itemType == "diamond" and item.amount then
                    return item.amount ~= "inf" and tonumber(item.amount) or 9999999999999
                end
            end
            return 0
        end,

        purchaseUpgrade = function(upgradeKey)
            local upgrade = AutoUpgradeSystemUpgrades[upgradeKey]
            if not upgrade then
                warn("[AutoUpgrade] Invalid upgrade key:", upgradeKey)
                return false
            end

            local path = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("RequestPurchaseTeamUpgrade")
            
            local success = path:InvokeServer(upgrade.ID)
            if success then
                upgrade.Level = upgrade.Level + 1
                return true
            end

            local diamonds = UpgradeUtils.getDiamondCount()
            local nextLevel = upgrade.Level + 1
            if nextLevel <= 3 and diamonds >= upgrade.Costs[nextLevel] then
                local retrySuccess = path:InvokeServer(upgrade.ID)
                if retrySuccess then
                    upgrade.Level = upgrade.Level + 1
                    return true
                else
                    warn("[AutoUpgrade] Forced upgrade attempt failed:", upgradeKey, "Diamonds:", diamonds)
                    upgrade.Level = upgrade.Level + 1 
                    return false
                end
            end
            return false
        end,

        scanTeamUpgradeApp = function(app)
            if not app:IsA("ScreenGui") or app.Name ~= "TeamUpgradeApp" then return end

            local function findChild(parent, name, class)
                for _, child in pairs(parent:GetChildren()) do
                    if child.Name == name and child.ClassName == class then return child end
                end
                return nil
            end

            local function updateUpgradeLevel(card, upgradeKey)
                local content = findChild(card, "Content", "Frame")
                if not content then return end
                
                local purchaseSection = findChild(content, "PurchaseSection", "Frame")
                if not purchaseSection then
                    AutoUpgradeSystemUpgrades[upgradeKey].Level = 3
                    return
                end
                
                local costInfo = findChild(purchaseSection, "Cost Info", "Frame")
                if not costInfo then return end
                
                local costLabel = findChild(costInfo, "2", "TextLabel")
                if costLabel and costLabel.Text then
                    local cost = tonumber(costLabel.Text)
                    for level, upgradeCost in pairs(AutoUpgradeSystemUpgrades[upgradeKey].Costs) do
                        if upgradeCost == cost then
                            AutoUpgradeSystemUpgrades[upgradeKey].Level = level - 1
                            return
                        end
                    end
                end
            end

            local frame2 = findChild(app, "2", "Frame")
            if frame2 then
                local container = findChild(frame2, "TeamUpgradeAppContainer", "ImageButton")
                if container then
                    local wrapper = findChild(container, "UpgradesWrapper", "Frame")
                    if wrapper then
                        updateUpgradeLevel(findChild(wrapper, "ARMOR_Card", "Frame"), "Armor")
                        updateUpgradeLevel(findChild(wrapper, "DAMAGE_Card", "Frame"), "Damage")
                        updateUpgradeLevel(findChild(wrapper, "DIAMOND_GENERATOR_Card", "Frame"), "DiamondGen")
                        updateUpgradeLevel(findChild(wrapper, "TEAM_GENERATOR_Card", "Frame"), "TeamGen")
                    end
                end
            end
        end,

        isNearNPC = function(range)
            if not entityLibrary.isAlive then return false, false end
            
            local position = entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position
            for _, npc in pairs(AutoUpgradeSystemNPCs) do
                if (position - npc.Position).Magnitude <= range then
                    return true, not npc.TeamUpgradeNPC
                end
            end
            return false, false
        end
    }

    local localPlayer = Players.LocalPlayer
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    
    table.insert(AutoUpgradeSystemConnections, playerGui.ChildAdded:Connect(UpgradeUtils.scanTeamUpgradeApp))
    GuiLibrary.SelfDestructEvent.Event:Connect(function()
        for _, conn in pairs(AutoUpgradeSystemConnections) do
            pcall(function() conn:Disconnect() end)
        end
    end)
    for _, app in pairs(playerGui:GetChildren()) do
        UpgradeUtils.scanTeamUpgradeApp(app)
    end

    task.spawn(function()
        repeat task.wait() until store.matchState ~= 0 or not shared.VapeExecuted
        for _, npc in pairs(CollectionService:GetTagged("TeamUpgradeShopkeeper")) do
            table.insert(AutoUpgradeSystemNPCs, {Position = npc.Position, TeamUpgradeNPC = false, Id = npc.Name})
        end
    end)

    AutoUpgradeSystem = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "AutoBuyDiamondUpgrades",
        Function = function(enabled)
            AutoUpgradeSystem.Enabled = enabled
            if enabled then
                task.spawn(function()
                    while AutoUpgradeSystem.Enabled do
                        local near, isTeamUpgrade = UpgradeUtils.isNearNPC(AutoUpgradeSystemConfig.Range)
                        if near and (not AutoUpgradeSystemConfig.CheckGui or bedwars.AppController:isAppOpen("TeamUpgradeApp")) then
                            local preferred = AutoUpgradeSystemConfig.PreferredUpgrade
                            if AutoUpgradeSystemUpgrades[preferred].Level < 3 then
                                local nextLevel = AutoUpgradeSystemUpgrades[preferred].Level + 1
                                if UpgradeUtils.getDiamondCount() >= AutoUpgradeSystemUpgrades[preferred].Costs[nextLevel] then
                                    UpgradeUtils.purchaseUpgrade(preferred)
                                end
                            end

                            for key, upgrade in pairs(AutoUpgradeSystemUpgrades) do
                                if upgrade.Level < 3 then
                                    local nextLevel = upgrade.Level + 1
                                    if UpgradeUtils.getDiamondCount() >= upgrade.Costs[nextLevel] then
                                        UpgradeUtils.purchaseUpgrade(key)
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end,
        HoverText = "Automatically purchases team upgrades with diamonds"
    })

    AutoUpgradeSystem.Restart = function()
        if AutoUpgradeSystem.Enabled then
            AutoUpgradeSystem.ToggleButton(false)
            task.wait(0.1)
            AutoUpgradeSystem.ToggleButton(true)
        end
    end

    AutoUpgradeSystem.RangeSlider = AutoUpgradeSystem.CreateSlider({
        Name = "Detection Range",
        Function = function(value) AutoUpgradeSystemConfig.Range = value end,
        Min = 1,
        Max = 20,
        Default = 20,
        HoverText = "Range to detect nearby upgrade NPCs"
    })

    local upgradeOptions = {}
    for key in pairs(AutoUpgradeSystemUpgrades) do table.insert(upgradeOptions, key) end
    AutoUpgradeSystem.UpgradeDropdown = AutoUpgradeSystem.CreateDropdown({
        Name = "Priority Upgrade",
        Function = function(value)
            AutoUpgradeSystemConfig.PreferredUpgrade = value
            AutoUpgradeSystem.Restart()
        end,
        List = upgradeOptions,
        Default = "Damage",
        HoverText = "Preferred upgrade to prioritize"
    })

    AutoUpgradeSystem.GuiToggle = AutoUpgradeSystem.CreateToggle({
        Name = "Require GUI Open",
        Function = function(enabled)
            AutoUpgradeSystemConfig.CheckGui = enabled
            AutoUpgradeSystem.Restart()
        end,
        HoverText = "Only buy when Team Upgrade GUI is open"
    })
end)

local isAlive = function(plr, healthblacklist)
	plr = plr or lplr
	local alive = false 
	if plr.Character and plr.Character.PrimaryPart and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then 
		alive = true
	end
	if not healthblacklist and alive and plr.Character.Humanoid.Health and plr.Character.Humanoid.Health <= 0 then 
		alive = false
	end
	return alive
end
local function fetchTeamMembers()
	local plrs = {}
	for i,v in pairs(game:GetService("Players"):GetPlayers()) do if v.Team == lplr.Team then table.insert(plrs, v) end end
	return plrs
end
local function isEveryoneDead()
	if #fetchTeamMembers() > 0 then
		for i,v in pairs(fetchTeamMembers()) do
			local plr = playersService:FindFirstChild(v.name)
			if plr and isAlive(plr, true) then
				return false
			end
		end
		return true
	else
		return true
	end
end
--[[run(function()
	GuiLibrary.RemoveObject("AutoLeaveOptionsButton")

	local playersService = game:GetService("Players")
	local lplr = playersService.LocalPlayer

	local leaveAttempted = false

	local AutoQueue = {Enabled = false, Connections = {}}
	local AutoQueue_GUI = {
		AutoPlayAgain = {Enabled = false},
		AutoPlayRandom = {Enabled = false},
		AutoPlayDelay = {Value = 1}
	}
	local queueFunction = function()
		if (not AutoQueue_GUI.AutoPlayAgain.Enabled) then return game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("TeleportToLobby"):FireServer() end
		local listofmodes = {}
		for i,v in pairs(bedwars.QueueMeta) do if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end end 
		bedwars.QueueController:joinQueue(AutoQueue_GUI.AutoPlayRandom.Enabled and listofmodes[math.random(1, #listofmodes)] or store.queueType)
	end
	AutoQueue = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoQueue",
		Function = function(call)
			table.insert(AutoQueue.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
				if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
					leaveAttempted = true
					if isEveryoneDead() and store.matchState ~= 2 then
						task.wait(1 + (AutoLeaveDelay.Value / 10))
						queueFunction()
					end
				end
			end))
			table.insert(AutoQueue.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
				task.wait(AutoLeaveDelay.Value / 10)
				if not AutoQueue.Enabled then return end
				if leaveAttempted then return end
				leaveAttempted = true
				queueFunction()
			end))
			if store.matchState == 2 or isEveryoneDead() then queueFunction() end
		end
	})
	AutoQueue.Restart = function() if AutoQueue.Enabled then AutoQueue.ToggleButton(false); AutoQueue.ToggleButton(false) end end
	AutoQueue_GUI.AutoPlayAgain = AutoQueue.CreateToggle({
		Name = "AutoPlayAgain",
		Function = AutoQueue.Restart,
		Default = true,
		HoverText = "Automatically queues a new game."
	})
	AutoQueue_GUI.AutoPlayRandom = AutoQueue.CreateToggle({
		Name = "AutoPlayRandom",
		Function = AutoQueue.Restart,
		Default = false,
		HoverText = "Chooses a random mode"
	})
	AutoQueue_GUI.AutoPlayDelay = AutoQueue.CreateSlider({
		Name = "AutoPlayDelay",
		Function = function() end,
		Default = 0,
		Min = 0,
		Max = 50
	})
end)--]]

run(function()
    local anim
	local asset
	local lastPosition
    local NightmareEmote = {Enabled = false}
	NightmareEmote = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "NightmareEmote",
		Function = function(call)
			if call then
				local l__GameQueryUtil__8
				if (not shared.CheatEngineMode) then 
					l__GameQueryUtil__8 = require(game:GetService("ReplicatedStorage")['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil 
				else
					local backup = {}; function backup:setQueryIgnored(part, index)
						if index == nil then index = true end
						part:SetAttribute("gamecore_GameQueryIgnore", index)
					end; l__GameQueryUtil__8 = backup;
				end
				local l__TweenService__9 = game:GetService("TweenService")
				local player = game:GetService("Players").LocalPlayer
				local p6 = player.Character
				
				if not p6 then NightmareEmote.ToggleButton(false) return end
				
				local v10 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Effects"):WaitForChild("NightmareEmote"):Clone();
				asset = v10
				v10.Parent = game.Workspace
				lastPosition = p6.PrimaryPart and p6.PrimaryPart.Position or Vector3.new()
				
				task.spawn(function()
					while asset ~= nil do
						local currentPosition = p6.PrimaryPart and p6.PrimaryPart.Position
						if currentPosition and (currentPosition - lastPosition).Magnitude > 0.1 then
							asset:Destroy()
							asset = nil
							NightmareEmote.ToggleButton(false)
							break
						end
						lastPosition = currentPosition
						v10:SetPrimaryPartCFrame(p6.LowerTorso.CFrame + Vector3.new(0, -2, 0));
						task.wait()
					end
				end)
				
				local v11 = v10:GetDescendants();
				local function v12(p8)
					if p8:IsA("BasePart") then
						l__GameQueryUtil__8:setQueryIgnored(p8, true);
						p8.CanCollide = false;
						p8.Anchored = true;
					end;
				end;
				for v13, v14 in ipairs(v11) do
					v12(v14, v13 - 1, v11);
				end;
				local l__Outer__15 = v10:FindFirstChild("Outer");
				if l__Outer__15 then
					l__TweenService__9:Create(l__Outer__15, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Outer__15.Orientation + Vector3.new(0, 360, 0)
					}):Play();
				end;
				local l__Middle__16 = v10:FindFirstChild("Middle");
				if l__Middle__16 then
					l__TweenService__9:Create(l__Middle__16, TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
						Orientation = l__Middle__16.Orientation + Vector3.new(0, -360, 0)
					}):Play();
				end;
                anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://9191822700"
				anim = p6.Humanoid:LoadAnimation(anim)
				anim:Play()
			else 
                if anim then 
					anim:Stop()
					anim = nil
				end
				if asset then
					asset:Destroy() 
					asset = nil
				end
			end
		end
	})
end)

--[[if not shared.CheatEngineMode then
	run(function()
		local AntiLagback = {Enabled = false}
		local control_module = require(lplr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")).controls
		local old = control_module.moveFunction
		local clone
		local connection
		local function clone_lplr_char()
			if not (lplr.Character ~= nil and lplr.Character.PrimaryPart ~= nil) then return nil end
			lplr.Character.Archivable = true
		
			local clone = lplr.Character:Clone()
		
			clone.Parent = game.Workspace
			clone.Name = "Clone"
		
			clone.PrimaryPart.CFrame = lplr.Character.PrimaryPart.CFrame
		
			gameCamera.CameraSubject = clone.Humanoid	
		
			task.spawn(function()
				for i, v in next, clone:FindFirstChild("Head"):GetDescendants() do
					v:Destroy()
				end
				for i, v in next, clone:GetChildren() do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						v.Transparency = 1
					end
					if v:IsA("Accessory") then
						v:FindFirstChild("Handle").Transparency = 1
					end
				end
			end)
			return clone
		end
		local function bypass()
			clone = clone_lplr_char()
			if not entitylib.isAlive then return AntiLagback:Toggle() end
			if not clone then return AntiLagback:Toggle() end
			control_module.moveFunction = function(self, vec, ...)
				local RaycastParameters = RaycastParams.new()
	
				RaycastParameters.FilterType = Enum.RaycastFilterType.Include
				RaycastParameters.FilterDescendantsInstances = {CollectionService:GetTagged("block")}
	
				local LookVector = Vector3.new(gameCamera.CFrame.LookVector.X, 0, gameCamera.CFrame.LookVector.Z).Unit
	
				if clone.PrimaryPart then
					local Raycast = game.Workspace:Raycast((clone.PrimaryPart.Position + LookVector), Vector3.new(0, -1000, 0), RaycastParameters)
					local Raycast2 = game.Workspace:Raycast(((clone.PrimaryPart.Position - Vector3.new(0, 15, 0)) + (LookVector * 3)), Vector3.new(0, -1000, 0), RaycastParameters)
	
					if Raycast or Raycast2 then
						clone.PrimaryPart.CFrame = CFrame.new(clone.PrimaryPart.Position + (LookVector / (GetSpeed())))
						vec = LookVector
					end
	
					if (not clone) and entitylib.isAlive then
						control_module.moveFunction = OldMoveFunction
						gameCamera.CameraSubject = lplr.Character.Humanoid
					end
				end
	
				return old(self, vec, ...)
			end
		end
		local function safe_revert()
			control_module.moveFunction = old
			if entitylib.isAlive then
				gameCamera.CameraSubject = lplr.Character:WaitForChild("Humanoid")
			end
			pcall(function()
				clone:Destroy()
			end)
		end
		AntiLagback = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
			Name = "AntiLagback",
			Function = function(call)
				if call then
					connection = lplr:GetAttributeChangedSignal("LastTeleported"):Connect(function()
						if entitylib.isAlive and store.matchState ~= 0 and not lplr.Character:FindFirstChildWhichIsA("ForceField") and (not vape.Modules.BedTP.Enabled) and (not vape.Modules.PlayerTP.Enabled) then					
							bypass()
							task.wait(4.5)
							safe_revert()
						end 
					end)
				else
					pcall(function() connection:Disconnect() end)
					control_module.moveFunction = old
					if entitylib.isAlive then
						gameCamera.CameraSubject = lplr.Character:WaitForChild("Humanoid")
					end
					pcall(function() clone:Destroy() end)
				end
			end
		})
	end)
end--]]

run(function()
	local Maid = {}
	Maid.__index = Maid
	
	function Maid.new()
		return setmetatable({ Tasks = {} }, Maid)
	end
	
	function Maid:Add(task)
		if typeof(task) == "RBXScriptConnection" or
		   (typeof(task) == "Instance" and task.Destroy) or
		   typeof(task) == "function" or
		   (typeof(task) == "table" and (task.Destroy or task.Disconnect)) then
			table.insert(self.Tasks, task)
		else
			warn("[Maid] Invalid task type: " .. typeof(task))
		end
		return task
	end
	
	function Maid:Clean()
		for _, task in ipairs(self.Tasks) do
			local success, errorMsg = pcall(function()
				if typeof(task) == "RBXScriptConnection" then
					task:Disconnect()
				elseif typeof(task) == "Instance" then
					task:Destroy()
				elseif typeof(task) == "function" then
					task()
				elseif typeof(task) == "table" then
					if task.Destroy then
						task:Destroy()
					elseif task.Disconnect then
						task:Disconnect()
					end
				end
			end)
			if not success then
				warn("[Maid] Error cleaning task: " .. tostring(errorMsg))
			end
		end
		table.clear(self.Tasks)
	end
	
	local Services = setmetatable({}, {
		__index = function(self, key)
			local suc, service = pcall(game.GetService, game, key)
			if suc and service then
				self[key] = service
				return service
			else
				warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
				return nil
			end
		end
	})
	
    local Players = Services.Players
    local Workspace = Services.Workspace
    local maid = Maid.new()
    local BetterSpectator = { Enabled = false }
    local Choice = { Value = Players.LocalPlayer.Name }
    local playerConnections = {} 
    local connectedPlayerMaid = nil 
    local localCharacter = nil
    local refreshDebounce = false 
    local lastRefreshTime = 0 

    local function getPlayerList()
        local playerList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:IsDescendantOf(Workspace) and player.Character.ClassName == "Model" then
                table.insert(playerList, player.Name)
            end
        end
        return playerList
    end

    local function findLocalCharacter()
        if localCharacter and localCharacter:IsDescendantOf(Workspace) and localCharacter.Name == Players.LocalPlayer.Name then
            return localCharacter
        end
        local char = Workspace:FindFirstChild(Players.LocalPlayer.Name)
        if char and char.ClassName == "Model" then
            localCharacter = char
            return char
        end
        return nil
    end

    local function saveLocalCharacter()
        local char = Players.LocalPlayer.Character
        if char and char:IsDescendantOf(Workspace) and char.ClassName == "Model" and char.Name == Players.LocalPlayer.Name then
            localCharacter = char
        else
            localCharacter = findLocalCharacter()
        end
    end

    local function connectPlayer(player)
        if playerConnections[player] then
            playerConnections[player]:Clean()
        end
        local playerMaid = Maid.new()
        playerMaid:Add(player.CharacterAdded:Connect(function()
            if not refreshDebounce then
                refreshChoices()
            end
        end))
        playerMaid:Add(player.CharacterRemoving:Connect(function()
            if not refreshDebounce then
                refreshChoices()
            end
        end))
        playerConnections[player] = playerMaid
    end

    local function clearConnections()
        for _, connectionMaid in pairs(playerConnections) do
            connectionMaid:Clean()
        end
        table.clear(playerConnections)
    end

    local function initiatePlayers()
        clearConnections()
        for _, player in ipairs(Players:GetPlayers()) do
            connectPlayer(player)
        end
    end

    local function updateChoice(playerName)
        local player = Players:FindFirstChild(playerName)
        if not player or not player.Character or not player.Character:IsDescendantOf(Workspace) then
            warningNotification("BetterSpectator", "Selected player is invalid or has no character.", 2)
            Choice.Value = Players.LocalPlayer.Name
            Players.LocalPlayer.Character = findLocalCharacter()
            if connectedPlayerMaid then
                connectedPlayerMaid:Clean()
                connectedPlayerMaid = nil
            end
            return
        end

        saveLocalCharacter()
        Players.LocalPlayer.Character = player.Character

        if connectedPlayerMaid then
            connectedPlayerMaid:Clean()
        end
        connectedPlayerMaid = Maid.new()
        connectedPlayerMaid:Add(player.CharacterRemoving:Connect(function()
            Players.LocalPlayer.Character = findLocalCharacter()
            warningNotification("BetterSpectator", "Spectated player died. Waiting for respawn...", 2)
        end))
        connectedPlayerMaid:Add(player.CharacterAdded:Connect(function(newChar)
            saveLocalCharacter()
            Players.LocalPlayer.Character = newChar
            InfoNotification("BetterSpectator", "Spectated player respawned.", 2)
        end))

        InfoNotification("BetterSpectator", "Now spectating " .. player.Name .. ".", 2)
    end

    function refreshChoices()
        if refreshDebounce or tick() - lastRefreshTime < 0.5 then
            return
        end
        refreshDebounce = true
        lastRefreshTime = tick()

        local playerList = getPlayerList()
        Choice:Change(playerList)
        initiatePlayers()

        if BetterSpectator.Enabled and Choice.Value ~= Players.LocalPlayer.Name then
            updateChoice(Choice.Value)
        else
            Players.LocalPlayer.Character = findLocalCharacter()
            if connectedPlayerMaid then
                connectedPlayerMaid:Clean()
                connectedPlayerMaid = nil
            end
        end

        refreshDebounce = false
    end

    BetterSpectator = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "BetterSpectator",
        Function = function(enabled)
            if enabled then
                BetterSpectator.Enabled = true
                initiatePlayers()
                maid:Add(Players.PlayerAdded:Connect(function(player)
                    connectPlayer(player)
                    refreshChoices()
                end))
                maid:Add(Players.PlayerRemoving:Connect(function(player)
                    if playerConnections[player] then
                        playerConnections[player]:Clean()
                        playerConnections[player] = nil
                    end
                    if Choice.Value == player.Name then
                        Choice.Value = Players.LocalPlayer.Name
                        updateChoice(Choice.Value)
                    end
                    refreshChoices()
                end))
                maid:Add(clearConnections)
                maid:Add(function()
                    if connectedPlayerMaid then
                        connectedPlayerMaid:Clean()
                        connectedPlayerMaid = nil
                    end
                    Players.LocalPlayer.Character = findLocalCharacter()
                    Choice.Value = Players.LocalPlayer.Name
                end)
                refreshChoices()
            else
                BetterSpectator.Enabled = false
                maid:Clean()
            end
        end,
        HoverText = "Allows spectating other players by switching your character's perspective."
    })

    Choice = BetterSpectator.CreateDropdown({
        Name = "Player",
        List = getPlayerList(),
        Default = Players.LocalPlayer.Name,
        Function = function(value)
            Choice.Value = value
            if BetterSpectator.Enabled then
                updateChoice(value)
            end
        end
    })
end)

if not shared.CheatEngineMode then
	local inputService = game:GetService('UserInputService')
	local isMobile = inputService.TouchEnabled and not inputService.KeyboardEnabled and not inputService.MouseEnabled
	run(function()
		local controller
		local LegacyLayout = {Enabled = false}
		LegacyLayout = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
			Name = "LegacyLayout",
			Function = function(call)
				if not controller then
					controller = require(game:GetService("ReplicatedStorage").rbxts_include.node_modules["@flamework"].core.out).Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController").mobileAbilityUIController.mobileLayoutController
				end
				if call and not isMobile then
					warningNotification("LegacyLayout", "Mobile devices only!", 3)
					--LegacyLayout:Toggle(false)
				end
				controller:setIsLegacyMode(call)
			end
		})
	end)
end

run(function()
	local a = {Enabled = false}
	a = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Leave Party",
		Function = function(call)
			if call then
				a.ToggleButton(false)
				game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty"):FireServer()
			end
		end
	})
end)

if not shared.CheatEngineMode then
	run(function()
		local KnitInit, Knit
		repeat
			KnitInit, Knit = pcall(function()
				return debug.getupvalue(require(game:GetService("Players").LocalPlayer.PlayerScripts.TS.knit).setup, 9)
			end)
			if KnitInit then break end
			task.wait()
		until KnitInit

		if not debug.getupvalue(Knit.Start, 1) then
			repeat task.wait() until debug.getupvalue(Knit.Start, 1)
		end

		local Players = game:GetService("Players")

		shared.PERMISSION_CONTROLLER_HASANYPERMISSIONS_REVERT = shared.PERMISSION_CONTROLLER_HASANYPERMISSIONS_REVERT or Knit.Controllers.PermissionController.hasAnyPermissions
		shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT = shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT or Knit.Controllers.MatchController.getPlayerParty

		local AC_MOD_View = {
			playerConnections = {},
			Enabled = false,
			Friends = {}, 
			parties = {}, 
			teamMap = {}, 
			display = {},
			isRefreshing = false,
			cacheDirty = true,
			disable_disguises = false,
			disguises = {},
			teamData = {}
		}

		AC_MOD_View.controller = Knit.Controllers.PermissionController
		AC_MOD_View.match_controller = Knit.Controllers.MatchController

		function AC_MOD_View:getPartyById(displayId)
			if not displayId then return end
			displayId = tostring(displayId)
			if self.display[displayId] then return self.display[displayId] end
			for _, party in pairs(self.parties) do
				if party.displayId == tostring(displayId) then
					self.display[displayId] = party
					return party
				end
			end
		end

		function AC_MOD_View:refreshDisplayCache()
			for _, plr in pairs(Players:GetPlayers()) do
				local playerId = tostring(plr.UserId)

				local playerPartyId = self.teamMap[playerId]
				if playerPartyId ~= nil then
					self:getPartyById(playerPartyId)
				end
				task.wait()
			end
		end

		function AC_MOD_View:refreshDisplayCacheAsync()
			task.spawn(self.refreshDisplayCache, self)
		end

		function AC_MOD_View:getPlayerTeamData(plr)
			if self.teamData[plr] then return self.teamData[plr] end

			self.teamData[plr] = {}

			local teamMembers = {}
			local playerTeam = plr.Team 
			if not playerTeam then
				return teamMembers 
			end

			local playerId = tostring(plr.UserId)
			self.Friends[playerId] = self.Friends[playerId] or {}

			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer == plr then continue end 

				local otherPlayerId = tostring(otherPlayer.UserId)
				local areFriends = self.Friends[playerId][otherPlayerId]

				if areFriends == nil then
					local suc, res = pcall(function()
						return plr:IsFriendsWith(otherPlayer.UserId)
					end)
					areFriends = suc and res or false

					if suc then
						self.Friends = self.Friends or {}
						self.Friends[playerId] = self.Friends[playerId] or {}
						self.Friends[playerId][otherPlayerId] = areFriends
						self.Friends[otherPlayerId] = self.Friends[otherPlayerId] or {}
						self.Friends[otherPlayerId][playerId] = areFriends
					end
				end

				if areFriends and otherPlayer.Team == playerTeam then
					table.insert(teamMembers, otherPlayerId)
				end
			end

			self.teamData[plr] = teamMembers

			return teamMembers
		end

		function AC_MOD_View:refreshPlayerTeamData()
			for i,v in pairs(Players:GetPlayers()) do
				self:getPlayerTeamData(v)
				task.wait()
			end
		end

		function AC_MOD_View:refreshPlayerTeamDataAsync()
			task.spawn(self.refreshPlayerTeamData, self)
		end

		function AC_MOD_View:refreshTeamMap()
			local allTeams = {}
			for _, p in pairs(Players:GetPlayers()) do
				local teamMembers = self:getPlayerTeamData(p)
				if teamMembers and #teamMembers > 0 then 
					allTeams[p] = teamMembers
				end
			end

			local validTeams = {}
			for playerInTeams, members in pairs(allTeams) do
				local playerIdInTeams = tostring(playerInTeams.UserId)
				local cleanedMembers = {}

				for _, memberId in pairs(members) do
					local memberIdStr = tostring(memberId)
					if memberIdStr == playerIdInTeams then
						print("Warning: Player " .. playerIdInTeams .. " has themselves in their team list.")
					else
						table.insert(cleanedMembers, memberIdStr)
					end
				end

				if #cleanedMembers > 0 then
					validTeams[playerInTeams] = cleanedMembers
				end
			end

			self.parties = {}
			self.teamMap = {}
			local teamId = 0
			for playerInTeams, members in pairs(validTeams) do
				local playerIdInTeams = tostring(playerInTeams.UserId)
				if not self.teamMap[playerIdInTeams] then
					self.teamMap[playerIdInTeams] = teamId
					table.insert(self.parties, {
						displayId = tostring(teamId),
						members = members
					})
					teamId = teamId + 1

					for _, memberId in pairs(members) do
						self.teamMap[memberId] = teamId - 1
					end
				end
			end

			self.cacheDirty = false
			self.isRefreshing = false
		end

		function AC_MOD_View:refreshTeamMapAsync()
			if self.isRefreshing then return end 
			self.isRefreshing = true
			task.spawn(function()
				self:refreshTeamMap()
			end)
		end

		function AC_MOD_View:getPlayerParty(plr)
			if not plr or not plr:IsA("Player") then
				return nil
			end

			local playerId = tostring(plr.UserId)

			if self.cacheDirty or not next(self.teamMap) then
				self:refreshTeamMapAsync()
			end

			local playerPartyId = self.teamMap[playerId]
			if playerPartyId ~= nil then
				return self:getPartyById(playerPartyId)
			end

			return nil 
		end

		AC_MOD_View.mockGetPlayerParty = function(self, plr)
			local parties = self.parties 
			if parties ~= nil and #parties > 0 then
				return shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT(self, plr)
			end
			return AC_MOD_View:getPlayerParty(plr)
		end

		function AC_MOD_View:toggleDisableDisguises()
			if not self.Enabled then return end
			if self.disable_disguises then
				for _,v in pairs(Players:GetPlayers()) do
					if v == Players.LocalPlayer then continue end
					if tostring(v:GetAttribute("Disguised")) == "true" then
						v:SetAttribute("Disguised", false)
						InfoNotification("Remove Disguises", "Disabled streamer mode for "..tostring(v.Name).."!", 3)
						table.insert(self.disguises, v)
					end
				end
			else
				for i,v in pairs(self.disguises) do
					if tostring(v:GetAttribute("Disguised")) ~= "true" then
						v:SetAttribute("Disguised", true)
						InfoNotification("Remove Disguises", "Re - enabled Streamer mode for "..tostring(v.Name).."!", 2)
					end
				end
				table.clear(self.disguises)
			end
		end

		function AC_MOD_View:refreshCore()
			self:refreshTeamMapAsync()
			self:refreshDisplayCacheAsync()
			self:refreshPlayerTeamDataAsync()

			self:toggleDisableDisguises()
		end

		function AC_MOD_View:refreshCoreAsync()
			task.spawn(self.refreshCore, self)
		end

		function AC_MOD_View:init()
			self.Enabled = true
			self.controller.hasAnyPermissions = function(self)
				return true
			end
			self.match_controller.getPlayerParty = self.mockGetPlayerParty

			self.playerConnections = {
				added = Players.PlayerAdded:Connect(function(player)
					self.cacheDirty = true
					self:refreshCoreAsync()
					player:GetPropertyChangedSignal("Team"):Connect(function()
						self.cacheDirty = true
						self:refreshCoreAsync()
					end)
				end),
				removed = Players.PlayerRemoving:Connect(function(player)
					local playerId = tostring(player.UserId)
					self.Friends[playerId] = nil 
					for _, cache in pairs(self.Friends) do
						cache[playerId] = nil
					end
					self.cacheDirty = true
					self:refreshCoreAsync()
				end)
			}

			self:refreshCore()
		end

		function AC_MOD_View:disable()
			self.Enabled = false

			self.controller.hasAnyPermissions = shared.PERMISSION_CONTROLLER_HASANYPERMISSIONS_REVERT
			self.match_controller.getPlayerParty = shared.MATCH_CONTROLLER_GETPLAYERPARTY_REVERT

			if self.playerConnections then
				for _, v in pairs(self.playerConnections) do
					pcall(function() v:Disconnect() end)
				end
				table.clear(self.playerConnections)
			end

			self.parties = {}
			self.teamMap = {}
			self.Friends = {}
			self.display = {}
			self.teamData = {}
			self.cacheDirty = true

			self:toggleDisableDisguises()
		end

		shared.ACMODVIEWENABLED = false
		AC_MOD_View.moduleInstance = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
			Name = "AC MOD View",
			Function = function(call)
				shared.ACMODVIEWENABLED = call
				if call then
					AC_MOD_View:init()
				else
					AC_MOD_View:disable()
				end
			end
		})

		AC_MOD_View.disableDisguisesToggle = AC_MOD_View.moduleInstance.CreateToggle({
			Name = "Remove Disguises",
			Function = function(call)
				AC_MOD_View.disable_disguises = call
				AC_MOD_View:toggleDisableDisguises()
			end,
			Default = true
		})
	end)
end

getgenv().run = run

pcall(function()
	local maintask
	maintask = task.spawn(function()
		local RunService = game:GetService("RunService")
		repeat 
			local suc, err = pcall(function()
				if shared.vapeentity and shared.vapeentity.isAlive then
					shared.vapeentity.character.RootPart = shared.vapeentity.character.HumanoidRootPart
				end
				RunService.Heartbeat:Wait()
			end)
			--[[if not suc then
				pcall(function()
					task.cancel(maintask)
				end)
			end--]]
		until not shared.VapeExecuted
	end)
    local function sreadfile(filename)
        local suc, content = pcall(readfile, filename)
        if not suc then
            warn("Failed to read file " .. filename .. ": " .. tostring(content))
            return nil
        end
        return content
    end

    local function createSandbox()
        return setmetatable({AutoWinModule = AutoWinModule, shared = shared}, {__index = getgenv()})
    end

    local function errorHandler(err)
        local stackTrace = debug.traceback("Error in loaded script: " .. tostring(err), 2)
        warn(stackTrace)
        return nil
    end

    local function executeProtected()
        local scriptContent = game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWExtra/main/ProjectThingy.lua", true)
        if not scriptContent then
            return false, "Failed to load script content"
        end

        local suc, func = pcall(loadstring, scriptContent)
        if not suc then
            warn("Failed to compile script: " .. tostring(func))
            return false, func
        end

		pcall(function()
			setfenv(func, createSandbox())
		end)

        local suc, res = xpcall(func, errorHandler)
        if not suc then
            return false, res
        end

        return true, res
    end

    local suc, res = executeProtected()
    if not suc then
        print("Script execution failed: " .. tostring(res))
    end
end)

run(function()
    local BedAssist = {Enabled = false}
    local bedassistrange = {Value = 30}
    local bedassistsmoothness = {Value = 6}
    local bedassistangle = {Value = 70}
    local bedassistfirstperson = {Enabled = false}
    local bedassistshopcheck = {Enabled = false}
	local bedassisthandcheck = {Enabled = false}

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or (store.localInventory or store.inventory).inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or (store.localInventory or store.inventory).inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function checkHand()
		return getPickaxeNear() or getAxeNear()
	end

    local camera = workspace.CurrentCamera
    local runService = game:GetService("RunService")
    local collectionService = game:GetService("CollectionService")
    local lplr = game.Players.LocalPlayer

    local beds = {}
    local Connections = {}

    local function isFirstPerson()
        if not (lplr.Character and lplr.Character:FindFirstChild("Head")) then return false end
        return (lplr.Character.Head.Position - camera.CFrame.Position).Magnitude < 2
    end

    local function getClosestEnemyBed(playerPos)
        local closestBed = nil
        local closestDistance = bedassistrange.Value

        for _, bed in pairs(beds) do
            if bed.Parent ~= nil then
                if bed.Name == "bed" and tostring(bed:GetAttribute("TeamId")) == tostring(lplr:GetAttribute("Team")) then
                    continue
                end
                if bed:GetAttribute("BedShieldEndTime") and bed:GetAttribute("BedShieldEndTime") > game.Workspace:GetServerTimeNow() then
                    continue
                end
                local distance = (playerPos - bed.Position).Magnitude
                if distance <= closestDistance then
                    local delta = (bed.Position - playerPos)
                    local localfacing = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character.HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1) or Vector3.new(1, 0, 0)
                    local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
                    if angle <= math.rad(bedassistangle.Value) / 2 then
                        closestDistance = distance
                        closestBed = bed
                    end
                end
            end
        end

        return closestBed
    end

    BedAssist = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "BedAssist",
        Function = function(callback)
            if callback then
                beds = collectionService:GetTagged("bed")
                local connection
                connection = runService.Heartbeat:Connect(function(dt)
                    if not BedAssist.Enabled then
                        connection:Disconnect()
                        camera.CameraType = Enum.CameraType.Custom
                        return
                    end
                    if not entityLibrary.isAlive then
                        return
                    end
					if bedassisthandcheck.Enabled and not checkHand() then 
						return
					end
                    if bedassistfirstperson.Enabled and not isFirstPerson() then
                        return
                    end
                    if bedassistshopcheck.Enabled then
                        local isShop = lplr:FindFirstChild("PlayerGui") and lplr.PlayerGui:FindFirstChild("ItemShop")
                        if isShop then return end
                    end

                    local playerPos = entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position
                    local closestBed = getClosestEnemyBed(playerPos)

                    if closestBed then
                        local bedPos = closestBed.Position
                        local currentCFrame = camera.CFrame
                        local targetCFrame = CFrame.lookAt(currentCFrame.Position, bedPos)
                        local lerpAmount = bedassistsmoothness.Value / 2
                        camera.CFrame = currentCFrame:Lerp(targetCFrame, lerpAmount * dt)
                    end
                end)
                table.insert(Connections, connection)
            else
                for _, v in pairs(Connections) do
                    pcall(function()
                        v:Disconnect()
                    end)
                end
                Connections = {}
                table.clear(beds)
                camera.CameraType = Enum.CameraType.Custom
            end
        end,
        HoverText = "Smoothly aims your camera at the closest enemy bed within range."
    })

    bedassistrange = BedAssist.CreateSlider({
        Name = "Assist Range",
        Min = 10,
        Max = 100,
        Function = function(val) end,
        Default = 30,
        Suffix = function(val) 
            return val == 1 and "stud" or "studs" 
        end
    })

    bedassistsmoothness = BedAssist.CreateSlider({
        Name = "Aim Speed",
        Min = 1,
        Max = 20,
        Function = function(val) end,
        Default = 6
    })

    bedassistangle = BedAssist.CreateSlider({
        Name = "Max Angle",
        Min = 10,
        Max = 360,
        Function = function(val) end,
        Default = 70
    })

    bedassistfirstperson = BedAssist.CreateToggle({
        Name = "First Person Only",
        Function = function() end,
        Default = false,
        HoverText = "Only activates in first-person mode."
    })

    bedassistshopcheck = BedAssist.CreateToggle({
        Name = "Shop Check",
        Function = function() end,
        Default = false,
        HoverText = "Disables aiming when in the shop menu."
    })

	bedassisthandcheck = BedAssist.CreateToggle({
		Name = "Hand Check",
		Function = function() end,
		Default = true,
		HoverText = "Checks if you are holding a pickaxe"
	})

    table.insert(Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
        table.insert(beds, bed)
    end))

    table.insert(Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
        local i = table.find(beds, bed)
        if i then
            table.remove(beds, i)
        end
    end))
end)

run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local invisibilityEnabled = false

    local function modifyHRP(onEnable)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if onEnable then
            hrp.Transparency = 0.3
            hrp.Color = Color3.new(1, 1, 1)
            hrp.Material = Enum.Material.Plastic
        else
            hrp.Transparency = 1
        end
        hrp.CanCollide = true
        hrp.Anchored = false
    end

    local function setCharacterVisibility(isVisible)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = isVisible and 0 or 1
            elseif part:IsA("Decal") then
                part.Transparency = isVisible and 0 or 1
            elseif part:IsA("LayerCollector") then
                part.Enabled = isVisible
            end
        end
    end

    local maid = {
		Clean = function(self)
			for _, v in pairs(self) do
				pcall(function()
					v:Disconnect()
				end)
			end
		end,
		Add = function(self, connection)
			table.insert(self, connection)
		end
	}

    Invisibility = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
        Name = 'Invisibility',
        Function = function(callback)
            invisibilityEnabled = callback
            maid:Clean()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

            if callback then
                InfoNotification('Invisibility Enabled', 'You are now invisible.', 4)
                modifyHRP(true)
                setCharacterVisibility(false)
                maid:Add(RunService.Heartbeat:Connect(function()
                    if not invisibilityEnabled then return end
                    local char = LocalPlayer.Character
                    if not char then return end
                    local humanoid = char:FindFirstChild("Humanoid")
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if not humanoid or not rootPart or humanoid.RigType == Enum.HumanoidRigType.R6 then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.LocalTransparencyModifier = 1
                        elseif part:IsA("Decal") then
                            part.Transparency = 1
                        elseif part:IsA("LayerCollector") then
                            part.Enabled = false
                        end
                    end
                    local oldcf = rootPart.CFrame
                    local oldcamoffset = humanoid.CameraOffset
                    local newcf = rootPart.CFrame - Vector3.new(0, humanoid.HipHeight + (rootPart.Size.Y / 2) - 1, 0)
                    rootPart.CFrame = newcf * CFrame.Angles(0, 0, math.rad(180))
                    humanoid.CameraOffset = Vector3.new(0, -5, 0)
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "http://www.roblox.com/asset/?id=11360825341"
                    local loaded = humanoid.Animator:LoadAnimation(anim)
                    loaded.Priority = Enum.AnimationPriority.Action4
                    loaded:Play()
                    loaded.TimePosition = 0.2
                    loaded:AdjustSpeed(0)
                    RunService.RenderStepped:Wait()
                    loaded:Stop()
                    humanoid.CameraOffset = oldcamoffset
                    rootPart.CFrame = oldcf
                end))
                maid:Add(LocalPlayer.CharacterAdded:Connect(function()
                    if invisibilityEnabled then
                        task.wait(0.5)
                        if Invisibility and Invisibility.Function then
                            Invisibility.Function(true, Invisibility)
                        end
                    end
                end))
            else
                modifyHRP(false)
                setCharacterVisibility(true)
                maid:Clean()
            end
        end,
        Default = false,
        Tooltip = ""
    })

    LocalPlayer.CharacterAdded:Connect(function()
        if invisibilityEnabled then
            task.wait(0.5)
            Invisibility.Function(true)
        end
    end)
end)

--[[run(function()
    local ClientCrasher
	local collectionService = game:GetService("CollectionService")
	local entitylib = entitylib or entityLibrary
	local signal
    ClientCrasher = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Client Crasher",
        Function = function(call)
            if call then
                signal = collectionService:GetInstanceAddedSignal('inventory-entity'):Connect(function(player)
                    local item = player:WaitForChild('HandInvItem')
                    for i,v in getconnections(item.Changed) do
						pcall(function()
                        	v:Disable()
						end)
                    end                
                end)

                repeat
                    if entitylib.isAlive then
                        for _, tool in (store.localInventory or store.inventory).inventory.items do
							task.spawn(switchItem, tool.tool)
						end
                    end
                    task.wait()
                until not ClientCrasher.Enabled
            else
				if signal then
					pcall(function() signal:Disconnect() end)
					signal = nil
				end
			end
        end
    })
end)--]]

run(function()
	local JadeExploit = {Enabled = false}
	JadeExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Jade Exploit",
		Function = function(call)
			if call then
				task.spawn(function()
					while JadeExploit.Enabled do
						game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer("jade_hammer_jump")
						task.wait(0.1)
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("JadeHammerSlam"):FireServer({slamIndex = 0})
					end
				end)
			end
		end
	})
end)