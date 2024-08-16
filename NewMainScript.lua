repeat task.wait() until game:IsLoaded()
if getgenv and not getgenv().shared then getgenv().shared = {} end
local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end


if not isfolder('vape') then makefolder('vape') end

local playersService = game:GetService('Players')
local httpService = game:GetService("HttpService")
local lplr = playersService.LocalPlayer

local voidware = {}
shared.voidware = voidware
getgenv().voidware = voidware

do
    voidware.githubUser = 'VapeVoidware'
    voidware.githubRepo = 'VoidwareBackup'
    voidware.apiVer = 1
    
    function logError(log)
        warn(`[VoidWare]: {log}`)
    end

    function logNormal(log)
        print(`[VoidWare]: {log}`)
    end

    local clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    local executor = 'unknown'
    if identifyexecutor then
        executor = identifyexecutor():lower()
    end
    local executors = {"solara", "fluxus", "macsploit", "hydrogen", "wave", "codex", "arceus", "delta", "vega", "cubix", "celery", "cryptic", "cacti", "appleware", "synapse", "salad"}
    for i, exec in pairs(executors) do
        if executor:find(exec) then
            executor = exec
            break
        end
    end

    function voidware.getID()
        local headers = {
            ["Content-type"] = "application/json",
            Authorization = "Bearer blankwontddosthis:3"
        }
        local data = {["client_id"] = clientId, ["user_id"] = lplr.UserId}
        local final_data = httpService:JSONEncode(data)
        local url = "https://api.vapevoidware.xyz/create_id"
        local a = request({
            Url = url,
            Method = 'POST',
            Headers = headers,
            Body = final_data
        })
        
        if a['StatusCode'] == 200 then
            writefile('vape/id.txt', httpService:JSONDecode(a["Body"])["id"])
        else
            logError(`create_id error {a.StatusCode}`)
        end
        --[[elseif a['StatusCode'] == 403 then
            lplr:Kick("Voidware Error]: Error doing step1 Error code: 1986")
        elseif a['StatusCode'] == 401 then
            lplr:Kick("Voidware Error]: Error doing step1 Error code: 1922")
        elseif a['StatusCode'] == 429 then
            lplr:Kick("Voidware Error]: Error doing step1 Error code: 1954 Please rejoin!")
        else
            lplr:Kick("Voidware Error]: Error doing step1 Error code: 2000".." | "..tostring(a["StatusCode"]))
        end--]]
    
        if shared.VoidDev then
            print("Raw Response: "..tostring(a))
            print("Decompressed data showing below:")
            if type(a) == "table" then
                for i,v in pairs(a) do
                    print("Showing data for: "..tostring(i))
                    if type(a[i]) == "table" then
                        print("Table reponse for "..tostring(i).." detected! Showing the table:")
                        for i2, v2 in pairs(a[i]) do
                            print("Showing data for: "..tostring(i2))
                            print("Data: "..tostring(a[i][i2]))
                        end
                    else
                        print("Data: "..tostring(a[i]))
                    end
                    print("Continuing with next child of the table:")
                    print("[-----------------------------]")
                end
            else
                print("The response type is invalid! (Expected: table)")
            end
        end
    end

    local illegalIDs = {
        ['exampleID'] = 'exampleKickMsg',
        ['f5c5e457-b32e-4be2-81d7-b3af9d31593b'] = 'YOU ARE A MADARCHOOD you monkey!!',
        ['059b8df3-0e5e-485b-baa6-349e7f9ead4b'] = 'hi'
    }

    function voidware.verifyID()
        if not clientId:match('%w+%-%w+%-%w+%-%w+%-%w+') then
            task.delay(5, function() while true do end end) -- bedwars disabler
            lplr['Kick\000'](lplr, 'mexican detected (no passport)')
        end

        for id, msg in pairs(illegalIDs) do
            if id == clientId then
                task.delay(5, function() while true do end end) -- bedwars disabler
                lplr['Kick\000'](lplr, msg)
            end
        end
    end

    function voidware.postAnalytics()
        local headers = {
            ["Content-type"] = "application/json",
            ["Authorization"] = "Bearer blankwontddosthis:3"
        }
        local data = {
            ["client_id"] = tostring(clientId), 
            ["executor"] = tostring(executor),
            ['user_id'] = tonumber(lplr.UserId),
            ['voidware_id'] = "github"
        }
        local final_data = httpService:JSONEncode(data)
        local url = `https://api.vapevoidware.xyz/v{voidware.apiVer}/stats/data/add`
        local a = request({
            Url = url,
            Method = 'POST',
            Headers = headers,
            Body = final_data
        })
        if a['StatusCode'] ~= 200 then
            logError(`postAnalytics ({a.StatusCode})`)
        end
    end

    function voidware.GetHttpData()
        local client_id = game:GetService("RbxAnalyticsService"):GetClientId()
        local user_id = lplr.UserId .. '' -- mini optimization
        local voidware_id = "github"
        return voidware_id, user_id, client_id
    end

    function voidware.readJsonFile(file)
        file = `vape/{file}`
        if isfile(file) then
            local data = readfile(file)
            local suc, res = pcall(function(data) return httpService:JSONDecode(data) end, data)
            if suc then
                return res
            else
                return {}
            end
        end
        return {}
    end

    function voidware.writeJsonFile(file, data)
        file = `vape/{file}`
        return writefile(file, httpService:JSONEncode(data))
    end

    task.spawn(voidware.getID)
    task.spawn(voidware.verifyID)
    task.spawn(voidware.postAnalytics)

    local blacklistedexecutors = {"solara", "celery", "appleware"}
    for i, exec in pairs(blacklistedexecutors) do
        if executor:find(exec) then 
            shared.BlacklistedExecutor = {
                Value = true,
                Executor = executor
            }
            --lplr:Kick("[Voidware]: Error loading Voidware! Reason: Unsupported Executor ["..tostring(executor).."] Please use another executor! Support server: discord.gg/voidware") 
        end
    end
end


--[[local function pload(fileName, criticalAsset)
    if not fileName then return warn("No fileName specified!") end
    fileName = tostring(fileName)
	local voidware_id, user_id, client_id = voidware.GetHttpData()
    local url = "https://storage.vapevoidware.xyz/VoidwareSource/"..fileName.."?voidware_id="..tostring(voidware_id).."&user_id="..tostring(user_id).."&client_id="..tostring(client_id)
	local a = request({
    	Url = url,
    	Method = 'GET',
	})
	if type(a) == "table" then
        if shared.VoidDev then
            if a["StatusCode"] and a["StatusCode"] == 200 then
                return loadstring(tostring(a["Body"]))()
            else
                if criticalAsset then lplr:Kick("[Voidware Error]: Error loading critical file: "..tostring(fileName).." Error code: "..tostring(a["StatusCode"]).." Response: "..tostring(a["Body"])) end
            end
        else
            if a["StatusCode"] and a["StatusCode"] == 200 then
                return loadstring(tostring(a["Body"]))()
            elseif a["StatusCode"] and a["StatusCode"] == 403 then
                print("Error loading: "..tostring(fileName).." Error code: 1986")
                if criticalAsset then lplr:Kick("[Voidware Error]: Error loading critical file: "..tostring(fileName).." Error code: "..tostring(a["StatusCode"]).." Response: "..tostring(a["Body"])) end
                return {["Error"] = "1986"}
            else
                if criticalAsset then lplr:Kick("[Voidware Error]: Error loading critical file: "..tostring(fileName).." Error code: "..tostring(a["StatusCode"]).." Response: "..tostring(a["Body"])) end
                return {["Error"] = "404"}
            end
        end
	end
end
shared.pload = pload
getgenv().pload = pload--]]

local profileManager = {}
do
    profileManager.profileDownloads = { -- not nessecary to define indexes
        [1] = 'Profiles',
        [2] = 'ClosetProfiles'
    }

    for _, dir in next, profileManager.profileDownloads do
        if not isfolder(`vape/{dir}`) then
            makefolder(`vape/{dir}`)
        end
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "idk"
    gui.DisplayOrder = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.OnTopOfCoreBlur = true
    gui.ResetOnSpawn = false
    gui.Parent = lplr.PlayerGui

    function profileManager.getOnlineProfile(profile, mode)
        if not isfile(`vape/{mode}/{profile}`) then
            local textlabel = Instance.new('TextLabel')
            textlabel.Size = UDim2.new(1, 0, 0, 36)
            textlabel.Text = 'Downloading '..path
            textlabel.BackgroundTransparency = 1
            textlabel.TextStrokeTransparency = 0
            textlabel.TextSize = 30
            textlabel.Font = Enum.Font.SourceSans
            textlabel.TextColor3 = Color3.new(1, 1, 1)
            textlabel.Position = UDim2.new(0, 0, 0, -36)
            textlabel.Parent = gui
            local suc, res = pcall(function() return game:HttpGet(`https://raw.githubusercontent.com/Erchobg/VoidwareProfiles/main/{mode}/{profile}`, true) end)
            writefile(`vape/{mode}/{profile}`, res)
            textlabel:Destroy()
            task.wait()
        end
        return print(`{mode}/{profile}`)
    end

    local hashes = voidware.readJsonFile('profileHashes.json')

    function profileManager.checkHash(file, hash, mode)
        return hashes[`{mode}_{file}`] == hash
    end

    function profileManager.updateHash(file, hash, mode)
        hashes[`{mode}_{file}`] = hash
        voidware.writeJsonFile('profileHashes.json', hashes)
    end

    function profileManager.downloadLatest(id)
        assert(type(id) == 'number', `profileManager.install (invalid id)`)
        local mode = profileManager.profileDownloads[id]
        local uri = `https://api.github.com/repos/Erchobg/VoidwareProfiles/contents/{mode}`
        local body = game:HttpGet(uri)
        if body ~= '404: Not Found' then 
            local suc, res = pcall(function(body) return httpService:JSONDecode(body) end, body)
            if suc then
                for _, file in next, httpService:JSONDecode(res) do
                    if not profileManager.checkHash(file.name, file.sha, mode) then
                        logNormal(`updating {mode}/{file.name}`)
                        profileManager.getOnlineProfile(file.name, mode)
                        profileManager.updateHash(file.name, file.sha, mode)
                    end
                end
            else
                logError('profileManager.install (bad json)')
            end
        end
    end
end


for _, dir in next, profileManager.profileDownloads do
    downloadLatest(_)
end

if not shared.VapeDeveloper then 
	local commit = "main"
	for i,v in pairs(game:HttpGet(`https://github.com/{voidware.githubUser}/{voidware.githubRepo}`):split("\n")) do 
		if v:find("commit") and v:find("fragment") then 
			local str = v:split("/")[5]
			commit = str:sub(0, str:find('"') - 1)
			break
		end
	end
	if commit then
		if isfolder("vape") then 
			if ((not isfile("vape/commithash.txt")) or (readfile("vape/commithash.txt") ~= commit or commit == "main")) then
				for i,v in pairs({"vape/Universal.lua", "vape/MainScript.lua", "vape/GuiLibrary.lua"}) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
                        if not shared.VoidDev then
						    delfile(v)
                        end
					end 
				end
				if isfolder("vape/CustomModules") then 
					for i,v in pairs(listfiles("vape/CustomModules")) do 
						if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
                            if not shared.VoidDev then
							    delfile(v)
                            end
						end 
					end
				end
				if isfolder("vape/Libraries") then 
					for i,v in pairs(listfiles("vape/Libraries")) do 
						if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
                            if not shared.VoidDev then
							    delfile(v)
                            end
						end 
					end
				end
				writefile("vape/commithash.txt", commit)
			end
		else
			makefolder("vape")
			writefile("vape/commithash.txt", commit)
		end
	else
		error("Failed to connect to github, please try using a VPN.")
	end
end

function voidware.getFile(scripturl, criticalAsset)
    if isfile('vape/'..scripturl) then
        if not shared.VoidDev then
            pcall(function() delfile('vape/'..scripturl) end)
        else
            return readfile('vape/'..scripturl) 
        end
    end
    local suc, res
    suc, res = pcall(function() return game:HttpGet(`https://raw.githubusercontent.com/{voidware.githubUser}/{voidware.githubRepo}/{readfile('vape/commithash.txt')}/{scripturl}`, true) end)
    if not suc or res == "404: Not Found" then
        if criticalAsset then
            lplr:Kick("Failed to connect to github : vape/"..scripturl.." : "..res)
        end
        error(res)
    end
    if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
    return res
end
local function pload(fileName, criticalAsset)
    return loadstring(voidware.getFile(fileName, criticalAsset))()
end
shared.pload = pload
getgenv().pload = pload

return pload("MainScript.lua", true)
