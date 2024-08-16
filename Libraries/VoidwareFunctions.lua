local VoidwareFunctions = {}

VoidwareFunctions["ClosetCheatToggle_Enable"] = Instance.new("BindableEvent")
VoidwareFunctions["ClosetCheatToggle_Disable"] = Instance.new("BindableEvent")

local GuiLibrary = shared.GuiLibrary
local GUI = shared.GUI
local lplr = game:GetService("Players").LocalPlayer
getgenv().lplr = lplr
local pload = shared.pload or function(file, isImportant) local suc, err = pcall(function() loadstring(readfile('vape/'..tostring(file))) end) if not suc and err then local text = "[Voidware Error] Error loading critical file! FileName: "..tostring(file).." Error: "..tostring(err) warn(text) if isImportant then game:GetService("Players").LocalPlayer:Kick(text) end end end
function GuiLibrary.HideWindow(windowName)
    local maingui = GuiLibrary.MainGui
    local windows = maingui:WaitForChild("ScaledGui"):WaitForChild("ClickGui")
    for i,v in pairs(windows:GetChildren()) do
        if string.find(windows:GetChildren()[i].Name, windowName) and windows:GetChildren()[i].ClassName == "TextButton" then
            windows:GetChildren()[i].Visible = false
            break
        end
    end
    local buttons = windows:WaitForChild("MainWindow"):WaitForChild("Children")
    for i,v in pairs(buttons:GetChildren()) do
        if string.find(buttons:GetChildren()[i].Name, windowName) and buttons:GetChildren()[i].ClassName == "TextButton" then
            buttons:GetChildren()[i].Visible = false
            break
        end
    end
end
function GuiLibrary.UnHideWindow(windowName) 
    local maingui = GuiLibrary.MainGui
    local windows = maingui:WaitForChild("ScaledGui"):WaitForChild("ClickGui")
    for i,v in pairs(windows:GetChildren()) do
        if string.find(windows:GetChildren()[i].Name, windowName) and windows:GetChildren()[i].ClassName == "TextButton" then
            windows:GetChildren()[i].Visible = true
            break
        end
    end
    local buttons = windows:WaitForChild("MainWindow"):WaitForChild("Children")
    for i,v in pairs(buttons:GetChildren()) do
        if string.find(buttons:GetChildren()[i].Name, windowName) and buttons:GetChildren()[i].ClassName == "TextButton" then
            buttons:GetChildren()[i].Visible = true
            break
        end
    end
end
function GuiLibrary.ToggleAllWindows(value)
    local blacklistedwindows = {"friends", "profiles", "targets"}
    --f not value then return warn("No value specified for ToggleAllWindows command!") end
    local buttons = {}
    for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
        if string.find(string.lower(i), "button") and not string.find(string.lower(i), "optionsbutton") and GuiLibrary.ObjectsThatCanBeSaved[i].Api and not string.find(string.lower(i), "friends") and not string.find(string.lower(i), "profiles") and not string.find(string.lower(i), "targets") then
            table.insert(buttons, GuiLibrary.ObjectsThatCanBeSaved[i].Api)
        end
    end
    for i,v in pairs(buttons) do
        if value then
            if not buttons[i].Enabled then buttons[i].ToggleButton() end
        else
            if buttons[i].Enabled then buttons[i].ToggleButton() end
        end
    end
end
function GuiLibrary.ExpandAllWindows(value)
    local windows = {}
    local exclusions = { "friends", "profiles", "targets", "overlay", "text gui", "radar", "target info" }
    for name, object in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
        local nameLower = string.lower(name)
        if string.find(nameLower, "window") and object.Api then
            local excluded = false
            for _, exclude in ipairs(exclusions) do
                if string.find(nameLower, exclude) then
                    excluded = true
                    break
                end
            end
            if not excluded then
                table.insert(windows, object.Api)
            end
        end
    end
    for _, window in pairs(windows) do
        if not window.Expanded then
            window.ExpandToggle()
        end
    end
end
function GuiLibrary.SortGui()
    local sorttable = {}
    local movedown = false
    local sortordertable = {
        GUIWindow = 1,
        HotWindow = 2,
        ExploitsWindow = 3,
        CustomisationWindow = 4,
        TPWindow = 5,
        VoidwareWindow = 6,
        CombatWindow = 7,
        BlatantWindow = 8,
        RenderWindow = 9,
        UtilityWindow = 10,
        WorldWindow = 11,
        FunnyWindow = 12,
        --GUISwitcherWindow = 13,
        FriendsWindow = 13,
        TargetsWindow = 14,
        ProfilesWindow = 15,
        ["Text GUICustomWindow"] = 16,
        TargetInfoCustomWindow = 17,
        RadarCustomWindow = 18
    }
    local storedpos = {}
    local num = 6
    for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
        local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
        if obj then
            if v.Type == "Window" and v.Object.Visible and (v.Object.Name ~= "GUISwitcher" or (not string.find(string.lower(v.Object.Name), "guiswitcher"))) then
                local sortordernum = (sortordertable[i] or #sorttable)
                sorttable[sortordernum] = v.Object
            end
        end
    end
    for i2,v2 in pairs(sorttable) do
        if num > 1697 then
            movedown = true
            num = 6
        end
        v2.Position = UDim2.new(0, num, 0, (movedown and (storedpos[num] and (storedpos[num] + 9) or 400) or 39))
        if not storedpos[num] then
            storedpos[num] = v2.AbsoluteSize.Y
            if v2.Name == "MainWindow" then
                storedpos[num] = 400
            end
        end
        num = num + 223
    end
end
function GuiLibrary.HideDivider(text, value)
    if not text then
        warn("No text specified in GuiLibrary.HideDivider")
        return
    end
    local maingui = GuiLibrary.MainGui
    local scaledGui = maingui:WaitForChild("ScaledGui")
    local clickGui = scaledGui:WaitForChild("ClickGui")
    local mainWindow = clickGui:WaitForChild("MainWindow")
    local buttons = mainWindow:WaitForChild("Children"):GetChildren()
    local dividers = {}
    for _, button in pairs(buttons) do
        if button.ClassName == "TextLabel" and button.Name == "TextLabel" then
            table.insert(dividers, button)
        end
    end
    local textLower = string.lower(text)
    for _, divider in pairs(dividers) do
        if string.find(string.lower(divider.Text), textLower) then
            if value then
                if divider.Visible then
                    divider.Visible = false
                end
            else
                if not divider.Visible then
                    divider.Visible = true
                end
            end
        end
    end
end
local vapewindows_controller = {
    --["windows"] = {"Combat", "Blatant", "Render", "Utility", "World"}
    ["windows"] = {"Combat", "Blatant", "Render", "Utility", "World", "GUISwitcher"}
}
local voidwarewindows_controller = {
    --["windows"] = {"Hot", "Exploits", "Customisation", "TP", "Voidware"}
    ["windows"] = {"Hot", "Exploits", "Customisation", "TP", "Voidware", "GUISwitcher"}
}
local vprivatewindows_controller = {
    --["windows"] = {"Funny"}
    ["windows"] = {"Funny", "GUISwitcher"}
}
function vapewindows_controller.HideWindows()
    for i,v in pairs(vapewindows_controller.windows) do
        GuiLibrary.HideWindow(vapewindows_controller.windows[i])
    end
end
function vapewindows_controller.UnHideWindows()
    for i,v in pairs(vapewindows_controller.windows) do
        GuiLibrary.UnHideWindow(vapewindows_controller.windows[i])
    end
end
function voidwarewindows_controller.HideWindows()
    for i,v in pairs(voidwarewindows_controller.windows) do
        GuiLibrary.HideWindow(voidwarewindows_controller.windows[i])
    end
end
function vprivatewindows_controller.UnHideWindows()
    for i,v in pairs(vprivatewindows_controller.windows) do
        GuiLibrary.UnHideWindow(vprivatewindows_controller.windows[i])
    end
end
function vprivatewindows_controller.HideWindows()
    for i,v in pairs(vprivatewindows_controller.windows) do
        GuiLibrary.HideWindow(vprivatewindows_controller.windows[i])
    end
end
function voidwarewindows_controller.UnHideWindows()
    for i,v in pairs(voidwarewindows_controller.windows) do
        GuiLibrary.UnHideWindow(voidwarewindows_controller.windows[i])
    end
end
shared.vapewindows_controller = vapewindows_controller
shared.voidwarewindows_controller = voidwarewindows_controller
shared.vprivatewindows_controller = vprivatewindows_controller
function VoidwareFunctions.LoadFunctions()
    local entityLibrary = loadstring(voidware.getFile("Libraries/entityHandler.lua"))()
    shared.vapeentity = entityLibrary
    getgenv().entityLibrary = entityLibrary
    local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
    task.spawn(function()
        do
            function RunLoops:BindToRenderStep(name, func)
                if RunLoops.RenderStepTable[name] == nil then
                    RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
                end
            end
        
            function RunLoops:UnbindFromRenderStep(name)
                if RunLoops.RenderStepTable[name] then
                    RunLoops.RenderStepTable[name]:Disconnect()
                    RunLoops.RenderStepTable[name] = nil
                end
            end
        
            function RunLoops:BindToStepped(name, func)
                if RunLoops.StepTable[name] == nil then
                    RunLoops.StepTable[name] = runService.Stepped:Connect(func)
                end
            end
        
            function RunLoops:UnbindFromStepped(name)
                if RunLoops.StepTable[name] then
                    RunLoops.StepTable[name]:Disconnect()
                    RunLoops.StepTable[name] = nil
                end
            end
        
            function RunLoops:BindToHeartbeat(name, func)
                if RunLoops.HeartTable[name] == nil then
                    RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
                end
            end
        
            function RunLoops:UnbindFromHeartbeat(name)
                if RunLoops.HeartTable[name] then
                    RunLoops.HeartTable[name]:Disconnect()
                    RunLoops.HeartTable[name] = nil
                end
            end
        end
    end)
    getgenv().RunLoops = RunLoops
    shared.RunLoops = RunLoops
    shared.NotifyColor = Color3.fromRGB(93, 63, 211)
    shared.NotifyIcon = 'assets/WarningNotification.png'
    local function warningNotification(title, text, delay)
        local suc, res = pcall(function()
            local frame = GuiLibrary.CreateNotification(title, text, delay, shared.NotifyIcon)
            frame.Frame.Frame.ImageColor3 = shared.NotifyColor
            return frame
        end)
        warn(title..": "..text)
        return (suc and res)
    end
    getgenv().warningNotification = warningNotification
    local function InfoNotification(title, text, delay)
        local suc, res = pcall(function()
            local frame = GuiLibrary.CreateNotification(title or "Voidware", text or "Successfully called function", delay or 7, "assets/InfoNotification.png")
            return frame
        end)
        warn(title..": "..text)
        return (suc and res)
    end
    getgenv().InfoNotification = InfoNotification
    local function errorNotification(title, text, delay)
        local suc, res = pcall(function()
            local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/InfoNotification.png")
            frame.Frame.Frame.ImageColor3 = Color3.fromRGB(220, 0, 0)
            return frame
        end)
        warn(title..": "..text)
        return (suc and res)
    end
    getgenv().errorNotification = errorNotification
    local function isAlive(plr, healthblacklist)
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
    getgenv().isAlive = isAlive
    local function getItemDrop(drop)
        if not isAlive(lplr, true) and not entityLibrary.LocalPosition then 
            return nil
        end
        local itemdrop, magnitude = nil, math.huge
        for i,v in next, collectionService:GetTagged('ItemDrop') do 
            if v.Name == drop then 
                local localpos = (isAlive(lplr, true) and lplr.Character.HumanoidRootPart.Position or entityLibrary.LocalPosition)
                local newdistance = (localpos - v.Position).Magnitude 
                if newdistance < magnitude then 
                    magnitude = newdistance 
                    itemdrop = v 
                end
            end
        end
        return itemdrop
    end
    getgenv().getItemDrop = getItemDrop
    local function isEnabled(module)
        if GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"] and GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api then
            return GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.Enabled or false
        else
            return false
        end
    end
    getgenv().isEnabled = isEnabled
    local canRespawn = function() end
    canRespawn = function()
        local success, response = pcall(function() 
            return lplr.leaderstats.Bed.Value == '✅' 
        end)
        return success and response 
    end
    getgenv().canRespawn = canRespawn
    local GetEnumItems = function() return {} end
	GetEnumItems = function(enum)
		local fonts = {}
		for i,v in next, Enum[enum]:GetEnumItems() do 
			table.insert(fonts, v.Name) 
		end
		return fonts
	end
    getgenv().GetEnumItems = GetEnumItems
    local GetTarget = function() return {} end
    GetTarget = function(distance, healthmethod, raycast, npc, team)
        local magnitude, target = (distance or healthmethod and 0 or math.huge), {}
        for i,v in playersService:GetPlayers() do 
            if v ~= lplr and isAlive(v) and isAlive(lplr, true) then 
                if ({shared.vapewhitelist:get(v)})[2] then
                    return
                end
                if shared.vapeentity.isPlayerTargetable(v) then 
                    return
                end
                local playerRaycasted = function() return true end
                if playerRaycasted(v) and raycast then 
                    return
                end
                if healthmethod and v.Character.Humanoid.Health < magnitude then 
                    magnitude = v.Character.Humanoid.Health
                    target.Human = true
                    target.RootPart = v.Character.HumanoidRootPart
                    target.Humanoid = v.Character.Humanoid
                    target.Player = v
                end 
                local playerdistance = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if playerdistance < magnitude then 
                    magnitude = playerdistance
                    target.Human = true
                    target.RootPart = v.Character.HumanoidRootPart
                    target.Humanoid = v.Character.Humanoid
                    target.Player = v
                end
            end
        end
        return target
    end
    getgenv().GetTarget = GetTarget
    local btext = function(text)
        return text .. ' '
    end
    getgenv().btext = btext
    local playSound = function(soundID, loop)
        soundID = (soundID or ''):gsub('rbxassetid://', '')
        local sound = Instance.new('Sound')
        sound.Looped = loop and true or false
        sound.Parent = workspace
        sound.SoundId = 'rbxassetid://' .. soundID
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
        return sound
    end
    getgenv().playSound = playSound
    local function getHealth(player)
        player = player or lplr
        return player.Character.Humanoid.Health
    end
    getgenv().getHealth = getHealth
    local function getItem(itemName, inv)
        task.spawn(function()
            repeat task.wait() until shared.GlobalStore
            local store = shared.GlobalStore
            for slot, item in pairs(inv or store.localInventory.inventory.items) do
                if item.itemType == itemName then
                    return item, slot
                end
            end
            return nil
        end)
    end
    getgenv().getItem = getItem
    local vapeAssert = function(argument, title, text, duration, hault, moduledisable, module) 
		if not argument then
			local suc, res = pcall(function()
				local notification = GuiLibrary.CreateNotification(title or "Voidware", text or "Failed to call function.", duration or 20, "assets/WarningNotification.png")
				notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
				notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
				if moduledisable and (module and GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.Enabled) then 
					GuiLibrary.ObjectsThatCanBeSaved[module.."OptionsButton"].Api.ToggleButton(false)
					print("Module disabled: " .. tostring(module))
				end
			end)
			if not suc then
				print("Error occurred: " .. tostring(res))
			end
			if hault then 
				while true do 
					task.wait() 
				end 
			end
		end
	end
    getgenv().vapeAssert = vapeAssert
    local function GetClanTag(plr)
        local atr, res = pcall(function()
            return plr:GetAttribute("ClanTag")
        end)
        return atr and res ~= nil and res
    end
    getgenv().GetClanTag = GetClanTag
    local GetEnumItems = function() return {} end
	GetEnumItems = function(enum)
		local fonts = {}
		for i,v in next, Enum[enum]:GetEnumItems() do 
			table.insert(fonts, v.Name) 
		end
		return fonts
	end
    getgenv().GetEnumItems = GetEnumItems
    local dumptable = function() return {} end
    dumptable = function(tab, tabtype, sortfunction)
        local data = {}
        for i,v in next, tab do
            local tabtype = tabtype and tabtype == 1 and i or v
            table.insert(data, tabtype)
        end
        if sortfunction then
            table.sort(data, sortfunction)
        end
        return data
    end
    getgenv().dumptable = dumptable    
end
function VoidwareFunctions.LoadServices()
    local collectionService = game:GetService("CollectionService")
    getgenv().collectionService = collectionService
    local TweenService = game:GetService("TweenService")
    getgenv().TweenService = TweenService
    getgenv().tweenService = TweenService
    local playersService = game:GetService("Players")
    getgenv().playersService = playersService
    local runService = game:GetService("RunService")
    getgenv().runService = runService
end
local log_directory = 'vape/Libraries/ChangesDetectorLog.txt'
local function fetch_changes_data()
    local table_for_save_1 = {}
    for i, v in pairs(shared.GuiLibrary.ObjectsThatCanBeSaved) do
        if v.Type == "OptionsButton" then
            local Name = v.Api.Name
            local Window = v.Api.Window or "Unknown"
            local table_for_save_2 = {ButtonName = Name, WindowName = Window}
            table.insert(table_for_save_1, table_for_save_2)
        end
    end
    return table_for_save_1
end
function VoidwareFunctions.CheckForChanges()
    local file_exists = false
    local file_data = {}
    local log_directory = 'vape/Libraries/ChangesDetectorLog.txt'
    if isfile(log_directory) then 
        file_exists = true 
    end

    if file_exists then
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(log_directory))
        end)
        if success then 
            file_data = result 
        end
    end

    local current_data = fetch_changes_data()
    local logged_changes = {}

    local function log_change(change_type, changed_button, before, after)
        if not change_type or not changed_button or (change_type == "WindowChange" and (not before or not after)) then 
            return warn("Please specify everything!") 
        end
        if change_type == "WindowChange" then
            print(string.format("[Module Moved] %s has changed its window from %s to %s", changed_button, before, after))
            InfoNotification("Module Moved", string.format("%s has changed its window from %s to %s", changed_button, before, after), 3)
        elseif change_type == "ButtonDeleted" then
            print(string.format("[Module Deleted] %s was deleted", changed_button))
            InfoNotification("Module Deleted", string.format("%s was deleted", changed_button), 3)
        elseif change_type == "ButtonCreated" then
            print(string.format("[Module Created] %s was added to %s", changed_button, after))
            InfoNotification("Module Created", string.format("%s was added to %s", changed_button, after), 3)
        end
        local table_to_insert = {Type = change_type, ButtonName = changed_button, Before = before, After = after}
        table.insert(logged_changes, table_to_insert)
    end

    local changes_detected = false

    if type(current_data) == "table" and type(file_data) == "table" then
        for _, current_button in pairs(current_data) do
            local found = false
            for _, logged_button in pairs(file_data) do
                if current_button["ButtonName"] == logged_button["ButtonName"] then
                    found = true
                    if current_button["WindowName"] ~= logged_button["WindowName"] then
                        log_change("WindowChange", current_button["ButtonName"], logged_button["WindowName"], current_button["WindowName"])
                        changes_detected = true
                    end
                    break
                end
            end
            if not found then
                log_change("ButtonCreated", current_button["ButtonName"], nil, current_button["WindowName"])
                changes_detected = true
            end
        end

        for _, logged_button in pairs(file_data) do
            local found = false
            for _, current_button in pairs(current_data) do
                if logged_button["ButtonName"] == current_button["ButtonName"] then
                    found = true
                    break
                end
            end
            if not found then
                log_change("ButtonDeleted", logged_button["ButtonName"], nil, nil)
                changes_detected = true
            end
        end
    end

    if not changes_detected then
        print("No changes detected")
        --InfoNotification("No Changes", "No changes detected", 3)
    end
end
function VoidwareFunctions.LogChangesFile()
    local data = fetch_changes_data
    writefile(log_directory, game:GetService("HttpService"):JSONEncode(data))
end
function VoidwareFunctions.EditWL(argTable)
    -- Example argTable: local args = {["TagColor"] = (0, 0, 0), ["TagText"] = "New tag :0"}
    local NewTag_text
    local NewTag_color
    local Roblox_Username
    if type(argTable) == "table" and argTable["api_key"] then
        if argTable["TagColor"] then NewTag_color = tostring(argTable["TagColor"]) end
        if argTable["TagText"] then NewTag_text = tostring(argTable["TagText"]) end
        if argTable["RobloxUsername"] then Roblox_Username = tostring(argTable["RobloxUsername"]) end

        if NewTag_text or NewTag_color or Roblox_Username then
            local api_key = argTable["api_key"]
            local tag_text = NewTag_text or ""
            local tag_color = NewTag_color or ""
            local roblox_username = Roblox_Username or game:GetService("Players").LocalPlayer.Name

            local headers = {
                ["Content-type"] = "application/json",
                ["api-key"] = tostring(api_key)
            }
            local data = {}
            if tag_text ~= "" then data["tag_text"] = tag_text end
            if tag_color ~= "" then data["tag_color"] = tag_color end
            data["roblox_username"] = tostring(roblox_username)
            local final_data = game:GetService("HttpService"):JSONEncode(data)
            local url = "https://whitelist.vapevoidware.xyz/edit_wl"
            local a = request({
                Url = url,
                Method = 'POST',
                Headers = headers,
                Body = final_data
            })
            print(a)
            if type(a) == "table" then
                for i,v in pairs(a) do
                    print("1: "..tostring(i).." 2: "..tostring(a[i]))
                end
            end
            return a
        end
    else
        print("Invalid table. 1: "..tostring(type(argTable)).." 2: "..tostring(#argTable).." 3: "..tostring(argTable["api_key"]))
        return "Invalid table. 1: "..tostring(type(argTable)).." 2: "..tostring(#argTable).." 3: "..tostring(argTable["api_key"])
    end
end
function VoidwareFunctions.Save_VD()
    task.spawn(function()
        local valid_windows = {}
        local full_data = {}
        if shared.GuiLibrary.ObjectsThatCantBeSaved and type(shared.GuiLibrary.ObjectsThatCantBeSaved) == "table" then
            for i,v in pairs(shared.GuiLibrary.ObjectsThatCantBeSaved) do
                if shared.GuiLibrary.ObjectsThatCantBeSaved[i]["Type"] and shared.GuiLibrary.ObjectsThatCantBeSaved[i]["Type"] == "CustomVoidwareWindow" and shared.GuiLibrary.ObjectsThatCantBeSaved[i]["Object"] then
                    table.insert(valid_windows, i)
                end
            end
        end
        for i,v in pairs(valid_windows) do
            local Table = shared.GuiLibrary.ObjectsThatCantBeSaved[valid_windows[i]]
            local Object = Table["Object"]
            local table_to_save = {}
            table_to_save["Position"] = {Object.Position.X.Scale, Object.Position.X.Offset, Object.Position.Y.Scale, Object.Position.Y.Offset}
            table_to_save["TableChildName"] = valid_windows[i]
            table.insert(full_data, table_to_save)
        end
        local Encoded_Data = game:GetService("HttpService"):JSONEncode(full_data)
        if shared.profilesDirectory then
            writefile("vape/"..shared.profilesDirectory.."/VoidwareData.txt", Encoded_Data)
        end
    end)
end
function VoidwareFunctions.Load_VD()
    task.spawn(function()
        if shared.profilesDirectory then
            if isfile("vape/"..shared.profilesDirectory.."/VoidwareData.txt") then
                local Decoded_Data = game:GetService("HttpService"):JSONDecode(readfile("vape/"..shared.profilesDirectory.."/VoidwareData.txt"))
                if type(Decoded_Data) == "table" then
                    for i,v in pairs(Decoded_Data) do
                        if Decoded_Data[i]["TableChildName"] then
                            task.spawn(function()
                                repeat task.wait() until shared.GuiLibrary.ObjectsThatCantBeSaved[Decoded_Data[i]["TableChildName"]]
                                if Decoded_Data[i]["Position"] then
                                    repeat task.wait() until shared.GuiLibrary.ObjectsThatCantBeSaved[Decoded_Data[i]["TableChildName"]]["Object"]
                                    shared.GuiLibrary.ObjectsThatCantBeSaved[Decoded_Data[i]["TableChildName"]]["Object"].Position = UDim2.new(Decoded_Data[i]["Position"][1], Decoded_Data[i]["Position"][2], Decoded_Data[i]["Position"][3], Decoded_Data[i]["Position"][4])
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
end
GuiLibrary.SelfDestructEvent.Event:Connect(function()
	VoidwareFunctions.LogChangesFile()
    VoidwareFunctions.Save_VD()
end)
function VoidwareFunctions.LoadVoidware()
    GuiLibrary.HideWindow("Friends")
    GuiLibrary.HideWindow("Targets")
    GuiLibrary.HideWindow("Profiles")
    --GuiLibrary.ToggleAllWindows(true)
    --GuiLibrary.ExpandAllWindows(true)
    --GuiLibrary.SortGui()
    GUI.CreateDivider("Voidware")
    local thing0 = {Enabled = false}
    thing0 = GUI.CreateOptionsButton({
        Name = 'ClosetCheatMode',
        Function = function(calling)
            if calling then 
                print("1: "..tostring(shared.voidware.closetCheating).." 2: "..tostring(shared.profilesDirectory))
                if shared.profilesDirectory ~= "ClosetProfiles/" then
                    VoidwareFunctions["ClosetCheatToggle_Enable"]:Fire()
                end
            else
                if shared.profilesDirectory ~= "Profiles/" then
                    VoidwareFunctions["ClosetCheatToggle_Disable"]:Fire()
                end
            end
        end,
        ["NoSave"] = true
    })
    task.spawn(function()
        repeat task.wait() until shared.GuiLibrary.ObjectsThatCannotBeSaved["ClosetCheatModeOptionsButton"]
        repeat task.wait() until shared.GuiLibrary.ObjectsThatCannotBeSaved["ClosetCheatModeOptionsButton"].Api
        if shared.voidware.closetCheating then
            if not shared.GuiLibrary.ObjectsThatCannotBeSaved["ClosetCheatModeOptionsButton"].Api.Enabled then
                shared.GuiLibrary.ObjectsThatCannotBeSaved["ClosetCheatModeOptionsButton"].Api.ToggleButton()
            end
        else
            if shared.GuiLibrary.ObjectsThatCannotBeSaved["ClosetCheatModeOptionsButton"].Api.Enabled then
                shared.GuiLibrary.ObjectsThatCannotBeSaved["ClosetCheatModeOptionsButton"].Api.ToggleButton()
            end
        end
    end)
    GUI.CreateDivider("GUI Modes")
    local thing = {Enabled = false}
    thing = GUI.CreateOptionsButton({
        Name = 'VoidwareGUI',
        Function = function(calling)
            if calling then 
                if shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"] and shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"].Api.Enabled then
                    shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"].Api.ToggleButton()
                end
                if shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"] and shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Api.Enabled then
                    shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Api.ToggleButton()
                end
                vapewindows_controller.HideWindows()
                vprivatewindows_controller.HideWindows()
                voidwarewindows_controller.UnHideWindows()
                GuiLibrary.SortGui()
            else
                voidwarewindows_controller.HideWindows()
            end
        end,
        --["NoSave"] = true
    })
    local thing2 = {Enabled = false}
    thing2 = GUI.CreateOptionsButton({
        Name = 'VapeGUI',
        Function = function(calling)
            if calling then 
                if shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"] and shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"].Api.Enabled then
                    shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"].Api.ToggleButton()
                end
                if shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"] and shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Api.Enabled then
                    shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Api.ToggleButton()
                end
                voidwarewindows_controller.HideWindows()
                vprivatewindows_controller.HideWindows()
                vapewindows_controller.UnHideWindows()
                GuiLibrary.SortGui()
            else
                vapewindows_controller.HideWindows()
            end
        end,
        --["NoSave"] = true
    })
    task.spawn(function()
        repeat task.wait() until shared.vapewhitelist
        repeat task.wait() until shared.vapewhitelist.loaded
        local prio = shared.vapewhitelist.localprio
        if type(prio) == "number" and prio > 0 then
            local thing3 = {Enabled = false}
            thing3 = GUI.CreateOptionsButton({
                Name = 'VPrivateGUI',
                Function = function(calling)
                    if calling then 
                        if shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"] and shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"].Api.Enabled then
                            shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"].Api.ToggleButton()
                        end
                        if shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"] and shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"].Api.Enabled then
                            shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"].Api.ToggleButton()
                        end
                        voidwarewindows_controller.HideWindows()
                        vapewindows_controller.HideWindows()
                        vprivatewindows_controller.UnHideWindows()
                        GuiLibrary.SortGui()
                    end
                end,
                --["NoSave"] = true
            })
            pload("CustomModules/VoidwarePrivate.lua", false)
        end
    end)
    task.spawn(function()
        repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"]
        repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"]
        --repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"]
    
        if not shared.GuiLibrary.ObjectsThatCanBeSaved["VoidwareGUIOptionsButton"].Api.Enabled and not shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"].Api.Enabled --[[and not shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Api.Enabled--]] then
            shared.GuiLibrary.ObjectsThatCanBeSaved["VapeGUIOptionsButton"].Api.ToggleButton()
        end
    end)
    VoidwareFunctions.LoadServices()
    VoidwareFunctions.LoadFunctions()
    VoidwareFunctions["ClosetCheatToggle_Enable"].Event:Connect(function()
        if not shared.voidware.closetCheating then
            shared.voidware.closetCheating = true
            GuiLibrary.Restart()
        end
    end)
    VoidwareFunctions["ClosetCheatToggle_Disable"].Event:Connect(function()
        if shared.voidware.closetCheating then
            shared.voidware.closetCheating = false
            GuiLibrary.Restart()
        end
    end)
    if shared.voidware.closetCheating then
        InfoNotification("Voidware | Closet Cheat Mode", "Closet Cheat Mode loaded successfully!", 3)
    end
    --[[task.spawn(function()
        VoidwareFunctions.CheckForChanges()
    end)--]]
    local function CreateGUIModeSwitcher()
        task.spawn(function()
            --[[local a = Instance.new("TextLabel")
            a.Parent = shared.GuiLibrary.MainGui:WaitForChild("ScaledGui"):WaitForChild("ClickGui")
            a.BackgroundColor3 = Color3.new(0, 0, 0)
            a.TextColor3 = Color3.new(255, 255, 255)
            a.TextScaled = true
            a.Position = UDim2.new(0, 750, 0.7, 100)
            a.Size = UDim2.new(0.25, 0, 0.05, 0)
            a.Text = "GUI Mode Switcher"--]]
            local function makeCorner(parent)
                local b = Instance.new("UICorner")
                b.CornerRadius = UDim.new(0, 10)
                b.Parent = parent
            end
            --makeCorner(a)
            repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.GUISwitcherWindow
            local a = shared.GuiLibrary.ObjectsThatCanBeSaved.GUISwitcherWindow.ChildrenObject
            repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.VoidwareGUIOptionsButton
            shared.GuiLibrary.ObjectsThatCanBeSaved.VoidwareGUIOptionsButton.Object.Parent = a
            --shared.GuiLibrary.ObjectsThatCanBeSaved.VoidwareGUIOptionsButton.Object.Position = UDim2.new(0, 0, 1.05, 0)
            makeCorner(shared.GuiLibrary.ObjectsThatCanBeSaved.VoidwareGUIOptionsButton.Object)
            repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved.VapeGUIOptionsButton
            shared.GuiLibrary.ObjectsThatCanBeSaved.VapeGUIOptionsButton.Object.Parent = a
            --shared.GuiLibrary.ObjectsThatCanBeSaved.VapeGUIOptionsButton.Object.Position = UDim2.new(0, 0, 2.05, 0)
            makeCorner(shared.GuiLibrary.ObjectsThatCanBeSaved.VapeGUIOptionsButton.Object)
            repeat task.wait() until shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"]
            shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Object.Parent = a
            --shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Object.Position = UDim2.new(0, 0, 3.05, 0)
            makeCorner(shared.GuiLibrary.ObjectsThatCanBeSaved["VPrivateGUIOptionsButton"].Object)
            repeat task.wait() until shared.GuiLibrary.ObjectsThatCantBeSaved["GUI ModesDivider1"]
            shared.GuiLibrary.ObjectsThatCantBeSaved["GUI ModesDivider1"].Object1:Destroy()
            --[[local c = Instance.new("Frame")
            c.Parent = a
            c.Size = UDim2.new(1, 0, 1, 0)
            c.BackgroundTransparency = 1
            local d = Instance.new("UIListLayout")
            d.Parent = a
            d.Padding = UDim.new(0.1, 0)   
            shared.GuiLibrary.ObjectsThatCantBeSaved[a.Text.."CustomWindow"] = {["Type"] = "CustomVoidwareWindow", ["Object"] = a}  
            repeat task.wait() until shared.dragGUI
            local dragGUI = shared.dragGUI
            dragGUI(shared.GuiLibrary.ObjectsThatCantBeSaved["GUI Mode SwitcherCustomWindow"].Object) --]]
        end) 
    end
    CreateGUIModeSwitcher()
    VoidwareFunctions.Load_VD()
    shared.VoidwareLoaded = true
end
VoidwareFunctions.LoadVoidware()
return VoidwareFunctions