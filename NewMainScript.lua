if shared.RiseMode then
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/VapeVoidware/VWRise/main/NewMainScript.lua'))()
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

writefile('vape/profiles/gui.txt', 'new')

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'vape', 'vape/games', 'vape/profiles', 'vape/assets', 'vape/libraries', 'vape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end


if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/VapeVoidware/VoidwareBakup')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('vape/profiles/commit.txt') and readfile('vape/profiles/commit.txt') or '') ~= commit then end
	writefile('vape/profiles/commit.txt', commit)
end

shared.oldgetcustomasset = shared.oldgetcustomasset or getcustomasset
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    getgenv().getcustomasset = shared.oldgetcustomasset -- vape bad code moment
end)
local CheatEngineMode = false
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CheatEngineMode = true end
if getgenv and not getgenv().shared then CheatEngineMode = true; getgenv().shared = {}; end
if getgenv and not getgenv().debug then CheatEngineMode = true; getgenv().debug = {traceback = function(string) return string end} end
if getgenv and not getgenv().require then CheatEngineMode = true; end
if getgenv and getgenv().require and type(getgenv().require) ~= "function" then CheatEngineMode = true end
local debugChecks = {
    Type = "table",
    Functions = {
        "getupvalue",
        "getupvalues",
        "getconstants",
        "getproto"
    }
}
if identifyexecutor and type(identifyexecutor) == "function" and tostring(identifyexecutor()):lower() == "appleware" then CheatEngineMode = true end
local function checkDebug()
    if not getgenv().debug then 
        CheatEngineMode = true 
    else 
        if type(debug) ~= debugChecks.Type then 
            CheatEngineMode = true
        else 
            for i, v in pairs(debugChecks.Functions) do
                if not debug[v] or (debug[v] and type(debug[v]) ~= "function") then 
                    CheatEngineMode = true 
                else
                    local suc, res = pcall(debug[v]) 
                    if tostring(res) == "Not Implemented" then 
                        CheatEngineMode = true 
                    end
                end
            end
        end
    end
end
if (not CheatEngineMode) then checkDebug() end
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode
if (not isfolder('vape')) then makefolder('vape') end
if (not isfolder('rise')) then makefolder('rise') end
if (not isfolder('vape/Libraries')) then makefolder('vape/Libraries') end
if (not isfolder('rise/Libraries')) then makefolder('rise/Libraries') end
local baseDirectory = shared.RiseMode and "rise/" or "vape/"
local function install_profiles(num)
    if not num then return warn("No number specified!") end
    local httpservice = game:GetService('HttpService')
    local guiprofiles = {}
    local profilesfetched
    local repoOwner = shared.RiseMode and "VapeVoidware/RiseProfiles" or "Erchobg/VoidwareProfiles"
    local function vapeGithubRequest(scripturl)
        if not isfile(baseDirectory..scripturl) then
            local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/'..repoOwner..'/main/'..scripturl, true) end)
            if not isfolder(baseDirectory.."profiles") then
                makefolder(baseDirectory..'profiles')
            end
            if not isfolder(baseDirectory..'ClosetProfiles') then makefolder(baseDirectory..'ClosetProfiles') end
            writefile(baseDirectory..scripturl, res)
            task.wait()
        end
        return print(scripturl)
    end
    local Gui1 = {
        MainGui = ""
    }
    local gui = Instance.new("ScreenGui")
        gui.Name = "idk"
        gui.DisplayOrder = 999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.OnTopOfCoreBlur = true
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
        Gui1["MainGui"] = gui
    
    local function downloadVapeProfile(path)
        task.spawn(function()
            local textlabel = Instance.new('TextLabel')
            textlabel.Size = UDim2.new(1, 0, 0, 36)
            textlabel.Text = 'Downloading '..path
            textlabel.BackgroundTransparency = 1
            textlabel.TextStrokeTransparency = 0
            textlabel.TextSize = 30
            textlabel.Font = Enum.Font.SourceSans
            textlabel.TextColor3 = Color3.new(1, 1, 1)
            textlabel.Position = UDim2.new(0, 0, 0, -36)
            textlabel.Parent = Gui1.MainGui
            task.wait(0.1)
            textlabel:Destroy()
            vapeGithubRequest(path)
        end)
        return
    end
    task.spawn(function()
        local res1
        if num == 1 then
            res1 = "https://api.github.com/repos/"..repoOwner.."/contents/Profiles"
        end
        res = game:HttpGet(res1, true)
        if res ~= '404: Not Found' then 
            for i,v in next, game:GetService("HttpService"):JSONDecode(res) do 
                if type(v) == 'table' and v.name then 
                    table.insert(guiprofiles, v.name) 
                end
            end
        end
        profilesfetched = true
    end)
    repeat task.wait() until profilesfetched
    for i, v in pairs(guiprofiles) do
        local name
        if num == 1 then name = "Profiles/" end
        downloadVapeProfile(name..guiprofiles[i])
        task.wait()
    end
    if (not isfolder(baseDirectory..'Libraries')) then makefolder(baseDirectory..'Libraries') end
    if num == 1 then writefile(baseDirectory..'Libraries/profilesinstalled4.txt', "true") end 
end
local function are_installed_1()
    if not isfolder(baseDirectory..'profiles') then makefolder(baseDirectory..'profiles') end
    if isfile(baseDirectory..'Libraries/profilesinstalled4.txt') then return true else return false end
end
if not are_installed_1() then install_profiles(1) end
local function vapeGithubRequest(scripturl, isImportant)
    if isfile(baseDirectory..scripturl) then
        if not shared.VoidDev then
            pcall(function() delfile(baseDirectory..scripturl) end)
        else
            return readfile(baseDirectory..scripturl) 
        end
    end
    local suc, res
    local url = (scripturl == "MainScript.lua" or scripturl == "GuiLibrary.lua") and shared.RiseMode and "https://raw.githubusercontent.com/VapeVoidware/VWRise/" or "https://raw.githubusercontent.com/VapeVoidware/VoidwareBakup/"
    suc, res = pcall(function() return game:HttpGet(url.."main/"..scripturl, true) end)
    if not suc or res == "404: Not Found" then
        if isImportant then
            game:GetService("Players").LocalPlayer:Kick("Failed to connect to github : "..baseDirectory..scripturl.." : "..res)
        end
        warn(baseDirectory..scripturl, res)
    end
    if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
    return res
end
shared.VapeDeveloper = shared.VapeDeveloper or shared.VoidDev
local function pload(fileName, isImportant, required)
    fileName = tostring(fileName)
    if string.find(fileName, "CustomModules") and string.find(fileName, "Voidware") then
        fileName = string.gsub(fileName, "Voidware", "VW")
    end        
    if shared.VoidDev and shared.DebugMode then warn(fileName, isImportant, required, debug.traceback(fileName)) end
    local res = vapeGithubRequest(fileName, isImportant)
    local a = loadstring(res)
    local suc, err = true, ""
    if type(a) ~= "function" then suc = false; err = tostring(a) else if required then return a() else a() end end
    if (not suc) then 
        if isImportant then
            if (not string.find(string.lower(err), "vape already injected")) and (not string.find(string.lower(err), "rise already injected")) then
				warn("[".."Failure loading critical file! : "..baseDirectory..tostring(fileName).."]: "..tostring(debug.traceback(err)))
            end
        else
            task.spawn(function()
                repeat task.wait() until shared.vape
                if not string.find(res, "404: Not Found") then 
					shared.vape:CreateNotification('Failure loading: '..baseDirectory..tostring(fileName), tostring(debug.traceback(err)), 30, 'alert')
                end
            end)
        end
    end
end
shared.pload = pload
getgenv().pload = pload

return pload('main.lua', true)