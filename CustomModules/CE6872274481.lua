repeat task.wait() until game:IsLoaded()
local GuiLibrary = shared.GuiLibrary
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local runservice = runService -- moment
local tweenService = game:GetService("TweenService")
local tweenservice = tweenService -- moment
local collectionService = game:GetService("CollectionService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local gameCamera = game.Workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local entityLibrary = shared.vapeentity
local entitylib = entityLibrary
local vapeConnections = {}
local vapeCachedAssets = {}
local function encode(tbl)
    return game:GetService("HttpService"):JSONEncode(tbl)
end
VoidwareFunctions.GlobaliseObject("encode", encode)
local function decode(tbl)
    return game:GetService("HttpService"):JSONDecode(tbl)
end
VoidwareFunctions.GlobaliseObject("decode", decode)
local function cprint(tbl)
	for i, v in pairs(tbl) do
		print(tostring(tbl), tostring(i), tostring(v))
	end
end
VoidwareFunctions.GlobaliseObject("cprint", cprint)
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true

local CheatEngineHelper = {
    SprintEnabled = false
}
local store = {
	damageBlockFail = tick(),
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "",
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	hand = {},
	matchState = 1,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = "vape"},
		chatStrings2 = {vape = "helloimusinginhaler"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}
local bedwars = {
    ProjectileRemote = "ProjectileFire",
    EquipItemRemote = "SetInvItem",
    DamageBlockRemote = "DamageBlock",
    ReportRemote = "ReportPlayer",
    PickupRemote = "PickupItemDrop",
    CannonAimRemote = "AimCannon",
    CannonLaunchRemote = "LaunchSelfFromCannon",
    AttackRemote = "SwordHit",
    GuitarHealRemote = "PlayGuitar",
	EatRemote = "ConsumeItem",
	SpawnRavenRemote = "SpawnRaven",
	MageRemote = "LearnElementTome",
	DragonRemote = "RequestDragonPunch",
	ConsumeSoulRemote = "ConsumeGrimReaperSoul",
	TreeRemote = "ConsumeTreeOrb",
	PickupMetalRemote = "CollectCollectableEntity",
	BatteryRemote = "ConsumeBattery"
}
local function extractTime(timeText)
	local minutes, seconds = string.match(timeText, "(%d+):(%d%d)")
    local tbl = {
        minutes = tonumber(minutes),
        seconds = tonumber(seconds)
    }
	function tbl:toSeconds()
		return tonumber(minutes) and tonumber(seconds) and tonumber(minutes)*60 + tonumber(seconds)
	end
	return tbl
end
local function getRemotes(paths)
    local allRemotes = {}
    local function filterDescendants(descendants, classNames)
        local filtered = {}
        if typeof(classNames) ~= "table" then
            classNames = {classNames}
        end
        for _, descendant in pairs(descendants) do
            for _, className in pairs(classNames) do
                if descendant:IsA(className) then
                    table.insert(filtered, descendant)
                    break 
                end
            end
        end
        return filtered
    end
    for _, path in pairs(paths) do
        local objectToGetDescendantsFrom = game
        for _, subfolder in pairs(string.split(path, ".")) do
            objectToGetDescendantsFrom = objectToGetDescendantsFrom:FindFirstChild(subfolder)
            if not objectToGetDescendantsFrom then
                --warn("Path " .. path .. " does not exist.")
                break
            end
        end
        if objectToGetDescendantsFrom then
            local remotes = filterDescendants(objectToGetDescendantsFrom:GetDescendants(), {"BindableEvent", "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent"})
            for _, remote in pairs(remotes) do
                table.insert(allRemotes, remote)
            end
        end
    end
    return allRemotes
end
--[[bedwars.Client = {}
function bedwars.Client:Get(remName, customTable, resRequired)
    --warn("B", remName, customTable)
    local remotes = customTable or getRemotes({"ReplicatedStorage"})
    for i,v in pairs(remotes) do
        --warn("C", i,v, v.Name, remName)
        if v.Name == remName then return v end
        if v.Name == remName or string.find(v.Name, remName) then  
			if (not resRequired) then return v else
				local tbl = {}
				function tbl:InvokeServer()
					local tbl2 = {}
					local res = v:InvokeServer()
					function tbl2:andThen(func)
						func(res)
					end
					return tbl2
				end
				return tbl
			end
			return v
        end
    end

	warn(debug.traceback("[bedwars.Client:Get]: Failure finding remote! Remote: "..tostring(remName).." CustomTable: "..tostring(customTable or "no table specified").." Using backup table..."))
	local backupTable = {}
	function backupTable:FireServer() return false end
	function backupTable:InvokeServer() return false end
	--- big brain moment :)
    return backupTable
end
function bedwars.Client:GetNamespace(nameSpace, blacklist)
    local remotes = getRemotes({"ReplicatedStorage"})
    local resolvedRemotes = {}
    local blacklist = blacklist or {}
    for i,v in pairs(remotes) do
        if (v.Name == nameSpace or string.find(v.Name, nameSpace)) and (not table.find(blacklist, v.Name)) then table.insert(resolvedRemotes, v) end
    end
    --for i,v in pairs(resolvedRemotes) do print("A", i, v) end
    local resolveFunctionTable = {}
    resolveFunctionTable.Namespace = resolvedRemotes
    function resolveFunctionTable:Get(remName)
        return bedwars.Client:Get(remName, resolvedRemotes)
    end
    return resolveFunctionTable
end--]]
bedwars.Client = {}
local cache = {} 
local namespaceCache = {}

local NetworkLogger = {
    usageStats = {},
    threshold = 20, 
    warningCooldown = 5, 
    lastWarning = {}
}

local function logRemoteUsage(remoteName, callType)
	remoteName = tostring(remoteName)
    local timeNow = tick()
    local key = remoteName .. "_" .. callType
    
    if not NetworkLogger.usageStats[key] then
        NetworkLogger.usageStats[key] = {
            count = 0,
            lastReset = timeNow,
            peakRate = 0
        }
    end
    
    local stats = NetworkLogger.usageStats[key]
    stats.count = stats.count + 1

	if shared.VoidDev then
		print(`Logged fire from {tostring(remoteName)} | {tostring(stats.count)}`)
	end
    
    if timeNow - stats.lastReset >= 1 then
        local rate = stats.count / (timeNow - stats.lastReset)
        stats.peakRate = math.max(stats.peakRate, rate)
        stats.count = 0
        stats.lastReset = timeNow
        
        if rate > NetworkLogger.threshold then
            if not NetworkLogger.lastWarning[key] or (timeNow - NetworkLogger.lastWarning[key] >= NetworkLogger.warningCooldown) then
				if shared.VoidDev then
					warn(string.format("[NetworkLogger] Excessive remote usage detected!\n" .."Remote: %s\nCallType: %s\nRate: %.2f calls/sec\nPeak: %.2f calls/sec", remoteName, callType, rate, stats.peakRate))
					warningNotification("NetworkLogger", string.format("Excessive remote usage detected!\n" .."Remote: %s\nCallType: %s\nRate: %.2f calls/sec\nPeak: %.2f calls/sec", remoteName, callType, rate, stats.peakRate), 3)
				end
                NetworkLogger.lastWarning[key] = timeNow
            end
        end
    end
end

local remoteThrottleTable = {}
local REMOTE_THROTTLE_TIME = {
    SwordHit = 0.1,
    ChestGetItem = 1.0,
    SetObservedChest = 0.2,
    _default = 0.1
}

local function shouldThrottle(remoteName)
    local now = tick()
    local throttleTime = REMOTE_THROTTLE_TIME[remoteName] or REMOTE_THROTTLE_TIME._default
    if not remoteThrottleTable[remoteName] or now - remoteThrottleTable[remoteName] > throttleTime then
        remoteThrottleTable[remoteName] = now
        return false
    end
	if shared.VoidDev and shared.ThrottleDebug then
   	 	warn("[Remote Throttle] Throttled remote call to '" .. tostring(remoteName) .. "' at " .. tostring(now))
	end
    return true
end

local function decorateRemote(remote, src)
    local isFunction = string.find(string.lower(remote.ClassName), "function")
    local isEvent = string.find(string.lower(remote.ClassName), "remoteevent")
    local isBindable = string.find(string.lower(remote.ClassName), "bindable")

    local function middlewareCall(method, ...)
        local remoteName = remote.Name
		local args = {...}
        if shouldThrottle(remoteName) then
            return
        end
        return method(...)
    end

    if isFunction then
        function src:CallServer(...)
			logRemoteUsage(remote, "InvokeServer")
            return middlewareCall(function(...) return remote:InvokeServer(...) end, ...)
        end
    elseif isEvent then
        function src:CallServer(...)
			logRemoteUsage(remote, "FireServer")
            return middlewareCall(function(...) return remote:FireServer(...) end, ...)
        end
    elseif isBindable then
        function src:CallServer(...)
			logRemoteUsage(remote, "BindableFire")
            return middlewareCall(function(...) return remote:Fire(...) end, ...)
        end
    end

    function src:InvokeServer(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    function src:FireServer(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    function src:SendToServer(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    function src:CallServerAsync(...)
        local args = {...}
        src:CallServer(unpack(args))
    end

    src.instance = remote
	src._custom = true

    return src
end

function bedwars.Client:Get(remName, customTable, resRequired, blacklist)
    if cache[remName] then
        return cache[remName] 
    end
	blacklist = blacklist or {}
	if remName == bedwars.ProjectileRemote then
		--customTable = bedwars.Client:GetNamespace(bedwars.ProjectileRemote, {"OasisProjectileFire"})
		blacklist = {"OasisProjectileFired"}
	end
    local remotes = customTable or getRemotes({"ReplicatedStorage"})
    for _, v in pairs(remotes) do
        if v.Name == remName or string.find(v.Name, remName) and not table.find(blacklist, v.Name) then  
            local remote
            if not resRequired then
                remote = decorateRemote(v, {})
            else
                local tbl = {}
                function tbl:InvokeServer()
                    local tbl2 = {}
                    local res = v:InvokeServer()
                    function tbl2:andThen(func)
                        func(res)
                    end
                    return tbl2
                end
				tbl = decorateRemote(v, tbl)
                remote = tbl
            end
            
            cache[remName] = remote 
            return remote
        end
    end
    warn(debug.traceback("[bedwars.Client:Get]: Failure finding remote! Remote: " .. tostring(remName) .. " CustomTable: " .. tostring(customTable or "no table specified") .. " Using backup table..."))
    local backupTable = {}
    function backupTable:FireServer() return false end
    function backupTable:InvokeServer() return false end
    cache[remName] = backupTable
    return backupTable
end

function bedwars.Client:GetNamespace(nameSpace, blacklist)
    local cacheKey = nameSpace .. (blacklist and table.concat(blacklist, ",") or "")
    if namespaceCache[cacheKey] then
        return namespaceCache[cacheKey]
    end
    local remotes = getRemotes({"ReplicatedStorage"})
    local resolvedRemotes = {}
    blacklist = blacklist or {}
    for _, v in pairs(remotes) do
        if (v.Name == nameSpace or string.find(v.Name, nameSpace)) and not table.find(blacklist, v.Name) then
            table.insert(resolvedRemotes, v)
        end
    end
    local resolveFunctionTable = {Namespace = resolvedRemotes}
    function resolveFunctionTable:Get(remName)
        return bedwars.Client:Get(remName, resolvedRemotes)
    end
    namespaceCache[cacheKey] = resolveFunctionTable 
    return resolveFunctionTable
end

function bedwars.Client:WaitFor(remName)
	local tbl = {}
	function tbl:andThen(func)
		repeat task.wait() until bedwars.Client:Get(remName)
		func(bedwars.Client:Get(remName).instance.OnClientEvent)
	end
	return tbl
end
bedwars.ClientStoreHandler = {}
function bedwars.ClientStoreHandler:dispatch(tbl)
    --- pov u can't reverse engineer this function :skull:
end
bedwars.ItemHandler = {}
bedwars.ItemHandler.ItemMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ItemMeta.json"))
pcall(function() bedwars.QueueMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("QueueMeta.json")) end)
--decode(readfile("vape/CheatEngine/ItemMeta.json"))
bedwars.ItemHandler.getItemMeta = function(item)
    for i,v in pairs(bedwars.ItemHandler.ItemMeta) do
        if i == item then return v end
    end
    return nil
end
bedwars.ItemTable = bedwars.ItemHandler.ItemMeta.items
bedwars.ItemMeta = bedwars.ItemTable
bedwars.KitMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("KitMeta.json"))
--decode(readfile("vape/CheatEngine/KitMeta.json"))
bedwars.ProdAnimationsMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ProdAnimationsMeta.json"))
--decode(readfile('vape/CheatEngine/ProdAnimationsMeta.json'))
bedwars.AnimationTypeMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("AnimationTypeMeta.json"))
bedwars.AnimationType = bedwars.AnimationTypeMeta
--decode(readfile('vape/CheatEngine/AnimationTypeMeta.json'))
bedwars.AnimationController = {
	ProdAnimationsMeta = bedwars.ProdAnimationsMeta,
	AnimationTypeMeta = bedwars.AnimationTypeMeta
}
function bedwars.AnimationController:getAssetId(IndexId)
	return bedwars.AnimationController.ProdAnimationsMeta[IndexId]
end
bedwars.AnimationUtil = {}
function bedwars.AnimationUtil:playAnimation(plr, id)
    repeat task.wait() until plr.Character
    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then warn("[bedwars.AnimationUtil:playAnimation]: Humanoid not found in the character"); return end
    local animation = Instance.new("Animation")
    animation.AnimationId = id
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local animationTrack = animator:LoadAnimation(animation)
    animationTrack:Play()
    return animationTrack 
end
function bedwars.AnimationUtil:fetchAnimationIndexId(name)
	if not bedwars.AnimationController.AnimationTypeMeta[name] then return nil end
	for i,v in pairs(bedwars.AnimationController.AnimationTypeMeta) do
		if i == name then return v end
	end
	return nil
end
bedwars.GameAnimationUtil = {}
bedwars.GameAnimationUtil.playAnimation = function(plr, id)
	return bedwars.AnimationUtil:playAnimation(plr, bedwars.AnimationController:getAssetId(id))
end
bedwars.ViewmodelController = {}
function bedwars.ViewmodelController:playAnimation(id)
	return bedwars.AnimationUtil:playAnimation(game:GetService("Players").LocalPlayer, bedwars.AnimationController:getAssetId(id))
end
bedwars.BlockController = {}
function bedwars.BlockController:isBlockBreakable() return true end
function bedwars.BlockController:getBlockPosition(block, nearestBed)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
	local ignoreTable = bedwars.QueryUtil.queryIgnored
	if lplr.Character then
		table.insert(ignoreTable, lplr.Character)
	end
    RayParams.FilterDescendantsInstances = ignoreTable
    RayParams.IgnoreWater = true
    local RayRes = game.Workspace:Raycast(type(block) == "userdata" and block.Position or block + Vector3.new(0, 30, 0), Vector3.new(0, -35, 0), RayParams)
    local targetBlock
    if RayRes then
        targetBlock = RayRes.Instance or type(block) == "userdata" and black or nil	
		if RayRes.Instance ~= nil and RayRes.Instance:GetAttribute("NoBreak") and nearestBed ~= nil then
			targetBlock = nearestBed
		end	
        local function resolvePos(pos) return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3)) end
        return resolvePos(targetBlock.Position), targetBlock
    else
        return false
    end
end
function bedwars.BlockController:getBlockPosition2(position)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {game:GetService("Players").LocalPlayer.Character, game.Workspace.Camera}
    RayParams.IgnoreWater = true
    local startPosition = position + Vector3.new(0, 30, 0)
    local direction = Vector3.new(0, -35, 0)
    local RayRes = game.Workspace:Raycast(startPosition, direction, RayParams)
    if RayRes then
        local targetBlock = RayRes.Instance
        if targetBlock then
            local function resolvePos(pos)
                return Vector3.new(
                    math.round(pos.X / 3),
                    math.round(pos.Y / 3),
                    math.round(pos.Z / 3)
                )
            end
            return resolvePos(targetBlock.Position)
        end
    end
    return nil
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	if not blockmeta then return end
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(store.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end
function bedwars.BlockController:calculateBlockDamage(plr, posTbl)
	local tool = getBestTool(tostring(posTbl.block))
	if not tool then return 0 end
	local tooldmg = bedwars.ItemTable[tostring(tool.itemType)].breakBlock
	if table.find(tooldmg, tostring(tool)) then tooldmg = tooldmg[tostring(tool)] else
		for i,v in pairs(tooldmg) do tooldmg = v break end
	end
	return tooldmg
end
function bedwars.BlockController:getAnimationController()
	return bedwars.AnimationController
end
function bedwars.BlockController:resolveBreakPosition(pos)
	return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3))
end
function bedwars.BlockController:resolveRaycastResult(block)
	local RayParams = RaycastParams.new()
	RayParams.FilterType = Enum.RaycastFilterType.Exclude
	RayParams.FilterDescendantsInstances = {game:GetService("Players").LocalPlayer.Character}
	RayParams.IgnoreWater = true
	return game.Workspace:Raycast(block.Position + Vector3.new(0, 30, 0), Vector3.new(0, -35, 0), RayParams)
end
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end
local function getPlacedBlock(pos, strict)
    if not pos then 
        warn(debug.traceback("[getPlacedBlock]: pos is nil!")) 
        return nil 
    end

    local checkDistance = 1
    local regionSize = Vector3.new(0.1, 0.1, 0.1) 
    
    local nearbyParts = {}
    local directions = {
        Vector3.new(1, 0, 0),  
        Vector3.new(-1, 0, 0), 
        Vector3.new(0, 1, 0),  
        Vector3.new(0, -1, 0),  
        Vector3.new(0, 0, 1), 
        Vector3.new(0, 0, -1)  
    }
    
    local centerRegion = Region3.new(pos - regionSize/2, pos + regionSize/2)
    local centerParts = game.Workspace:FindPartsInRegion3(centerRegion, nil, math.huge)
    for _, part in pairs(centerParts) do
        if part and part.ClassName == "Part" and part.Parent then
			if bedwars.QueryUtil:isQueryIgnored(part) then continue end
            if strict then
                if part.Parent.Name == 'Blocks' and part.Parent.ClassName == "Folder" then
                    table.insert(nearbyParts, part)
                end
            else
                table.insert(nearbyParts, part)
            end
        end
    end
    
    for _, dir in pairs(directions) do
        local checkPos = pos + dir * checkDistance
        local region = Region3.new(checkPos - regionSize/2, checkPos + regionSize/2)
        local parts = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
        
        for _, part in pairs(parts) do
            if part and part.ClassName == "Part" and part.Parent then
				if bedwars.QueryUtil:isQueryIgnored(part) then continue end
                if strict then
                    if part.Parent.Name == 'Blocks' and part.Parent.ClassName == "Folder" then
                        table.insert(nearbyParts, part)
                    end
                else
                    table.insert(nearbyParts, part)
                end
            end
        end
    end
    
    if #nearbyParts > 0 then
        return nearbyParts[1]
    end
    return nil
end
VoidwareFunctions.GlobaliseObject("getPlacedBlock", getPlacedBlock)
function bedwars.BlockController:getStore()
	local tbl = {}
	function tbl:getBlockData(pos)
		return getPlacedBlock(pos)
	end
	function tbl:getBlockAt(pos)
		return getPlacedBlock(pos)
	end
	return tbl
end
local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end
local failedBreak = 0
bedwars.breakBlock = function(block, anim)
    if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled or lplr:GetAttribute("DenyBlockBreak") then return end
	if block.Name == "bed" and tostring(block:GetAttribute("TeamId")) == tostring(game:GetService("Players").LocalPlayer:GetAttribute("Team")) then return end
    local resolvedPos = bedwars.BlockController:getBlockPosition(block)
    if resolvedPos then
		local result = bedwars.Client:Get(bedwars.DamageBlockRemote):InvokeServer({
            blockRef = {
                blockPosition = resolvedPos
            },
            hitPosition = resolvedPos,
            hitNormal = resolvedPos
        })
		if result ~= "failed" then
			failedBreak = 0
			task.spawn(function()
				local animation
				if anim then
					local lplr = game:GetService("Players").LocalPlayer
					animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(bedwars.AnimationUtil:fetchAnimationIndexId("BREAK_BLOCK")))
					--bedwars.ViewmodelController:playAnimation(15)
				end
				task.wait(0.3)
				if animation ~= nil then
					animation:Stop()
					animation:Destroy()
				end
			end)
		else
			failedBreak = failedBreak + 1
		end
    end
end
local updateitem = Instance.new("BindableEvent")
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, newproxy(true))
	end
end))
local function encode(tbl)
    return game:GetService("HttpService"):JSONEncode(tbl)
end
local lplr = game:GetService("Players").LocalPlayer
local function corehotbarswitch(tool)
	local function findChild(name, className, children, nodebug)
		children = children:GetChildren()
        for i,v in pairs(children) do if v.Name == name and v.ClassName == className then return v end end
        local args = {Name = tostring(name), ClassName == tostring(className), Children = children}
		if not nodebug then
			--warn("[findChild]: CHILD NOT FOUND! Args: ", game:GetService("HttpService"):JSONEncode(args), name, className, children)
		end
        return nil
    end
	local function resolveHotbar()
		local hotbar
		hotbar = findChild("hotbar", "ScreenGui", lplr:WaitForChild("PlayerGui"))
		if not hotbar then return false end

		local _1 = findChild("1", "Frame", hotbar)
		if not _1 then return false end

		local ItemsHotbar = findChild("ItemsHotbar", "Frame", _1)
		if not ItemsHotbar then return false end

		return {
			hotbar = hotbar,
			items = ItemsHotbar
		}
	end
	local function resolveItemHotbar(hotbar)
		if tostring(hotbar) == "10" then return "blacklisted" end
		local res = {
			id = hotbar.Name,
			toolImage = "",
			toolAmount = 0,
			object = hotbar
		}
		if not tonumber(res.id) then return false end

		local _1 = findChild("1", "ImageButton", hotbar)
		if not _1 then return false end

		local __1 = findChild("1", "TextLabel", _1, true)
		if __1 then 
			res.toolAmount = tonumber(__1.Text) or nil
		end

		local _3 = findChild("3", "Frame", _1, true)
		if not _3 then return false end

		local ___1 = findChild("1", "ImageLabel", _3, true)
		if not ___1 then return false end
		res.toolImage = ___1.Image

		return res
	end
	local function resolveItemsHotbar(hotbar)
		local res = {}
		for i,v in pairs(hotbar:GetChildren()) do
			local rev = resolveItemHotbar(v)
			local name = tostring(v.Name)
			if rev and type(rev) == "table" then 
				if res[name] then warn("Duplication found! Overwriting... ["..name.."]") end
				res[name] = rev
			else
				if rev == "blacklisted" then continue end
				if res[name] then warn("Duplication found! Overwriting... ["..name.."]") end
				res[name] = {
					object = v
				}
			end
		end
		return res
	end
	local function findTool(items_rev, img)
		local res = {
			tool = nil,
			activated = nil
		}
		for i,v in pairs(items_rev) do
			if v.toolImage and tostring(v.toolImage) == tostring(img) then 
				res.tool = v
			end
			local img = findChild("1", "ImageButton", v.object)
			if img and img.Position ~= UDim2.new(0, 0, 0, 0) then
				res.activated = v
			end
		end
		return res
	end
	local function deactivatify(object)
		local img = findChild("1", "ImageButton", object)
		if img then
			img.Position = UDim2.new(0, 0, 0, 0)
			img.BorderColor3 = Color3.fromRGB(114, 127, 172)
			local text = findChild("1", "TextLabel", img)
			text.TextColor3 = Color3.fromRGB(255, 255, 255)
			text.BackgroundColor3 = Color3.fromRGB(114, 127, 172)
		end
	end
	local function activatify(object)
		local img = findChild("1", "ImageButton", object)
		if img then
			img.Position = UDim2.new(0, 0, -0.075, 0)
			img.BorderColor3 = Color3.fromRGB(255, 255, 255)
			local text = findChild("1", "TextLabel", img)
			text.TextColor3 = Color3.fromRGB(0, 0, 0)
			text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	task.spawn(function()
		local function run(func)
			local suc, err = pcall(function()
				func()
			end)
			if err then warn("[CoreSwitch Error]: "..tostring(debug.traceback(err))) end
		end
		run(function()
			if not lplr.Character then return false end

			if not tool then
				tool = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character:FindFirstChild('HandInvItem').Value or nil
			end
			if not tool then return false end
			tool = tostring(tool)

			local hotbar_rev = resolveHotbar()
			if not hotbar_rev then return false end

			local ItemsHotbar = hotbar_rev.items
			local items_rev = resolveItemsHotbar(ItemsHotbar)
			if not items_rev then return false end
		
			repeat task.wait() until (bedwars.ItemMeta ~= nil and type(bedwars.ItemMeta) == "table") or (bedwars.ItemTable ~= nil and type(bedwars.ItemTable) == "table")
			local meta = ((bedwars.ItemMeta and bedwars.ItemMeta[tool]) or (bedwars.ItemTable and bedwars.ItemTable[tool]))
			if ((not meta) or (meta ~= nil and (not meta.image))) then return false end

			local img = meta.image
			
			local tool_rev = findTool(items_rev, img)
			if ((not tool_rev) or ((tool_rev ~= nil) and (not tool_rev.tool))) then return false end
			local rev = {
				image = findChild("1", "ImageButton", tool_rev.tool.object)
			}
			if tool_rev.activated then 
				rev.activate = findChild("1", "ImageButton", tool_rev.activated.object)
			end
			if (not rev.image) then return false end

			if rev.activate then
				deactivatify(tool_rev.activated.object)
			end
			activatify(tool_rev.tool.object)
		end)	
	end)
end

local function coreswitch(tool, ignore)
    local character = lplr.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    if not ignore then
		local currentHandItem
		for _, acc in character:GetChildren() do
			if acc:IsA("Accessory") and acc:GetAttribute("InvItem") == true and acc:GetAttribute("ArmorSlot") == nil and acc:GetAttribute("IsBackpack") == nil then
				currentHandItem = acc
				break
			end
		end
		if currentHandItem then
			currentHandItem:Destroy()
		end
	
		for _, weld in pairs(character:GetDescendants()) do
			if weld:IsA("Weld") and weld.Name == "HandItemWeld" then
				weld:Destroy()
			end
		end
	
		local inventoryFolder = character:FindFirstChild("InventoryFolder")
		if not inventoryFolder or not inventoryFolder.Value then return end
		local toolInstance = inventoryFolder.Value:FindFirstChild(tool.Name)
		if not toolInstance then return end
		local clone = toolInstance:Clone()
	
		clone:SetAttribute("InvItem", true)
	
		humanoid:AddAccessory(clone)
	
		local handle = clone:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			local attachment = handle:FindFirstChildWhichIsA("Attachment")
			if attachment then
				local characterAttachment = character:FindFirstChild(attachment.Name, true)
				if characterAttachment and characterAttachment:IsA("Attachment") then
					local weld = Instance.new("Weld")
					weld.Name = "HandItemWeld"
					weld.Part0 = characterAttachment.Parent 
					weld.Part1 = handle
					weld.C0 = characterAttachment.CFrame
					weld.C1 = attachment.CFrame
					weld.Parent = handle
				end
			end
		end
	
		local handInvItem = character:FindFirstChild("HandInvItem")
		if handInvItem then
			handInvItem.Value = tool
		end
	end

	pcall(function()
		local res = bedwars.Client:Get(bedwars.EquipItemRemote):InvokeServer({hand = tool})
		if res ~= nil and res == true then
			local handInvItem = character:FindFirstChild("HandInvItem")
			if handInvItem then
				handInvItem.Value = tool
			end
		elseif string.find(string.lower(tostring(res)), 'promise') then
			res:andThen(function(res)
				if res == true then
					local handInvItem = character:FindFirstChild("HandInvItem")
					if handInvItem then
						handInvItem.Value = tool
					end
				end
			end)
		end
	end)

    return true
end

local function getItem(itemName, inv)
	for slot, item in pairs(inv or store.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end
VoidwareFunctions.GlobaliseObject("getItem", getItem)

local function switchItem(tool, delayTime)
	if tool ~= nil and type(tool) == "string" then
		tool = getItem(tool) and getItem(tool).tool
	end
	local _tool = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character:FindFirstChild('HandInvItem').Value or nil
	if _tool ~= nil and _tool ~= tool then
		coreswitch(tool, true)
		corehotbarswitch()
	end
end
VoidwareFunctions.GlobaliseObject("switchItem", switchItem)
local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		switchItem(tool.tool)
	end
end
bedwars.ClientDamageBlock = {}
function bedwars.ClientDamageBlock:Get(rem)
	local a = bedwars.Client:Get(bedwars.DamageBlockRemote)
	local tbl = {}
	function tbl:CallServerAsync(call)
		local res = a:InvokeServer(call)
		local tbl2 = {}
		function tbl2:andThen(func)
			func(res)
		end
		return tbl2
	end
	return tbl
end
function bedwars.ClientDamageBlock:WaitFor(remName)
	return bedwars.Client:WaitFor(remName)
end
local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local healthbarblocktable = {
	blockHealth = -1,
	breakingBlockPosition = Vector3.zero
}
local physicsUpdate = 1 / 60
local getBlockHealth = function() end
getBlockHealth = function(block, blockpos)
	return block:GetAttribute('Health')
end

local function getTool(breakType)
	local bestTool, bestToolSlot, bestToolDamage = nil, nil, 0
	for slot, item in store.localInventory.inventory.items do
		local toolMeta = bedwars.ItemTable[item.itemType].breakBlock
		if toolMeta then
			local toolDamage = toolMeta[breakType] or 0
			if toolDamage > bestToolDamage then
				bestTool, bestToolSlot, bestToolDamage = item, slot, toolDamage
			end
		end
	end
	return bestTool, bestToolSlot
end

local getBlockHits = function() end
getBlockHits = function(block, blockpos)
	if not block then return 0 end
	local suc, res = pcall(function()
		local breaktype = bedwars.ItemTable[block.Name] and bedwars.ItemTable[block.Name].block and bedwars.ItemTable[block.Name].block.breakType
		local tool = getTool(breaktype)
		tool = tool and bedwars.ItemTable[tool.itemType].breakBlock[breaktype] or 2
		return getBlockHealth(block, bedwars.BlockController:getBlockPosition(blockpos)) / tool
	end)
	return suc and res or 0
end

local cache = {}
local sides = {
    Vector3.new(3, 0, 0),  
    Vector3.new(-3, 0, 0),
    Vector3.new(0, 3, 0), 
    Vector3.new(0, -3, 0), 
    Vector3.new(0, 0, 3),  
    Vector3.new(0, 0, -3)
}
local calculatePath = function() end
calculatePath = function(target, blockpos)
	if cache[blockpos] then
		return unpack(cache[blockpos])
	end
	local visited, unvisited, distances, air, path = {}, {{0, blockpos}}, {[blockpos] = 0}, {}, {}
	local blocks = {}
	for _ = 1, 10000 do
		local _, node = next(unvisited)
		if not node then break end
		table.remove(unvisited, 1)
		visited[node[2]] = true
		for _, side in sides do
			side = node[2] + side
			if visited[side] then continue end
			local block = getPlacedBlock(side)
			if not block or block:GetAttribute('NoBreak') or block == target then
				if not block then
					air[node[2]] = true
				end
				continue
			end
			table.insert(blocks, block)
			local curdist = getBlockHits(block, side) + node[1]
			if curdist < (distances[side] or math.huge) then
				table.insert(unvisited, {curdist, side})
				distances[side] = curdist
				path[side] = node[2]
			end
		end
	end
	local pos, cost = nil, math.huge
	for node in air do
		if distances[node] < cost then
			pos, cost = node, distances[node]
		end
	end
	if pos then
		cache[blockpos] = { pos, cost, path, blocks }
		return pos, cost, path, blocks
	end
end

local getPickaxe = function() end

local function run(func)
	local suc, err = pcall(function()
		func()
	end)
	if err then warn("[CE687224481.lua Module Error]: "..tostring(debug.traceback(err))) end
end

run(function()
    local VisualizerHighlight = nil
    local LastBlock = nil
    local VisualizerTimeout = 1
    local LastBreakTime = 0
    local IsBreaking = false

    local function updateVisualizer(block, isBreaking)
        local currentTime = tick()

        if not isBreaking and not block then
            if VisualizerHighlight then
                VisualizerHighlight:Destroy()
                VisualizerHighlight = nil
            end
            LastBlock = nil
            LastBreakTime = 0
            IsBreaking = false
            return
        end

        if block then
            local blockKey = tostring(block.Position) 

            if blockKey ~= LastBlock or not VisualizerHighlight or not VisualizerHighlight.Parent then
                if VisualizerHighlight then
                    VisualizerHighlight:Destroy()
                end

                VisualizerHighlight = Instance.new("Highlight")
                VisualizerHighlight.Adornee = block
                VisualizerHighlight.FillTransparency = 1
                VisualizerHighlight.OutlineTransparency = 0.3 
                VisualizerHighlight.Parent = workspace

                VisualizerHighlight.OutlineColor = (blockKey ~= LastBlock) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
                LastBlock = blockKey
            end

            IsBreaking = isBreaking
            LastBreakTime = currentTime

            task.spawn(function()
                while VisualizerHighlight and VisualizerHighlight.Parent and (tick() - LastBreakTime < VisualizerTimeout) and IsBreaking do
                    task.wait(0.1)
                end
                if VisualizerHighlight and VisualizerHighlight.Parent then
                    VisualizerHighlight:Destroy()
                    VisualizerHighlight = nil
                    LastBlock = nil
                    IsBreaking = false
                end
            end)
        end
    end

    bedwars.breakBlock2 = function(block, anim)
        if lplr:GetAttribute('DenyBlockBreak') or not entitylib.isAlive or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
            print('exit 1') 
            updateVisualizer(nil, false)
            return 
        end
        
        local cost, pos, target, path, blocks = math.huge, nil, nil, nil, {}

        for _, v in ({block.Position / 3}) do
            local dpos, dcost, dpath, dblocks = calculatePath(block, v * 3)
            if dpos and dcost < cost then
                cost, pos, target, path = dcost, dpos, v * 3, dpath
                blocks = dblocks
            end
        end

        if pos then
            entitylib.character.HumanoidRootPart = entitylib.character.HumanoidRootPart
            if (entitylib.character.HumanoidRootPart.Position - pos).Magnitude > 30 then 
                updateVisualizer(nil, false)
                return 
            end
            local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
            local dblock, dpos = bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
            if not dblock then dblock = blocks[1] end

            if (game.Workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.4 then
                local tool
                if dblock and bedwars.ItemTable[dblock.Name] then
                    local breaktype = bedwars.ItemTable[dblock.Name].block.breakType
                    tool = getTool(breaktype)
                else
                    tool = getPickaxe()
                end
                if tool then
                    switchItem(tool.tool)
                end
            end

            updateVisualizer(block, true)

            local result = bedwars.Client:Get(bedwars.DamageBlockRemote):InvokeServer({
                blockRef = {blockPosition = dpos},
                hitPosition = pos,
                hitNormal = Vector3.FromNormalId(Enum.NormalId.Right)
            })
            print(dblock, dpos, pos, result)

            if result then
                if result == 'cancelled' then
                    store.damageBlockFail = tick() + 1
                    print('exit 4')
                    updateVisualizer(nil, false) 
                    return
                elseif result == 'destroyed' then
                    updateVisualizer(nil, false)
                end

                if anim then
                    local animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
                    bedwars.ViewmodelController:playAnimation(15)
                    task.wait(0.3)
                    animation:Stop()
                    animation:Destroy()
                end
            end

            return pos, path, target
        else 
            print('exit 2') 
            updateVisualizer(nil, false)
        end
    end
end)
bedwars.placeBlock = function(pos, blockName)
	--if (not isBlockCovered(Vector3.new(pos.X/3, pos.Y/3, pos.Z/3))) then
		bedwars.Client:GetNamespace("PlaceBlock", {"PlaceBlockEvent", "DefenderRequestPlaceBlock"}):Get("PlaceBlock"):InvokeServer({
			["blockType"] = blockName,
			["position"] = Vector3.new(pos.X/3, pos.Y/3, pos.Z/3),
			["blockData"] = 0
		})
	--end
end
bedwars.getIcon = function(item, showinv)
	local itemmeta = bedwars.ItemTable[item.itemType]
	if itemmeta and showinv then
		return itemmeta.image or ""
	end
	return ""
end
bedwars.getInventory = function(plr)
	local inv = {
		items = {},
		armor = {}
	}
	local repInv = plr.Character and plr.Character:FindFirstChild("InventoryFolder") and plr.Character:FindFirstChild("InventoryFolder").Value
	if repInv then
		if repInv.ClassName and repInv.ClassName == "Folder" then
			for i,v in pairs(repInv:GetChildren()) do
				if not v:GetAttribute("CustomSpawned") then
					table.insert(inv.items, {
						tool = v,
						itemType = tostring(v),
						amount = v:GetAttribute("Amount")
					})
				end
			end
		end
	end
	local plrInvTbl = {
		"ArmorInvItem_0",
		"ArmorInvItem_1",
		"ArmorInvItem_2"
	}
	local function allowed(char)
		local state = true
		for i,v in pairs(plrInvTbl) do if (not char:FindFirstChild(v)) then state = false end end
		return state
	end
	local plrInv = plr.Character and allowed(plr.Character)
	if plrInv then
		for i,v in pairs(plrInvTbl) do
			table.insert(inv.armor, tostring(plr.Character:FindFirstChild(v).Value) == "" and "empty" or tostring(plr.Character:FindFirstChild(v).Value) ~= "" and {
				tool = v,
				itemType = tostring(plr.Character:FindFirstChild(v).Value)
			})
		end
	end
	return inv
end
bedwars.getKit = function(plr)
	return plr:GetAttribute("PlayingAsKits") or "none"
end
bedwars.QueueController = {}
function bedwars.QueueController:leaveParty()
    bedwars.Client:Get("LeaveParty"):InvokeServer()
end
function bedwars.QueueController:joinQueue(queueType)
    bedwars.Client:Get("joinQueue"):FireServer({["queueType"] = queueType})
end
bedwars.InfernalShieldController = {}
function bedwars.InfernalShieldController:raiseShield()
    bedwars.Client:Get("UseInfernalShield"):FireServer({["raised"] = true})
end
bedwars.SwordController = {
    lastSwing = tick(),
	lastAttack = game.Workspace:GetServerTimeNow()
}
bedwars.SwordController.isClickingTooFast = function() end
function bedwars.SwordController:canSee() return true end
-- bedwars.SwordController:playSwordEffect(swordmeta, false)
function bedwars.SwordController:playSwordEffect(swordmeta, status)
	task.spawn(function()
		local animation
		local animName = swordmeta.displayName:find(" Scythe") and "SCYTHE_SWING" or "SWORD_SWING"
		local animCooldown = swordmeta.displayName:find(" Scythe") and 0.3 or 0.15
		local lplr = game:GetService("Players").LocalPlayer
		animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(bedwars.AnimationUtil:fetchAnimationIndexId(animName)))
		task.wait(animCooldown)
		if animation ~= nil then animation:Stop(); animation:Destroy() end
	end)
end
function bedwars.SwordController:swingSwordAtMouse()
	pcall(function() return bedwars.Client:Get("SwordSwingMiss"):FireServer({["weapon"] = store.localHand.tool, ["chargeRatio"] = 0}) end)
end
bedwars.ScytheController = {}
function bedwars.ScytheController:playLocalAnimation() -- kinda useless but eh 
	task.spawn(function()
		local animation
		local lplr = game:GetService("Players").LocalPlayer
		animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(bedwars.AnimationUtil:fetchAnimationIndexId("SCYTHE_SWING")))
		task.wait(0.3)
		if animation ~= nil then
			animation:Stop()
			animation:Destroy()
		end
	end)
end
bedwars.SettingsController = {}
function bedwars.SettingsController:setFOV(num)
	gameCamera.FieldOfView = num
end
bedwars.AppController = {}
function bedwars.AppController:isAppOpen(appName)
	return game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild(appName)
end
bedwars.KillEffectMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("KillEffectMeta.json"))
--decode(readfile('vape/CheatEngine/KillEffectMeta.json'))
bedwars.BalloonController = {}
function bedwars.BalloonController:inflateBalloon()
	bedwars.Client:Get("InflateBalloon"):FireServer()
end
bedwars.SoundList = decode(VoidwareFunctions.fetchCheatEngineSupportFile("SoundListMeta.json"))
--decode(readfile('vape/CheatEngine/SoundListMeta.json'))
bedwars.SoundManager = {}
function bedwars.SoundManager:playSound(soundId)
	local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = game.Workspace
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end
bedwars.QueryUtil = {
	queryIgnored = {},
	setQueryIgnored = function(self, object, status)
		if status == nil then status = true end
		if status == true then table.insert(self.queryIgnored, object) else 
			local index = table.find(self.queryIgnored, object) 
			if index then table.remove(self.queryIgnored, index) end
		end
		object:SetAttribute("gamecore_GameQueryIgnore", status)
	end,
	isQueryIgnored = function(self, object)
		return object:GetAttribute("gamecore_GameQueryIgnore")
	end
}
bedwars.MatchController = {
	fetchPlayerTeam = function(self, plr)
		return tostring(plr.Team)
	end,
	fetchGameTime = function(self)
		local time, timeTable, suc = 0, {seconds = 0, minutes = 0}, false
		local window = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TopBarAppGui")
		if window then
			local frame = window:FindFirstChild("TopBarApp")
			if frame then
				for i,v in pairs(frame:GetChildren()) do
					if v.ClassName == "Frame" and v:FindFirstChild("4") and v:FindFirstChild("5") then
						if v:FindFirstChild("4").ClassName == "ImageLabel" and v:FindFirstChild("5").ClassName == "TextLabel" then
							time, timeTable, suc = extractTime(v:FindFirstChild("5").Text):toSeconds(), {
								seconds = extractTime(v:FindFirstChild("5").Text).seconds,
								minutes = extractTime(v:FindFirstChild("5").Text).minutes
							}, true
							break
						end
					end
				end
			end
		end
		return time, timeTable, suc
	end
}
local lastTime, timeMoving = 0, true
task.spawn(function()
	repeat 
		local time, timeTable, suc = bedwars.MatchController:fetchGameTime()
		if time == lastTime then timeMoving = false else timeMoving = true end
		lastTime = time
		--warn("Checked time! ", time == lastTime, timeMoving)
		task.wait(2)
	until (not shared.VapeExecuted)
end)
function bedwars.MatchController:fetchMatchState()
	local matchState = 0

	local time, timeTable, suc
	--repeat time, timeTable, suc = bedwars.MatchController:fetchGameTime() until suc 
	time, timeTable, suc = bedwars.MatchController:fetchGameTime()
	if (not suc) then time, timeTable, suc = bedwars.MatchController:fetchGameTime() end
	local plrTeam = bedwars.MatchController:fetchPlayerTeam(game:GetService("Players").LocalPlayer)

	if time > 0 then matchState = plrTeam == "Spectators" and 2 or 1 else matchState = 0 end
	if (not timeMoving) and time > 0 then matchState = 2 end

	if (not suc) then warn("[bedwars.MatchController:fetchMatchState]: Failure getting valid time!"); matchState = 1 end

	--print(matchState, time, encode(timeTable), suc, plrTeam)

	return matchState
end
bedwars.RavenController = {}
function bedwars.RavenController:detonateRaven()
	bedwars.Client:Get("DetonateRaven"):InvokeServer()
end
bedwars.DefaultKillEffect = {}
bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
	--- :shrug:
end
vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
	local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
	local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
	bedwars.DefaultKillEffect.onKill(nil, nil, killed, nil)
end)
bedwars.CooldownController = {}
local cooldownTable = {}
function cooldownTable:fetchIndexes()
	local indexes = {}
	for i,v in pairs(cooldownTable) do if type(v) ~= "function" then table.insert(indexes, v) end end
	return indexes
end
function cooldownTable:fetchItemIndex(item)
	local itemIndex
	for i,v in pairs(cooldownTable:fetchIndexes()) do if v.item == item then itemIndex = i end break end
	if (not itemIndex) then warn("[cooldownTable:fetchItemIndex]: FAILURE! itemIndex for "..tostring(item).." not found!"); return nil end
	return itemIndex
end
function cooldownTable:revokeCooldownAction(item)
	local itemIndex = cooldownTable:fetchItemIndex(item)
	if (not itemIndex) then warn("[cooldownTable:revokeCooldownAction]: Failure! Item: "..tostring(item)); return end
	cooldownTable[itemIndex].canceled = true
end
function cooldownTable:activateCooldownAction(item)
	local itemIndex = cooldownTable:fetchItemIndex(item)
	if (not itemIndex) then warn("[cooldownTable:activateCooldownAction]: Failure! Item: "..tostring(item)); return end
	task.spawn(function()
		repeat
			cooldownTable[itemIndex].cooldown = cooldownTable[itemIndex].cooldown - 0.1
			task.wait(0.1)
		until cooldownTable[itemIndex].cooldown == 0 or cooldownTable[itemIndex].cooldown < 0 or cooldownTable[itemIndex].canceled
		cooldownTable[itemIndex].cooldown = 0
		cooldownTable[itemIndex] = nil
	end)
end
function cooldownTable:registerCooldownItem(item, cooldown)
	cooldownTable[tostring(game:GetService("HttpService"):GenerateGUID(false))] = {["item"] = item, ["cooldown"] = cooldown, ["canceled"] = false} 
end
bedwars.CooldownController.CooldownTable = cooldownTable
function bedwars.CooldownController:setOnCooldown(item, cooldown)
	cooldownTable:registerCooldownItem(item, cooldown)
	cooldownTable:activateCooldownAction(item)
end
function bedwars.CooldownController:getRemainingCooldown(item)
	local itemIndex = cooldownTable:fetchItemIndex(item)
	if (not itemIndex) then cooldownTable:registerCooldownItem(item, 0) return 0 end
	return cooldownTable[itemIndex].cooldown
end
bedwars.AbilityController = {}
function bedwars.AbilityController:canUseAbility(ability) return true end -- no reverse engineering possible :(
function bedwars.AbilityController:useAbility(ability, ...)
	local args = {...}
	bedwars.Client:Get("useAbility"):FireServer(ability, unpack(args))
end
bedwars.ShopItemsMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ShopItemsMeta.json"))
--decode(readfile('vape/CheatEngine/ShopItemsMeta.json'))
bedwars.ShopItems = bedwars.ShopItemsMeta.ShopItems
local bowConstants = {}
local function getBowConstants()
	--[[local suc, err = pcall(function()
		repeat task.wait() until entityLibrary.character.HumanoidRootPart
		local characterPosition = entityLibrary.character.HumanoidRootPart.Position
		targetPosition = Vector3.new(0, -60, 0) -- :)
	
		local relX = (0 - characterPosition.X) * 0.1 
		local relY = (-60 - characterPosition.Y) * 0.05
		local relZ = (0 - characterPosition.Z) * 0.1
	
		return {
			RelX = relX,
			RelY = relY,
			RelZ = relZ
		}
	end)
	return suc and err or {RelX = 0, RelY = 0, RelZ = 0}--]]
	return {
		RelZ = 0,
		RelX = 0.8,
		RelY = -0.6,
		CameraMultiplier = 10,
		BeamGrowthMultiplier = 0.08
	}
end
bowConstants = getBowConstants()
bedwars.BowConstantsTable = bowConstants
bedwars.ProjectileMeta = decode(VoidwareFunctions.fetchCheatEngineSupportFile("ProjectileMeta.json"))
--decode(readfile('vape/CheatEngine/ProjectileMeta.json'))
bedwars.ProjectileUtil = {}
function bedwars.ProjectileUtil:createProjectile(p15, p16, p17, p18)
	local l__Projectiles__19, l__ProjectileMeta__5, l__Workspace__3, l__CollectionService__12 = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Projectiles"), bedwars.ProjectileMeta, game.Workspace, collectionService
	local u20 = nil;
	u20 = function(p19)
		return "projectile:" .. tostring(p19);
	end;
	local v68 = l__ProjectileMeta__5[p16].projectileModel;
	if v68 == nil then
		v68 = p16;
	end;
	local v69 = l__Projectiles__19:WaitForChild(v68);
	assert(v69, "Projectile model for projectile " .. p16 .. " can't be found.");
	local v70 = v69:Clone();
	assert(v70.PrimaryPart, "Primary part missing on projectile " .. v70.Name);
	v70.Name = p16;
	if p18 == nil then
		return nil;
	end;
	v70:SetPrimaryPartCFrame(p18);
	v70.Parent = l__Workspace__3;
	v70:SetAttribute("ProjectileShooter", p15.UserId);
	l__CollectionService__12:AddTag(v70, u20(p15.UserId));
	return v70;
end
function bedwars.ProjectileUtil.setupProjectileConstantOrientation(p22, p23)
	local l__ProjectileMeta__5, l__Players__9 = bedwars.ProjectileMeta, game:GetService("Players")
	local v76 = l__ProjectileMeta__5[p22.Name];
	if v76.useServerModel and p23 ~= l__Players__9.LocalPlayer then
		return v75;
	end;
	return v75;
end
bedwars.ProjectileController = {}
function bedwars.ProjectileController:createLocalProjectile(p29, p30, p31, p32, p33, p34, p35, p36)
	local l__ProjectileMeta__18, l__ProjectileUtil__20, l__Players__10 = bedwars.ProjectileMeta, bedwars.ProjectileUtil, game:GetService("Players")
	local v40 = l__ProjectileMeta__18[p31];
	local v41 = l__ProjectileUtil__20.createProjectile(l__Players__10.LocalPlayer, p30, p31, (l__Players__10.LocalPlayer.Character:GetPrimaryPartCFrame()));
	if not v41 or not (not v40.useServerModel) then
		return;
	end;
	l__ProjectileUtil__20.setupProjectileConstantOrientation(v41, l__Players__10.LocalPlayer);
	local v42 = 1;
	local v43 = p36;
	if v43 ~= nil then
		v43 = v43.drawDurationSeconds;
	end;
	local v44 = v43 ~= nil;
	p30 = bedwars.ItemTable[p31]
	if v44 then
		local v45 = p30;
		if v45 ~= nil then
			v45 = v45.maxStrengthChargeSec;
		end;
		v44 = v45;
	end;
	if v44 ~= 0 and v44 == v44 and v44 then
		v42 = math.clamp(p36.drawDurationSeconds / p30.maxStrengthChargeSec, 0, 1);
	end;
	local v46 = v40.gravitationalAcceleration;
	if v46 == nil then
		v46 = 196.2;
	end;
	local v47 = {};
	local v48 = p30;
	if v48 ~= nil then
		v48 = v48.relativeOverride;
	end;
	v47.relative = v48;
	v47.projectileSource = p30;
	v47.drawPercent = v42;
	return v41;
end
bedwars.MageKitUtil = {}
bedwars.MageKitUtil.MageElementVisualizations = decode(VoidwareFunctions.fetchCheatEngineSupportFile("MageKitUtileMeta.json")).MageElementMeta
--decode(readfile('vape/CheatEngine/MageKitUtileMeta.json')).MageElementMeta
bedwars.BalanceFile = decode(VoidwareFunctions.fetchCheatEngineSupportFile("BalanceFireMeta.json"))
--decode(readfile('vape/CheatEngine/BalanceFireMeta.json'))
bedwars.MageController = {}
bedwars.FishermanController = {}
bedwars.FishermanController.startMinigame = function() end
bedwars.DragonSlayerController = {}
function bedwars.DragonSlayerController:playPunchAnimation(animPos)
	return bedwars.GameAnimationUtil.playAnimation(game:GetService("Players").LocalPlayer, bedwars.AnimationType.DRAGON_SLAYER_PUNCH)
end
function bedwars.DragonSlayerController:fetchDragonEmblems()
	return game.Workspace:FindFirstChild("DragonEmblems") and game.Workspace:FindFirstChild("DragonEmblems").ClassName and game.Workspace:FindFirstChild("DragonEmblems").ClassName == "Folder" and game.Workspace:FindFirstChild("DragonEmblems"):GetChildren() or {}
end
bedwars.DragonSlayerController.emblemCache = {}
function bedwars.DragonSlayerController:fetchDragonEmblemData(emblem)
    --[[if self.emblemCache[emblem] then
        return self.emblemCache[emblem] 
    end--]]
    local c = emblem and emblem.Parent and emblem.ClassName and emblem.ClassName == "Model" and emblem:GetChildren() or {}
    local cn = #c
    local tbl = {
        stackCount = 0,
        CFrame = emblem:GetPrimaryPartCFrame()
    }
    if cn == 3 then
        for i, v in pairs(c) do
            if v.Parent and v.ClassName and v.ClassName == "MeshPart" then
                if tostring(v.BrickColor) == "Persimmon" then
                    tbl.stackCount = tbl.stackCount + 1
                end
            end
        end
    end
    self.emblemCache[emblem] = tbl
    return tbl
end
function bedwars.DragonSlayerController:deleteEmblem(emblem) 
	pcall(function() emblem:Destroy() end)
end
function bedwars.DragonSlayerController:resolveTarget(emblemCFrame)
	local target
	local maxDistance = 5
	for i, v in pairs(game.Workspace:GetChildren()) do
		if v and v.Parent and v.ClassName == "Model" and #v:GetChildren() > 0 and v.PrimaryPart then
			local distance = (v:GetPrimaryPartCFrame().Position - emblemCFrame.Position).Magnitude
			if distance <= maxDistance then target = v break end
		end
	end
	return target
end
bedwars.GrimReaperController = {}
function bedwars.GrimReaperController:fetchSoulsByPosition()
	local souls = {}
	for i,v in pairs(game.Workspace:GetChildren()) do
		if v and v.Parent and v.ClassName and v.ClassName == "Model" and v.Name == "GrimReaperSoul" and v:FindFirstChild("GrimSoul") then
			table.insert(souls, v)
		end
	end
	return souls
end
bedwars.SpiritAssassinController = {}
function bedwars.SpiritAssassinController:fetchSpiritOrbs()
	local orbs = {}
	for i,v in pairs(game.Workspace:GetChildren()) do
		if v.Name == "SpiritOrb" and v.ClassName == "Model" and v:GetAttribute("SpiritSecret") then
			table.insert(orbs, v)
		end
	end
	return orbs
end
function bedwars.SpiritAssassinController:activateOrb(orb)
	bedwars.Client:GetNamespace("UseSpirit", {"SpiritAssassinWinEffectUseSpirit", "SpiritAssassinUseSpirit"}):Get("UseSpirit"):InvokeServer({["secret"] = tostring(orb:GetAttribute("SpiritSecret"))})
end
function bedwars.SpiritAssassinController:Invoke()
	for i,v in pairs(self:fetchSpiritOrbs()) do self:activateOrb(v) end
end
bedwars.WarlockController = {cooldown = 3, last = 0}
function bedwars.WarlockController:link(target)
	if target then
		local current = tick()
		if current - self.last < self.cooldown then return end
		self.last = current
		return bedwars.Client:Get("WarlockLinkTarget"):InvokeServer({["target"] = target})
	else return nil end
end
bedwars.EmberController = {}
function bedwars.EmberController:BladeRelease(blade)
	if blade then
		return bedwars.Client:Get('HellBladeRelease'):FireServer({chargeTime = 1, player = lplr, weapon = blade})
	else return nil end
end
bedwars.KaidaController = {}
function bedwars.KaidaController:request(target)
	--if shared.vapewhitelist.localprio > 0 then
		if target then 
			return bedwars.Client:Get("SummonerClawAttackRequest"):FireServer({["clientTime"] = tick(), ["direction"] = (target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position - lplr.Character.HumanoidRootPart.Position).unit, ["position"] = target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position})
		else return nil end
	--end
end
bedwars.DaoController = {chargingMaid = nil}

local CustomRoact = {}
local function createElement(elementType, props, children)
    local element = {Type = elementType, Props = props or {}, Children = children or {}}
    if props and props[CustomRoact.Ref] then
        element.Ref = props[CustomRoact.Ref]
        props[CustomRoact.Ref] = nil
    end
    return element
end
CustomRoact.createElement = createElement

function CustomRoact.Ref()
    local ref = {Value = nil}
    function ref:getValue()
        return self.Value
    end
    return ref
end

local function applyProps(instance, props)
    for prop, value in next, props do
        if prop ~= "Parent" and prop ~= "Adornee" then
            instance[prop] = value
        end
    end
    if props.Adornee then
        instance.Adornee = props.Adornee
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
end

local function createInstanceFromElement(element)
    local instance
    if element.Type == "BillboardGui" then
        instance = Instance.new("BillboardGui")
    elseif element.Type == "Frame" then
        instance = Instance.new("Frame")
    elseif element.Type == "UICorner" then
        instance = Instance.new("UICorner")
    elseif element.Type == "ImageLabel" then
        instance = Instance.new("ImageLabel")
    elseif element.Type == "TextLabel" then
        instance = Instance.new("TextLabel")
    else
        return nil
    end
    applyProps(instance, element.Props)
    if element.Ref then
        element.Ref.Value = instance
    end
    for _, child in next, element.Children do
        local childInstance = createInstanceFromElement(child)
        if childInstance then
            childInstance.Parent = instance
        end
    end
    return instance
end

function CustomRoact.mount(element, parent)
    local instance = createInstanceFromElement(element)
    if instance then
        instance.Parent = parent
    end
    return {Instance = instance}
end

function CustomRoact.unmount(mounted)
    if mounted and mounted.Instance then
        mounted.Instance:Destroy()
    end
end

bedwars.Roact = CustomRoact

local CustomPromise = {}
function CustomPromise.new(executor)
    local promise = {Status = "Pending", Callbacks = {}}
    function promise:andThen(callback)
        if self.Status == "Fulfilled" then
            task.spawn(callback)
        elseif self.Status == "Pending" then
            table.insert(self.Callbacks, callback)
        end
        return self
    end
    local function resolve()
        if promise.Status == "Pending" then
            promise.Status = "Fulfilled"
            for _, callback in next, promise.Callbacks do
                task.spawn(callback)
            end
            promise.Callbacks = {}
        end
    end
    task.spawn(function()
        pcall(function() executor(resolve) end)
    end)
    return promise
end

function CustomPromise.delay(seconds)
    return CustomPromise.new(function(resolve)
        task.wait(seconds)
        resolve()
    end)
end

bedwars.RuntimeLib = bedwars.RuntimeLib or {}
bedwars.RuntimeLib.Promise = CustomPromise

bedwars.StoreController = {}
function bedwars.StoreController:fetchLocalHand()
	repeat task.wait() until game:GetService("Players").LocalPlayer.Character
	return game:GetService("Players").LocalPlayer.Character:FindFirstChild("HandInvItem")
end
function bedwars.StoreController:updateLocalInventory()
	store.localInventory.inventory = bedwars.getInventory(game:GetService("Players").LocalPlayer)
	store.inventory = store.localInventory
end
function bedwars.StoreController:updateEquippedKit()
	store.equippedKit = bedwars.getKit(game:GetService("Players").LocalPlayer)
end
function bedwars.StoreController:updateMatchState()
	store.matchState = bedwars.MatchController:fetchMatchState()
end
function bedwars.StoreController:updateBowConstantsTable(targetPos)
	bedwars.BowConstantsTable = getBowConstants(targetPos)
end
function bedwars.StoreController:updateStoreBlocks()
	store.blocks = collectionService:GetTagged("block")
end
function bedwars.StoreController:updateZephyrOrb()
	if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen") and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud") and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect") and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack") and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack").ClassName and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack").ClassName == "TextLabel" then store.zephyrOrb = tonumber(game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("StatusEffectHudScreen"):FindFirstChild("StatusEffectHud"):FindFirstChild("WindWalkerEffect"):FindFirstChild("EffectStack").Text) end
end
function bedwars.StoreController:updateLocalHand()
	local currentHand = bedwars.StoreController:fetchLocalHand()
	if (not currentHand) then store.localHand = {} return end
	local handType = ""
	if currentHand and currentHand.Value and currentHand.Value ~= "" then
		local handData = bedwars.ItemTable[tostring(currentHand.Value)]
		handType = handData.sword and "sword" or handData.block and "block" or tostring(currentHand.Value):find("bow") and "bow"
	end
	store.localHand = {tool = currentHand and currentHand.Value, itemType = currentHand and currentHand.Value and tostring(currentHand.Value) or "", Type = handType, amount = currentHand and currentHand:GetAttribute("Amount") and type(currentHand:GetAttribute("Amount")) == "number" or 0}
	store.localHand.toolType = store.localHand.Type
	store.hand = store.localHand
end
VoidwareFunctions.GlobaliseObject("StoreTable", {})
function bedwars.StoreController:executeStoreTable()
	for i,v in pairs(shared.StoreTable) do
		if type(v) == "function" then task.spawn(function() pcall(function() v() end) end) end
	end
end
--[[local UpdateIndexes = {}
function bedwars.StoreController:registerUpdateIndex(func, cooldown)
	table.insert(updateIndexes, {
		Function = func,
		WaitTime = cooldown
	})
end
bedwars.StoreController:registerUpdateIndex(function() bedwars.StoreController:updateLocalHand() end, 0.1)
bedwars.StoreController:registerUpdateIndex(function() bedwars.StoreController:updateLocalInventory() end, 0.1)
bedwars.StoreController:registerUpdateIndex(function() bedwars.StoreController:updateEquippedKit() end, 0.5)
bedwars.StoreController:registerUpdateIndex(function() bedwars.StoreController:updateMatchState() end, 0.1)
bedwars.StoreController:registerUpdateIndex(function() bedwars.StoreController:updateStoreBlocks() end, 1)
bedwars.StoreController:registerUpdateIndex(function() bedwars.StoreController:executeStoreTable() end, 0.5)
bedwars.StoreController:registerUpdateIndex(function() if store.equippedKit == "wind_walker" then bedwars.StoreController:updateZephyrOrbe() end end, 0.5)--]]

function bedwars.StoreController:updateQueueType()
	local att = game:GetService("Workspace"):GetAttribute("QueueType")
	if att then
		store.queueType = att
	end
end

function bedwars.StoreController:updateStore()
	task.spawn(function() pcall(function() self:updateLocalHand() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateLocalInventory() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateEquippedKit() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateMatchState() end) end)
	task.wait(0.1)
	task.spawn(function() pcall(function() self:updateStoreBlocks() end) end)
	task.wait(0.1)
	if store.equippedKit == "wind_walker" then
		task.wait(0.1)
		task.spawn(function() pcall(function() self:updateZephyrOrb() end) end)
	end
	if store.queueType == "bedwars_test" then
		task.spawn(function() pcall(function() self:updateQueueType() end) end)
	end
end

pcall(function() bedwars.StoreController:updateStore() end)

for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do
	bedwars.Client:WaitFor(v):andThen(function(connection)
		table.insert(vapeConnections, connection:Connect(function(...)
			vapeEvents[v]:Fire(...)
		end))
	end)
end
for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do
	bedwars.ClientDamageBlock:WaitFor(v):andThen(function(connection)
		table.insert(vapeConnections, connection:Connect(function(...)
			vapeEvents[v]:Fire(...)
		end))
	end)
end
VoidwareFunctions.GlobaliseObject("vapeEvents", vapeEvents)
table.insert(shared.StoreTable, function()
	VoidwareFunctions.GlobaliseObject("vapeEvents", vapeEvents)
end)

store.blockRaycast.FilterType = Enum.RaycastFilterType.Include
store.blocks = collectionService:GetTagged("block")
store.blockRaycast.FilterDescendantsInstances = {store.blocks}
table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
	table.insert(store.blocks, block)
	store.blockRaycast.FilterDescendantsInstances = {store.blocks}
end))
table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
	local index = table.find(store.blocks, block)
	if index then
		table.remove(store.blocks, index)
		store.blockRaycast.FilterDescendantsInstances = {store.blocks}
	end
end))
local AutoLeave = {Enabled = false}

task.spawn(function()
	repeat
		task.spawn(function() bedwars.StoreController:updateStore() end)
		task.wait(0.2)
	until (not shared.VapeExecuted)
end)

table.insert(vapeConnections, game.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = game.Workspace.CurrentCamera or game.Workspace:FindFirstChildWhichIsA("gameCamera")
end))
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
--ME WHEN THE MOBILE EXPLOITS ADD A DISFUNCTIONAL ISNETWORKOWNER (its for compatability I swear!!)
local isnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
VoidwareFunctions.GlobaliseObject("isnetworkowner", isnetworkowner)
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			task.wait(0.1)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
		if suc and req then
			writefile(path, req)
		else
			return ""
		end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path]
end

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function run(func)
	local suc, err = pcall(function()
		func()
	end)
	if err then warn("[CE687224481.lua Module Error]: "..tostring(debug.traceback(err))) end
end

local function isFriend(plr, recolor)
	if shared.RiseMode then return false end
	if GuiLibrary.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	if shared.RiseMode then return false end
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr) return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField") end
VoidwareFunctions.GlobaliseObject("isVulnarable", isVulnarable)

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do
		if velocityCheck then
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = game.Workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), store.blockRaycast)
		if floorDetection then
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local whitelist = shared.vapewhitelist
local RunLoops = shared.RunLoops

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

local function getItem(itemName, inv)
	for slot, item in pairs(inv or store.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end
VoidwareFunctions.GlobaliseObject("getItem", getItem)

local cache = {}
local function getItemNear(itemName, inv)
    inv = inv or store.localInventory.inventory.items
    if cache[itemName] then
        local cachedItem, cachedSlot = cache[itemName].item, cache[itemName].slot
        if inv[cachedSlot] and inv[cachedSlot].itemType == cachedItem.itemType then
            return cachedItem, cachedSlot
        else
            cache[itemName] = nil
        end
    end
    for slot, item in pairs(inv) do
        if item.itemType == itemName or item.itemType:find(itemName) then
            cache[itemName] = { item = item, slot = slot }
            return item, slot
        end
    end
    return nil
end
VoidwareFunctions.GlobaliseObject("getItemNear", getItemNear)

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(store.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end
VoidwareFunctions.GlobaliseObject("getHotbarSlot", getHotbarSlot)

local function getNearbyObjects(origin, distance)
    assert(typeof(origin) == "Vector3", "Origin must be a Vector3")
    assert(typeof(distance) == "number" and distance > 0, "Distance must be a positive number")
    local minBound = origin - Vector3.new(distance, distance, distance)
    local maxBound = origin + Vector3.new(distance, distance, distance)
    local region = Region3.new(minBound, maxBound)
    local workspaceObjects = game.Workspace:FindPartsInRegion3WithIgnoreList(region, {}, math.huge)
    local nearbyObjects = {}
    for _, part in pairs(workspaceObjects) do
        if (part.Position - origin).Magnitude <= distance then
            table.insert(nearbyObjects, part)
        end
    end
    return nearbyObjects
end
VoidwareFunctions.GlobaliseObject("getNearyObjects", getNearbyObjects)

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do
		if attributeName:find("Shield") and type(attributeValue) == "number" then
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end
VoidwareFunctions.GlobaliseObject("getShieldAttribute", getShieldAttribute)

getPickaxe = function()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(store.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(store.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.baseDamage or 0
			if not bestSword or swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end
VoidwareFunctions.GlobaliseObject("getSword", getSword)

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(store.localInventory.inventory.items) do
		if item.itemType:find("bow") then
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(store.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

--[[local function getSpeed()
	local speed = 0
	if lplr.Character then
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if store.grapple > tick() then
			speed = speed + 90
		end
		if store.scythe > tick() then
			speed = speed + 5
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then
			speed = speed + 20
		end
		local armor = store.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then
			speed = speed + 12
		end
		if store.zephyrOrb ~= 0 then
			speed = speed + 12
		end
	end
	return speed
end--]]
local isZephyr = false
--local desyncboost = {Enabled = false}
--local killauraNearPlayer
local oldhealth
local lastdamagetick = tick()
task.spawn(function()
	repeat task.wait() until entityLibrary.isAlive
	oldhealth = game:GetService("Players").LocalPlayer.Character.Humanoid.Health
	game:GetService("Players").LocalPlayer.Character.Humanoid.HealthChanged:Connect(function(new)
		repeat task.wait() until entityLibrary.isAlive
		if new < oldhealth then
			lastdamagetick = tick() + 0.25
		end
		oldhealth = new
	end)
end)
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
	pcall(function()
		repeat task.wait() until entityLibrary.isAlive
		local oldhealth = game:GetService("Players").LocalPlayer.Character.Humanoid.Health
		repeat task.wait() until game:GetService("Players").LocalPlayer.Character.Humanoid
		game:GetService("Players").LocalPlayer.Character.Humanoid.HealthChanged:Connect(function(new)
			if new < oldhealth then
				lastdamagetick = tick() + 0.25
			end
			oldhealth = new
		end)
	end)
end)
shared.zephyrActive = false
shared.scytheActive = false
shared.SpeedBoostEnabled = false
shared.scytheSpeed = 5
local function getSpeed(reduce)
	local speed = 0
	if lplr.Character then
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if store.grapple > tick() then
			speed = speed + 90
		end
		if store.scythe > tick() and shared.scytheActive then
			speed = speed + shared.scytheSpeed
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then
			speed = speed + 20
		end
		if lastdamagetick > tick() and shared.SpeedBoostEnabled then
			speed = speed + 10
		end;
		local armor = store.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then
			speed = speed + 12
		end
		if store.zephyrOrb ~= 0 then
			speed = speed + 12
		end
		if store.zephyrOrb ~= 0 and shared.zephyrActive then
			isZephyr = true
		else
			isZephyr = false
		end
	end
	pcall(function()
		--speed = speed + (CheatEngineHelper.SprintEnabled and 23 - game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed or 0)
	end)
	return reduce and speed ~= 1 and math.max(speed * (0.8 - (0.3 * math.floor(speed))), 1) or speed
end
VoidwareFunctions.GlobaliseObject("getSpeed", getSpeed)

local Reach = {Enabled = false}
local blacklistedblocks = {bed = true, ceramic = true}
local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3)
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
	return realvec
end
VoidwareFunctions.GlobaliseObject("getScaffold", getScaffold)

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(store.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end
VoidwareFunctions.GlobaliseObject("getBestTool", getBestTool)

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do
			if bedwars.ItemTable[v2] then
				local blockmeta = bedwars.ItemTable[v2].block
				sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
				if blockmeta then
					local tool = getBestTool(v2)
					if tool then
						sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
					end
				end
			end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end
	end
	return softestside, softest
end

local entityCache = {
    entities = {},
    lastUpdate = 0,
    updateInterval = 0.5, 
    dummyNames = {
        "Void Enemy Dummy", "Emerald Enemy Dummy", "Diamond Enemy Dummy",
        "Leather Enemy Dummy", "Regular Enemy Dummy", "Iron Enemy Dummy"
    },
    connections = {}
}

local function getMagnitude(pos1, pos2, overridepos, distance)
    local mag = (pos1 - pos2).Magnitude
    return overridepos and mag > distance and (overridepos - pos2).Magnitude or mag
end

local function createEntityTemplate(name, char, rootPart, userId)
    return {
        Player = {Name = name, UserId = userId or 1443379645},
        Character = char,
        RootPart = rootPart,
        JumpTick = tick() + 5,
        Jumping = false,
        Humanoid = {HipHeight = 2}
    }
end

local function EntityNearPosition(distance, ignore, overridepos)
    local currentTime = tick()
    local playerPos = lplr.Character and lplr.Character.PrimaryPart and lplr.Character.PrimaryPart.Position
    if not playerPos then return nil end

    local closestEntity, closestMagnitude = nil, distance

    if currentTime - entityCache.lastUpdate >= entityCache.updateInterval then
        entityCache.entities = {}

		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				table.insert(entityCache.entities, v) 
			end
		end
        
        if not ignore then
            for _, name in ipairs(entityCache.dummyNames) do
                for _, v in pairs(collectionService:GetTagged("trainingRoomDummy")) do
					if not v.PrimaryPart then task.wait(1) end
					if not v:FindFirstChild("HumanoidRootPart") then task.wait(1) end
                    if v.Name == name and v.PrimaryPart then
                        table.insert(entityCache.entities, createEntityTemplate(
                            v.Name, 
                            v, 
                            v.PrimaryPart, 
                            v.Name == "Duck" and 2020831224 or 1443379645
                        ))
                    end
                end
            end

            local tagChecks = {
                Monster = function(v) return v:GetAttribute("Team") ~= lplr:GetAttribute("Team") end,
                GuardianOfDream = function(v) return v:GetAttribute("Team") ~= lplr:GetAttribute("Team") end,
                DiamondGuardian = true,
                GolemBoss = true,
                Drone = function(v)
                    local droneUserId = tonumber(v:GetAttribute("PlayerUserId"))
                    if droneUserId == lplr.UserId then return false end
                    local droneplr = playersService:GetPlayerByUserId(droneUserId)
                    return not droneplr or droneplr.Team ~= lplr.Team
                end,
                entity = function(v)
                    if v:HasTag('inventory-entity') and not v:HasTag('Monster') then return false end
                    return v:GetAttribute("Team") ~= lplr:GetAttribute("Team")
                end
            }

            for tag, check in pairs(tagChecks) do
                for _, v in pairs(collectionService:GetTagged(tag)) do
                    if v.PrimaryPart and (check == true or check(v)) then
                        table.insert(entityCache.entities, createEntityTemplate(
                            v.Name, 
                            v, 
                            v.PrimaryPart, 
                            v.Name == "Duck" and 2020831224 or 1443379645
                        ))
                    end
                end
            end

            for _, v in pairs(workspace:GetChildren()) do
                if v.Name == "InfectedCrateEntity" and v.ClassName == "Model" and v.PrimaryPart then
                    table.insert(entityCache.entities, createEntityTemplate("InfectedCrateEntity", v, v.PrimaryPart))
                end
            end

            for _, v in pairs(store.pots or {}) do
                if v.PrimaryPart then
                    table.insert(entityCache.entities, createEntityTemplate("Pot", v, v.PrimaryPart))
                end
            end
        end

        entityCache.lastUpdate = currentTime
    end

    for _, v in ipairs(entityCache.entities) do
        local mag = getMagnitude(playerPos, v.RootPart.Position, overridepos, distance)
        if mag <= closestMagnitude then
            closestEntity, closestMagnitude = v, mag
        end
    end

    return closestEntity
end

shared.EntityNearPosition = EntityNearPosition

local function startEntityTracking()
    for _, conn in pairs(entityCache.connections) do
        if conn.Connected then conn:Disconnect() end
    end
    entityCache.connections = {}

    local function addEntity(ent)
        if ent:HasTag('inventory-entity') and not ent:HasTag('Monster') then return end
        entityCache.lastUpdate = 0
    end

    for _, ent in collectionService:GetTagged('entity') do
        addEntity(ent)
    end

    table.insert(entityCache.connections, collectionService:GetInstanceAddedSignal('entity'):Connect(addEntity))
    table.insert(entityCache.connections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function()
        entityCache.lastUpdate = 0 
    end))
end

local function cleanupEntityTracking()
    for _, conn in pairs(entityCache.connections) do
        if conn.Connected then conn:Disconnect() end
    end
    entityCache.connections = {}
    entityCache.entities = {}
    entityCache.lastUpdate = 0
end

startEntityTracking()

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	cleanupEntityTracking()
end)
VoidwareFunctions.GlobaliseObject("EntityNearPosition", EntityNearPosition)

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
				if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
				end
			end
		end
	end
	return closestEntity
end
VoidwareFunctions.GlobaliseObject("EntityNearMouse", EntityNearMouse)

--[[local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
	if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, v)
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then continue end
					table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(store.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
				end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end--]]

local function AllNearPosition(distance, amount, sortfunction, prediction, npcIncluded)
	local returnedplayer = {}
	local currentamount = 0
	if entityLibrary.isAlive then
		local sortedentities = {}
		local lplr = game:GetService("Players").LocalPlayer
		if npcIncluded then
			for _, npc in pairs(game.Workspace:GetChildren()) do
				if npc.Name == "Void Enemy Dummy" or npc.Name == "Emerald Enemy Dummy" or npc.Name == "Diamond Enemy Dummy" or npc.Name == "Leather Enemy Dummy" or npc.Name == "Regular Enemy Dummy" or npc.Name == "Iron Enemy Dummy" then
					if npc:FindFirstChild("HumanoidRootPart") then
						local distance2 = (npc.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
						if distance2 < distance then
							table.insert(sortedentities, npc)
						end
					end
				end
			end
		end
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
			if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, v)
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then end
					table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GuardianOfDream")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then end
					table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then end
					table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
				end
			end
		end
		for i,v in pairs(game.Workspace:GetChildren()) do
			if v.Name == "InfectedCrateEntity" and v.ClassName == "Model" and v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "InfectedCrateEntity", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
				end
			end
		end
		for i, v in pairs(store.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
				if mag <= distance then
					table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
				end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end
VoidwareFunctions.GlobaliseObject("AllNearPosition", AllNearPosition)

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in pairs(res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == "ItemList" and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

local function isWhitelistedBed(bed)
    if bed and bed.Name == 'bed' then
        for i, v in pairs(playersService:GetPlayers()) do
            if bed:GetAttribute("Team"..(v:GetAttribute("Team") or 0).."NoBreak") and not ({whitelist:get(v)})[2] then
                return true
            end
        end
    end
    return false
end

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") and not isFriend(plr) and ({whitelist:get(plr)})[2]
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService("HttpService"):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
		if char then
			task.spawn(function()
				local humrootpart = char:WaitForChild("HumanoidRootPart", 10)
				local head = char:WaitForChild("Head", 10)
				local hum = char:WaitForChild("Humanoid", 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
				if humrootpart and hum and head then
					local childremoved
					local newent
					if localcheck then
						entityLibrary.isAlive = true
						entityLibrary.character.Head = head
						entityLibrary.character.Humanoid = hum
						entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
					else
						newent = {
							Player = plr,
							Character = char,
							HumanoidRootPart = humrootpart,
							RootPart = humrootpart,
							Head = head,
							Humanoid = hum,
							Targetable = entityLibrary.isPlayerTargetable(plr),
							Team = plr.Team,
							Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
						}
						local inv = char:WaitForChild("InventoryFolder", 5)
						if inv then
							local armorobj1 = char:WaitForChild("ArmorInvItem_0", 5)
							local armorobj2 = char:WaitForChild("ArmorInvItem_1", 5)
							local armorobj3 = char:WaitForChild("ArmorInvItem_2", 5)
							local handobj = char:WaitForChild("HandInvItem", 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function()
									task.delay(0.3, function()
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										store.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function()
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							store.inventories[plr] = bedwars.getInventory(plr)
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("Health"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state)
							local animnum = tonumber(({state.Animation.AnimationId:gsub("%D+", "")})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService("MarketplaceService"):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find("jump") then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find("Shield") then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
					end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Humanoid" then
							if localcheck then
								if char == lplr.Character then
									if part.Name == "HumanoidRootPart" then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild("HumanoidRootPart")
										if not root then
											root = char:WaitForChild("HumanoidRootPart", 3)
										end
										if root then
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
				end
			end)
		end
	end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal("Character"):Connect(function()
			if plr.Character then
				entityLibrary.refreshEntity(plr, localcheck)
			else
				if localcheck then
					entityLibrary.isAlive = false
				else
					entityLibrary.removeEntity(plr)
				end
			end
		end))
		table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal("Team"):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
				if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then
					table.insert(tab, v)
				end
			end
			for i,v in next, tab do
				entityLibrary.refreshEntity(v.Player)
			end
			if localcheck then
				entityLibrary.fullEntityRefresh()
			else
				entityLibrary.refreshEntity(plr, localcheck)
			end
		end))
		if plr.Character then
			task.spawn(entityLibrary.refreshEntity, plr, localcheck)
		end
	end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in pairs(entityLibrary.entityList) do
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
end

run(function()
	pcall(function()
		local handsquare = Instance.new("ImageLabel")
		handsquare.Size = UDim2.new(0, 26, 0, 27)
		handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
		handsquare.Position = UDim2.new(0, 72, 0, 44)
		handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
		local handround = Instance.new("UICorner")
		handround.CornerRadius = UDim.new(0, 4)
		handround.Parent = handsquare
		local helmetsquare = handsquare:Clone()
		helmetsquare.Position = UDim2.new(0, 100, 0, 44)
		helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
		local chestplatesquare = handsquare:Clone()
		chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
		chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
		local bootssquare = handsquare:Clone()
		bootssquare.Position = UDim2.new(0, 155, 0, 44)
		bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
		local uselesssquare = handsquare:Clone()
		uselesssquare.Position = UDim2.new(0, 182, 0, 44)
		uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
		local oldupdate = vapeTargetInfo.UpdateInfo
		vapeTargetInfo.UpdateInfo = function(tab, targetsize)
			local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
			handsquare.BackgroundTransparency = bkgcheck and 1 or 0
			helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
			chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
			bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
			uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
			pcall(function()
				for i,v in pairs(shared.VapeTargetInfo.Targets) do
					local inventory = store.inventories[v.Player] or {}
						if inventory.hand then
							handsquare.Image = bedwars.getIcon(inventory.hand, true)
						else
							handsquare.Image = ""
						end
						if inventory.armor[4] then
							helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
						else
							helmetsquare.Image = ""
						end
						if inventory.armor[5] then
							chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
						else
							chestplatesquare.Image = ""
						end
						if inventory.armor[6] then
							bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
						else
							bootssquare.Image = ""
						end
					break
				end
			end)
			return oldupdate(tab, targetsize)
		end
	end)
end)
pcall(function()
    local options = {
        "SilentAimOptionsButton",
        "ReachOptionsButton",
        "MouseTPOptionsButton",
        "PhaseOptionsButton",
        "AutoClickerOptionsButton",
        "SpiderOptionsButton",
        "LongJumpOptionsButton",
        "HitBoxesOptionsButton",
        "KillauraOptionsButton",
        "TriggerBotOptionsButton",
        "AutoLeaveOptionsButton",
        "SpeedOptionsButton",
        "FlyOptionsButton",
        "ClientKickDisablerOptionsButton",
        "NameTagsOptionsButton",
        "SafeWalkOptionsButton",
        "BlinkOptionsButton",
        "FOVChangerOptionsButton",
        "AntiVoidOptionsButton",
        "SongBeatsOptionsButton"
        --"TargetStrafeOptionsButton"
    }

    for _, option in ipairs(options) do
        task.spawn(function()
            pcall(function()
                GuiLibrary.RemoveObject(option)
            end)
        end)
    end
end)

local function Wallcheck(attackerCharacter, targetCharacter, additionalIgnore)
    if not (attackerCharacter and targetCharacter) then
        return false
    end

    local humanoidRootPart = attackerCharacter.PrimaryPart
    local targetRootPart = targetCharacter.PrimaryPart
    if not (humanoidRootPart and targetRootPart) then
        return false
    end

    local origin = humanoidRootPart.Position
    local targetPosition = targetRootPart.Position
    local direction = targetPosition - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.RespectCanCollide = true

    local ignoreList = {attackerCharacter}
    
    if additionalIgnore and typeof(additionalIgnore) == "table" then
        for _, item in pairs(additionalIgnore) do
            table.insert(ignoreList, item)
        end
    end

    raycastParams.FilterDescendantsInstances = ignoreList

    local raycastResult = workspace:Raycast(origin, direction, raycastParams)

    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(targetCharacter) then
            return true
        else
            return false
        end
    else
        return true
    end
end

run(function()
	local Players = game:GetService("Players")
	local playersService = Players
	function getColor3FromDecimal(decimal)
		if not decimal then return false end
		local r = math.floor(decimal / (256 * 256)) % 256
		local g = math.floor(decimal / 256) % 256
		local b = decimal % 256
		
		return Color3.new(r / 255, g / 255, b / 255)
	end
	if shared.CORE_CUSTOM_CONNECTIONS and type(shared.CORE_CUSTOM_CONNECTIONS) == "table" then
		for i,v in pairs(shared.CORE_CUSTOM_CONNECTIONS) do
			pcall(function()
				v:Disconnect()
			end)
		end
		table.clear(shared.CORE_CUSTOM_CONNECTIONS)
	end
	shared.CORE_CUSTOM_CONNECTIONS = {}
	shared.CORE_CUSTOM_CONNECTIONS.EntityDeathEvent = vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
        local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
        local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
        if not killed or not killer then return end
		shared.custom_notify("kill", killer, killed, deathTable.finalKill)
    end)
	shared.CORE_CUSTOM_CONNECTIONS.BedwarsBedBreak = vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
		if not (bedTable ~= nil and type(bedTable) == "table" and bedTable.brokenBedTeam ~= nil and type(bedTable.brokenBedTeam) == "table" and bedTable.brokenBedTeam.id ~= nil) then return end
		local team = bedwars.QueueMeta[store.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
		local destroyer = Players:GetPlayerByUserId(tonumber(bedTable.player.UserId)) or {Name = "Unknown player"}
		if not destroyer then destroyer = "Unknown player" end
		shared.custom_notify("bedbreak", destroyer, nil, nil, {
			Name = team and team.displayName:upper() or 'WHITE',
			Color = team and team.colorHex and getColor3FromDecimal(tonumber(team.colorHex)) or Color3.fromRGB(255, 255, 255)
		})
	end)
	shared.CORE_CUSTOM_CONNECTIONS.MatchEndEvent = vapeEvents.MatchEndEvent.Event:Connect(function(winTable)
		local team = bedwars.QueueMeta[store.queueType].teams[tonumber(winTable.winningTeamId)]
		if winTable.winningTeamId == lplr:GetAttribute('Team') then
			shared.custom_notify("win", nil, nil, false, {
				Name = team and team.displayName:upper() or 'WHITE',
				Color = team and team.colorHex and getColor3FromDecimal(tonumber(team.colorHex)) or Color3.fromRGB(255, 255, 255)
			})
		else
			shared.custom_notify("defeat", nil, nil, false, {
				Name = team and team.displayName:upper() or 'WHITE',
				Color = team and team.colorHex and getColor3FromDecimal(tonumber(team.colorHex)) or Color3.fromRGB(255, 255, 255)
			})
		end
    end)
end)

--if (not shared.RiseMode) then
	run(function()
		local function isFirstPerson()
			if not (lplr.Character and lplr.Character:FindFirstChild("Head")) then return nil end
			return (lplr.Character.Head.Position - gameCamera.CFrame.Position).Magnitude < 2
		end
		local AimAssist = {Enabled = false}
		local AimAssistClickAim = {Enabled = false}
		local AimAssistStrafe = {Enabled = false}
		local AimSpeed = {Value = 1}
		local HandCheck = {Enabled = false}
		local AimAssistTargetFrame = {Players = {Enabled = false}}
		local IgnoreEntities = {Enabled = false}
		local ShopCheck = {Enabled = false}
		local FirstPersonCheck = {Enabled = false}

		AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
			Name = "AimAssist",
			Function = function(callback)
				if callback then
					RunLoops:BindToRenderStep("AimAssist", function(dt)
						vapeTargetInfo.Targets.AimAssist = nil
						if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
							if HandCheck.Enabled and not (store.localHand and store.localHand.Type and store.localHand.Type == "sword") then return end
							local plr = EntityNearPosition(18, IgnoreEntities.Enabled)
							if plr then
								if FirstPersonCheck.Enabled then
									if not isFirstPerson() then return end
								end
								if ShopCheck.Enabled then
									local isShop = lplr:FindFirstChild("PlayerGui") and lplr:FindFirstChild("PlayerGui"):FindFirstChild("ItemShop") or nil
									if isShop then return end
								end
								vapeTargetInfo.Targets.AimAssist = {
									Humanoid = {
										Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
										MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
									},
									Player = plr.Player
								}
								if store.localHand.Type == "sword" then
									if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
										if store.matchState == 0 then return end
									end
									if AimAssistTargetFrame.Walls.Enabled then
										if not Wallcheck(lplr.Character, plr.Character) then return end
									end
									gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("HumanoidRootPart").Position or plr.Character.RootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
								end
							end
						end
					end)
				else
					RunLoops:UnbindFromRenderStep("AimAssist")
					vapeTargetInfo.Targets.AimAssist = nil
				end
			end,
			HoverText = "Smoothly aims to closest valid target with sword"
		})
		AimAssist.Restart = function() if AimAssist.Enabled then AimAssist.ToggleButton(false); AimAssist.ToggleButton(false) end end
		IgnoreEntities = AimAssist.CreateToggle({
			Name = "Ignore bots (skeletons, void creautures)",
			Function = function() end,
			Default = false
		})
		ShopCheck = AimAssist.CreateToggle({
			Name = "Shop Check",
			Function = function() end,
			Default = false
		})
		FirstPersonCheck = AimAssist.CreateToggle({
			Name = "First Person Check",
			Function = function() end,
			Default = false
		})
		AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
		HandCheck = AimAssist.CreateToggle({
			Name = "Sword Check",
			Function = AimAssist.Restart,
			Default = true,
			HoverText = "Checks if you are holding a sword"
		})
		AimAssistClickAim = AimAssist.CreateToggle({
			Name = "Click Aim",
			Function = function() end,
			Default = true,
			HoverText = "Only aim while mouse is down"
		})
		AimAssistStrafe = AimAssist.CreateToggle({
			Name = "Strafe increase",
			Function = function() end,
			HoverText = "Increase speed while strafing away from target"
		})
		AimSpeed = AimAssist.CreateSlider({
			Name = "Smoothness",
			Min = 1,
			Max = 100,
			Function = function(val) end,
			Default = 50
		})
	end)
--end

--[[run(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local AutoClickerThread

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in pairs(lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Active then
				return false
			end
		end
		for i,v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	local function AutoClick()
		local firstClick = tick() + 0.1
		AutoClickerThread = task.spawn(function()
			repeat
				task.wait()
				if entityLibrary.isAlive then
					if not autoclicker.Enabled then break end
					if not isNotHoveringOverGui() then continue end
					if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then continue end
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then continue end
					end
					if store.localHand.Type == "sword" then
						if bedwars.DaoController.chargingMaid == nil then
							task.spawn(function()
								if firstClick <= tick() then
									bedwars.SwordController:swingSwordAtMouse()
								else
									firstClick = tick()
								end
							end)
							task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or 0.142))
						end
					elseif store.localHand.Type == "block" then
						if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
							if (game.Workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
								local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
								if mouseinfo then
									task.spawn(function()
										if mouseinfo.placementPosition == mouseinfo.placementPosition then
											bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
										end
									end)
								end
								task.wait((1 / autoclickercps.GetRandomValue()))
							end
						end
					end
				end
			until not autoclicker.Enabled
		end)
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function()
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick))
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
							if AutoClickerThread then
								task.cancel(AutoClickerThread)
								AutoClickerThread = nil
							end
						end))
					end)
				end
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then AutoClick() end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and AutoClickerThread then
						task.cancel(AutoClickerThread)
						AutoClickerThread = nil
					end
				end))
			end
		end,
		HoverText = "Hold attack button to automatically click"
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = "Place Blocks",
		Function = function() end,
		Default = true,
		HoverText = "Automatically places blocks when left click is held."
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoClickDelay",
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self)
					self.lastSwing = tick()
					return false
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = "Remove the CPS cap"
	})
end)--]]

--[[run(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local AutoClickerThread

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in pairs(lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Active then
				return false
			end
		end
		for i,v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do
			if v.Parent and v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	local function AutoClick()
		local firstClick = tick() + 0.1
		AutoClickerThread = task.spawn(function()
			repeat
				task.wait()
				if entityLibrary.isAlive then
					if not autoclicker.Enabled then break end
					if not isNotHoveringOverGui() then continue end
					--if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then continue end
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then continue end
					end
					if store.localHand.Type == "sword" then
						if bedwars.DaoController.chargingMaid == nil then
							task.spawn(function()
								if firstClick <= tick() then
									bedwars.SwordController:swingSwordAtMouse()
								else
									firstClick = tick()
								end
							end)
							task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or 0.142))
						end
					elseif store.localHand.Type == "block" then
						if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
							if (game.Workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
								local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
								if mouseinfo then
									task.spawn(function()
										if mouseinfo.placementPosition == mouseinfo.placementPosition then
											bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
										end
									end)
								end
								task.wait((1 / autoclickercps.GetRandomValue()))
							end
						end
					end
				end
			until not autoclicker.Enabled
		end)
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function()
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Down:Connect(AutoClick))
						table.insert(autoclicker.Connections, lplr.PlayerGui.MobileUI['2'].MouseButton1Up:Connect(function()
							if AutoClickerThread then
								task.cancel(AutoClickerThread)
								AutoClickerThread = nil
							end
						end))
					end)
				end
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then AutoClick() end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and AutoClickerThread then
						task.cancel(AutoClickerThread)
						AutoClickerThread = nil
					end
				end))
			end
		end,
		HoverText = "Hold attack button to automatically click"
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = "Place Blocks",
		Function = function() end,
		Default = true,
		HoverText = "Automatically places blocks when left click is held."
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoClickDelay",
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self)
					self.lastSwing = tick()
					return false
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = "Remove the CPS cap"
	})
end)--]]

--[[run(function()
	local ReachValue = {Value = 14}

	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach",
		Function = function(callback)
			bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = callback and ReachValue.Value + 2 or 14.4
		end,
		HoverText = "Extends attack reach"
	})
	ReachValue = Reach.CreateSlider({
		Name = "Reach",
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)--]]

run(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = GuiLibrary["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton({
		["Name"] = "Sprint",
		["Function"] = function(callback)
			if callback then
				sprinten = true
				thread = task.spawn(function()
					repeat task.wait()
						if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
							game:GetService("Players").LocalPlayer:SetAttribute("Sprinting", true)
							game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = 20
						end
					until not sprinten
				end)
			else 
				sprinten = false
				if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
					game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = 16
				end
				game:GetService("Players").LocalPlayer:SetAttribute("Sprinting", false)
				if thread then
					task.cancel(thread)
					thread = nil
				end
			end 
		end,
		["HoverText"] = "Sets your sprinting to true."
	})
	game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
		if sprinten then
			character:WaitForChild("Humanoid").WalkSpeed = 23
		else
			character:WaitForChild("Humanoid").WalkSpeed = 16
		end
	end)
	game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function(character)
		if character:WaitForChild("Humanoid") then
			character:WaitForChild("Humanoid").WalkSpeed = 16
		end
	end)
end)

--[[run(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Velocity",
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = "Reduces knockback taken"
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)--]]

run(function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local kbUtil = replicatedStorage:WaitForChild("TS"):WaitForChild("damage")["knockback-util"]
	local orig = {
		kbDirectionStrength = 11750,
		kbUpwardStrength = 10000
	}

    local Velocity = {Enabled = false}
    local Horizontal = {Value = 0}
    local Vertical = {Value = 0}
    local TargetCheck = {Enabled = false}
    local rand, old = Random.new()
    
    Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
        Name = 'Velocity',
        Function = function(callback)
            if callback then
				task.spawn(function()
					repeat
						local check = (not TargetCheck.Enabled) or entitylib.EntityPosition({
							Range = 50,
							Part = 'RootPart',
							Players = true
						})
		
						if check then
							kbUtil:SetAttribute("ConstantManager_kbDirectionStrength", orig.kbDirectionStrength * (Horizontal.Value / 100))
							kbUtil:SetAttribute("ConstantManager_kbUpwardStrength", orig.kbDirectionStrength * (Vertical.Value / 100))
						else
							kbUtil:SetAttribute("ConstantManager_kbDirectionStrength", orig.kbDirectionStrength)
							kbUtil:SetAttribute("ConstantManager_kbUpwardStrength", orig.kbDirectionStrength)
						end

						task.wait()
					until not Velocity.Enabled
				end)
            else
                task.wait()
                kbUtil:SetAttribute("ConstantManager_kbDirectionStrength", orig.kbDirectionStrength)
                kbUtil:SetAttribute("ConstantManager_kbUpwardStrength", orig.kbDirectionStrength)
            end
        end,
        HoverText = 'Reduces knockback taken'
    })
    Horizontal = Velocity.CreateSlider({
        Name = 'Horizontal',
        Min = 0,
        Max = 100,
        Default = 0,
		Function = function() end
    })
    Vertical = Velocity.CreateSlider({
        Name = 'Vertical',
        Min = 0,
        Max = 100,
        Default = 0,
		Function = function() end
    })
    TargetCheck = Velocity.CreateToggle({Name = 'Only when targeting', Default = false, Function = function() end})
end)

run(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then
			return 200
		end
		return res
	end

	local permissions = {
		[87365146] = {
			"admin",
			"freecam"
		},
		[78390760] = {
			"filmer"
		},
		[225721992] = {
			"admin",
			"freecam"
		},
		[21406719] = {
			"admin",
			"freecam"
		},
		[1776734677] = {
			"filmer"
		},
		[308165] = {
			"admin",
			"freecam"
		},
		[172603477] = {
			"artist",
			"freecam"
		},
		[281575310] = {
			"admin",
			"freecam"
		},
		[2237298638] = {
			"artist",
			"freecam"
		},
		[437492645] = {
			"artist",
			"freecam"
		},
		[34466481] = {
			"artist",
			"freecam"
		},
		[205430552] = {
			"artist",
			"freecam"
		},
		[3361695884] = {
			"admin",
			"freecam"
		},
		[22808138] = {
			"admin",
			"freecam",
			"filmer",
			"anticheat_mod"
		},
		[1793668872] = {
			"admin"
		},
		[22641473] = {
			"admin",
			"freecam"
		},
		[4001781] = {
			"admin",
			"freecam"
		},
		[75380482] = {
			"admin",
			"freecam"
		},
		[20663325] = {
			"admin",
			"freecam"
		},
		[4308133] = {
			"admin",
			"freecam"
		}
	}

	local flyAllowedmodules = {"Sprint", "AutoClicker", "AutoReport", "AutoReportV2", "AutoRelic", "AimAssist", "AutoLeave", "Reach"}
	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			local isStaff = getRole(plr) >= 100 or permissions[plr.UserId] and table.find(permissions[plr.UserId], "admin")
			local perms = permissions[plr.UserId]
			if perms then
				pcall(function()
					if not table.find(perms, "admin") then
						warningNotification("StaffDetector", plr.Name.." is "..tostring(perms[1]).."!", 3)
					end
				end)	
			end
			if isStaff then
				if AutoLeaveStaff.Enabled then
					if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
						bedwars.QueueController.leaveParty()
					end
					if AutoLeaveStaff2.Enabled then
						warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name).." : Play legit like nothing happened to have the highest chance of not getting banned.", 60)
						GuiLibrary.SaveSettings = function() end
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do
							if v.Type == "OptionsButton" then
								if table.find(flyAllowedmodules, i:gsub("OptionsButton", "")) == nil and tostring(v.Object.Parent.Parent):find("Render") == nil then
									if v.Api.Enabled then
										v.Api.ToggleButton(false)
									end
									v.Api.SetKeybind("")
									v.Object.TextButton.Visible = false
								end
							end
						end
					else
						GuiLibrary.SelfDestruct()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Vape",
							Text = "Staff Detected\n"..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name),
							Duration = 60,
						})
					end
					return
				else
					warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 60)
				end
			end
		end)
	end

	local function isEveryoneDead() return true end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoLeave",
		Function = function(callback)
			if callback then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and store.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.Client:Get("TeleportToLobby"):FireServer()
								else
									if AutoLeaveRandom.Enabled then
										local listofmodes = {}
										for i,v in pairs(bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.QueueController:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.QueueController:joinQueue(store.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.Client:Get("TeleportToLobby"):FireServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then
									local listofmodes = {}
									for i,v in pairs(bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.QueueController:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.QueueController:joinQueue(store.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in pairs(playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = "Leaves if a staff member joins your game or when the match ends."
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = "Delay before going back to the hub."
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = "Play Again",
		Function = function() end,
		HoverText = "Automatically queues a new game.",
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = "Staff",
		Function = function(callback)
			if AutoLeaveStaff2.Object then
				AutoLeaveStaff2.Object.Visible = callback
			end
		end,
		HoverText = "Automatically uninjects when staff joins",
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = "Staff AutoConfig",
		Function = function() end,
		HoverText = "Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.",
		Default = true
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = "Random",
		Function = function(callback) end,
		HoverText = "Chooses a random mode"
	})
	AutoLeaveStaff2.Object.Visible = false
end)

local autobankballoon = false
--[[run(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon()
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not store.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = store.queueType:find("mega") or store.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until store.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = store.queueType:find("mega") or store.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray then
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat("Fly", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
						end

						if flyAllowed <= 0 then
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then
								if (not onground) then
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat("Fly")
				if FlyAnywayProgressBarFrame then
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = function() end,
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = "Pop Balloon",
		Function = function() end,
		HoverText = "Pops balloons when Fly is disabled."
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = "Damage Animation",
		Function = function(callback)
			if Flydamagecamera.Object then
				Flydamagecamera.Object.Visible = callback
			end
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt)
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = "Progress Bar",
		Function = function(callback)
			if callback then
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = "show amount of Fly time",
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
end)--]]
local autobankballoon = false
run(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyMobileButtons = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local mobileControls = {}

	local function createMobileButton(name, position, icon)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(0, 60, 0, 60)
		button.Position = position
		button.BackgroundTransparency = 0.2
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		button.BorderSizePixel = 0
		button.Text = icon
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Font = Enum.Font.SourceSansBold
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
		return button
	end

	local function cleanupMobileControls()
		for _, control in pairs(mobileControls) do
			if control then
				control:Destroy()
			end
		end
		mobileControls = {}
	end

	local function setupMobileControls()
		cleanupMobileControls()
		local gui = Instance.new("ScreenGui")
		gui.Name = "FlyControls"
		gui.ResetOnSpawn = false
		gui.Parent = lplr.PlayerGui

		local upButton = createMobileButton("UpButton", UDim2.new(0.9, -70, 0.7, -140), "↑")
		local downButton = createMobileButton("DownButton", UDim2.new(0.9, -70, 0.7, -70), "↓")

		mobileControls.UpButton = upButton
		mobileControls.DownButton = downButton
		mobileControls.ScreenGui = gui

		upButton.Parent = gui
		downButton.Parent = gui

		return upButton, downButton
	end

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))

				local isMobile = inputService.TouchEnabled and not inputService.KeyboardEnabled and not inputService.MouseEnabled
				if FlyMobileButtons.Enabled or isMobile then
					local upButton, downButton = setupMobileControls()
					
					table.insert(Fly.Connections, upButton.MouseButton1Down:Connect(function()
						if FlyVertical.Enabled then FlyUp = true end
					end))
					table.insert(Fly.Connections, upButton.MouseButton1Up:Connect(function()
						FlyUp = false
					end))
					table.insert(Fly.Connections, downButton.MouseButton1Down:Connect(function()
						if FlyVertical.Enabled then FlyDown = true end
					end))
					table.insert(Fly.Connections, downButton.MouseButton1Up:Connect(function()
						FlyDown = false
					end))
				end

				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							if not mobileControls.UpButton then
								FlyUp = jumpButton.ImageRectOffset.X == 146 and FlyVertical.Enabled
							end
						end))
						if not mobileControls.UpButton then
							FlyUp = jumpButton.ImageRectOffset.X == 146 and FlyVertical.Enabled
						end
					end)
				end

				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon()
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not store.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = store.queueType:find("mega") or store.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until store.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = store.queueType:find("mega") or store.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then
					FlyAnywayProgressBarFrame.Visible = true
					pcall(function() FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true) end)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray then
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat("Fly", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or store.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0 and FlyAnywayProgressBar.Enabled
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							pcall(function()
								FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							end)
						end

						if flyAllowed <= 0 then
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then
								if (not onground) then
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then
								FlyAnywayProgressBarFrame.Visible = groundtime ~= nil
								if groundtime ~= nil then
									FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
								end
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat("Fly")
				if FlyAnywayProgressBarFrame then
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
				cleanupMobileControls()
			end
		end,
		HoverText = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end,
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = function() end,
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = "Pop Balloon",
		Function = function() end,
		HoverText = "Pops balloons when Fly is disabled."
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = "Damage Animation",
		Function = function(callback)
			if Flydamagecamera.Object then
				Flydamagecamera.Object.Visible = callback
			end
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt)
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = "Progress Bar",
		Function = function(callback)
			if callback then
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 = Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = "show amount of Fly time",
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
	FlyMobileButtons = Fly.CreateToggle({
		Name = "Mobile Buttons",
		Default = false,
		Function = function(callback)
			if Fly.Enabled then
				Fly.ToggleButton(false) 
				Fly.ToggleButton(false)
			end
		end
	})
end)

--[[run(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = "Normal"}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.Client:Get("GrapplingHookFunctions").OnClientEvent:Connect(function(p4)
		if p4.hookFunction == "PLAYER_IN_TRANSIT" then
			bedwars.CooldownController:setOnCooldown("grappling_hook", 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "GrappleExploit",
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.Client:Get("GrapplingHookFunctions").OnClientEvent:Connect(function(p4)
					if p4.hookFunction == "PLAYER_IN_TRANSIT" then
						store.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem("grappling_hook")
				if fireball then
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown("grappling_hook") == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:InvokeServer(fireball["tool"], nil, "grappling_hook_projectile", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, game.Workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification("GrappleExploit", "missing grapple hook", 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat("GrappleExploit", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat("GrappleExploit")
			end
		end,
		HoverText = "Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)",
		ExtraText = function()
			if GuiLibrary.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"]["Api"].Enabled then
				return alternatelist[table.find(GrappleExploitMode["List"], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value
		end
	})
end)--]]

run(function()
	local InfiniteFly = {Enabled = false}
	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "InfiniteFly",
		Function = function(call)
			if call then
				InfiniteFly.ToggleButton(false)
			end
		end
	})
end)

local killauraNearPlayer
run(function()
	local Killaura = {Enabled = false}
	local killauraboxes = {}
	local killauraboxSize = Vector3.new(6, 9, 6)
	--Vector3.new(3, 6, 3)
	local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = "Distance"}
	local killaurarealremote = {FireServer = function() end}
	task.spawn(function()
		killaurarealremote = bedwars.Client:Get(bedwars.AttackRemote)
		local Reach = Reach or {Enabled = false}
		local HitBoxes = HitBoxes or {Enabled = false}
		killaurarealremote.FireServer = function(self, attackTable, ...)
			local suc, plr = pcall(function()
				return playersService:GetPlayerFromCharacter(attackTable.entityInstance)
			end)

			local selfpos = attackTable.validate.selfPosition.value
			local targetpos = attackTable.validate.targetPosition.value
			store.attackReach = ((selfpos - targetpos).Magnitude * 100) // 1 / 100
			store.attackReachUpdate = tick() + 1

			if Reach.Enabled or HitBoxes.Enabled then
				attackTable.validate.raycast = attackTable.validate.raycast or {}
				attackTable.validate.selfPosition.value += CFrame.lookAt(selfpos, targetpos).LookVector * math.max((selfpos - targetpos).Magnitude - 14.399, 0)
			end

			if suc and plr then
				if not select(2, whitelist:get(plr)) then return end
			end

			return self:SendToServer(attackTable, ...)
		end
	end)
	local killauramethod = {Value = "Normal"}
	local killauraothermethod = {Value = "Normal"}
	local killauraanimmethod = {Value = "Normal"}
	local killaurarange = {Value = 14}
	local killauraangle = {Value = 360}
	local killaurahitslowmode = {Value = 2}
	local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
	local killauramouse = {Enabled = false}
	local killauracframe = {Enabled = false}
	local killauragui = {Enabled = false}
	local killauratarget = {Enabled = false}
	local killaurasound = {Enabled = false}
	local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
	local killaurahandcheck = {Enabled = false}
	local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
	local killauracolorChanged = Instance.new("BindableEvent")
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
	local Killauranear = false
	local killauraplaying = false
	local oldViewmodelAnimation = function() end
	local oldPlaySound = function() end
	local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local lastSwingServerTime = 0
	local lastSwingServerTimeDelta = 0

	local OneTapCooldown = {Value = 5}

	local function createRangeCircle()
		local suc, err = pcall(function()
			if identifyexecutor and not string.find(string.lower(identifyexecutor()), "wave") and not shared.CheatEngineMode then
				killaurarangecirclepart = Instance.new("MeshPart")
				killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
				if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
					killaurarangecirclepart.Color = GuiLibrary.GUICoreColor
					GuiLibrary.GUICoreColorChanged.Event:Connect(function()
						killaurarangecirclepart.Color = GuiLibrary.GUICoreColor
					end)
				else
					killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
					killauracolorChanged.Event:Connect(function()
						killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
					end)
				end
				killaurarangecirclepart.CanCollide = false
				killaurarangecirclepart.Anchored = true
				killaurarangecirclepart.Material = Enum.Material.Neon
				killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
				if Killaura.Enabled then
					killaurarangecirclepart.Parent = gameCamera
				end
				killaurarangecirclepart:SetAttribute("gamecore_GameQueryIgnore", true)
			end
		end)
		if (not suc) then
			pcall(function()
				killaurarangecircle:ToggleButton(false)
				InfoNotification("Killaura - Range Visualiser Circle", "There was an error creating the circle. Disabling...", 2)
			end)
		end
	end

	local function getStrength(plr)
		local inv = store.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in pairs(inv.items) do
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then
					strongestsword = itemmeta.sword.damage / 100
				end
			end
			strength = strength + strongestsword
			for i,v in pairs(inv.armor) do
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
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

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		["Vertical Spin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		["Exhibition Old"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		Pulse = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.5},
			{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(-20), math.rad(0), math.rad(0)), Time = 1.0},
			{CFrame = CFrame.new(0.69, -0.68, 0.6) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0)), Time = 1.5},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 2.0}
		},
		["Slowly Smooth"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.5},
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.75},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1.25},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 1.5},
		},
		["Latest Remake"] = {
			{CFrame = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), Time = 0.4},
			{CFrame = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), Time = 0.4}
		},
		["Exhibition Fast"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-20), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.8, 0.5) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.07},
		},
		["Smooth Gaming"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), Time = 0.4},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.6},
			{CFrame = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), Time = 0.6},
			{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.8},
			{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 1.0},
			{CFrame = CFrame.new(0.8, -0.8, 0.5) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 1.2},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1.4},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 1.6}
		}	
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
			if store.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if (tick() - bedwars.SwordController.lastSwing) > 0.1 then return false end
			--if not inputService:IsMouseButtonPressed(0) then return false end
		end
		--[[if killauragui.Enabled then
			if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then return false end
		end--]]
		local sword = killaurahandcheck.Enabled and store.localHand or getSword()
		--warn("getAttackData", tostring(sword))
		--print(encode(store.localHand))
		--print(killaurahandcheck.Enabled, store.localHand, sword, sword and sword.tool or "no tool", sword and sword.itemType and bedwars.ItemTable[sword.itemType] or "itemType not found!")
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.itemType]
		--[[if killaurahandcheck.Enabled then
			if store.localHand.Type ~= "sword" or bedwars.DaoController.chargingMaid then return false end
		end--]]
		if killaurahandcheck.Enabled and not (store.localHand and store.localHand.Type and store.localHand.Type == "sword") then return false end
		return sword, swordmeta
	end

	--[[local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if entityLibrary.isAlive then
				local shield = getItem("infernal_shield")
				if shield then
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute("InfernalShieldRaised") then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end--]]

	local sigridcheck = false

	Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Killaura",
		Function = function(callback)
			if callback then
				lastSwingServerTime = Workspace:GetServerTimeNow()
                lastSwingServerTimeDelta = 0
				
				if killaurarangecircle.Enabled then
					createRangeCircle()
				end

				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						local suc, err = pcall(function()
							if (killauraanimation.Enabled and not killauraswing.Enabled) then
								if killauraNearPlayer then
									pcall(function()
										if originalArmC0 == nil then
											originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
										end
										if killauraplaying == false then
											killauraplaying = true
											for i,v in pairs(anims[killauraanimmethod.Value]) do
												if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
												if not oldNearPlayer and killauraanimationtween.Enabled then
													gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
													continue
												end
												killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
												killauracurrentanim:Play()
												task.wait(v.Time - 0.01)
											end
											killauraplaying = false
										end
									end)
								end
								oldNearPlayer = killauraNearPlayer
							end
						end)
						if not suc then
							warn('[Killaura ARG1 Error]: '..tostring(err))
						end
					until Killaura.Enabled == false
				end)

				local targetedPlayer
				--- BindToHearbeat
				RunLoops:BindToHeartbeat("Killaura", function()
					local suc, err = pcall(function()
						for i,v in pairs(killauraboxes) do
							if v:IsA("BoxHandleAdornment") and v.Adornee then
								local cf = v.Adornee and v.Adornee.CFrame
								local onex, oney, onez = cf:ToEulerAnglesXYZ()
								v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
							end
						end
						if entityLibrary.isAlive then
							if killauraaimcirclepart then
								killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
							end
							if killauraparticlepart then
								killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
							end
							local Root = entityLibrary.character.HumanoidRootPart
							if Root then
								if killaurarangecirclepart then
									killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
								end
								local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
								local LowerTorso = Root.Parent and Root.Parent:FindFirstChild("LowerTorso")
								local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
								if Neck and RootC0 then
									if originalNeckC0 == nil then
										originalNeckC0 = Neck.C0.p
									end
									if originalRootC0 == nil then
										originalRootC0 = RootC0.C0.p
									end
									if originalRootC0 and killauracframe.Enabled then
										if targetedPlayer ~= nil then
											local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
											local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
											local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
											local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
											local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
											Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
											RootC0.C0 = lookCFrame2 + originalRootC0
										else
											Neck.C0 = CFrame.new(originalNeckC0)
											RootC0.C0 = CFrame.new(originalRootC0)
										end
									end
								end
							end
						end
					end)
					if not suc then
						warn("[Killaura ARG2 Error]: "..tostring(err))
					end
				end)
				--[[if killauraautoblock.Enabled then
					task.spawn(autoBlockLoop)
				end--]]
				task.spawn(function()
					repeat
						task.wait(0.01)
						if not Killaura.Enabled then break end
						vapeTargetInfo.Targets.Killaura = nil
						store.KillauraTarget = nil
						local plrs = {EntityNearPosition(killaurarange.Value, false)}
						local firstPlayerNear
						if #plrs > 0 then
							if sigridcheck and entityLibrary.isAlive and lplr.Character:FindFirstChild("elk") then return end
							task.spawn(function()
								pcall(function()
									--if getItemNear('warlock_staff') then bedwars.WarlockController:link(plrs[1].Character) end
									if shared.EmberAutoKit and getItemNear('infernal_saber') then bedwars.EmberController:BladeRelease(getItemNear('infernal_saber')) end
									if getItemNear('summoner_claw') then bedwars.KaidaController:request(plrs[1].Character) end
									if getItemNear('noctium_blade') then for i,v in pairs({"void_knight_consume_emerald", "void_knight_consume_iron"}) do if bedwars.AbilityController:canUseAbility(v) then bedwars.AbilityController:useAbility(v) end end end
								end)
							end)
							local sword, swordmeta = getAttackData()
							if sword and swordmeta and swordmeta.sword then
								switchItem(sword.tool)
								for i, plr in pairs(plrs) do
									local root = plr.RootPart
									if not root then
										continue
									end
									--if workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack < OneTapCooldown.Value/10 then continue end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not Wallcheck(lplr.Character, plr.Character) then continue end
									end
									if killauranovape.Enabled and store.whitelist.clientUsers[plr.Player.Name] then
										continue
									end
									if not firstPlayerNear then
										firstPlayerNear = true
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											Humanoid = {
												Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
												MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										}
										store.KillauraTarget = plr.Character
										if animationdelay <= tick() then
											animationdelay = tick() + (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or (killaurasync.Enabled and 0.24 or 0.14))
											if not killauraswing.Enabled then
												bedwars.SwordController:playSwordEffect(swordmeta, false)
											end
											if swordmeta.displayName:find(" Scythe") then
												bedwars.ScytheController:playLocalAnimation()
											end
										end
									end
									--if (game.Workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then break end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
                                    bedwars.SwordController.lastSwingServerTime = workspace:GetServerTimeNow()

									lastSwingServerTimeDelta = workspace:GetServerTimeNow() - lastSwingServerTime
                                    lastSwingServerTime = workspace:GetServerTimeNow()
									
									store.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									store.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = 0},
										entityInstance = plr.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position),
												cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
											},
											targetPosition = attackValue(root.Position),
											selfPosition = attackValue(selfpos)
										},
										--lastSwingServerTimeDelta = lastSwingServerTimeDelta
									})
									local spear = getItemNear('spear')
									if spear then
										switchItem(spear.tool)
										killaurarealremote:FireServer({
											weapon = spear.tool,
											chargedAttack = {chargeRatio = 0},
											entityInstance = plr.Character,
											validate = {
												raycast = {
													cameraPosition = attackValue(root.Position),
													cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
												},
												targetPosition = attackValue(root.Position),
												selfPosition = attackValue(selfpos)
											},
                                            --lastSwingServerTimeDelta = lastSwingServerTimeDelta
										})
									end
									break
								end
							end
							task.wait(killaurahitslowmode.Value/10)
						end
						if not firstPlayerNear then
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then
										gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tweenservice:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
						for i,v in pairs(killauraboxes) do
							pcall(function()
								local attacked = killauratarget.Enabled and plrs[i] or nil
								v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
							end)
						end	
					until (not Killaura.Enabled)
				end)
			else
				vapeTargetInfo.Targets.Killaura = nil
				store.KillauraTarget = nil
				RunLoops:UnbindFromHeartbeat("Killaura")
				killauraNearPlayer = false
				for i,v in pairs(killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
				--[[bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
				bedwars.SoundManager.playSound = oldPlaySound
				oldViewmodelAnimation = nil--]]
				pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
					if originalArmC0 == nil then
						originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
					end
					if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenservice:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
					end
				end)
			end
		end,
		HoverText = "Attack players around you\nwithout aiming at them."
	})
	killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {"Distance"}
	for i,v in pairs(killaurasortmethods) do if i ~= "Distance" then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = "Sort",
		Function = function() end,
		List = sortmethods
	})
	killaurarange = Killaura.CreateSlider({
		Name = "Attack range",
		Min = 1,
		Max = 18,
		Function = function(val)
			if killaurarangecirclepart then
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end,
		Default = 18
	})
	--[[OneTapCooldown = Killaura.CreateSlider({
		Name = "OneTap Cooldown",
		Function = function() end,
		Min = 0,
		Max = 5,
		Default = 4.2
	})--]]
	killauraangle = Killaura.CreateSlider({
		Name = "Max angle",
		Min = 1,
		Max = 360,
		Function = function(val) end,
		Default = 360
	})
	killaurahitslowmode = Killaura.CreateSlider({
		Name = "Hit Slowmode",
		Min = 0,
		Max = 10,
		Function = function(val) end,
		Default = 0
	})
	local animmethods = {}
	for i,v in pairs(anims) do table.insert(animmethods, i) end
	killauraanimmethod = Killaura.CreateDropdown({
		Name = "Animation",
		List = animmethods,
		Function = function(val) end
	})
	local oldviewmodel
	local oldraise
	local oldeffect
	--[[killauraautoblock = Killaura.CreateToggle({
		Name = "AutoBlock",
		Function = function(callback)
			if callback then
				oldviewmodel = bedwars.ViewmodelController.setHeldItem
				bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
					if newItem and newItem.Name == "infernal_shield" then
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = bedwars.InfernalShieldController.raiseShield
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == "infernal_shield" then
					local sword, swordmeta = getSword()
					if sword then
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})--]]
	killauramouse = Killaura.CreateToggle({
		Name = "Require mouse down",
		Function = function() end,
		HoverText = "Only attacks when left click is held.",
		Default = false
	})
	--[[killauragui = Killaura.CreateToggle({
		Name = "GUI Check",
		Function = function() end,
		HoverText = "Attacks when you are not in a GUI."
	})--]]
	killauratargethighlight = Killaura.CreateToggle({
		Name = "Use New Highlight",
		Function = function(callback)
			for i, v in pairs(killauraboxes) do
				v:Remove()
			end
			for i = 1, 10 do
				local killaurabox
				if callback then
					killaurabox = Instance.new("Highlight")
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
						killaurabox.FillColor = GuiLibrary.GUICoreColor
						GuiLibrary.GUICoreColorChanged.Event:Connect(function()
							killaurabox.FillColor = GuiLibrary.GUICoreColor
						end)
					else
						killauracolorChanged.Event:Connect(function()
							killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
						end)
					end
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new("BoxHandleAdornment")
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
						killaurabox.Color3 = GuiLibrary.GUICoreColor
						GuiLibrary.GUICoreColorChanged.Event:Connect(function()
							killaurabox.Color3 = GuiLibrary.GUICoreColor
						end)
					else
						killauracolorChanged.Event:Connect(function()
							killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
						end)
					end
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = killauraboxSize
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauratarget = Killaura.CreateToggle({
		Name = "Show target",
		Function = function(callback)
			if killauratargethighlight.Object then
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = "Shows a red box over the opponent."
	})
	--[[killauracolor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val)
			for i,v in pairs(killauraboxes) do
				v[(killauratargethighlight.Enabled and "FillColor" or "Color3")] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})--]]
	killauracolor = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
	VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
		color = {Hue = h, Sat = s, Value = v}
		killauracolor = color
		killauracolorChanged:Fire()
	end))
	pcall(function()
		for i = 1, 10 do
			local killaurabox = Instance.new("BoxHandleAdornment")
			killaurabox.Transparency = 0.5
			killaurabox.Color3 = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
			killauracolorChanged.Event:Connect(function()
				killaurabox.Color3 = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
			end)
			killaurabox.Adornee = nil
			killaurabox.AlwaysOnTop = true
			killaurabox.Size = killauraboxSize
			killaurabox.ZIndex = 11
			killaurabox.Parent = GuiLibrary.MainGui
			killauraboxes[i] = killaurabox
		end
	end)
	killauracframe = Killaura.CreateToggle({
		Name = "Face target",
		Function = function() end,
		HoverText = "Makes your character face the opponent."
	})
	killaurarangecircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then
				createRangeCircle()
			else
				if killaurarangecirclepart then
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = "Aim Visualizer",
		Function = function(callback)
			if callback then
				killauraaimcirclepart = Instance.new("Part")
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
					killauraaimcirclepart.Color = GuiLibrary.GUICoreColor
					GuiLibrary.GUICoreColorChanged.Event:Connect(function()
						killauraaimcirclepart.Color = GuiLibrary.GUICoreColor
					end)
				else
					killauraaimcirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
					killauracolorChanged.Event:Connect(function()
						killauraaimcirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
					end)
				end
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = "Crit Particle",
		Function = function(callback)
			if callback then
				killauraparticlepart = Instance.new("Part")
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = killauraboxSize
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new("ParticleEmitter")
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
			else
				if killauraparticlepart then
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
	--[[killaurasound = Killaura.CreateToggle({
		Name = "No Swing Sound",
		Function = function() end,
		HoverText = "Removes the swinging sound."
	})--]]
	killauraswing = Killaura.CreateToggle({
		Name = "No Swing",
		Function = function() end,
		HoverText = "Removes the swinging animation."
	})
	killaurahandcheck = Killaura.CreateToggle({
		Name = "Sword Check",
		Function = function() end,
		HoverText = "Only attacks when your sword is held."
	})
	killauraanimation = Killaura.CreateToggle({
		Name = "Custom Animation",
		Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = "Uses a custom animation for swinging"
	})
	killauraanimationtween = Killaura.CreateToggle({
		Name = "No Tween",
		Function = function() end,
		HoverText = "Disable's the in and out ease"
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
		Name = "Synced Animation",
		Function = function() end,
		HoverText = "Times animation with hit attempt"
	})
	killauranovape = Killaura.CreateToggle({
		Name = "No Vape",
		Function = function() end,
		HoverText = "no hit vape user"
	})
	killauranovape.Object.Visible = false
	Killaura.CreateToggle({
		Name = "Sigrid Check",
		Default = false,
		Function = function(call)
			sigridcheck = call
		end
	})
end)

local LongJump = {Enabled = false}
run(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then
			local newray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, store.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		--[[fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = game.Workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = game.Workspace:Raycast(pos, Vector3.new(0, -30, 0), store.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:InvokeServer(fireball.tool, "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, game.Workspace:GetServerTimeNow() - 0.045)
			end)
		end,--]]
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2,
							block = block
						})
						bedwars.Client:Get(bedwars.CannonAimRemote):FireServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do
								local call = bedwars.Client:Get(bedwars.CannonLaunchRemote):InvokeServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block)})
								if call then
									bedwars.breakBlock(block)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < game.Workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < game.Workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new("Frame")
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new("TextLabel")
	LongJumpacprogressbartext.Text = "2.5s"
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in pairs(damagemethods) do
						local item = getItem(i)
						if item then
							if i == "tnt" then
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat("LongJump", function(dt)
						if entityLibrary.isAlive then
							if entityLibrary.character.Humanoid.Health <= 0 then
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then
								if newval then
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then
									LongJumpacprogressbartext.Text = newnum.."s"
								end
								if directionvec == nil then
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, store.blockRaycast)
								if ray then
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = "2.5s"
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then
								LongJumpacprogressbartext.Text = "2.5s"
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat("LongJump")
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end,
		HoverText = "Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)"
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

run(function()
    local NoFall = {}
	local MitigationChoice = {Value = "VelocityClamp"}
	local RishThreshold = {Value = 30}
    local PredictiveAnalysis = {}
    local MitigationStrategies = {}
    local velocityHistory = {}
    local maxHistory = 10
	local tracked = 0
    
    local function recordVelocity()
		if not entitylib.isAlive or not entitylib.character or not entitylib.character.HumanoidRootPart then return end
        local velocity = entitylib.character.HumanoidRootPart.Velocity
        table.insert(velocityHistory, velocity.Y)
        if #velocityHistory > maxHistory then
            table.remove(velocityHistory, 1)
        end
    end
    
    local function analyzeFallRisk()
        if #velocityHistory < maxHistory then return 0 end
        local downwardTrend = 0
        for i = 2, #velocityHistory do
            if velocityHistory[i] < velocityHistory[i - 1] and velocityHistory[i] < 0 then
                downwardTrend = downwardTrend + (velocityHistory[i - 1] - velocityHistory[i])
            end
        end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {lplr.Character}
        local rootPos = entitylib.character.HumanoidRootPart.Position
        local rayResult = workspace:Raycast(rootPos, Vector3.new(0, -50, 0), raycastParams)
        local distanceToGround = rayResult and (rootPos.Y - rayResult.Position.Y) or math.huge
        local riskFactor = downwardTrend * (distanceToGround > 10 and 1.5 or 1)
        return riskFactor, distanceToGround
    end
    
    local function hasMitigationItem()
        for _, item in pairs(store.localInventory.inventory.items) do
			if item and item.itemType and string.find(string.lower(tostring(item.itemType)), 'wool') then 
				return item
			end
        end
        return nil
    end
    
    MitigationStrategies.VelocityClamp = function(risk)
        if not entitylib.isAlive or not entitylib.character or not entitylib.character.HumanoidRootPart then return end
        local root = entitylib.character.HumanoidRootPart
        local currentVelocity = root.Velocity
        if currentVelocity.Y < -50 then
            root.Velocity = Vector3.new(currentVelocity.X, math.clamp(currentVelocity.Y, -50, math.huge), currentVelocity.Z)
        end
    end
    
    MitigationStrategies.TeleportBuffer = function(distance)
        if not entitylib.isAlive or not entitylib.character or not entitylib.character.HumanoidRootPart then return end
        local root = entitylib.character.HumanoidRootPart
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {lplr.Character}
        local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -distance - 2, 0), raycastParams)
        if rayResult and distance > 10 then
            local safePos = rayResult.Position + Vector3.new(0, 3, 0)
            pcall(function()
                root.CFrame = CFrame.new(safePos)
            end)
        end
    end
    
    MitigationStrategies.ItemDeploy = function(item)
        if not item then return end
        local root = entitylib.character.HumanoidRootPart
        local belowPos = root.Position - Vector3.new(0, 3, 0)
        bedwars.placeBlock(belowPos, item.itemType, true)
    end

	MitigationStrategies.HumanoidState = function()
		if entitylib.isAlive then
			tracked = entitylib.character.Humanoid.FloorMaterial == Enum.Material.Air and math.min(tracked, entitylib.character.RootPart.AssemblyLinearVelocity.Y) or 0
			if tracked < -85 then
				entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			end
		end
	end
    
    NoFall = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = 'NoFall',
        Function = function(callback)
            if callback then
                RunLoops:BindToHeartbeat('NoFallMonitor', function()
					recordVelocity()
					local risk, distance = analyzeFallRisk()
					if risk > RishThreshold.Value then
						if MitigationChoice.Value ~= "ItemDeploy" then
							MitigationStrategies[MitigationChoice.Value](MitigationChoice.Value == "VelocityClamp" and risk or MitigationChoice.Value == "TeleportBuffer" and distance)
						else
							local mitigationItem = hasMitigationItem()
							if mitigationItem then
								if distance < 10 then
									MitigationStrategies.ItemDeploy(mitigationItem)
								end
							else
								warningNotification("NoFall", "Mitigation Item not found. Using VelocityClamp instead...", 3)
								MitigationStrategies.VelocityClamp(risk)
							end
						end
					end
                end)
            else
                RunLoops:UnbindFromHeartbeat('NoFallMonitor')
                table.clear(velocityHistory)
				tracked = 0
            end
        end,
        HoverText = 'Prevents fall damage'
    })

	RishThreshold = NoFall.CreateSlider({
		Name = "Risk Threshold",
		Function = function() end,
		Min = 5,
		Max = 100,
		Default = 30
	})

	MitigationChoice = NoFall.CreateDropdown({
		Name = "Mitigation Strategies",
		Default = "HumanoidState",
		List = {"HumanoidState", "VelocityClamp", "TeleportBuffer", "ItemDeploy"},
		Function = function()
			if MitigationChoice.Value == "ItemDeploy" then
				warningNotification("Mitigation Strategies - ItemDeploy", "Not yet finished! Its recommended to use VelocityClamp instead.", 1.5)
			end
		end
	})
end)

--[[run(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoSlowdown",
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end,
		HoverText = "Prevents slowing down when using items."
	})
end)--]]

local spiderActive = false
local holdingshift = false
run(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = game.Workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Phase",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("Phase", function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {store.blocks, collectionService:GetTagged("spawn-cage")}
							local PhaseRayCheck = game.Workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Phase")
			end
		end,
		HoverText = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = "Blocks",
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

--[[run(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = "HumanoidRootPart"}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "ProjectileAimbot",
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find("arrow") == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = game.Workspace.Gravity
						local balloons = plr.Character:GetAttribute("InflatedBalloons")

						if balloons and balloons > 0 then
							playerGravity = (game.Workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then
							playerGravity = (game.Workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == "telepearl" then
							shootpos = pos
							shootvelo = Vector3.zero
						end

						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = "Part",
		List = {"HumanoidRootPart", "Head"},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = "Other Projectiles",
		Function = function() end,
		Default = true
	})
end)--]]

--until I find a way to make the spam switch item thing not bad I'll just get rid of it, sorry.
local Scaffold = {Enabled = false}
run(function()
	local scaffoldtext = Instance.new("TextLabel")
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = "0"
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	local AutoSwitch = {Enabled = false}
	task.spawn(function()
		for x = -3, 3, 3 do
			for y = -3, 3, 3 do
				for z = -3, 3, 3 do
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z))
					end
				end
			end
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then
			for i,v in pairs(store.blocks) do
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local WoolOnly = {Enabled = false}

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Scaffold",
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled and not AutoSwitch.Enabled then
							if store.localHand.Type ~= "block" then continue end
						end
						if ScaffoldMouseCheck.Enabled then
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if store.localHand.Type == "block" then
								wool = store.localHand.tool.Name
								woolamount = getItem(store.localHand.tool.Name).amount or 0
							elseif (not wool) and (not WoolOnly.Enabled) then
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or "0")
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							if AutoSwitch.Enabled then
								pcall(function() switchItem(wool) end)
							end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end

							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end,
		HoverText = "Helps you make bridges/scaffold walk."
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = "Expand",
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = "Build range"
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = "Diagonal",
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = "Tower",
		Function = function(callback)
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	WoolOnly = Scaffold.CreateToggle({
		Name = "Wool Only",
		Function = function() end,
		HoverText = "Only places blocks if they are wool."
	})
	AutoSwitch = Scaffold.CreateToggle({
		Name = "Auto Switch",
		Function = function() end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = "Require mouse down",
		Function = function(callback) end,
		HoverText = "Only places when left click is held.",
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = "Downwards",
		Function = function(callback) end,
		HoverText = "Goes down when left shift is held."
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = "Stop Motion",
		Function = function() end,
		HoverText = "Stops your movement when going up"
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = "Block Count",
		Function = function(callback)
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback
			end
		end,
		HoverText = "Shows the amount of blocks in the middle."
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = "Hand Check",
		Function = function() end,
		HoverText = "Only builds with blocks in your hand."
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = "Animation",
		Function = function() end
	})
end)

local antivoidvelo
--[[run(function()
    local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
    local SpeedDamageBoost = {Enabled = false}
    local raycastparameters = RaycastParams.new()
    local damagetick = tick()

    Speed = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if entityLibrary.isAlive then
						if GuiLibrary.ObjectsThatCanBeSaved["FlyOptionsButton"] and GuiLibrary.ObjectsThatCanBeSaved["FlyOptionsButton"].Api and GuiLibrary.ObjectsThatCanBeSaved["FlyOptionsButton"].Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved["InfiniteFlyOptionsButton"] and GuiLibrary.ObjectsThatCanBeSaved["InfiniteFlyOptionsButton"].Api and GuiLibrary.ObjectsThatCanBeSaved["InfiniteFlyOptionsButton"].Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved["LongJumpOptionsButton"] and GuiLibrary.ObjectsThatCanBeSaved["LongJumpOptionsButton"].Api and GuiLibrary.ObjectsThatCanBeSaved["LongJumpOptionsButton"].Api.Enabled then return end
						local speedValue = ((damagetick > tick() and SpeedValue.Value * 2.25 or SpeedValue.Value) * getSpeed(true))
						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and speedValue or (20 * getSpeed()))
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then 
							if SpeedMode.Value == "Heatseeker" then 
								speedValue = tick() % 1 < 0.6 and 5 or (20 * getSpeed(true)) / 0.4
							end
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end,
		HoverText = "Increases your movement speed",
		ExtraText = function() return SpeedMode.Value end
	})
	Speed.Restart = function()
		if Speed.Enabled then Speed.ToggleButton(false); Speed.ToggleButton(false) end
	end
	SpeedMode = Speed.CreateDropdown({
		Name = "Mode",
		Function = Speed.Restart,
		List = {"CFrame", "Normal", "Heatseeker"}
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Function = function() end,
		Min = 1,
		Max = 23,
		Default = 23
	})
    SpeedDamageBoost = Speed.CreateToggle({
		Name = "Damage Boost",
		Function = Speed.Restart,
		Default = true
	})
end)--]]
run(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local SpeedDamageBoost = {Enabled = false}
	local raycastparameters = RaycastParams.new()
	local damagetick = tick()

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				shared.SpeedBoostEnabled = SpeedDamageBoost.Enabled
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
						lastdamagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if store.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = damagetick > tick() and SpeedValue.Value * 2.25 - 1 or SpeedValue.Value + getSpeed()
						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end,
		HoverText = "Increases your movement.",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	Speed.Restart = function()
		if Speed.Enabled then Speed.ToggleButton(false); Speed.ToggleButton(false) end
	end
	SpeedDamageBoost = Speed.CreateToggle({
		Name = "Damage Boost",
		Function = Speed.Restart,
		Default = true
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23.3,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = "Big Mode Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump",
		Function = function(callback)
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = "Jump Sound",
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

run(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local function getPlacedBlock(pos, strict)
		if (not pos) then warn(debug.traceback("[getPlacedBlock]: pos is nil!")) return nil end
		local regionSize = Vector3.new(1, 1, 1)
		local region = Region3.new(pos - regionSize / 2, pos + regionSize / 2)
		local parts = game.Workspace:FindPartsInRegion3(region, nil, math.huge)
		local res 
		for _, part in pairs(parts) do
			if part and part.ClassName and part.ClassName == "Part" and part.Parent then
				if strict then
					if part.Parent.Name == 'Blocks' and part.Parent.ClassName == "Folder" then res = part end
				else
					res = part 
				end
			end
			break
		end
		return res
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Spider",
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat("Spider", function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == "Normal" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)), true)
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)), true)
							if newray and (not newray.CanCollide) then newray = nil end
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then
								SpiderPart = Instance.new("TrussPart")
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)), true)
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat("Spider")
				holdingshift = false
			end
		end,
		HoverText = "Lets you climb up walls"
	})
	SpiderMode = Spider.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Classic"},
		Function = function()
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

run(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new("Folder")
	BedESPFolder.Name = "BedESPFolder"
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedESP",
		Function = function(callback)
			if callback then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart.Name ~= 'Bed' then continue end
						local boxhandle = Instance.new("BoxHandleAdornment")
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
					if BedESPTable[bed] then
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in pairs(collectionService:GetTagged("bed")) do
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart:IsA("BasePart") then
							local boxhandle = Instance.new("BoxHandleAdornment")
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = "Render Beds through walls"
	})
end)

run(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute("NoBreak") and "unbreakable" or extrablock.Name)
				else
					table.insert(blocks, "unbreakable")
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in pairs(cachedNormalSides) do
			for i2,v2 in pairs(getallblocks2(pos, v)) do
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in pairs(getallblocks2(pos + Vector3.new(0, 0, 3), v)) do
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(bedblocks) do
			local blockimage = Instance.new("ImageLabel")
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new("Folder")
	BedPlatesFolder.Name = "BedPlatesFolder"
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = BedPlatesFolder
		billboard.Name = "bed"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedPlates",
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(v)
					if BedPlatesTable[v] then
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				task.spawn(function()
					repeat 
						for i, v in pairs(collectionService:GetTagged("bed")) do
							addBed(v)
						end
						task.wait(5)
						BedPlatesFolder:ClearAllChildren()
					until not BedPlates.Enabled
				end)
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

run(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in next, (ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
		local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in next, (chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
				local blockimage = Instance.new('ImageLabel')
				blockimage.Size = UDim2.new(0, 32, 0, 32)
				blockimage.BackgroundTransparency = 1
				blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
				blockimage.Parent = v.Frame
			end
		end
	end

	local ChestESPFolder = Instance.new('Folder')
	ChestESPFolder.Name = 'ChestESPFolder'
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {}
	local ChestESPBackground = {}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new('BillboardGui')
			billboard.Parent = ChestESPFolder
			billboard.Name = 'chest'
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new('Frame')
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new('UIListLayout')
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new('UICorner')
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild('ChestFolderValue').Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ChestESP',
		Function = function(calling)
			if calling then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal('chest'):Connect(chestfunc))
					for i,v in next, (collectionService:GetTagged('chest')) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = 'ItemList',
		TempText = 'item or part of item',
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = 'Background',
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

run(function()
	local FieldOfViewValue = {Value = 70}
	local FieldOfView = {Enabled = false}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() bedwars.SettingsController:setFOV(FieldOfViewValue.Value) until (not FieldOfView.Enabled)
				end)
			end
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.SettingsController:setFOV(FieldOfViewValue.Value)
			end
		end
	})
end)

run(function()
	local old
	local old2
	local oldhitpart
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local originaltextures = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until store.matchState ~= 0
			for i,v in pairs(store.blocks) do
				if v:GetAttribute("PlacedByUserId") == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v]
					for i2,v2 in pairs(v:GetChildren()) do
						pcall(function()
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FPSBoost",
		Function = function(callback)
			if callback then
				fpsboosttextures()
			else
				fpsboosttextures()
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = "Remove Textures",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

run(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = "GameTheme"}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				pcall(function()
					sethiddenproperty(lightingService, "Technology", "ShadowMap")
				end)
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = "13:00:00"
				lightingService.Sky.SkyboxBk = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxDn = "rbxassetid://6334928194"
				lightingService.Sky.SkyboxFt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxLf = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxRt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxUp = "rbxassetid://7018689553"
			end)
		end,
		Winter = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = game.Workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = "00:00:00"
				pcall(function() game.Workspace.Clouds:Destroy() end)
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() game.Workspace.Clouds:Destroy() end)
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameTheme",
		Function = function(callback)
			if callback then
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification("GameTheme", "Disabled Next Game", 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = "Theme",
		Function = function() end,
		List = {"Old", "Winter", "Halloween", "Valentines"}
	})
end)

run(function()
	local oldkilleffect
	local KillEffectMode = {Value = "Gravity"}
	local KillEffectList = {Value = "None"}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			pcall(function() p5:BreakJoints() end)
			task.spawn(function()
				local partvelo = {}
				for i,v in pairs(p5:GetDescendants()) do
					if v:IsA("BasePart") then
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = game.Workspace
				local nametag = clone:FindFirstChild("Nametag", true)
				if nametag then nametag:Destroy() end
				game:GetService("Debris"):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				pcall(function() clone:BreakJoints() end)
				task.wait(0.01)
				for i,v in pairs(clone:GetDescendants()) do
					if v:IsA("BasePart") then
						local bodyforce = Instance.new("BodyForce")
						bodyforce.Force = Vector3.new(0, (game.Workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			pcall(function() p5:BreakJoints() end)
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then
					newpos2 = Vector3.zero
				end
				local part = Instance.new("Part")
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = game.Workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = game.Workspace
				game:GetService("Debris"):AddItem(part, 0.5)
				game:GetService("Debris"):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then
					local soundpart = Instance.new("Part")
					soundpart.Transparency = 1
					soundpart.Anchored = true
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = game.Workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6993372814"
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in pairs(bedwars.KillEffectMeta) do
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KillEffect",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute("KillEffectType", "none")
						if KillEffectMode.Value == "Bedwars" then
							lplr:SetAttribute("KillEffectType", KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {"Bedwars"}
	for i,v in pairs(killeffects) do
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = "Mode",
		Function = function()
			if KillEffect.Enabled then
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = "Bedwars",
		Function = function()
			if KillEffect.Enabled then
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

local function addBlur(parent)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = 'rbxassetid://14898786664'
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.Parent = parent
	return blur
end

run(function()
	local KitESP = {Enabled = false}
	local Connections = {}
	local Background = {Enabled = true}
	local Color = {Hue = 30, Sat = 30, Value = 30}
	local espobjs = {}
	local espfold = Instance.new("Folder")
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local blur = addBlur(billboard)
		blur.Visible = Background.Enabled
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Background.Enabled and Color3.fromHSV(Color.Hue, Color.Sat, Color.Value) or Color3.fromRGB(30, 30, 30)
		image.BackgroundTransparency = not Background.Enabled and 1 or 0
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon, custom)
		if (not custom) then
			local con1, con2, con3 = collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
				espadd(v.PrimaryPart, icon)
			end), collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
				espadd(v.PrimaryPart, icon)
			end), collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
				if espobjs[v.PrimaryPart] then
					espobjs[v.PrimaryPart]:Destroy()
					espobjs[v.PrimaryPart] = nil
				end
			end)
			table.insert(Connections, con1)
			table.insert(Connections, con2)
			table.insert(Connections, con3)
		else
			local function check(v)
				if v.Name == tag and v.ClassName == "Model" then
					espadd(v.PrimaryPart, icon)
				end
			end
			local con1, con2 = game.Workspace.ChildAdded:Connect(check), game.Workspace.ChildRemoved:Connect(function(v)
				pcall(function()
					if espobjs[v.PrimaryPart] then
						espobjs[v.PrimaryPart]:Destroy()
						espobjs[v.PrimaryPart] = nil
					end
				end)
			end)
			table.insert(Connections, con1)
			table.insert(Connections, con2)
			for i,v in pairs(game.Workspace:GetChildren()) do
				check(v)
			end
		end
	end

	local esptbl = {
		["metal_detector"] = {
			{"hidden-metal", "iron"}
		},
		["beekeeper"] = {
			{"bee", "bee"}
		},
		["bigman"] = {
			{"treeOrb", "natures_essence_1"}
		},
		["alchemist"] = {
			{"Thorns", "thorns", true},
			{"Mushrooms", "mushrooms", true},
			{"Flower", "wild_flower", true}
		},
		["star_collector"] = {
			{"CritStar", "crit_star", true},
			{"VitalityStar", "vitality_star", true}
		},
		["spirit_gardener"] = {
			{"SpiritGardenerEnergy", "spirit", true}
		}
	}

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KitESP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if KitESP.Enabled then
						local p1 = esptbl[store.equippedKit]
						if (not p1) then return end
						for i,v in pairs(p1) do 
							addKit(unpack(v))
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
				for i,v in pairs(Connections) do
					pcall(function() v:Disconnect() end)
				end
			end
		end
	})
	
	Background = KitESP.CreateToggle({
		Name = 'Background',
		Function = function(callback)
			if Color and Color.Object then Color.Object.Visible = callback end
			for _, v in espobjs do
				v.Blur.Visible = callback
			end
		end,
		Default = true
	})
	Color = KitESP.CreateColorSlider({
		Name = 'Background Color',
		DefaultValue = 0,
		DefaultOpacity = 0.5,
		Function = function(hue, sat, val)
			for _, v in espobjs do
				v.ImageLabel.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		end,
		Darker = true
	})
end)

run(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
		str = str:gsub("<br%s*/>", "\n")
		return (str:gsub("<[^<>]->", ""))
	end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = "jade_hammer",
		archer = "tactical_crossbow",
		angel = "",
		cowgirl = "lasso",
		dasher = "wood_dao",
		axolotl = "axolotl",
		yeti = "snowball",
		smoke = "smoke_block",
		trapper = "snap_trap",
		pyro = "flamethrower",
		davey = "cannon",
		regent = "void_axe",
		baker = "apple",
		builder = "builder_hammer",
		farmer_cletus = "carrot_seeds",
		melody = "guitar",
		barbarian = "rageblade",
		gingerbread_man = "gumdrop_bounce_pad",
		spirit_catcher = "spirit",
		fisherman = "fishing_rod",
		oil_man = "oil_consumable",
		santa = "tnt",
		miner = "miner_pickaxe",
		sheep_herder = "crook",
		beast = "speed_potion",
		metal_detector = "metal_detector",
		cyber = "drone",
		vesta = "damage_banner",
		lumen = "light_sword",
		ember = "infernal_saber",
		queen_bee = "bee"
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = whitelist:tag(plr.Player, true)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health).."</font>"
			end
			if NameTagsDistance.Enabled then
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new("ImageLabel")
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = "Hand"
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ""
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = "Helmet"
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = "Chestplate"
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = "Boots"
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = "Kit"
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute("PlayingAsKit") ~= ""
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute("PlayingAsKit")] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute("PlayingAsKit")]}, NameTagsShowInventory.Enabled) or ""
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new("Text")
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new("Square")
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = whitelist:tag(plr.Player, true)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then
				nametagstrs[ent.Player] = whitelist:tag(ent.Player, true)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then
					local inventory = store.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find("rbxasset://") then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ""
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find("rbxasset://") then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ""
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find("rbxasset://") then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ""
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find("rbxasset://") then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ""
					end
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then
				nametagstrs[ent.Player] = whitelist:tag(ent.Player, true)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			pcall(function()
				for i,v in pairs(nametagsfolderdrawing) do
					local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
					if not headVis then
						v.Main.Visible = false
						continue
					end
					local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
					if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then
						v.Main.Visible = false
						continue
					end
					if NameTagsDistance.Enabled then
						local stringsize = tostring(mag):len()
						if nametagsizes[v.entity.Player] ~= stringsize then
							local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
							v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
						end
						nametagsizes[v.entity.Player] = stringsize
						v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
					end
					v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
					v.Main.Visible = true
				end
			end)
		end,
		Drawing = function()
			for i,v in pairs(nametagsfolderdrawing) do
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags",
		Function = function(callback)
			if callback then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in pairs(entityLibrary.entityList) do
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in pairs(entityLibrary.entityList) do
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then
					RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("NameTags")
				if nametagfuncs2[methodused] then
					for i,v in pairs(nametagsfolderdrawing) do
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in pairs(Enum.Font:GetEnumItems()) do
		if v.Name ~= "SourceSans" then
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = "Font",
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = "Player Color",
		Function = function(hue, sat, val)
			if NameTags.Enabled and nametagcolorfuncs[methodused] then
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = "Scale",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = "Background",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = "Use Display Name",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = "Health",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = "Distance",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = "Equipment",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = "Teammates",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = "Drawing",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

run(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NoBob",
		Function = function(callback)
			local viewmodel = gameCamera:FindFirstChild("Viewmodel")
			if viewmodel then
				if callback then
					--oldfunc = bedwars.ViewmodelController.playAnimation
					--[[bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end--]]
					--bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					--bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = "Removes the ugly bobbing when you move and makes sword farther"
	})
	nobobdepth = nobob.CreateSlider({
		Name = "Depth",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = "RotX",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = "RotY",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = "RotZ",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

run(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = game.Workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled)
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService("TweenService"):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SongBeats",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then
						warningNotification("SongBeats", "no songs", 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				--gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = "Intensity",
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

run(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AntiAFK",
		Function = function(callback)
			if callback then
				bedwars.Client:Get("AfkInfo"):FireServer({
					afk = false
				})
			end
		end
	})
end)

run(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBalloon",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in pairs(store.blocks) do
							local newray = game.Workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.blockRaycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new("Part")
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = store.localHand.tool
								for i = 1, 3 do
									if getItem("balloon") and (AutoBalloonLegit.Enabled and getHotbarSlot("balloon") or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") < 3 or lplr.Character:GetAttribute("InflatedBalloons") == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot("balloon") then
												bedwars.ClientStoreHandler:dispatch({
													type = "InventorySelectHotbarSlot",
													slot = getHotbarSlot("balloon")
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = "InventorySelectHotbarSlot",
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = game.Workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove()
				end
			end
		end,
		HoverText = "Automatically Inflates Balloons"
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = "Delay to inflate balloons."
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = "Legit Mode",
		Function = function() end,
		HoverText = "Switches to balloons in hotbar and inflates them."
	})
end)

local autobankapple = false
run(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyAxolotl = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = "leather_chestplate",
		[2] = "iron_chestplate",
		[3] = "diamond_chestplate",
		[4] = "emerald_chestplate"
	}

	local swords = {
		[1] = "wood_sword",
		[2] = "stone_sword",
		[3] = "iron_sword",
		[4] = "diamond_sword",
		[5] = "emerald_sword"
	}

	local scythes = {
		[1] = "wood_scythe",
		[2] = "stone_scythe",
		[3] = "iron_scythe",
		[4] = "diamond_scythe",
		[5] = "mythic_scythe"
	}

	local axes = {
		[1] = "wood_axe",
		[2] = "stone_axe",
		[3] = "iron_axe",
		[4] = "diamond_axe"
	}

	local pickaxes = {
		[1] = "wood_pickaxe",
		[2] = "stone_pickaxe",
		[3] = "iron_pickaxe",
		[4] = "diamond_pickaxe"
	}
	
	local axolotls = {
		[1] = "shield_axolotl",
		[2] = "damage_axolotl",
		[3] = "break_speed_axolotl",
		[4] = "health_regen_axolotl"
 	}

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
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == "✅"  end)
			if AutoBankDeath.Enabled and (game.Workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")) < 2 and suc and res then
				return nil, false, false
			end
			if AutoBankStay.Enabled then
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		res = bedwars.Client:Get("BedwarsPurchaseItem"):InvokeServer({
			shopItem = itemtab,
			shopId = id
		})
		if waitdelay then
			repeat task.wait() until res ~= nil
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or store.localInventory.inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or store.localInventory.inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == "axe" then
			itemType = getAxeNear() or "wood_axe"
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == "pickaxe" then
			itemType = getPickaxeNear() or "wood_pickaxe"
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in pairs(bedwars.ShopItems) do
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local function metafyAxolotl(name)
		local data = {
			["ShieldAxolotl"] = "shield_axolotl",
			["DamageAxolotl"] = "damage_axolotl",
			["BreakSpeedAxolotl"] = "break_speed_axolotl",
			["HealthRegenAxolotl"] = "health_regen_axolotl"
		}
		return data[name] or ""
	end

	local function getAxolotls()
		local res = {}
		local data_folder = workspace:FindFirstChild("AxolotlModel")
		if not data_folder then return res, true end

		for i,v in pairs(data_folder:GetChildren()) do
			if v.ClassName ~= "Model" then continue end
			local owner = v:FindFirstChild("AxolotlData")
			if not owner then continue end
			if owner.ClassName ~= "ObjectValue" then continue end
			if not owner.Value then continue end
			if tostring(owner.Value) == lplr.Name.."_Axolotl" then
				table.insert(res, {
					axolotlType = v.Name,
					name = metafyAxolotl(v.Name)
				})
			end
		end

		return res
	end

	local function getAxolotl(metaName, inv)
		for i,v in pairs(inv) do
			if v.name == metaName then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype)
			--- shopType doesnt matter :shrug:
			local inv = store.localInventory.inventory
			local armor = inv.armor
			local currentArmor = armor[2]
			if type(currentArmor) ~= "table" then currentArmor = {itemType = ""} end
			if tostring(currentArmor.itemType) == "nil" then currentArmor = {itemType = ""} end
			local armorToBuy
			if currentArmor.itemType == "" then armorToBuy = "leather_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("leather") then armorToBuy = "iron_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("iron") then armorToBuy = "diamond_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("diamond") then armorToBuy = "emerald_chestplate" end
			if currentArmor.itemType ~= "" and currentArmor.itemType:find("emerald") then armorToBuy = "none" end
			local shopitem = getShopItem(armorToBuy)
			if shopitem then
				local currency = getItem(shopitem.currency, inv.items)
				if currency and currency.amount >= shopitem.price then
					buyItem(getShopItem(armorToBuy))
				end
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			local inv = store.localInventory.inventory
			local currentsword = shared.scythexp and getItemNear("scythe", inv.items) or getItemNear("sword", inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if shared.scythexp then
				swordindex = (currentsword and table.find(scythes, currentsword.itemType) or 0) + 1
			end
			if getItemNear("scythe", inv.items) then 
				if currentsword ~= nil and table.find(scythes, currentsword.itemType) == nil then return end
			else
				if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			end
			local highestbuyable = nil
			local tableToDo = shared.scythexp and scythes or swords
			for i = swordindex, #tableToDo, 1 do
				local shopitem = shared.scythexp and getShopItem(scythes[i]) or getShopItem(swords[i])
				if shopitem and i == swordindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then
						highestbuyable = shopitem
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end,
		Axolotl = function(inv, upgrades, shoptype)
			if store.equippedKit ~= "axolotl" then return end
			if not AutoBuyAxolotl.Enabled then return end

			local inv = store.localInventory.inventory
			local inv_axolotls, abort = getAxolotls()
			if abort then return end

			local tableToDo = axolotls

			local axolotlindex = 0
			for i,v in pairs(axolotls) do
				if getAxolotl(v, inv_axolotls) then
					axolotlindex = i
				end
			end
			axolotlindex = axolotlindex + 1

			local highestbuyable = nil
			for i = axolotlindex, #tableToDo, 1 do
				local shopitem = getShopItem(axolotls[i])
				if shopitem and i == axolotlindex then
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then
						highestbuyable = shopitem
					end
				end
			end

			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, store.equippedKit) == nil) then
				buyItem(highestbuyable)
			end
		end	
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBuy",
		Function = function(callback)
			if callback then
				buyingthing = false
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = store.localInventory.inventory
							local currentupgrades = {}
							if store.equippedKit == "dasher" then
								swords = {
									[1] = "wood_dao",
									[2] = "stone_dao",
									[3] = "iron_dao",
									[4] = "diamond_dao",
									[5] = "emerald_dao"
								}
							elseif store.equippedKit == "ice_queen" then
								swords[5] = "ice_sword"
							elseif store.equippedKit == "ember" then
								swords[5] = "infernal_saber"
							elseif store.equippedKit == "lumen" then
								swords[5] = "light_sword"
							elseif store.equippedKit == "pyro" then
								swords[6] = "flamethrower"
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen("BedwarsItemShopApp") or bedwars.AppController:isAppOpen("BedwarsTeamUpgradeApp"))) and (not enchant) then
								for i,v in pairs(AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] ~= "true" then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in pairs(buyfunctions) do v(inv, currentupgrades, npctype and "upgrade" or "item") end
								for i,v in pairs(AutoBuyCustom.ObjectList) do
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] == "true" then
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = "Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC"
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = "Buy Armor",
		Function = function() end,
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = "Buy Sword",
		Function = function() end,
		Default = true
	})
	AutoBuyAxolotl = AutoBuy.CreateToggle({
		Name = "Buy Axolotl",
		Function = function() end,
		Default = true
	})
	AutoBuyAxolotl.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until store.equippedKit ~= ""
		AutoBuyAxolotl.Object.Visible = store.equippedKit == "axolotl"
	end)
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = "Shop GUI Check",
		Function = function() end,
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = "Tier Skip",
		Function = function() end,
		Default = true
	})
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = "BuyList",
		TempText = "item/amount/priority/after",
		SortFunction = function(a, b)
			local amount1 = a:split("/")
			local amount2 = b:split("/")
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14
end)

run(function()
    local function getDiamonds()
        local function getItem(itemName, inv)
            for slot, item in pairs(inv or store.localInventory.inventory.items) do
                if item.itemType == itemName then
                    return item, slot
                end
            end
            return nil
        end
        local inv = store.localInventory.inventory
        if inv.items and type(inv.items) == "table" and getItem("diamond", inv.items) and getItem("diamond", inv.items).amount then 
            return tostring(getItem("diamond", inv.items).amount) ~= "inf" and tonumber(getItem("diamond", inv.items).amount) or 9999999999999
        else 
            --warn("failure", inv.items, type(inv.items) == "table", getItem("diamond", inv.items))
            return 0 
        end
    end
    local resolve = {
        ["Armor"] = {
            Name = "ARMOR",
            Upgrades = {[1] = 4, [2] = 8, [3] = 20},
            CurrentUpgrade = 0,
            Function = function()

            end
        },
        ["Damage"] = {
            Name = "DAMAGE",
            Upgrades = {[1] = 5, [2] = 10, [3] = 18},
            CurrentUpgrade = 0,
            Function = function()

            end
        },
        ["Diamond Gen"] = {
            Name = "DIAMOND_GENERATOR",
            Upgrades = {[1] = 4, [2] = 8, [3] = 12},
            CurrentUpgrade = 0,
            Function = function()

            end
        },
        ["Team Gen"] = {
            Name = "TEAM_GENERATOR",
            Upgrades = {[1] = 4, [2] = 8, [3] = 16},
            CurrentUpgrade = 0,
            Function = function()

            end
        }
    }
    local function buyUpgrade(translation)
        if not translation or not resolve[translation] or not type(resolve[translation]) == "table" then return warn(debug.traceback("[buyUpgrade]: Invalid translation given! "..tostring(translation))) end
        local res = bedwars.Client:Get("RequestPurchaseTeamUpgrade"):InvokeServer(resolve[translation].Name)
        if res == true then resolve[translation].CurrentUpgrade = resolve[translation].CurrentUpgrade + 1 else
            if getDiamonds() >= resolve[translation].Upgrades[resolve[translation].CurrentUpgrade + 1] then
                local res2 = bedwars.Client:Get("RequestPurchaseTeamUpgrade"):InvokeServer(resolve[translation].Name)
                if res2 == true then resolve[translation].CurrentUpgrade = resolve[translation].CurrentUpgrade + 1 else
                    warn("Using force use of current upgrade...", translation, tostring(res), tostring(res2))
                    resolve[translation].CurrentUpgrade = resolve[translation].CurrentUpgrade + 1
                end
            end
        end
    end
    local function resolveTeamUpgradeApp(app)
        if (not app) or not app:IsA("ScreenGui") then return "invalid app! "..tostring(app) end
        local function findChild(name, className, children)
            for i,v in pairs(children) do if v.Name == name and v.ClassName == className then return v end end
            local args = {Name = tostring(name), ClassName == tostring(className), Children = children}
            warn(debug.traceback("[findChild]: CHILD NOT FOUND! Args: "), game:GetService("HttpService"):JSONEncode(args), name, className, children)
            return nil
        end
        local function resolveCard(card, translation)
            local a = "["..tostring(card).." | "..tostring(translation).."] "
            local suc, res = true, a
            local function p(b) suc = false; res = a..tostring(b).." not found!" return suc, res end
            if not card or not translation or not card:IsA("Frame") then suc = false; res = a.."Invalid use of resolveCard!" return suc, res end
            translation = tostring(translation)
            local function resolveUpgradeCost(cost)
                if not cost then return warn(debug.traceback("[resolveUpgradeCost]: Invalid cost given!")) end
                cost = tonumber(cost)
                if resolve[translation] and resolve[translation].Upgrades and type(resolve[translation].Upgrades) == "table" then
                    for i,v in pairs(resolve[translation].Upgrades) do 
                        if v == cost then return i end
                    end
                end
            end
            local Content = findChild("Content", "Frame", card:GetChildren())
            if Content then
                local PurchaseSection = findChild("PurchaseSection", "Frame", Content:GetChildren())
                if PurchaseSection then
                    local Cost_Info = findChild("Cost Info", "Frame", PurchaseSection:GetChildren())
                    if Cost_Info then
                        local Current_Diamond_Required = findChild("2", "TextLabel", Cost_Info:GetChildren())
                        if Current_Diamond_Required then
                            local upgrade = resolveUpgradeCost(Current_Diamond_Required.Text)
                            if upgrade then
                                resolve[translation].CurrentUpgrade = upgrade - 1
                            else warn("invalid upgrade", translation, Current_Diamond_Required.Text) end
                        else return p("Card->Content->PurchaseSection->Cost Info") end
                    else resolve[translation].CurrentUpgrade = 3 return p("Card->Content->PurchaseSection->Cost Info") end
                else return p("Card->Content->PurchaseSection") end
            else return p("Card->Content") end
        end
        local frame2 = findChild("2", "Frame", app:GetChildren())
        if frame2 then
            local TeamUpgradeAppContainer = findChild("TeamUpgradeAppContainer", "ImageButton", frame2:GetChildren())
            if TeamUpgradeAppContainer then
                local UpgradesWrapper = findChild("UpgradesWrapper", "Frame", TeamUpgradeAppContainer:GetChildren())
                if UpgradesWrapper then
                    local suc1, res1, suc2, res2, suc3, res3, suc4, res4 = resolveCard(findChild("ARMOR_Card", "Frame", UpgradesWrapper:GetChildren()), "Armor"), resolveCard(findChild("DAMAGE_Card", "Frame", UpgradesWrapper:GetChildren()), "Damage"), resolveCard(findChild("DIAMOND_GENERATOR_Card", "Frame", UpgradesWrapper:GetChildren()), "Diamond Gen"), resolveCard(findChild("TEAM_GENERATOR_Card", "Frame", UpgradesWrapper:GetChildren()), "Team Gen")
                end
            end
        end
    end
    local function check(app) if app.Name and app:IsA("ScreenGui") and app.Name == "TeamUpgradeApp" then resolveTeamUpgradeApp(app) end end
    local con = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui").ChildAdded:Connect(check)
    GuiLibrary.SelfDestructEvent.Event:Connect(function() pcall(function() con:Disconnect() end) end)
    for i, app in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do check(app) end

    local bedwarsshopnpcs = {}
    task.spawn(function()
		repeat task.wait() until store.matchState ~= 0 or not shared.VapeExecuted
		for i,v in pairs(collectionService:GetTagged("TeamUpgradeShopkeeper")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

    local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
		end
		return npc, not npccheck, enchant, newid
	end

    local AutoBuyDiamond = {Enabled = false}
    local PreferredUpgrade = {Value = "Damage"}
    local AutoBuyDiamondGui = {Enabled = false}
    local AutoBuyDiamondRange = {Value = 20}

    AutoBuyDiamond = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "AutoBuyDiamondUpgrades",
        Function = function(call)
            if call then
                repeat task.wait()
                    if nearNPC(AutoBuyDiamondRange.Value) then
                        if (not AutoBuyDiamondGui.Enabled) or bedwars.AppController:isAppOpen("TeamUpgradeApp") then
                            if resolve[PreferredUpgrade.Value].CurrentUpgrade ~= 3 and getDiamonds() >= resolve[PreferredUpgrade.Value].Upgrades[resolve[PreferredUpgrade.Value].CurrentUpgrade + 1] then buyUpgrade(PreferredUpgrade.Value) end
                            for i,v in pairs(resolve) do if v.CurrentUpgrade ~= 3 and getDiamonds() >= v.Upgrades[v.CurrentUpgrade + 1] then buyUpgrade(i) end end
                        end
                    end
                until (not AutoBuyDiamond.Enabled)
            end
        end,
        HoverText = "Auto buys diamond upgrades"
    })
    AutoBuyDiamond.Restart = function() if AutoBuyDiamond.Enabled then AutoBuyDiamond.ToggleButton(false); AutoBuyDiamond.ToggleButton(false) end end
    AutoBuyDiamondRange = AutoBuyDiamond.CreateSlider({
        Name = "Range",
        Function = function() end,
        Min = 1,
        Max = 20,
        Default = 20
    })
    local real_list = {}
    for i,v in pairs(resolve) do table.insert(real_list, tostring(i)) end
    PreferredUpgrade = AutoBuyDiamond.CreateDropdown({
        Name = "PreferredUpgrade",
        Function = AutoBuyDiamond.Restart,
        List = real_list,
        Default = "Damage"
    })
    AutoBuyDiamondGui = AutoBuyDiamond.CreateToggle({
        Name = "Gui Check",
        Function = AutoBuyDiamond.Restart
    })
end)

run(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeStar = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						--[[local newray = game.Workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), store.blockRaycast)
						print("newray: ", tostring(newray))
						if newray ~= nil then
							local res = bedwars.Client:Get(bedwars.ProjectileRemote):InvokeServer(pot.tool, "heal_splash_potion", "heal_splash_potion", (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService("HttpService"):GenerateGUID(), {drawDurationSeconds = 1})
							print("res: ", tostring(res))
						end--]]
					end
				end
			else
				autobankapple = false
			end
			local starItem = AutoConsumeStar.Enabled and (getItem("vitality_star") or getItem("crit_star"))
			if starItem then
				bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
					item = starItem.tool
				})
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then
				bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.Client:Get(bedwars.EatRemote):InvokeServer({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoConsume",
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find("Shield") or changed:find("Health") or changed:find("speed") then
						AutoConsumeFunc()
					end
				end))
				task.spawn(function()
					repeat task.wait(1)
						AutoConsumeFunc()
					until (not AutoConsume.Enabled)
				end)
				AutoConsumeFunc()
			end
		end,
		HoverText = "Automatically heals for you when health or shield is under threshold."
	})
	AutoConsume.Restart = function() if AutoConsume.Enabled then AutoConsume.ToggleButton(false); AutoConsume.ToggleButton(false) end end
	AutoConsumeStar = AutoConsume.CreateToggle({
		Name = "Auto Consume Stars",
		Function = AutoConsumeStar.Restart,
		Default = true
	})
	AutoConsumeStar.Object.Visible = (store.equippedKit == "star_collector")
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = "Health",
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = "Speed Potions",
		Function = function() end,
		Default = true
	})
end)

--[[run(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = "Toggle"}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == "swords" then
			local sword = getSword()
			realitem = sword and sword.itemType or "wood_sword"
		elseif realitem == "pickaxes" then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or "wood_pickaxe"
		elseif realitem == "axes" then
			local axe = getAxe()
			realitem = axe and axe.itemType or "wood_axe"
		elseif realitem == "bows" then
			local bow = getBow()
			realitem = bow and bow.itemType or "wood_bow"
		elseif realitem == "wool" then
			realitem = getWool() or "wool_white"
		end
		return realitem
	end

	local function findItemInTable(tab, item)
		for i, v in pairs(tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in pairs(store.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in pairs(store.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in pairs(store.localInventory.inventory.items) do
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = store.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar",
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar",
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryAddToHotbar",
							item = nextitem1,
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = "InventoryAddToHotbar",
						item = nextitem2,
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = "InventoryRemoveFromHotbar",
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoHotbar",
		Function = function(callback)
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == "On Key" then
					if AutoHotbar.Enabled then
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = "Automatically arranges hotbar to your liking."
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = "lol"
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = "Clear Hotbar",
		Function = function() end
	})
end)--]]

run(function()
	local AutoKit = {Enabled = false, Connections = {}}
	local AutoKitTrinity = {Value = "Void"}
	local Legit = {Enabled = false}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = GetAllNearestHumanoidToPosition(true, 30, 1000, true)
		local lowest, lowestplayer = 10000, nil
		for i,v in pairs(plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute("Health") <= lowest and v.Character:GetAttribute("Health") < v.Character:GetAttribute("MaxHealth") then
					lowest = v.Character:GetAttribute("Health")
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end

	local function collection(tags, module, customadd, customremove)
		tags = typeof(tags) ~= 'table' and {tags} or tags
		local objs, connections = {}, {}
	
		for _, tag in tags do
			table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
				if customadd then
					customadd(objs, v, tag)
					return
				end
				table.insert(objs, v)
			end))
			table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
				if customremove then
					customremove(objs, v, tag)
					return
				end
				v = table.find(objs, v)
				if v then
					table.remove(objs, v)
				end
			end))
	
			for _, v in collectionService:GetTagged(tag) do
				if customadd then
					customadd(objs, v, tag)
					continue
				end
				table.insert(objs, v)
			end
		end
	
		local cleanFunc = function(self)
			for _, v in connections do
				v:Disconnect()
			end
			table.clear(connections)
			table.clear(objs)
			table.clear(self)
		end
	
		return objs, cleanFunc
	end

	local function kitCollection(id, func, range, specific)
		local objs = type(id) == 'table' and id or collection(id, AutoKit)
		repeat
			if entitylib.isAlive then
				local localPosition = entitylib.character.HumanoidRootPart.Position
				for _, v in objs do
					if not AutoKit.Enabled then break end
					local part = not v:IsA('Model') and v or v.PrimaryPart
					if part and (part.Position - localPosition).Magnitude <= (not Legit.Enabled and specific and math.huge or range) then
						func(v)
					end
				end
			end
			task.wait(0.1)
		until not AutoKit.Enabled
	end

	local AutoKit_Functions = {
		ember = function()
			shared.EmberAutoKit = true
		end,
		hannah = function()
			kitCollection('HannahExecuteInteraction', function(v)
				local billboard = bedwars.Client:Get("HannahPromptTrigger"):InvokeServer({
					user = lplr,
					victimEntity = v
				}) and v:FindFirstChild('Hannah Execution Icon')
	
				if billboard then
					billboard:Destroy()
				end
			end, 30, true)
		end,
		wizard = function()
			repeat
				local ability = lplr:GetAttribute('WizardAbility')
				if ability and bedwars.AbilityController:canUseAbility(ability) then
					local plr = EntityNearPosition(50, true)
	
					if plr then
						bedwars.AbilityController:useAbility(ability, {target = plr.RootPart.Position})
					end
				end
	
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		warlock = function()
			local lastTarget
			repeat
				if store.hand.tool and store.hand.tool.Name == 'warlock_staff' then
					local plr = EntityNearPosition(30, false)
	
					if plr and plr.Character ~= lastTarget then
						if not bedwars.WarlockController:link(plr) then
							plr = nil
						end
					end
	
					lastTarget = plr and plr.Character
				else
					lastTarget = nil
				end
	
				task.wait(0.1)
			until not AutoKit.Enabled
		end,
		["star_collector"] = function()
			local function fetchItem(obj)
				local args = {
					[1] = {
						["id"] = obj:GetAttribute("Id"),
						["collectableName"] = obj.Name
					}
				}
				local res = bedwars.Client:Get("CollectCollectableEntity"):FireServer(unpack(args))
			end
			local allowedNames = {"CritStar", "VitalityStar"}
			task.spawn(function()
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						local maxDistance = 30
						for i,v in pairs(game.Workspace:GetChildren()) do
							if v.Parent and v.ClassName == "Model" and table.find(allowedNames, v.Name) and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
								local pos1 = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
								local pos2 = v.PrimaryPart.Position
								if (pos1 - pos2).Magnitude <= maxDistance then
									fetchItem(v)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["spirit_assassin"] = function()
			repeat
				task.wait()
				bedwars.SpiritAssassinController:Invoke()
			until (not AutoKit.Enabled)
		end,
		["alchemist"] = function()
			table.insert(AutoKit.Connections, game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
				if AutoKit.Enabled then
					local parts = string.split(msg, " ")
					if parts[1] and (parts[1] == "/recipes" or parts[1] == "/potions") then
						local potions = bedwars.ItemTable["brewing_cauldron"].crafting.recipes
						local function resolvePotionsData(data)
							local finalData = {}
							for i,v in pairs(data) do
								local result = v.result
								local brewingTime = v.timeToCraft
								local recipe = ""
								for i2, v2 in pairs(v.ingredients) do
									recipe = recipe ~= "" and recipe.." + "..tostring(v2) or recipe == "" and recipe..tostring(v2)
								end
								table.insert(finalData, {
									Result = result, 
									BrewingTime = brewingTime,
									Recipe = recipe
								})
							end
							return finalData
						end
						for i,v in pairs(resolvePotionsData(potions)) do
							local text = v.Result..": "..v.Recipe.." ("..tostring(v.BrewingTime).."seconds)"
							game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
								Text = text,
								Color = Color3.new(255, 255, 255),
								Font = Enum.Font.SourceSans,
								FontSize = Enum.FontSize.Size36
							})
						end
					end
				end
			end))
			local function fetchItem(obj)
				local args = {
					[1] = {
						["id"] = obj:GetAttribute("Id"),
						["collectableName"] = obj.Name
					}
				}
				local res = bedwars.Client:Get("CollectCollectableEntity"):FireServer(unpack(args))
			end
			local allowedNames = {"Thorns", "Mushrooms", "Flower"}
			task.spawn(function()
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						local maxDistance = 30
						for i,v in pairs(game.Workspace:GetChildren()) do
							if v.Parent and v.ClassName == "Model" and table.find(allowedNames, v.Name) and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
								local pos1 = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position
								local pos2 = v.PrimaryPart.Position
								if (pos1 - pos2).Magnitude <= maxDistance then
									fetchItem(v)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["melody"] = function()
			task.spawn(function()
				repeat
					task.wait(0.1)
					if getItem("guitar") then
						local plr = GetTeammateThatNeedsMost()
						if plr and healtick <= tick() then
							bedwars.Client:Get(bedwars.GuitarHealRemote):FireServer({
								healTarget = plr.Character
							})
							healtick = tick() + 2
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["bigman"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = collectionService:GetTagged("treeOrb")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and v:FindFirstChild("Spirit") and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
							if bedwars.Client:Get(bedwars.TreeRemote):InvokeServer({
								treeOrbSecret = v:GetAttribute("TreeOrbSecret")
							}) then
								v:Destroy()
								collectionService:RemoveTag(v, "treeOrb")
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["metal_detector"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = collectionService:GetTagged("hidden-metal")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
							bedwars.Client:Get(bedwars.PickupMetalRemote):InvokeServer({
								id = v:GetAttribute("Id")
							})
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		--[[["battery"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = bedwars.BatteryEffectsController.liveBatteries
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
							bedwars.Client:Get(bedwars.BatteryRemote):SendToServer({
								batteryId = i
							})
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,--]]
		["grim_reaper"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = bedwars.GrimReaperController:fetchSoulsByPosition()
					for i,v in pairs(itemdrops) do
						--if entityLibrary.isAlive and lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute("GrimReaperChannel")) then
						if entityLibrary.isAlive then
							local res = bedwars.Client:Get(bedwars.ConsumeSoulRemote):InvokeServer({
								secret = v:GetAttribute("GrimReaperSoulSecret")
							})
							v:Destroy()
						end
						--end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["farmer_cletus"] = function()
			task.spawn(function()
				repeat
					task.wait()
					local itemdrops = collectionService:GetTagged("HarvestableCrop")
					for i,v in pairs(itemdrops) do
						if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
							bedwars.Client:Get("CropHarvest"):InvokeServer({
								position = bedwars.BlockController:getBlockPosition(v)
							})
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["dragon_slayer"] = function()
			local lastFired
			task.spawn(function()
				repeat
					task.wait(0.5)
					if entityLibrary.isAlive then
						for i,v in pairs(bedwars.DragonSlayerController:fetchDragonEmblems()) do
							local data = bedwars.DragonSlayerController:fetchDragonEmblemData(v)
							--print("1", encode(data))
							if data.stackCount >= 3 then
								--local localPos = lplr.Character:GetPrimaryPartCFrame().Position
								--local punchCFrame = CFrame.new(localPos, (v:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
								--lplr.Character:SetPrimaryPartCFrame(punchCFrame)
								--bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
								local ctarget = bedwars.DragonSlayerController:resolveTarget(v:GetPrimaryPartCFrame())
								bedwars.DragonSlayerController:deleteEmblem(v)
								if ctarget then 
									task.spawn(function()
										bedwars.Client:Get(bedwars.DragonRemote):FireServer({
											target = ctarget
										})
									end)
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["mage"] = function()
			task.spawn(function()
				repeat
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i, v in pairs(collectionService:GetTagged("TomeGuidingBeam")) do
							local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
							if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute("TomeSecret") then
								local res = bedwars.Client:Get(bedwars.MageRemote):InvokeServer({
									secret = obj:GetAttribute("TomeSecret")
								})
								if res.success and res.element then
									bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
									bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
									--bedwars.MageController:destroyTomeGuidingBeam()
									--bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
									local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
									if sound and sound ~= "" then
										local activeSound = bedwars.SoundManager:playSound(sound)
										if activeSound then task.wait(0.3) pcall(function() activeSound:Stop(); activeSound:Destroy() end) end
									end
									pcall(function() obj:Destroy() end)
									--[[task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
										--bedwars.MageController:fadeOutTome(obj)
										if lplr.Character and res.element then
											--bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)
										end
									end)--]]
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		--[[["angel"] = function()
			warningNotification("AutoKit", "Trinity kit detected! A dropdown has been created. Please tap the 3 dots \n next to the module to choose type.", 4)
			table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function(angelTable)
				task.wait(0.5)
				if not AutoKit.Enabled then return end
				if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute("AngelType") == nil then
					bedwars.Client:Get(bedwars.TrinityRemote):SendToServer({
						angel = AutoKitTrinity.Value
					})
				end
			end))
		end,--]]
		["miner"] = function()
			task.spawn(function()
				repeat 
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i,v in pairs(game.Workspace:GetChildren()) do
							local a = game.Workspace:GetChildren()[i]
							if a.ClassName == "Model" and #a:GetChildren() > 1 then
								if a:GetAttribute("PetrifyId") then
									bedwars.Client:Get("DestroyPetrifiedPlayer"):FireServer({
										["petrifyId"] = a:GetAttribute("PetrifyId")
									})
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["sorcerer"] = function()
			task.spawn(function()
				repeat 
					task.wait(0.1)
					if entityLibrary.isAlive then
						local player = game.Players.LocalPlayer
						local character = player.Character or player.CharacterAdded:Wait()
						local thresholdDistance = 10
						for i, v in pairs(game.Workspace:GetChildren()) do
							local a = v
							pcall(function()
								if a.ClassName == "Model" and #a:GetChildren() > 1 then
									if a:GetAttribute("Id") then
										local c = (a:FindFirstChild(a.Name:lower().."_PESP") or Instance.new("BoxHandleAdornment"))
										c.Name = a.Name:lower().."_PESP"
										c.Parent = a
										c.Adornee = a
										c.AlwaysOnTop = true
										c.ZIndex = 0
										task.spawn(function()
											local d = a:WaitForChild("2")
											c.Size = d.Size
										end)
										c.Transparency = 0.3
										c.Color = BrickColor.new("Magenta")
										local playerPosition = character.HumanoidRootPart.Position
										local partPosition = a.PrimaryPart.Position
										local distance = (playerPosition - partPosition).Magnitude
										if distance <= thresholdDistance then
											bedwars.Client:Get("CollectCollectableEntity"):FireServer({
												["id"] = a:GetAttribute("Id"),
												["collectableName"] = "AlchemyCrystal"
											})
										end
									end
								end
							end)
						end										
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["nazar"] = function()
			task.spawn(function()
				repeat 
					task.wait(0.5)
					if entityLibrary.isAlive then
						bedwars.AbilityController:useAbility("enable_life_force_attack")
						local function shouldUse()
							local lplr = game:GetService("Players").LocalPlayer
							if not (lplr.Character:FindFirstChild("Humanoid")) then
								local healthbar = pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer["1"] end)
								local classname = pcall(function() return healthbar.ClassName end)
								if healthbar and classname == "TextLabel" then 
									local health = tonumber(healthbar.Text)
									if health < 100 then return true, "SucBackup" else return false, "SucBackup" end
								else
									return true, "Backup"
								end
							else
								if lplr.Character.Humanoid.Health < lplr.Character.Humanoid.MaxHealth then return true else return false end
							end
						end
						local val, extra = shouldUse()
						if extra then if shared.VoidDev then print("Using backup method: "..tostring(extra)) end end
						if val then
							bedwars.AbilityController:useAbility("consume_life_foce")
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["necromancer"] = function()
			local function activateGrave(obj)
				if (not obj) then return warn("[AutoKit - necromancer.activateGrave]: No object specified!") end
				local required_args = {
					armorType = obj:GetAttribute("ArmorType"),
					weaponType = obj:GetAttribute("SwordType"),
					associatedPlayerUserId = obj:GetAttribute("GravestonePlayerUserId"),
					secret = obj:GetAttribute("GravestoneSecret"),
					position = obj:GetAttribute("GravestonePosition")
				}
				for i,v in pairs(required_args) do
					if (not v) then return warn("[AutoKit - necromancer.activateGrave]: A required arg is missing! ArgName: "..tostring(i).." ObjectName: "..tostring(obj.Name)) end
				end
				bedwars.Client:Get("ActivateGravestone"):InvokeServer({
					["skeletonData"] = {
						["armorType"] = armorType,
						["weaponType"] = weaponType,
						["associatedPlayerUserId"] = associatedPlayerUserId
					},
					["secret"] = secret,
					["position"] = position
				})
			end
			local function verifyAttributes(obj)
				if (not obj) then return warn("[AutoKit - necromancer.verifyAttributes]: No object specified!") end
				local required_attributes = {"ArmorType", "GravestonePlayerUserId", "GravestonePosition", "GravestoneSecret", "SwordType"}
				for i,v in pairs(required_attributes) do
					if (not obj:GetAttribute(v)) then print(v.." not found in "..obj.Name); return false end
				end
				return true
			end
			task.spawn(function()
				repeat
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i,v in pairs(game.Workspace:GetChildren()) do
							local a = game.Workspace:GetChildren()[i]
							if (not a) then return warn("[AutoKit - Core]: The object went missing before it could get used!") end
							if a.ClassName == "Model" and a:FindFirstChild("Root") and a.Name == "Gravestone" then
								if verifyAttributes(a) then
									local res = activateGrave(a)
									warn("[AutoKit - necromancer.activateGrave - RESULT]: "..tostring(res))
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end,
		["jailor"] = function()
			local function activateSoul(obj)
				bedwars.Client:Get("CollectCollectableEntity"):FireServer({
					["id"] = obj:GetAttribute("Id"),
					["collectableName"] = "JailorSoul"
				})
			end
			local function verifyAttributes(obj)
				if obj:GetAttribute("Id") then return true else return false end
			end
			task.spawn(function()
				repeat
					task.wait(0.1)
					if entityLibrary.isAlive then
						for i,v in pairs(game.Workspace:GetChildren()) do
							local a = game.Workspace:GetChildren()[i]
							if (not a) then return warn("[AutoKit - Core]: The object went missing before it could get used!") end
							if a.ClassName == "Model" and a.Name == "JailorSoul" then
								if verifyAttributes(a) then
									local res = activateSoul(a)
									warn("[AutoKit - jailor.activateSoul - RESULT]: "..tostring(res))
								end
							end
						end
					end
				until (not AutoKit.Enabled)
			end)
		end
	}

	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoKit",
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanController.startMinigame
				bedwars.FishermanController.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until store.equippedKit ~= ""
					if AutoKit.Enabled then
						if AutoKit_Functions[store.equippedKit] then task.spawn(AutoKit_Functions[store.equippedKit]) end
					end
				end)
			else
				shared.EmberAutoKit = nil
				bedwars.FishermanController.startMinigame = oldfish
				oldfish = nil
			end
		end,
		HoverText = "Automatically uses a kits ability"
	})
	local function resolveKitName(kitName)
		local repstorage = game:GetService("ReplicatedStorage")
		local KitMeta = bedwars.KitMeta
		if KitMeta[kitName] then return (KitMeta[kitName].name or kitName) else return kitName end
	end
	local function isSupportedKit(kit) if AutoKit_Functions[kit] then return "Supported" else return "Not Supported" end end
	local SupportedKit = AutoKit.CreateTextLabel({
		Name = "SupportedKit",
		Text = "Kit: "..tostring(resolveKitName(store.equippedKit)).." ["..isSupportedKit(store.equippedKit).."]"
	})
	task.spawn(function()
		repeat task.wait() until shared.VapeFullyLoaded
		SupportedKit.EditText("Kit: "..tostring(resolveKitName(bedwars.getKit(game:GetService("Players").LocalPlayer))).." ["..isSupportedKit(bedwars.getKit(game:GetService("Players").LocalPlayer)).."]")
	end)
	Legit = AutoKit.CreateToggle({
		Name = "Legit",
		Function = function() end,
		Default = false
	})
	AutoKitTrinity = AutoKit.CreateDropdown({
		Name = "Angel",
		List = {"Void", "Light"},
		Function = function() end
	})
	AutoKitTrinity.Object.Visible = (store.equippedKit == "angel")
end)

run(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {Enabled = false}
	local AutoReportV2Notify = {Enabled = false}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoReportV2",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						for i,v in pairs(playersService:GetPlayers()) do
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute("PlayerConnected") and whitelist:get(v) == 0 then
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.Client:Get(bedwars.ReportRemote):InvokeServer(v.UserId)
								store.statistics.reported = store.statistics.reported + 1
								if AutoReportV2Notify.Enabled then
									warningNotification("AutoReportV2", "Reported "..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end
		end,
		HoverText = "dv mald"
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = "Notify",
		Function = function() end
	})
end)

local sendmessage = function() end
sendmessage = function(text)
	local function createBypassMessage(message)
		local charMappings = {
			["a"] = "ɑ", ["b"] = "ɓ", ["c"] = "ɔ", ["d"] = "ɗ", ["e"] = "ɛ",
			["f"] = "ƒ", ["g"] = "ɠ", ["h"] = "ɦ", ["i"] = "ɨ", ["j"] = "ʝ",
			["k"] = "ƙ", ["l"] = "ɭ", ["m"] = "ɱ", ["n"] = "ɲ", ["o"] = "ɵ",
			["p"] = "ρ", ["q"] = "ɋ", ["r"] = "ʀ", ["s"] = "ʂ", ["t"] = "ƭ",
			["u"] = "ʉ", ["v"] = "ʋ", ["w"] = "ɯ", ["x"] = "x", ["y"] = "ɣ",
			["z"] = "ʐ", ["A"] = "Α", ["B"] = "Β", ["C"] = "Ϲ", ["D"] = "Δ",
			["E"] = "Ε", ["F"] = "Ϝ", ["G"] = "Γ", ["H"] = "Η", ["I"] = "Ι",
			["J"] = "ϳ", ["K"] = "Κ", ["L"] = "Λ", ["M"] = "Μ", ["N"] = "Ν",
			["O"] = "Ο", ["P"] = "Ρ", ["Q"] = "Ϙ", ["R"] = "Ϣ", ["S"] = "Ϛ",
			["T"] = "Τ", ["U"] = "ϒ", ["V"] = "ϝ", ["W"] = "Ω", ["X"] = "Χ",
			["Y"] = "Υ", ["Z"] = "Ζ"
		}
		local bypassMessage = ""
		for i = 1, #message do
			local char = message:sub(i, i)
			bypassMessage = bypassMessage .. (charMappings[char] or char)
		end
		return bypassMessage
	end
	--text = text.." | discord.gg/voidware"
	--text = createBypassMessage(text)
	local textChatService = game:GetService("TextChatService")
	local replicatedStorageService = game:GetService("ReplicatedStorage")
	if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(text)
	else
		replicatedStorageService.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, 'All')
	end
end
getgenv().sendmessage = sendmessage

local bedTeamCache = {}
local function get_bed_team(id)
	if bedTeamCache[id] then
		return true, bedTeamCache[id]
	end
	local teamName = "Unknown"
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player ~= game:GetService("Players").LocalPlayer then
			if player:GetAttribute("Team") and tostring(player:GetAttribute("Team")) == tostring(id) then
				teamName = tostring(player.Team)
				break
			end
		end
	end
	bedTeamCache[id] = teamName
	return false, teamName
end

run(function()
	local justsaid = ''
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ''
		local lastlet = ''
		for i,v in next, (str:split('')) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end
	local reporttable = {
		gay = 'Bullying',
		gae = 'Bullying',
		gey = 'Bullying',
		hack = 'Scamming',
		exploit = 'Scamming',
		cheat = 'Scamming',
		hecker = 'Scamming',
		haxker = 'Scamming',
		hacer = 'Scamming',
		fat = 'Bullying',
		black = 'Bullying',
		getalife = 'Bullying',
		report = 'Bullying',
		fatherless = 'Bullying',
		disco = 'Offsite Links',
		yt = 'Offsite Links',
		dizcourde = 'Offsite Links',
		retard = 'Swearing',
		bad = 'Bullying',
		trash = 'Bullying',
		nolife = 'Bullying',
		killyour = 'Bullying',
		kys = 'Bullying',
		hacktowin = 'Bullying',
		bozo = 'Bullying',
		kid = 'Bullying',
		adopted = 'Bullying',
		linlife = 'Bullying',
		commitnotalive = 'Bullying',
		vape = 'Offsite Links',
		futureclient = 'Offsite Links',
		download = 'Offsite Links',
		youtube = 'Offsite Links',
		die = 'Bullying',
		lobby = 'Bullying',
		ban = 'Bullying',
		wizard = 'Bullying',
		wisard = 'Bullying',
		witch = 'Bullying',
		magic = 'Bullying',
	}
	local reporttableexact = {
		L = 'Bullying',
	}
	local rendermessages = {
		[1] = {'cry me a river <name>', 'boo hooo <name>', 'womp womp <name>', 'I could care less <name>.'}
	}
	local AutoToxicPhrases6 = {ObjectList = {}}
	local AutoToxicPhrases5 = {ObjectList = {}}
	local AutoToxicPhrases7 = {ObjectList = {}}
	local AutoToxicPhrases3 = {ObjectList = {}}
	local AutoToxicPhrases2 = {ObjectList = {}}
	local AutoToxicPhrases = {ObjectList = {}}
	local AutoToxicPhrases4 = {ObjectList = {}}
	local AutoToxicPhrases8 = {ObjectList = {}}
	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub('%W+', ''):lower())
		for i,v in next, (reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in next, (reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in next, (AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return 'Bullying', v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoToxic',
		Function = function(calling)
			if calling then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or 'Who needs a bed when you got Voidware <name>? | .gg/voidware'
						if custommsg then
							custommsg = custommsg:gsub('<name>', (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or 'Your bed has been sent to the abyss <teamname>! | .gg/voidware'
						if custommsg then
							local team = get_bed_team(bedtable.brokenBedTeam.id)
							local teamname = team and team.displayName:lower() or 'white'
							custommsg = custommsg:gsub('<teamname>', teamname)
						end
						sendmessage(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or 'I was too laggy <name>. That\'s why you won. | .gg/voidware'
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killer.DisplayName or killer.Name))
								end
								sendmessage(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Voidware. | .gg/voidware'
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or '<name> things could have ended for you so differently, if you\'ve used Voidware. | .gg/voidware'
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killed.DisplayName or killed.Name))
								end
								sendmessage(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							sendmessage('gg')
						end
						if AutoToxicWin.Enabled then
							sendmessage(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or 'Voidware is simply better everyone. | .gg/voidware')
						end
					end
				end))
				table.insert(AutoToxic.Connections, textChatService.MessageReceived:Connect(function(tab)
					if AutoToxicRespond.Enabled then
						local plr = playersService:GetPlayerByUserId(tab.TextSource.UserId)
						local args = tab.Text:split(" ")
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(tab.Text)
							if reportreason then
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
								end
								local msg = custommsg or "I don't care about the fact that I'm hacking, I care about you dying in a block game. L "..(plr.DisplayName or plr.Name).." | vxpe on top"
								if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
									textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
								else
									replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, 'All')
								end
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = 'AutoGG',
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = 'Win',
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = 'Death',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = 'Bed Break',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = 'Bed Destroyed',
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = 'Respond',
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = 'Final Kill',
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = 'Teammates',
		Function = function() end, 
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = 'ToxicList',
		TempText = 'phrase (win)',
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = 'ToxicList2',
		TempText = 'phrase (kill) <name>',
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = 'ToxicList3',
		TempText = 'phrase (death) <name>',
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = 'ToxicList7',
		TempText = 'phrase (bed break) <teamname>',
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = 'ToxicList6',
		TempText = 'phrase (bed destroyed) <name>',
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = 'ToxicList4',
		TempText = 'phrase (text to respond with) <name>',
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = 'ToxicList5',
		TempText = 'phrase (text to respond to)',
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = 'ToxicList8',
		TempText = 'phrase (lagback) <name>',
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

run(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local doneChests = {}
	local cheststealerdelays = {}
	local chests = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				if table.find(doneChests, chest) then return end
				table.insert(doneChests, chest)
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.Client:GetNamespace("Inventory"):Get("ChestGetItem"):InvokeServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(chests) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					if table.find(doneChests, chest) then return end
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.Client:GetNamespace("Inventory"):Get("SetObservedChest"):FireServer(chest)
						for i3,v3 in pairs(chestitems) do
							task.wait(0.1)
							if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
								task.spawn(function()
									pcall(function()
										cheststealerdelays[v3] = tick() + 0.2
										bedwars.Client:GetNamespace("Inventory"):Get("ChestGetItem"):InvokeServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.Client:GetNamespace("Inventory"):Get("SetObservedChest"):FireServer(nil)
					end
					table.insert(doneChests, chest)
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ChestStealer",
		Function = function(callback)
			if callback then
				chests = collectionService:GetTagged("chest")
				task.spawn(function()
					repeat task.wait(5)
						chests = collectionService:GetTagged("chest")
					until (not ChestStealer.Enabled)
				end)
				task.spawn(function()
					repeat task.wait() until store.matchState > 0
					repeat
						task.wait(0.4)
						if entityLibrary.isAlive then
							cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
						end
					until (not ChestStealer.Enabled)
				end)
			else table.clear(doneChests) end
		end,
		HoverText = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = "GUI Check",
		Function = function() end
	})
	--[[ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = "Only Skywars",
		Function = function() end,
		Default = true
	})--]]
end)

--[[run(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "PickupRange",
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged("ItemDrop")
						for i,v in pairs(itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.Client:Get(bedwars.PickupRemote):InvokeServer({itemDrop = v})
									end)
								end
							end
						end
						task.wait(0.2)
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 10,
		Function = function() end,
		Default = 10
	})
end)--]]

--[[run(function()
	local BowExploit = {Enabled = false}
	local BowExploitTarget = {Value = "Mouse"}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		"fireball",
		"telepearl"
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ProjectileExploit",
		Function = function(callback)
			if callback then
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							local plr
							if BowExploitTarget.Value == "Mouse" then
								plr = EntityNearMouse(10000)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, true)
							end
							if plr then
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = game.Workspace.Gravity
									local balloons = plr.Character:GetAttribute("InflatedBalloons")
									if balloons and balloons > 0 then
										playergrav = (game.Workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then
										playergrav = (game.Workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == "telepearl" then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, game.Workspace.Gravity, false)
									if calculated then
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, game.Workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = "Mode",
		List = {"Mouse", "Range"},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
end)--]]

run(function()
	local RavenTP = {Enabled = false}
	local RavenTPMode = {Value = "Toggle"}
	local function Raven()
		task.spawn(function()
			if getItem("raven") then
				local plr = EntityNearMouse(1000)
				if plr then
					local projectile = bedwars.Client:Get(bedwars.SpawnRavenRemote, nil, true):InvokeServer():andThen(function(projectile)
						if projectile then
							local projectilemodel = projectile
							if not projectilemodel then
								projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
							end
							local bodyforce = Instance.new("BodyForce")
							bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * game.Workspace.Gravity, 0)
							bodyforce.Name = "AntiGravity"
							bodyforce.Parent = projectilemodel.PrimaryPart

							if plr then
								projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
								task.wait(0.3)
								bedwars.RavenController:detonateRaven()
							else
								if RavenTPMode.Value ~= "Toggle" then
									warningNotification("RavenTP", "Player died before it could TP.", 3)
								end
							end
						else
							if RavenTPMode.Value ~= "Toggle" then
								warningNotification("RavenTP", "Raven on cooldown.", 3)
							end
						end
					end)
				else
					if RavenTPMode.Value ~= "Toggle" then
						warningNotification("RavenTP", "Player not found.", 3)
					end
				end
			else
				if RavenTPMode.Value ~= "Toggle" then
					warningNotification("RavenTP", "Raven not found.", 3)
				end
			end
		end)
	end
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "RavenTP",
		Function = function(callback)
			if callback then
				pcall(function()
					if RavenTPMode.Value ~= "Toggle" then
						Raven()
						RavenTP.ToggleButton(true)
					else
						repeat Raven() task.wait() until not RavenTP.Enabled
					end
				end)
			end
		end,
		HoverText = "Spawns and teleports a raven to a player\nnear your mouse."
	})
	RavenTPMode = RavenTP.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if RavenTP.Enabled then
				RavenTP.ToggleButton(false)
				RavenTP.ToggleButton(false)
			end
		end
	})
end)

--[[run(function()
	local tiered = {}
	local nexttier = {}

	for i,v in pairs(bedwars.ShopItems) do
		if type(v) == "table" then
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ShopTierBypass",
		Function = function(callback)
			if callback then
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = "Allows you to access tiered items early."
	})
end)--]]

local lagbackedaftertouch = false
run(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = "Normal"}
	local AntiVoidMoveMode = {Value = "Normal"}
	local AntiVoid = {Enabled = false, Connections = {}}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local GuiSync = {Enabled = false}

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then
			local tops = {}
			for i,v in pairs(store.blocks) do
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then
					table.insert(tops, close)
				end
			end
			for i,v in pairs(tops) do
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 20
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AntiVoid",
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new("Part")
					AntiVoidPart.CanCollide = AntiVoidMode.Value == "Collide"
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					shared.AntiVoidPart = AntiVoidPart
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = game.Workspace
					if AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 then
						AntiVoidPart.Parent = nil
					end
					if GuiSync.Enabled then
						--AntiVoidPart.Color
						pcall(function()
							if shared.RiseMode and GuiLibrary.GUICoreColor and GuiLibrary.GUICoreColorChanged then
								AntiVoidPart.Color = GuiLibrary.GUICoreColor
								local con = GuiLibrary.GUICoreColorChanged.Event:Connect(function()
									if AntiVoid.Enabled and GuiSync.Enabled then
										AntiVoidPart.Color = GuiLibrary.GUICoreColor
									end
								end)
								table.insert(AntiVoid.Connections, con)
							else
								local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
								AntiVoidPart.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
								VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
									if AntiVoid.Enabled then
										color = {Hue = h, Sat = s, Value = v}
										AntiVoidPart.Color = Color3.fromHSV(color.Hue, color.Sat, color.Value)
									end
								end))
							end
						end)
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= "Collide" then
								if AntiVoidMode.Value == "Velocity" then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute("LastTeleported")
										RunLoops:BindToHeartbeat("AntiVoid", function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute("LastTeleported") == lastTeleport then
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat("AntiVoid")
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == "Normal" then
							local ray = game.Workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), store.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy()
				end
			end
		end,
		HoverText = "Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)"
	})
	AntiVoid.Restart = function() if AntiVoid.Enbaled then AntiVoid.ToggleButton(false); AntiVoid.ToggleButton(false) end end
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = "Position Mode",
		Function = function(val)
			if val == "Classic" then
				task.spawn(function()
					repeat task.wait() until store.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in pairs(store.blocks) do
							local newray = game.Workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), store.blockRaycast)
							if i % 200 == 0 then
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = game.Workspace
					end
				end)
			end
		end,
		List = {"Normal", "Classic"}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = "Move Mode",
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.CanCollide = val == "Collide"
			end
		end,
		List = {"Normal", "Collide", "Velocity"}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = "Invisible",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val)
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v)
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
	GuiSync = AntiVoid.CreateToggle({
		Name = "GUI Color Sync",
		Function = function(call)
			pcall(function() AntiVoidColor.Object.Visible = not call end)	
			AntiVoid.Restart()
		end
	})
end)

run(function()
	local entitylib = entityLibrary
    local BedProtector = {Enabled = false}
	local Priority = {ObjectList = {}}
	local Layers = {Value = 2}
	local CPS = {Value = 50}
	local Mode = {Value = "On Key"}

	local AutoSwitch = {Enabled = false}
	local HandCheck = {Enabled = false}
	local BlockTypeCheck = {Enabled = false}
    
    local function getBedNear()
        local localPosition = entitylib.isAlive and entitylib.character.HumanoidRootPart.Position or Vector3.zero
        for _, v in collectionService:GetTagged("bed") do
            if (localPosition - v.Position).Magnitude < 20 and v:GetAttribute("Team"..(lplr:GetAttribute("Team") or -1).."NoBreak") then
                return v
            end
        end
    end

	local function isAllowed(block)
		if not BlockTypeCheck.Enabled then return true end
		local allowed = {"wool", "stone_brick", "wood_plank_oak", "ceramic", "obsidian"}
		for _, v in pairs(allowed) do
			if string.find(string.lower(tostring(block)), v) then 
				return true
			end
		end
		return false
	end

	local function getBlocks()
        local blocks = {}
        for _, item in store.localInventory.inventory.items do
            local block = bedwars.ItemTable[item.itemType].block
            if block and isAllowed(item.itemType) then
                table.insert(blocks, {itemType = item.itemType, health = block.health, tool = item.tool})
            end
        end

        local priorityMap = {}
        for _, v in pairs(Priority.ObjectList) do
			local core = v:split("/")
            local blockType, layer = core[1], core[2]
            if blockType and layer then
                priorityMap[blockType] = tonumber(layer)
            end
        end

        local prioritizedBlocks = {}
        local fallbackBlocks = {}

        for _, block in pairs(blocks) do
			local prioLayer
			for name, layer in pairs(priorityMap) do
				if string.find(string.lower(tostring(block.itemType)), string.lower(tostring(name))) then
					prioLayer = layer
					break
				end
			end
            if prioLayer then
                table.insert(prioritizedBlocks, {itemType = block.itemType, health = block.health, layer = prioLayer, tool = block.tool})
            else
                table.insert(fallbackBlocks, {itemType = block.itemType, health = block.health, tool = block.tool})
            end
        end

        table.sort(prioritizedBlocks, function(a, b) return a.layer < b.layer end)
        table.sort(fallbackBlocks, function(a, b) return a.health > b.health end)

        local finalBlocks = {}
        for _, block in pairs(prioritizedBlocks) do
            table.insert(finalBlocks, {block.itemType, block.health})
        end
        for _, block in pairs(fallbackBlocks) do
            table.insert(finalBlocks, {block.itemType, block.health})
        end

        return finalBlocks
    end
    
    local function getPyramid(size, grid)
        local positions = {}
        for h = size, 0, -1 do
            for w = h, 0, -1 do
                table.insert(positions, Vector3.new(w, (size - h), ((h + 1) - w)) * grid)
                table.insert(positions, Vector3.new(-w, (size - h), ((h + 1) - w)) * grid)
                table.insert(positions, Vector3.new(w, (size - h), -(h - w)) * grid)
                table.insert(positions, Vector3.new(-w, (size - h), -(h - w)) * grid)
            end
        end
        return positions
    end

    local function tblClone(cltbl)
        local restbl = table.clone(cltbl)
        for _, v in pairs(cltbl) do
            table.insert(restbl, v)
        end
        return restbl
    end

    local function cleantbl(restbl, req)
        for i = #restbl, req + 1, -1 do
            table.remove(restbl, i)
        end
        return restbl
    end

	local autoCheckLoop

	local function autoCheck()
		if not BedProtector.Enabled or Mode.Value ~= "Toggle" then return end

		local bed = getBedNear()
		if not bed then return end

		local bedPos = bed.Position
		local playerPos = entitylib.isAlive and entitylib.character.HumanoidRootPart.Position or Vector3.zero
		local distance = (playerPos - bedPos).Magnitude

		if distance < 12 then
			local blocks = getBlocks()
			if #blocks == 0 then return end

			local positions = getPyramid(Layers.Value - 1, 3)
			for _, pos in ipairs(positions) do
				local blockPos = bedPos + pos
				if not getPlacedBlock(blockPos) then
					bedwars.placeBlock(blockPos, blocks[1][1], false)
					task.wait(1 / CPS.Value)
				end
			end
		end
	end

	local function startAutoLoop()
		if autoCheckLoop then return end
		autoCheckLoop = task.spawn(function()
			while BedProtector.Enabled and Mode.Value == "Toggle" do
				autoCheck()
				task.wait(1.5)
			end
			autoCheckLoop = nil
		end)
	end

	local function stopAutoLoop()
		if autoCheckLoop then
			task.cancel(autoCheckLoop)
			autoCheckLoop = nil
		end
	end

    local res_attempts = 0
    
    local function buildProtection(bedPos, blocks, layers, cps)
        local delay = 1 / cps 
        local blockIndex = 1
        local posIndex = 1
        
        local function placeNextBlock()
            if not BedProtector.Enabled or blockIndex > layers then
                BedProtector.ToggleButton(false)
                return
            end

            local block = blocks[blockIndex]
            if not block then
                BedProtector.ToggleButton(false)
                return
            end

			if AutoSwitch.Enabled then
				switchItem(block.tool)
			end

            local positions = getPyramid(blockIndex - 1, 3)
            if posIndex > #positions then
                blockIndex += 1
                posIndex = 1
                task.delay(delay, placeNextBlock)
                return
            end

            local pos = positions[posIndex]
            if not getPlacedBlock(bedPos + pos) then
                bedwars.placeBlock(bedPos + pos, block[1], false)
            end
            
            posIndex += 1
            task.delay(delay, placeNextBlock)
        end
        
        placeNextBlock()
    end

    BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
        Name = "BedProtector",
        Function = function(callback)
            if callback then
				if Mode.Value == "Toggle" then
					startAutoLoop()
					return
				end

                local bed = getBedNear()
                local bedPos = bed and bed.Position
                if bedPos then
					if HandCheck.Enabled and not AutoSwitch.Enabled then
						if not (store.hand and store.hand.toolType == "block") then
							errorNotification("BedProtector | Hand Check", "You aren't holding a block!", 1.5)
							BedProtector.ToggleButton(false)
							return
						end
					end

                    local blocks = getBlocks()
                    if #blocks == 0 then 
                        warningNotification("BedProtector", "No blocks for bed defense found!", 3) 
                        BedProtector.ToggleButton(false)
                        return 
                    end

                    if #blocks < Layers.Value then
                        repeat 
                            blocks = tblClone(blocks)
                            blocks = cleantbl(blocks, Layers.Value)
                            task.wait()
                            res_attempts += 1
                        until #blocks == Layers.Value or res_attempts > (Layers.Value < 10 and Layers.Value or 10)
                    elseif #blocks > Layers.Value then
                        blocks = cleantbl(blocks, Layers.Value)
                    end
                    res_attempts = 0

                    buildProtection(bedPos, blocks, Layers.Value, CPS.Value)
                else
                    InfoNotification("BedProtector", "Please get closer to your bed!", 5)
                    BedProtector.ToggleButton(false)
                end
            else
				stopAutoLoop()
                res_attempts = 0
            end
        end,
        HoverText = "Automatically places strong blocks around the bed with customizable speed."
    })

    Layers = BedProtector.CreateSlider({
        Name = "Layers",
        Function = function() end,
        Min = 1,
        Max = 10,
        Default = 2,
        HoverText = "Number of protective layers around the bed"
    })

    CPS = BedProtector.CreateSlider({
        Name = "CPS",
        Function = function() end,
        Min = 5,
        Max = 50,
        Default = 50,
        HoverText = "Blocks placed per second"
    })

	AutoSwitch = BedProtector.CreateToggle({
		Name = "Auto Switch",
		Function = function() end,
		Default = true
	})

	Mode = BedProtector.CreateDropdown({
		Name = "Mode",
		List = {"Toggle", "On Key"},
		Function = function(val)
			Mode.Value = val
			if val == "Toggle" and BedProtector.Enabled then
				startAutoLoop()
			else
				stopAutoLoop()
			end
		end,
		Default = "On Key"
	})

	HandCheck = BedProtector.CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})

	BlockTypeCheck = BedProtector.CreateToggle({
		Name = "Block Type Check",
		Function = function() end,
		Default = true
	})

	Priority = BedProtector.CreateTextList({
		Name = "Block/Layer",
		Function = function() end,
		TempText = "block/layer",
		SortFunction = function(a, b)
			local layer1 = a:split("/")
			local layer2 = b:split("/")
			layer1 = tonumber(layer1[2]) or 1
			layer2 = tonumber(layer2[2]) or 1
			return layer1 < layer2
		end
	})
end)

run(function()
	local uipallet = {
		Main = Color3.fromRGB(0, 0, 0),
		Text = Color3.fromRGB(255, 255, 255),
		Font = Font.fromEnum(Enum.Font.Arial),
		FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.SemiBold),
		Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
	}
	local color = {}
	do
		function color.Dark(col, num)
			local h, s, v = col:ToHSV()
			return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
		end
	
		function color.Light(col, num)
			local h, s, v = col:ToHSV()
			return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
		end
	end

	bedwars.BlockBreaker = {
		healthbarMaid = {
			DoCleaning = function(self)
				self._tasks = self._tasks or {}
				for i,v in pairs(self._tasks) do
					if type(v) == "function" then pcall(v) end
				end
				table.clear(self._tasks)
			end,
			GiveTask = function(self, task)
				self._tasks = self._tasks or {}
				table.insert(self._tasks, task)
			end
		},
		breakEffect = {
			playBreak = function(self, blockName, blockPosition, plr) end,
			playHit = function(self, blockName, blockPosition, plr) end
		}
	}
	local blockCache = {}
	local function customHealthbar(self, blockRef, health, maxHealth, changeHealth, block)
		if block:GetAttribute('NoHealthbar') then return end
		bedwars.ItemMeta = bedwars.ItemMeta or bedwars.ItemTable
		if not bedwars.ItemMeta[block.Name] then return end
		if not self.healthbarPart or not self.healthbarBlockRef or self.healthbarBlockRef.blockPosition ~= blockRef.blockPosition then
			self.healthbarMaid:DoCleaning()
			self.healthbarBlockRef = blockRef
			local create = bedwars.Roact.createElement
			local suc, res = pcall(function() return math.clamp(health / maxHealth, 0, 1) end)
			local percent = suc and res or 0.5
			local cleanCheck = true
			local part = Instance.new('Part')
			part.Size = Vector3.one
			part.CFrame = CFrame.new(blockRef.blockPosition*3)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.Parent = workspace
			self.healthbarPart = part
			bedwars.QueryUtil:setQueryIgnored(self.healthbarPart, true)
	
			local mounted = bedwars.Roact.mount(create('BillboardGui', {
				Size = UDim2.fromOffset(249, 102),
				StudsOffset = Vector3.new(0, 2.5, 0),
				Adornee = part,
				MaxDistance = 40,
				AlwaysOnTop = true
			}, {
				create('Frame', {
					Size = UDim2.fromOffset(160, 50),
					Position = UDim2.fromOffset(44, 32),
					BackgroundColor3 = Color3.new(),
					BackgroundTransparency = 0.5
				}, {
					create('UICorner', {CornerRadius = UDim.new(0, 5)}),
					create('ImageLabel', {
						Size = UDim2.new(1, 89, 1, 52),
						Position = UDim2.fromOffset(-48, -31),
						BackgroundTransparency = 1,
						Image = "rbxassetid://14898786664",
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(52, 31, 261, 502)
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(13, 12),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = Color3.new(),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('TextLabel', {
						Size = UDim2.fromOffset(145, 14),
						Position = UDim2.fromOffset(12, 11),
						BackgroundTransparency = 1,
						Text = bedwars.ItemMeta[block.Name].displayName or block.Name,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextColor3 = color.Dark(uipallet.Text, 0.16),
						TextScaled = true,
						Font = Enum.Font.Arial
					}),
					create('Frame', {
						Size = UDim2.fromOffset(138, 4),
						Position = UDim2.fromOffset(12, 32),
						BackgroundColor3 = uipallet.Main
					}, {
						create('UICorner', {CornerRadius = UDim.new(1, 0)}),
						create('Frame', {
							[bedwars.Roact.Ref] = self.healthbarProgressRef,
							Size = UDim2.fromScale(percent, 1),
							BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
						}, {create('UICorner', {CornerRadius = UDim.new(1, 0)})})
					})
				})
			}), part)
	
			self.healthbarMaid:GiveTask(function()
				cleanCheck = false
				self.healthbarBlockRef = nil
				bedwars.Roact.unmount(mounted)
				if self.healthbarPart then
					self.healthbarPart:Destroy()
				end
				self.healthbarPart = nil
			end)
	
			bedwars.RuntimeLib.Promise.delay(5):andThen(function()
				if cleanCheck then
					self.healthbarMaid:DoCleaning()
				end
			end)
		end
		self.healthbarPart.CFrame = CFrame.new(blockRef.blockPosition*3)
		local newpercent = math.clamp((health - changeHealth) / maxHealth, 0, 1)
		tweenService:Create(self.healthbarPart:WaitForChild("BillboardGui"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Frame"), TweenInfo.new(0.3), {
			Size = UDim2.fromScale(newpercent, 1), BackgroundColor3 = Color3.fromHSV(math.clamp(newpercent / 2.5, 0, 1), 0.89, 0.75)
		}):Play()
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local function getLastCovered(pos, normal)
		local lastfound, lastpos = nil, nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock, extrablockpos = getPlacedBlock(blockpos)
			local covered = isBlockCovered(blockpos)
			if extrablock then
				lastfound, lastpos = extrablock, extrablockpos
				if not covered then
					break
				end
			else
				break
			end
		end
		return lastfound, lastpos
	end

	local function get(block, att)
		local suc, err = pcall(function() return block:GetAttribute(att) end)
		return suc and err or ""
	end

	local function isblockbreakable(block, plr)
		if tostring(block) == "Part" then return false end
		if get(block, "NoBreak") ~= "true" and get(block, "PlacedByUserId") ~= tostring(lplr.UserId) then 
			return true 
		else 
			return false 
		end
	end

	local VisualizerHighlight = nil
    local LastBlock = nil
    local VisualizerTimeout = 1
    local LastBreakTime = 0
    local IsBreaking = false

	local function updateVisualizer(block, isBreaking)
        local currentTime = tick()

        if not isBreaking and not block then
            if VisualizerHighlight then
                VisualizerHighlight:Destroy()
                VisualizerHighlight = nil
            end
            LastBlock = nil
            LastBreakTime = 0
            IsBreaking = false
            return
        end

        if block then
            local blockKey = tostring(block.Position) 

            if blockKey ~= LastBlock or not VisualizerHighlight or not VisualizerHighlight.Parent then
                if VisualizerHighlight then
                    VisualizerHighlight:Destroy()
                end

                VisualizerHighlight = Instance.new("Highlight")
                VisualizerHighlight.Adornee = block
                VisualizerHighlight.FillTransparency = 1
                VisualizerHighlight.OutlineTransparency = 0.3 
                VisualizerHighlight.Parent = workspace

                VisualizerHighlight.OutlineColor = (blockKey ~= LastBlock) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
                LastBlock = blockKey
            end

            IsBreaking = isBreaking
            LastBreakTime = currentTime

            task.spawn(function()
                while VisualizerHighlight and VisualizerHighlight.Parent and (tick() - LastBreakTime < VisualizerTimeout) and IsBreaking do
                    task.wait(0.1)
                end
                if VisualizerHighlight and VisualizerHighlight.Parent then
                    VisualizerHighlight:Destroy()
                    VisualizerHighlight = nil
                    LastBlock = nil
                    IsBreaking = false
                end
            end)
        end
    end

	local nearestBed

	local breakBlock = function(pos, effects, normal, bypass, anim)
		if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then
			return
		end
		if lplr:GetAttribute("DenyBlockBreak") then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		--if not block then block, blockpos = getPlacedBlock(bedwars.BlockController:getBlockPosition(pos)) end
		if not block then blockpos, block = bedwars.BlockController:getBlockPosition(pos, nearestBed) end
		updateVisualizer(block, true)
		if not isblockbreakable(block, lplr) then blockpos, block = nil, nil end
		if blockpos and block then
			--[[if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end--]]
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				store.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientDamageBlock:Get("DamageBlock"):CallServerAsync({
						blockRef = blockhealthbarpos,
						hitPosition = blockpos * 3,
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= "failed" then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockhealth = block:GetAttribute("Health")
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
							blockhealthbarpos.block = block
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							if not healthbarblocktable.blockHealth then 
								healthbarblocktable.blockHealth = block:GetAttribute("Health")
							end
							if not healthbarblocktable.blockHealth then healthbarblocktable.blockHealth = blockdmg*3 end
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker.healthbarBlockRef = blockhealthbarpos
								--bedwars.BlockBreaker.healthbarPart = block
								customHealthbar(bedwars.BlockBreaker, blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								--bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end
	
	local sides = {}
    for _, v in Enum.NormalId:GetEnumItems() do
        if v.Name == "Bottom" then continue end
        table.insert(sides, Vector3.FromNormalId(v) * 3)
    end

    local function findClosestBreakableBlock(start, playerPos)
		local closestBlock = nil
		local closestDistance = math.huge
		local closestPos = nil
		local closestNormal = nil

		local vectorToNormalId = {
			[Vector3.new(1, 0, 0)] = Enum.NormalId.Right,
			[Vector3.new(-1, 0, 0)] = Enum.NormalId.Left,
			[Vector3.new(0, 1, 0)] = Enum.NormalId.Top,
			[Vector3.new(0, -1, 0)] = Enum.NormalId.Bottom,
			[Vector3.new(0, 0, 1)] = Enum.NormalId.Front,
			[Vector3.new(0, 0, -1)] = Enum.NormalId.Back
		}

		for _, side in sides do
			for i = 1, 15 do
				local blockPos = start + (side * i)
				local block = getPlacedBlock(blockPos)
				if not block or block:GetAttribute("NoBreak") then break end
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockPos / 3}, lplr) then
					local distance = (playerPos - blockPos).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						closestBlock = block
						closestPos = blockPos
						local normalizedSide = side.Unit 
						for vector, normalId in pairs(vectorToNormalId) do
							if (normalizedSide - vector).Magnitude < 0.01 then 
								closestNormal = normalId
								break
							end
						end
					end
				end
			end
		end

		return closestBlock, closestPos, closestNormal
	end

	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukerslowmode = {Value = 0.2}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
	local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
	local nukerbeds = {Enabled = false}
	local nukerclosestblock = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
	local luckyblocktable = {}

	local nearbed = false

	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Nuker",
		Function = function(callback)
			if callback then
				bedwars.ItemTable = bedwars.ItemTable or bedwars.ItemMeta
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end))
				table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.remove(luckyblocktable, table.find(luckyblocktable, v))
					end
				end))
				task.spawn(function()
					repeat
						nearbed = false
						if (not nukernofly.Enabled or not (GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or store.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in pairs(collectionService:GetTagged("bed")) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj.Name == "bed" and tostring(obj:GetAttribute("TeamId")) == tostring(lplr:GetAttribute("Team")) then continue end
										if obj:GetAttribute("BedShieldEndTime") then
											if obj:GetAttribute("BedShieldEndTime") > game.Workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												nearbed = true
												nearestBed = obj
												if nukerclosestblock.Enabled then
                                                    local playerPos = entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position
                                                    local closestBlock, closestPos, closestNormal = findClosestBreakableBlock(obj.Position, playerPos)
                                                    if closestBlock and closestPos then
                                                        broke = true
                                                        breakBlock(closestPos, nukereffects.Enabled, closestNormal, false, nukeranimation.Enabled)
                                                        task.wait(nukerslowmode.Value ~= 0 and nukerslowmode.Value/10 or 0)
                                                        break
                                                    end
                                                else
                                                    local res, amount = getBestBreakSide(obj.Position)
                                                    local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
                                                    broke = true
                                                    breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
                                                    task.wait(nukerslowmode.Value ~= 0 and nukerslowmode.Value/10 or 0)
                                                    break
                                                end
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in pairs(luckyblocktable) do
								if broke then break end
								if nearbed then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												task.wait(nukerslowmode.Value ~= 0 and nukerslowmode.Value/10 or 0)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
					until (not Nuker.Enabled)
				end)
			else
				luckyblocktable = {}
			end
		end,
		HoverText = "Automatically destroys beds & luckyblocks around you."
	})
	nukerslowmode = Nuker.CreateSlider({
		Name = "Break Slowmode",
		Min = 0,
		Max = 10,
		Function = function() end,
		Default = 2
	})
	nukerrange = Nuker.CreateSlider({
		Name = "Break range",
		Min = 1,
		Max = 30,
		Function = function(val) end,
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = "Show HealthBar & Effects",
		Function = function(callback)
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = "Break Animation",
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = "Self Break",
		Function = function() end,
	})
	nukerbeds = Nuker.CreateToggle({
		Name = "Break Beds",
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = "Fly Disable",
		Function = function() end
	})
	nukerclosestblock = Nuker.CreateToggle({
        Name = "Break Closest Block",
        Function = function(callback) end,
        Default = false,
        HoverText = "Breaks the closest block when targeting beds, making it less blatant."
    })
	nukerluckyblock = Nuker.CreateToggle({
		Name = "Break LuckyBlocks",
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = "Break IronOre",
		Function = function(callback)
			if callback then
				luckyblocktable = {}
				for i,v in pairs(store.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = "NukerList",
		TempText = "block (tesla_trap)",
		AddFunction = function()
			luckyblocktable = {}
			for i,v in pairs(store.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)

--[[run(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ""}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in pairs(aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in pairs(tempfolder:GetChildren()) do
				if v.Position == pos then
					return v
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in pairs(tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == "start_block" then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in pairs(tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in pairs(tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientDamageBlock:Get("PlaceBlock"):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition2(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition2(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Schematica",
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new("Folder")
					tempfolder.Parent = game.Workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions["start_block"] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in pairs(positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == "wool_white" and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new("Part")
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in pairs(Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new("Texture")
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in pairs(positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == "wool_white" and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then
							Schematica.ToggleButton(false)
							warningNotification("Schematica", "Finished Placing Blocks", 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = "Automatically places structure at mouse position."
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = "File",
		TempText = "File (location in game.Workspace)",
		FocusLost = function(enter)
			local suc, res = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new("Frame")
				tempgui.Name = "SchematicListOfBlocks"
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new("UIListLayout")
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in pairs(getmaterials(res.blocks)) do
					local testframe = Instance.new("Frame")
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new("ImageLabel")
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new("TextLabel")
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in pairs(tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in pairs(v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)--]]

--[[run(function()
	local Disabler = {Enabled = false}
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "FirewallBypass",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						local item = getItemNear("scythe")
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then
							bedwars.Client:Get("ScytheDash"):SendToServer({direction = Vector3.new(9e9, 9e9, 9e9)})
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								store.scythe = tick() + 1
							end
						end
					until (not Disabler.Enabled)
				end)
			end
		end,
		HoverText = "Float disabler with scythe"
	})
end)--]]

if (not shared.RiseMode) then
	run(function()
		store.TPString = shared.vapeoverlay or nil
		local origtpstring = store.TPString
		local Overlay = GuiLibrary.CreateCustomWindow({
			Name = "Overlay",
			Icon = "vape/assets/TargetIcon1.png",
			IconSize = 16
		})
		local overlayframe = Instance.new("Frame")
		overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		overlayframe.Size = UDim2.new(0, 200, 0, 120)
		overlayframe.Position = UDim2.new(0, 0, 0, 5)
		overlayframe.Parent = Overlay.GetCustomChildren()
		local overlayframe2 = Instance.new("Frame")
		overlayframe2.Size = UDim2.new(1, 0, 0, 10)
		overlayframe2.Position = UDim2.new(0, 0, 0, -5)
		overlayframe2.Parent = overlayframe
		local overlayframe3 = Instance.new("Frame")
		overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		overlayframe3.Size = UDim2.new(1, 0, 0, 6)
		overlayframe3.Position = UDim2.new(0, 0, 0, 6)
		overlayframe3.BorderSizePixel = 0
		overlayframe3.Parent = overlayframe2
		local oldguiupdate = GuiLibrary.UpdateUI
		GuiLibrary.UpdateUI = function(h, s, v, ...)
			overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
			return oldguiupdate(h, s, v, ...)
		end
		local framecorner1 = Instance.new("UICorner")
		framecorner1.CornerRadius = UDim.new(0, 5)
		framecorner1.Parent = overlayframe
		local framecorner2 = Instance.new("UICorner")
		framecorner2.CornerRadius = UDim.new(0, 5)
		framecorner2.Parent = overlayframe2
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -7, 1, -5)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.Font = Enum.Font.Arial
		label.LineHeight = 1.2
		label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		label.TextSize = 16
		label.Text = ""
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.Position = UDim2.new(0, 7, 0, 5)
		label.Parent = overlayframe
		local OverlayFonts = {"Arial"}
		for i,v in pairs(Enum.Font:GetEnumItems()) do
			if v.Name ~= "Arial" then
				table.insert(OverlayFonts, v.Name)
			end
		end
		local OverlayFont = Overlay.CreateDropdown({
			Name = "Font",
			List = OverlayFonts,
			Function = function(val)
				label.Font = Enum.Font[val]
			end
		})
		OverlayFont.Bypass = true
		Overlay.Bypass = true
		local overlayconnections = {}
		local oldnetworkowner
		local teleported = {}
		local teleported2 = {}
		local teleportedability = {}
		local teleportconnections = {}
		local pinglist = {}
		local fpslist = {}
		local matchstatechanged = 0
		local mapname = "Unknown"
		local overlayenabled = false

		task.spawn(function()
			pcall(function()
				mapname = game.Workspace:WaitForChild("Map"):WaitForChild("Worlds"):GetChildren()[1].Name
				mapname = string.gsub(string.split(mapname, "_")[2] or mapname, "-", "") or "Blank"
			end)
		end)

		local function didpingspike()
			local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
			for i,v in pairs(pinglist) do
				if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then
					return currentpingcheck.." => "..v.." ping"
				else
					currentpingcheck = v
				end
			end
			return nil
		end

		local function notlasso()
			for i,v in pairs(collectionService:GetTagged("LassoHooked")) do
				if v == lplr.Character then
					return false
				end
			end
			return true
		end
		local matchstatetick = tick()

		GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateToggle({
			Name = "Overlay",
			Icon = "vape/assets/TargetIcon1.png",
			Function = function(callback)
				overlayenabled = callback
				Overlay.SetVisible(callback)
				if callback then
					table.insert(overlayconnections, bedwars.Client:OnEvent("ProjectileImpact", function(p3)
						if not vapeInjected then return end
						if p3.projectile == "telepearl" then
							teleported[p3.shooterPlayer] = true
						elseif p3.projectile == "swap_ball" then
							if p3.hitEntity then
								teleported[p3.shooterPlayer] = true
								local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
								if plr then teleported[plr] = true end
							end
						end
					end))

					table.insert(overlayconnections, replicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].abilityUsed.OnClientEvent:Connect(function(char, ability)
						if ability == "recall" or ability == "hatter_teleport" or ability == "spirit_assassin_teleport" or ability == "hannah_execute" then
							local plr = playersService:GetPlayerFromCharacter(char)
							if plr then
								teleportedability[plr] = tick() + (ability == "recall" and 12 or 1)
							end
						end
					end))

					table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
						if bedTable.player.UserId == lplr.UserId then
							store.statistics.beds = store.statistics.beds + 1
						end
					end))

					local victorysaid = false
					table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
						local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
						if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
							victorysaid = true
						end
					end))

					table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
						if deathTable.finalKill then
							local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
							local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
							if not killed or not killer then return end
							if killed ~= lplr and killer == lplr then
								store.statistics.kills = store.statistics.kills + 1
							end
						end
					end))

					task.spawn(function()
						repeat
							local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
							if #pinglist >= 10 then
								table.remove(pinglist, 1)
							end
							table.insert(pinglist, ping)
							task.wait(1)
							if store.matchState ~= matchstatechanged then
								if store.matchState == 1 then
									matchstatetick = tick() + 3
								end
								matchstatechanged = store.matchState
							end
							if not store.TPString then
								store.TPString = tick().."/"..store.statistics.kills.."/"..store.statistics.beds.."/"..(victorysaid and 1 or 0).."/"..(1).."/"..(0).."/"..(0).."/"..(0)
								origtpstring = store.TPString
							end
							if entityLibrary.isAlive and (not oldcloneroot) then
								local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
								if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then
									local respawnflag = math.abs(lplr:GetAttribute("SpawnTime") - lplr:GetAttribute("LastTeleported")) > 3
									if (not teleported[lplr]) and respawnflag then
										task.delay(1, function()
											local falseflag = didpingspike()
											if not falseflag then
												store.statistics.lagbacks = store.statistics.lagbacks + 1
											end
										end)
									end
								end
								oldnetworkowner = newnetworkowner
							else
								oldnetworkowner = nil
							end
							teleported[lplr] = nil
							for i, v in pairs(entityLibrary.entityList) do
								if teleportconnections[v.Player.Name.."1"] then continue end
								teleportconnections[v.Player.Name.."1"] = v.Player:GetAttributeChangedSignal("LastTeleported"):Connect(function()
									if not vapeInjected then return end
									for i = 1, 15 do
										task.wait(0.1)
										if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
									end
									if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) > 3 and matchstatetick <= tick() then
										store.statistics.universalLagbacks = store.statistics.universalLagbacks + 1
										vapeEvents.LagbackEvent:Fire(v.Player)
									end
									teleported[v.Player] = nil
								end)
								teleportconnections[v.Player.Name.."2"] = v.Player:GetAttributeChangedSignal("PlayerConnected"):Connect(function()
									teleported2[v.Player] = true
									task.delay(5, function()
										teleported2[v.Player] = nil
									end)
								end)
							end
							local splitted = origtpstring:split("/")
							label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2] + store.statistics.kills).."\nBeds : "..(splitted[3] + store.statistics.beds).."\nWins : "..(splitted[4] + (victorysaid and 1 or 0)).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6] + store.statistics.lagbacks).."\nUniversal Lagbacks : "..(splitted[7] + store.statistics.universalLagbacks).."\nReported : "..(splitted[8] + store.statistics.reported).."\nMap : "..mapname
							local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
							overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
							store.TPString = splitted[1].."/"..(splitted[2] + store.statistics.kills).."/"..(splitted[3] + store.statistics.beds).."/"..(splitted[4] + (victorysaid and 1 or 0)).."/"..(splitted[5] + 1).."/"..(splitted[6] + store.statistics.lagbacks).."/"..(splitted[7] + store.statistics.universalLagbacks).."/"..(splitted[8] + store.statistics.reported)
						until not overlayenabled
					end)
				else
					for i, v in pairs(overlayconnections) do
						if v.Disconnect then pcall(function() v:Disconnect() end) continue end
						if v.disconnect then pcall(function() v:disconnect() end) continue end
					end
					table.clear(overlayconnections)
				end
			end,
			Priority = 2
		}, true)
	end)
end

--[[run(function()
	local Disabler = {Enabled = false}
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.HotWindow.Api.CreateOptionsButton({
		Name = "ScytheDisabler",
		Function = function(callback)
			if callback then
				if getItemNear("scythe") then
					warningNotification("ScytheDisabler", "You can now set your speed to 100 :)", 5)
				else
					warningNotification("ScytheDisabler", "Scythe is required", 5)
					Disabler.ToggleButton()
				end
				task.spawn(function()
					repeat
						task.wait()
						local item = getItemNear("scythe")
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then
							bedwars.Client:Get("ScytheDash"):SendToServer({direction = Vector3.new(9e9, 9e9, 9e9)})
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								store.scythe = tick() + 1
							end
						end
					until (not Disabler.Enabled)
				end)
			else
				warningNotification("ScytheDisabler", "Please set your speed back to 23", 5)
			end
		end,
		HoverText = "Float disabler with scythe"
	})
end)--]]

--if (not shared.RiseMode) then
	run(function()
		local createwarning = warningNotification
		local ReachDisplay = {}
		local ReachLabel
		ReachDisplay = GuiLibrary.CreateLegitModule({
			Name = "Reach Display",
			Function = function(callback)
				if callback then
					task.spawn(function()
						repeat
							task.wait(0.4)
							ReachLabel.Text = store.attackReachUpdate > tick() and store.attackReach.." studs" or "0.00 studs"
						until (not ReachDisplay.Enabled)
					end)
				end
			end
		})
		ReachLabel = Instance.new("TextLabel")
		ReachLabel.Size = UDim2.new(0, 100, 0, 41)
		ReachLabel.BackgroundTransparency = 0.5
		ReachLabel.TextSize = 15
		ReachLabel.Font = Enum.Font.Gotham
		ReachLabel.Text = "0.00 studs"
		ReachLabel.TextColor3 = Color3.new(1, 1, 1)
		local color = GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api
		ReachLabel.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		VoidwareFunctions.Connections:register(VoidwareFunctions.Controllers:get("UpdateUI").UIUpdate.Event:Connect(function(h,s,v)
			color = {Hue = h, Sat = s, Value = v}
			ReachLabel.BackgroundColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		end))
		--Color3.new()
		ReachLabel.Parent = ReachDisplay.GetCustomChildren()
		local ReachCorner = Instance.new("UICorner")
		ReachCorner.CornerRadius = UDim.new(0, 4)
		ReachCorner.Parent = ReachLabel
	end)
--end

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then
		AutoLeave.ToggleButton(false)
	end
end)

--[[run(function()
	local ScytheExploit = {Enabled = false}
	ScytheExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "ScytheExploit",
		Function = function(callback)
			shared.scythexp = callback
		end
	})
end)--]]

--[[run(function() 
    local Settings = {
        BypassActive = {Enabled = false},
        ZephyrMode = {Enabled = false},
        ScytheEnabled = {Enabled = false},
        ScytheSpeed = {Value = 5},
        ScytheBypassSpeed = {Value = 50},
        NoKillauraForScythe = {Enabled = false},
        ClientMod = {Enabled = false},
        DirectionMode = {Value = "LookVector + MoveDirection"},
        DelayActive = {Enabled = false},
        Multiplier = {Value = 0.01},
        Divider = {Value = 0.01},
        DivVal = {Value = 2},
        BlinkStatus = false,
        TickCounter = 0,
        ScytheTickCounter = {Value = 2},
        ScytheDelay = {Value = 0},
        WeaponTiers = {
            [1] = 'stone_sword',
            [2] = 'iron_sword',
            [3] = 'diamond_sword',
            [4] = 'emerald_sword',
            [5] = 'rageblade'
        }
    }
    Settings.BypassActive = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "ActivateBypass",
        Function = function(toggle)
            if toggle then
				warningNotification("ActivateBypass", "WARNING! Using this might result in an AUTO-BAN (the chances are small but NOT 0)", 7)
                task.spawn(function()
					repeat task.wait(1.5)
						shared.zephyrActive = Settings.ZephyrMode.Enabled
						shared.scytheActive = Settings.ScytheEnabled
						shared.scytheSpeed = Settings.ScytheSpeed.Value
						if Settings.ScytheEnabled then
							local weapon = getItemNear("scythe")
							if weapon and (not killauraNearPlayer and store.queueType:find("skywars") or not store.queueType:find("skywars")) then
								switchItem(weapon.tool)
							end
							if weapon then
								if killauraNearPlayer and Settings.NoKillauraForScythe.Enabled then
									scytheSpeed = math.random(5, 10)
								end
								Settings.TickCounter = Settings.TickCounter + 1
								if entityLibrary.isAlive then
									if Settings.TickCounter >= Settings.ScytheBypassSpeed.Value then
										--pcall(function() sethiddenproperty(entityLibrary.character.HumanoidRootPart, "NetworkIsSleeping", false) end)
										Settings.TickCounter = 0
										Settings.BlinkStatus = false
									else
										--pcall(function() sethiddenproperty(entityLibrary.character.HumanoidRootPart, "NetworkIsSleeping", true) end)
										Settings.BlinkStatus = true
									end
								end
								store.holdingscythe = true
								local direction
								if Settings.DirectionMode.Value == "LookVector" then
									direction = entityLibrary.character.HumanoidRootPart.CFrame.LookVector
								elseif Settings.DirectionMode.Value == "MoveDirection" then
									direction = entityLibrary.character.Humanoid.MoveDirection
								elseif Settings.DirectionMode.Value == "LookVector + MoveDirection" then
									direction = entityLibrary.character.HumanoidRootPart.CFrame.LookVector + entityLibrary.character.Humanoid.MoveDirection
								end
								if Settings.Divider.Value ~= 0 then
									bedwars.Client:Get("ScytheDash"):FireServer({direction = direction / Settings.Divider.Value * Settings.Multiplier.Value})
								else
									bedwars.Client:Get("ScytheDash"):FireServer({direction = direction * Settings.Multiplier.Value})
								end
								if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
									store.scythe = tick() + 1
								else
									store.scythe = 0
								end
								if not isnetworkowner(entityLibrary.character.HumanoidRootPart) then
									store.scythe = 0
								end
							else
								store.holdingscythe = false
								store.scythe = 0
							end
						end
						if Settings.ClientMod.Enabled then
							local playerScripts = lplr.PlayerScripts
							if playerScripts.Modules:FindFirstChild("anticheat") then
								playerScripts.Modules.anticheat:Destroy()
							end
							if playerScripts:FindFirstChild("GameAnalyticsClient") then
								playerScripts.GameAnalyticsClient:Destroy()
							end
							if game:GetService("ReplicatedStorage").Modules:FindFirstChild("anticheat") then
								game:GetService("ReplicatedStorage").Modules.anticheat:Destroy()
							end
						end
					until (not Settings.BypassActive.Enabled)
                end)
            else
                Settings.TickCounter = 0
				--pcall(function() sethiddenproperty(entityLibrary.character.HumanoidRootPart, "NetworkIsSleeping", false) end)
            end
        end,
        HoverText = "Disables AntiCheat and adjusts scythe mechanics",
        ExtraText = function()
            local activeCount = 0
            if Settings.ZephyrMode.Enabled then activeCount = activeCount + 1 end
            if Settings.ScytheEnabled then activeCount = activeCount + 1 end
            if Settings.ClientMod.Enabled then activeCount = activeCount + 1 end
            return activeCount.." Bypasses Activated"
        end
    })
    
    Settings.ClientMod = Settings.BypassActive.CreateToggle({
        Name = "Disable AntiCheat",
        Default = true,
        Function = function() end
    })
    
    Settings.ScytheEnabled = Settings.BypassActive.CreateToggle({
        Name = "Enable Scythe",
        Default = true,
        Function = function() end
    })

    Settings.ScytheSpeed = Settings.BypassActive.CreateSlider({
        Name = "Scythe Speed Control",
        Min = 0,
        Max = 35,
        Default = 25,
        Function = function() end
    })
    
    Settings.ScytheBypassSpeed = Settings.BypassActive.CreateSlider({
        Name = "Bypass Speed",
        Min = 0,
        Max = 300,
        Default = 50,
        Function = function() end
    })
    
    Settings.NoKillauraForScythe = Settings.BypassActive.CreateToggle({
        Name = "Disable Killaura",
        Default = true,
        Function = function() end
    })

    Settings.DirectionMode = Settings.BypassActive.CreateDropdown({
        Name = "Direction Control",
        List = {"LookVector", "MoveDirection", "LookVector + MoveDirection"},
        Function = function() end
    })
    
    Settings.Multiplier = Settings.BypassActive.CreateSlider({
        Name = "Direction Multiplier",
        Min = 0,
        Max = 0.01,
        Default = 0.001,
        Function = function() end
    })

    Settings.ZephyrMode = Settings.BypassActive.CreateToggle({
        Name = "Enable Zephyr",
        Default = true,
        Function = function() end
    })
end)--]]

run(function()
	local WhisperAura = {Enabled = false}
	local WhisperRange = {Value = 100}
	local WhisperTask
	local lplr = game:GetService("Players").LocalPlayer
	local function getServerOwl()
		return game.Workspace:FindFirstChild("ServerOwl")
	end
	local function getPlayerFromUserId(userId)
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.UserId == userId then return v end
		end
	end
	local function attack(plr)
		local suc, res = pcall(function()
			if (not plr) then return warn("[WhisperAura | attack]: Player not specified!") end
			local targetPosition = plr.Character.HumanoidRootPart.Position
			local direction = (targetPosition - lplr.Character.HumanoidRootPart.Position).unit
			local ProjectileRefId = game:GetService("HttpService"):GenerateGUID(true)
			local fromPosition
			local ServerOwl = game.Workspace:FindFirstChild("ServerOwl")
			if ServerOwl and ServerOwl.ClassName and ServerOwl.ClassName == "Model" and ServerOwl:GetAttribute("Owner") and ServerOwl:GetAttribute("Target") then
				if tonumber(ServerOwl:GetAttribute("Owner")) == lplr.UserId then
					local target = getPlayerFromUserId(tonumber(ServerOwl:GetAttribute("Target")))
					if target then
						fromPosition = target.Character.HumanoidRootPart.Position
					end
				end
			end
			local initialVelocity = direction
	
			return bedwars.Client:Get("OwlFireProjectile"):InvokeServer({
				["ProjectileRefId"] = ProjectileRefId,
				["direction"] = direction,
				["fromPosition"] = fromPosition,
				["initialVelocity"] = initialVelocity
			})
		end)
		return res
	end
	WhisperAura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "WhisperAura",
		Function = function(call)
			if call then
				WhisperTask = task.spawn(function()
					repeat 
						task.wait()
						if entityLibrary.isAlive and store.matchState > 0 then
							local plr = EntityNearPosition(WhisperRange.Value, true)
							if plr then pcall(function() attack(plr) end) end
						end
					until (not WhisperAura.Enabled)
				end)
			else
				pcall(function()
					task.cancel(WhisperTask)
				end)
			end
		end
	})
	WhisperRange = WhisperAura.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 10,
		Max = 1000,
		Default = 50
	})
end)

run(function()
	local function isXeno()
		local status = false

		if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
			local suc, res = pcall(function()
				return identifyexecutor()
			end)   
			res = tostring(res)
			if string.find(string.lower(res), 'xeno') then status = true end
		else status = false end

		return status
	end
	if isXeno() then
		local CombatConstant

		local Value
		
		Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
			Name = 'Reach',
			Function = function(callback)
				
			end,
			HoverText = 'Extends attack reach'
		})
		Value = Reach.CreateSlider({
			Name = 'Range',
			Min = 0,
			Max = 18,
			Default = 18,
			Function = function(val)
				if Reach.Enabled then
					
				end
			end
		})
	end
end)

run(function()
	local AutoSuffocate = {Enabled = false}
	local LimitItem = {Enabled = false}
	local Range = {Value = 30}
	
	local function fixPosition(pos)
		return bedwars.BlockController:getBlockPosition(pos) * 3
	end
	
	AutoSuffocate = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AutoSuffocate',
		Function = function(callback)
			if callback then
				repeat
					local item = store.hand.toolType == 'block' and store.hand.tool.Name or not LimitItem.Enabled and getWool()
	
					if item then
						local plrs = {EntityNearPosition(Range.Value, true)}
	
						for _, ent in plrs do
							local needPlaced = {}
	
							for _, side in Enum.NormalId:GetEnumItems() do
								side = Vector3.fromNormalId(side)
								if side.Y ~= 0 then continue end
	
								side = fixPosition(ent.Character.PrimaryPart.Position + side * 2)
								if not getPlacedBlock(side) then
									table.insert(needPlaced, side)
								end
							end
	
							if #needPlaced < 3 then
								table.insert(needPlaced, fixPosition(ent.Head.Position))
								table.insert(needPlaced, fixPosition(ent.Character.PrimaryPart.Position - Vector3.new(0, 1, 0)))
	
								for _, pos in needPlaced do
									if not getPlacedBlock(pos) then
										task.spawn(bedwars.placeBlock, pos, item)
										break
									end
								end
							end
						end
					end
	
					task.wait(0.09)
				until not AutoSuffocate.Enabled
			end
		end,
		HoverText = 'Places blocks on nearby confined entities'
	})
	Range = AutoSuffocate.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 20,
		Default = 20,
		Function = function() end
	})
	LimitItem = AutoSuffocate.CreateToggle({
		Name = 'Limit to Items',
		Default = true,
		Function = function() end
	})
end)

run(function()
	local entitylib = entityLibrary
	local AutoVoidDrop = {Enabled = false}
	local OwlCheck = {Enabled = false}

	local DropItemRemote
	
	AutoVoidDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoVoidDrop',
		Function = function(callback)
			if callback then
				repeat task.wait() until store.matchState ~= 0 or (not AutoVoidDrop.Enabled)
				if not AutoVoidDrop.Enabled then return end

				if not DropItemRemote then DropItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("DropItem") end
	
				local lowestpoint = math.huge
				for _, v in store.blocks do
					local point = (v.Position.Y - (v.Size.Y / 2)) - 50
					if point < lowestpoint then 
						lowestpoint = point 
					end
				end
	
				repeat
					if entitylib.isAlive then
						local root = entitylib.character.HumanoidRootPart
						if root.Position.Y < lowestpoint and (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 and not getItem('balloon') then
							if not OwlCheck.Enabled or not root:FindFirstChild('OwlLiftForce') then
								for _, item in {'iron', 'diamond', 'emerald', 'gold'} do
									item = getItem(item)
									if item then
										item = DropItemRemote:InvokeServer({
											item = item.tool,
											amount = item.amount
										})
	
										if item then
											item:SetAttribute('ClientDropTime', tick() + 100)
										end
									end
								end
							end
						end
					end
	
					task.wait(0.1)
				until not AutoVoidDrop.Enabled
			end
		end,
		HoverText = 'Drops resources when you fall into the void'
	})
	OwlCheck = AutoVoidDrop.CreateToggle({
		Name = 'Owl check',
		Default = true,
		HoverText = 'Refuses to drop items if being picked up by an owl',
		Function = function() end
	})
end)

run(function()
	local ProjectileAura = {Enabled = false}
	local Targets
	local Range = {Value = 30}
	local List = {ListEnabled = {'arrow', 'snowball'}}
	local rayCheck = RaycastParams.new()
	rayCheck.FilterType = Enum.RaycastFilterType.Include

	local projectileRemote = {InvokeServer = function() end}
	local FireDelays = {}
	task.spawn(function()
		projectileRemote = bedwars.Client:Get(bedwars.ProjectileRemote)
	end)

	local function getAmmo(check, item)
		if not check.ammoItemTypes then return item.itemType end
		for _, item in store.inventory.inventory.items do
			if check.ammoItemTypes and table.find(check.ammoItemTypes, item.itemType) then
				return item.itemType
			end
		end
	end

	local function projectileType(item, ammo)
		local res
		if not ammo then ammo = "" end
		ammo = tostring(ammo)
		local meta = bedwars.ItemMeta[item.itemType]
		if not (item ~= nil and type(item) == "table" and item.itemType ~= nil and meta ~= nil and type(meta) == "table" and meta.displayName ~= nil) then return res end
		if meta.displayName == "Crossbow" and ammo == "arrow" then
			res = "crossbow_arrow"
		elseif item.itemType == "snowball" then
			res = "snowball"
		elseif item.itemType == "wood_bow" then
			res = "arrow"
		else
			res = item.itemType.."_"..ammo
		end
		return res
	end
	
	local function getProjectiles()
		bedwars.ItemMeta = bedwars.ItemMeta or bedwars.ItemTable
		local items = {}
		for _, item in store.inventory.inventory.items do
			if item and item.itemType == "mage_spellbook" then
				table.insert(items, {
					item,
					nil, 
					nil,
					0.3
				})
				continue
			end
			if item and item.itemType == "owl_orb" then
				table.insert(items, {
					item,
					nil, 
					nil,
					0.3
				})
				continue
			end
			if item and item.itemType == "light_sword" then
				table.insert(items, {
					item,
					nil, 
					nil,
					0.3
				})
			end
			local proj = bedwars.ItemMeta[item.itemType].projectileSource
			local ammo = proj and getAmmo(proj, item)
			if not table.find(List.ListEnabled, 'sword_wave1') then table.insert(List.ListEnabled, 'sword_wave1') end
			if not table.find(List.ListEnabled, 'ninja_chakram_4') then table.insert(List.ListEnabled, 'ninja_chakram_4') end
			if ammo and table.find(List.ListEnabled, ammo) then
				local res = projectileType(item, ammo)
				if res then
					table.insert(items, {
						item,
						ammo,
						res,
						proj
					})
				end
			end
		end
		return items
	end

	local HttpService = game:GetService("HttpService")
	local httpService = HttpService

	local function specialGUID()
		return string.upper((tostring(HttpService:GenerateGUID(false)):split("-"))[1])
	end
	
	local function selfPosition()
		return lplr.Character and lplr.Character.PrimaryPart and lplr.Character.PrimaryPart.Position
	end

	local handle = {
		Lumen = function(ent, item, ammo, projectile, itemMeta)
			if not item.tool then return end
			if not ent then return end
			local selfPos = selfPosition()
			if not selfPos then return end
	
			local vec = ent.PrimaryPart.Position * Vector3.new(1, 0, 1)
			lplr.Character.PrimaryPart.CFrame = CFrame.lookAt(lplr.Character.PrimaryPart.Position, Vector3.new(vec.X, lplr.Character.PrimaryPart.Position.Y + 0.001, vec.Z))
	
			local mag = lplr.Character.PrimaryPart.CFrame.LookVector*80
	
			projectileRemote:InvokeServer(
				item.tool,
				"light_sword",
				"sword_wave1",
				Vector3.new(selfPos.X, selfPos.Y + 2, selfPos.Z),
				selfPos,
				mag,
				specialGUID(),
				{
					["shotId"] = specialGUID(),
					["drawDurationSec"] = 0
				},
				workspace:GetServerTimeNow() - 0.045
			)

			local plr = ent
			vapeTargetInfo.Targets.ProjectileAura = {
				Humanoid = {
					Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
					MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
				},
				Player = plr.Player
			}
			
			pcall(function()
				FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
			end)
		end,
		Umeko = function(ent, item, ammo, projectile, itemMeta)
			if not item.tool then return end
			if not ent then return end
			local selfPos = selfPosition()
			if not selfPos then return end
	
			local vec = ent.PrimaryPart.Position * Vector3.new(1, 0, 1)
			lplr.Character.PrimaryPart.CFrame = CFrame.lookAt(lplr.Character.PrimaryPart.Position, Vector3.new(vec.X, lplr.Character.PrimaryPart.Position.Y + 0.001, vec.Z))
	
			switchItem(item.tool)

			local targetPos = ent.PrimaryPart.Position

			local expectedTime = (selfPos - targetPos).Magnitude / 160
			targetPos += (ent.PrimaryPart.Velocity * expectedTime)

			local plr = ent
			vapeTargetInfo.Targets.ProjectileAura = {
				Humanoid = {
					Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
					MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
				},
				Player = plr.Player
			}

			projectileRemote:InvokeServer(
				item.tool,
				nil,
				"ninja_chakram_4",
				selfPos + Vector3.new(0, 2, 0),
				selfPos,
				(selfPos - targetPos).Unit * -160,
				specialGUID(),
				{
					["shotId"] = specialGUID(),
					["drawDurationSec"] = 1
				},
				workspace:GetServerTimeNow() - 0.045
			)
			
			pcall(function()
				FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
			end)
		end,
		Whim = function(ent, item, ammo, projectile, itemMeta)
			if not item.tool then return end
			if not ent then return end
			local selfPos = selfPosition()
			if not selfPos then return end
	
			local vec = ent.PrimaryPart.Position * Vector3.new(1, 0, 1)
			lplr.Character.PrimaryPart.CFrame = CFrame.lookAt(lplr.Character.PrimaryPart.Position, Vector3.new(vec.X, lplr.Character.PrimaryPart.Position.Y + 0.001, vec.Z))
	
			switchItem(item.tool)

			local targetPos = ent.RootPart.Position

			local expectedTime = (selfPos - targetPos).Magnitude / 160
			targetPos += (ent.RootPart.Velocity * expectedTime)

			local plr = ent
			vapeTargetInfo.Targets.ProjectileAura = {
				Humanoid = {
					Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
					MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
				},
				Player = plr.Player
			}

			projectileRemote:InvokeServer(
				item.tool,
				nil,
				"mage_spell_base",
				selfPos + Vector3.new(0, 2, 0),
				selfPos,
				(selfPos - targetPos).Unit * -160,
				specialGUID(),
				{
					["shotId"] = specialGUID(),
					["drawDurationSec"] = 1
				},
				workspace:GetServerTimeNow() - 0.045
			)
			
			pcall(function()
				FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
			end)
		end,
		Whisper = function(ent, item, ammo, projectile, itemMeta)
			local function getPlayerFromUserId(userId)
				if not userId then return nil end
				local suc = pcall(function()
					userId = tonumber(userId)
				end)
				if not suc then return nil end
				for i,v in pairs(game:GetService("Players"):GetPlayers()) do
					if v.UserId == userId then return v end
				end
			end
			local function getOwl()
				local owl = Filter(game.Workspace:GetChildren(), function(v)
					if v.ClassName and v.ClassName == "Model" and v.Name and v.Name == "ServerOwl" and tostring(v:GetAttribute("Owner")) == tostring(lplr.UserId) and getPlayerFromUserId(tostring(v:GetAttribute("Target"))) then 
						return true
					else
						return false
					end
				end)
				if not owl then return end

				if not item.tool then return end
				if not ent then return end
				local selfPos = selfPosition()
				if not selfPos then return end

				local targetPosition = ent.RootPart.Position
				local direction = (targetPosition - lplr.Character.HumanoidRootPart.Position).unit

				local target = getPlayerFromUserId(tostring(owl:GetAttribute("Target")))
				local ProjectileRefId, direction, fromPosition, initialVelocity = specialGUID(), direction, nil, direction
				local suc = pcall(function()
					fromPosition = target.Character.HumanoidRootPart.Position
				end)
				if not suc then return end

				local plr = ent
				vapeTargetInfo.Targets.ProjectileAura = {
					Humanoid = {
						Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
						MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
					},
					Player = plr.Player
				}

				bedwars.Client:Get("OwlFireProjectile"):InvokeServer({
					ProjectileRefId = ProjectileRefId,
					direction = direction,
					fromPosition = fromPosition,
					initialVelocity = initialVelocity
				})
			end
		end
	}

	local entitylib, prediction
	
	ProjectileAura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		Function = function(callback)
			if callback then
				if not callback then vapeTargetInfo.Targets.ProjectileAura = nil end
				if not entitylib then entitylib = loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/libraries/entity.lua", true))() end
				if not prediction then prediction = loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/libraries/prediction.lua", true))() end
				task.spawn(function()
					repeat
						if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) > 0.5 then
							task.spawn(function()
								local ent = EntityNearPosition(Range.Value, false)
								if not ent then vapeTargetInfo.Targets.ProjectileAura = nil end
								if ent then
									ent.RootPart = ent.RootPart or ent.PrimaryPart
									if Targets.Walls.Enabled then
										if not Wallcheck(lplr.Character, ent.Character) then return end
									end
									local pos = entitylib.character.RootPart.Position
									for _, data in getProjectiles() do
										local item, ammo, projectile, itemMeta = unpack(data)
										if (FireDelays[item.itemType] or 0) < tick() then
											if item.itemType == "light_sword" then
												handle.Lumen(ent, unpack(data))
												continue
											elseif item.itemType == "ninja_chakram_4" then
												handle.Umeko(ent, unpack(data))
												continue
											elseif item.itemType == "mage_spellbook" then
												handle.Whim(ent, unpack(data))
												continue
											elseif item.itemType == "owl_orb" then
												handle.Whisper(ent, unpack(data))
												continue
											end
											rayCheck.FilterDescendantsInstances = {workspace.Map}
											local meta = bedwars.ProjectileMeta[projectile]
											print(projectile, meta)
											if not meta then continue end
											local projSpeed, gravity = meta.launchVelocity, meta.gravitationalAcceleration or 196.2
											local calc = prediction.SolveTrajectory(pos, projSpeed, gravity, ent.RootPart.Position, ent.RootPart.Velocity, workspace.Gravity, ent.HipHeight, ent.Jumping and 42.6 or nil, rayCheck)
											if calc then
												local plr = ent
												vapeTargetInfo.Targets.ProjectileAura = {
													Humanoid = {
														Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
														MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
													},
													Player = plr.Player
												}
												local switched = switchItem(item.tool)
			
												task.spawn(function()
													local dir, id = CFrame.lookAt(pos, calc).LookVector, httpService:GenerateGUID(true)
													local shootPosition = (CFrame.new(pos, calc) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).Position
													--bedwars.ProjectileController:createLocalProjectile(meta, ammo, projectile, shootPosition, id, dir * projSpeed, {drawDurationSeconds = 1})
													local res = projectileRemote:InvokeServer(item.tool, ammo, projectile, shootPosition, pos, dir * projSpeed, id, {drawDurationSeconds = 1, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
													if not res then
														FireDelays[item.itemType] = tick()
													else
														local shoot = itemMeta.launchSound
														shoot = shoot and shoot[math.random(1, #shoot)] or nil
														if shoot then
															bedwars.SoundManager:playSound(shoot)
														end
													end
												end)
			
												FireDelays[item.itemType] = tick() + itemMeta.fireDelaySec
												if switched then
													task.wait(0.05)
												end
											end
										end
									end
								end
							end)
						end
						task.wait(0.1)
					until not ProjectileAura.Enabled
				end)
			end
		end,
		HoverText = 'Shoots people around you'
	})
	Targets = ProjectileAura.CreateTargetWindow({})
	Range = ProjectileAura.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 50,
		Default = 50,
		Function = function() end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)

local function collection(tags, module, customadd, customremove)
	tags = typeof(tags) ~= 'table' and {tags} or tags
	local objs, connections = {}, {}
	
	for _, tag in tags do
		table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			if customadd then
				customadd(objs, v, tag)
				return
			end
			table.insert(objs, v)
		end))
		table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if customremove then
				customremove(objs, v, tag)
				return
			end
			v = table.find(objs, v)
			if v then
				table.remove(objs, v)
			end
		end))
	
		for _, v in collectionService:GetTagged(tag) do
			if customadd then
				customadd(objs, v, tag)
				continue
			end
			table.insert(objs, v)
		end
	end
	
	local cleanFunc = function(self)
		for _, v in connections do
			v:Disconnect()
		end
		table.clear(connections)
		table.clear(objs)
		table.clear(self)
	end
	
	return objs, cleanFunc
end
store.shop = collection({'BedwarsItemShop', 'TeamUpgradeShopkeeper'}, GuiLibrary, function(tab, obj)
    table.insert(tab, {Id = obj.Name, RootPart = obj, Shop = obj:HasTag('BedwarsItemShop'), Upgrades = obj:HasTag('TeamUpgradeShopkeeper')})
end)

run(function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local guiService = game:GetService("GuiService")

	local AutoBank
	local UIToggle
	local UI
	local Chests
	local Items = {}

	local AutoBankMode = {Value = "Toggle"}
	
	local function addItem(itemType, shop)
		local item = Instance.new('ImageLabel')
		item.Image = bedwars.getIcon({itemType = itemType}, true)
		item.Size = UDim2.fromOffset(32, 32)
		item.Name = itemType
		item.BackgroundTransparency = 1
		item.LayoutOrder = #UI:GetChildren()
		item.Parent = UI
		local itemtext = Instance.new('TextLabel')
		itemtext.Name = 'Amount'
		itemtext.Size = UDim2.fromScale(1, 1)
		itemtext.BackgroundTransparency = 1
		itemtext.Text = ''
		itemtext.TextColor3 = Color3.new(1, 1, 1)
		itemtext.TextSize = 16
		itemtext.TextStrokeTransparency = 0.3
		itemtext.Font = Enum.Font.Arial
		itemtext.Parent = item
		Items[itemType] = {Object = itemtext, Type = shop}
	end
	
	local function refreshBank(echest)
		for i, v in Items do
			local item = echest:FindFirstChild(i)
			v.Object.Text = item and item:GetAttribute('Amount') or ''
		end
	end
	
	local function nearChest()
		if entitylib.isAlive then
			local pos = entitylib.character.HumanoidRootPart.Position
			for _, chest in Chests do
				if (chest.Position - pos).Magnitude < 20 then
					return true
				end
			end
		end
	end
	
	local function handleState()
		local chest = replicatedStorage.Inventories:FindFirstChild(lplr.Name..'_personal')
		if not chest then return end
	
		local mapCF = workspace.MapCFrames:FindFirstChild((lplr:GetAttribute('Team') or 1)..'_spawn')
		if AutoBankMode.Value ~= "Toggle" then
			if not nearChest() then
				warningNotification("AutoBank", "No chest close by.", 3)
			else
				warningNotification("AutoBank", "Successfully stored the loot in a personal chest!", 3)
			end
		end
		if mapCF and nearChest() then
			for _, v in chest:GetChildren() do
				local item = Items[v.Name]
				if item then
					task.spawn(function()
						bedwars.Client:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest, v)
						refreshBank(chest)
					end)
				end
			end
		else
			for _, v in store.localInventory.inventory.items do
				local item = Items[v.itemType]
				if item then
					task.spawn(function()
						bedwars.Client:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(chest, v.tool)
						refreshBank(chest)
					end)
				end
			end
		end
	end
	
	AutoBank = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBank',
		Function = function(callback)
			if callback then
				Chests = collection('personal-chest', AutoBank)
				UI = Instance.new('Frame')
				UI.Size = UDim2.new(1, 0, 0, 32)
				UI.Position = UDim2.fromOffset(0, -240)
				UI.BackgroundTransparency = 1
				UI.Visible = UIToggle.Enabled
				UI.Parent = vape.gui
				AutoBank:Clean(UI)
				local Sort = Instance.new('UIListLayout')
				Sort.FillDirection = Enum.FillDirection.Horizontal
				Sort.HorizontalAlignment = Enum.HorizontalAlignment.Center
				Sort.SortOrder = Enum.SortOrder.LayoutOrder
				Sort.Parent = UI
				addItem('iron', true)
				addItem('gold', true)
				addItem('diamond', false)
				addItem('emerald', true)
				addItem('void_crystal', true)
	
				task.spawn(function()
					repeat
						local hotbar = lplr.PlayerGui:FindFirstChild('hotbar')
						hotbar = hotbar and hotbar['1']:FindFirstChild('HotbarHealthbarContainer')
						if hotbar then
							UI.Position = UDim2.fromOffset(0, (hotbar.AbsolutePosition.Y + guiService:GetGuiInset().Y) - 40)
						end
		
						--local newState = nearChest()
						--if newState then
							handleState()
						--end
		
						task.wait(0.1)
					until (not AutoBank.Enabled)
				end)

				if AutoBankMode.Value ~= "Toggle" then
					AutoBank.ToggleButton(false)
				end
			else
				table.clear(Items)
			end
		end,
		HoverText = 'Automatically puts resources in ender chest'
	})
	AutoBankMode = AutoBank.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function()
			if AutoBank.Enabled then
				AutoBank.ToggleButton(false)
				AutoBank.ToggleButton(false)
			end
		end
	})
	UIToggle = AutoBank.CreateToggle({
		Name = 'UI',
		Function = function(callback)
			if AutoBank.Enabled then
				UI.Visible = callback
			end
		end,
		Default = true
	})
end)

run(function()
	local UICleanup
	local StarterGui = game:GetService("StarterGui")
	UICleanup = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "UICleanup",
		Function = function(call)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not call)
		end
	})
end)

local function collection(tags, module, customadd, customremove)
		tags = typeof(tags) ~= 'table' and {tags} or tags
		local objs, connections = {}, {}
	
		for _, tag in tags do
			table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
				if customadd then
					customadd(objs, v, tag)
					return
				end
				table.insert(objs, v)
			end))
			table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
				if customremove then
					customremove(objs, v, tag)
					return
				end
				v = table.find(objs, v)
				if v then
					table.remove(objs, v)
				end
			end))
	
			for _, v in collectionService:GetTagged(tag) do
				if customadd then
					customadd(objs, v, tag)
					continue
				end
				table.insert(objs, v)
			end
		end
	
		local cleanFunc = function(self)
			for _, v in connections do
				v:Disconnect()
			end
			table.clear(connections)
			table.clear(objs)
			table.clear(self)
		end
	
		return objs, cleanFunc
	end
	store.shop = collection({'BedwarsItemShop', 'TeamUpgradeShopkeeper'}, GuiLibrary, function(tab, obj)
        table.insert(tab, {Id = obj.Name, RootPart = obj, Shop = obj:HasTag('BedwarsItemShop'), Upgrades = obj:HasTag('TeamUpgradeShopkeeper')})
    end)

--VoidwareFunctions.GlobaliseObject("store", store)
VoidwareFunctions.GlobaliseObject("GlobalStore", store)

--VoidwareFunctions.GlobaliseObject("bedwars", bedwars)
VoidwareFunctions.GlobaliseObject("GlobalBedwars", bedwars)

VoidwareFunctions.GlobaliseObject("VapeBWLoaded", true)
local function createMonitoredTable(originalTable, onChange)
    local proxy = {}
    local mt = {
        __index = originalTable,
        __newindex = function(t, key, value)
            local oldValue = originalTable[key]
            originalTable[key] = value
            if onChange then
                onChange(key, oldValue, value)
            end
        end
    }
    setmetatable(proxy, mt)
    return proxy
end
local function onChange(key, oldValue, newValue)
   --print("Changed key:", key, "from", oldValue, "to", newValue)
   	--VoidwareFunctions.GlobaliseObject("store", store)
	VoidwareFunctions.GlobaliseObject("GlobalStore", store)
end
local function onChange2(key, oldValue, newValue)
	--print("Changed key:", key, "from", oldValue, "to", newValue)
	--VoidwareFunctions.GlobaliseObject("bedwars", bedwars)
	VoidwareFunctions.GlobaliseObject("GlobalBedwars", bedwars)
 end

store = createMonitoredTable(store, onChange)
bedwars = createMonitoredTable(bedwars, onChange2)

--if (not shared.CheatEngineMode) then pload("CustomModules/S6872274481.lua") end