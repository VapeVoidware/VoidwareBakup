local pload = shared.pload or function(file, isImportant) local suc, err = pcall(function() loadstring(readfile('vape/'..tostring(file))) end) if not suc and err then local text = "[Voidware Error] Error loading critical file! FileName: "..tostring(file).." Error: "..tostring(err) warn(text) if isImportant then game:GetService("Players").LocalPlayer:Kick(text) end end end
shared.CustomSaveVape = 6839171747
pload("CustomModules/6839171747.lua")

-- nigger
