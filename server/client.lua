ESX = nil
local HasPendingRequest = false
local isGangMenu = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('master_society:RequestOpenBossMenu', function()
	TriggerServerEvent("master_society:RequestOpenBossMenu", false)
end)

AddEventHandler('master_society:OpenGangMenu', function()
	TriggerServerEvent("master_society:RequestOpenBossMenu", true)
end)

RegisterNUICallback("NUIFocusOff", function()
	closeUI()
end)

function closeUI()
	SendNUIMessage({
		action = "hide"
	})
	
	SetNuiFocus(false, false)
end

function openUI(allPlayers, isGang)
	SetNuiFocus(true, true)
	isGangMenu = isGang
	
	SendNUIMessage({
		action = "display",
		type = "normal",
		players = allPlayers,
		isGang = isGang
	})
end

RegisterNetEvent('masterking32:closeAllUI')
AddEventHandler('masterking32:closeAllUI', function() 
	closeUI()
end)

RegisterNetEvent('master_society:OpenBossMenu')
AddEventHandler('master_society:OpenBossMenu', function(allPlayers, isGang)
	TriggerEvent("masterking32:closeAllUI")
	Citizen.Wait(100)
	openUI(allPlayers, isGang)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNUICallback("getPlayerInfo", function(data)
	TriggerServerEvent("master_society:RequestOpenUIPlayer", data.player, isGangMenu)
end)

RegisterNUICallback("saveChanges", function(data)
	TriggerServerEvent("master_society:RequestSaveChanges", data.player, data.grade, data.sub, isGangMenu)
end)

RegisterNUICallback("InviteToJob", function(data)
	TriggerServerEvent("master_society:InviteToJob", data.xTarget, isGangMenu)
end)

RegisterNetEvent('master_society:ShowUIPlayer')
AddEventHandler('master_society:ShowUIPlayer', function(playerData)
	SendNUIMessage({
		action = "showplayer",
		playerData = playerData
	})
end)

RegisterNetEvent('master_society:getInvite')
AddEventHandler('master_society:getInvite', function(JobName)
	HasPendingRequest = true
	exports.pNotify:SendNotification({text = "جهت قبول درخواست استخدام در '" .. JobName .. "'، H بزنید.", type = "success", timeout = 8000})
	
	Citizen.CreateThread(function()
		Citizen.Wait(10000)
		if HasPendingRequest then
			HasPendingRequest = false
		end
	end)
end)

RegisterNetEvent('master_keymap:h')
AddEventHandler('master_keymap:h', function()
	if HasPendingRequest then
		TriggerServerEvent('master_society:acceptRequest')
		HasPendingRequest = false
	end
end)
