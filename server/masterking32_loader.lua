local Client_Source = LoadResourceFile(GetCurrentResourceName(), "server/client.lua")
local load_for_players = {}
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

encoded = enc(Client_Source)

local function splitByChunk(text, chunkSize)
    local s = {}
    for i=1, #text, chunkSize do
        s[#s+1] = enc(text:sub(i,i+chunkSize - 1))
    end
    return s
end

local st = splitByChunk(encoded, 2000)

total_parts = #st
RegisterServerEvent(GetCurrentResourceName() .. ':masterking32_sl')
AddEventHandler(GetCurrentResourceName() .. ':masterking32_sl', function()
	local _source = source
	if load_for_players[_source] ~= nil then
		TriggerEvent('master_warden:DropMeServer', _source, 'A bit Smart Dumper!')
		return
	end
	
	load_for_players[_source] = true
	
	Citizen.CreateThread(function()
		for i,v in ipairs(st) do
			Citizen.CreateThread(function()
				Citizen.Wait(math.random(0,10))
				TriggerClientEvent(GetCurrentResourceName() .. ':masterking32_cl', _source, i, v, total_parts)
			end)
		end
	end)
end)