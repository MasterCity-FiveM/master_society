ESX = nil
local Jobs = {}
local RegisteredSocieties = {}
local jobInvites = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
		Jobs[result[i].name] = result[i]
		Jobs[result[i].name].grades = {}
		Jobs[result[i].name].subs = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2, 1 do
		Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
	end
	
	local result3 = MySQL.Sync.fetchAll('SELECT * FROM job_subs', {})

	for i=1, #result3, 1 do
		Jobs[result3[i].job].subs[tostring(result3[i].job_sub)] = result3[i]
	end
end)

RegisterNetEvent('master_society:RequestOpenBossMenu')
AddEventHandler('master_society:RequestOpenBossMenu', function(isGang)
	ESX.RunCustomFunction("anti_ddos", source, 'master_society:RequestOpenBossMenu', {})
	_source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer and not isGang and xPlayer.job and xPlayer.job.name and xPlayer.job.grade_name == 'boss' then
		MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, job_grade FROM users WHERE job = @job ORDER BY job_grade DESC', {
			['@job'] = xPlayer.job.name
		}, function (results)
			local employees = {}
			
			for i=1, #results, 1 do
				table.insert(employees, {
					name       = results[i].firstname .. ' ' .. results[i].lastname,
					identifier = results[i].identifier,
					grade_label = results[i].job_grade .. ' - ' .. Jobs[xPlayer.job.name].grades[tostring(results[i].job_grade)].label_fa
				})
			end
			
			TriggerClientEvent('master_society:OpenBossMenu', xPlayer.source, employees, isGang)
		end)
	elseif xPlayer and isGang then
		ESX.TriggerServerCallback("master_gang:GetGang", xPlayer.source, function(data)
			if data ~= false and data.gang ~= nil and data.grade == 6 then
				MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, gang_grade FROM users WHERE gang = @gang ORDER BY gang_grade DESC', {
					['@gang'] = data.gang
				}, function (results)
					local employees = {}
					
					for i=1, #results, 1 do
						table.insert(employees, {
							name       = results[i].firstname .. ' ' .. results[i].lastname,
							identifier = results[i].identifier,
							grade_label = results[i].gang_grade .. ' - ' .. Config.gang_grades[results[i].gang_grade].label_fa
						})
					end
					
					TriggerClientEvent('master_society:OpenBossMenu', xPlayer.source, employees, isGang)
				end)
			end
		end, xPlayer.source)
	end
end)

RegisterNetEvent('master_society:RequestOpenUIPlayer')
AddEventHandler('master_society:RequestOpenUIPlayer', function(TargetIdentifier, isGang)
	ESX.RunCustomFunction("anti_ddos", source, 'master_society:RequestOpenUIPlayer', {})
	if TargetIdentifier == nil then
		return
	end
	
	_source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer and not isGang and xPlayer.job ~= nil and xPlayer.job.name and xPlayer.job.grade_name == 'boss'  then
		MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, job, job_sub, job_grade FROM users WHERE identifier = @identifier AND job = @job', {
            ['@identifier'] = TargetIdentifier,
            ['@job'] = xPlayer.job.name,
        }, function(results)
            if #results ~= 0 and xPlayer.job.name == results[1].job then
				PlayerData = results[1]
				PlayerData.JobGrades = {}
				PlayerData.JobSubs = {}
				PlayerData.JobGrades = Jobs[xPlayer.job.name].grades
				PlayerData.JobSubs = Jobs[xPlayer.job.name].subs
				TriggerClientEvent("master_society:ShowUIPlayer", xPlayer.source, PlayerData)
			else
				TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'بازیکن مورد نظر یافت نشد.', type = "error", timeout = 5000, layout = "bottom"})
            end
        end)
	elseif xPlayer and isGang then
		ESX.TriggerServerCallback("master_gang:GetGang", xPlayer.source, function(data)
			if data ~= false and data.gang ~= nil and data.grade == 6 then
				MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, gang, gang_grade FROM users WHERE identifier = @identifier AND gang = @gang', {
					['@identifier'] = TargetIdentifier,
					['@gang'] = data.gang,
				}, function(results)
					if #results ~= 0 and data.gang == results[1].gang then
						PlayerData = results[1]
						PlayerData.job = PlayerData.gang
						PlayerData.job_grade = PlayerData.gang_grade
						PlayerData.JobGrades = {}
						PlayerData.JobSubs = {}
						PlayerData.JobGrades = Config.gang_grades
						TriggerClientEvent("master_society:ShowUIPlayer", xPlayer.source, PlayerData)
					else
						TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'بازیکن مورد نظر یافت نشد.', type = "error", timeout = 5000, layout = "bottom"})
					end
				end)
			end
		end, xPlayer.source)
	end
end)

RegisterNetEvent('master_society:RequestSaveChanges')
AddEventHandler('master_society:RequestSaveChanges', function(TargetIdentifier, Grade, Sub, isGang)
	ESX.RunCustomFunction("anti_ddos", source, 'master_society:RequestSaveChanges', {})
	if TargetIdentifier == nil then
		return
	end
	
	_source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer and not isGang and xPlayer.job ~= nil and xPlayer.job.name and xPlayer.job.grade_name == 'boss'  then
		MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, job, job_sub, job_grade FROM users WHERE identifier = @identifier', {
            ['@identifier'] = TargetIdentifier,
        }, function(results)
            if #results ~= 0 and xPlayer.job.name == results[1].job then
				local xTarget = ESX.GetPlayerFromIdentifier(TargetIdentifier)
				
				job = xPlayer.job.name
				
				if xPlayer.identifier == TargetIdentifier then
					Grade = xPlayer.job.grade
				end
				
				if Sub == '-' then
					Sub = ''
				end
				
				if Grade == '-' then
					Grade = 0
					job = 'unemployed'
					Sub = ''
				end				
				
				if xTarget then
					if xTarget.source ~= xPlayer.source then
						xTarget.setJob(job, Grade)
					end
					
					xTarget.setJobSub(Sub)
					--ESX.SavePlayer(xTarget, function(rowsChanged) end)
				else
					MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade, job_sub = @job_sub WHERE identifier = @identifier', {
						['@identifier'] = TargetIdentifier,
						['@job'] = job,
						['@job_grade'] = Grade,
						['@job_sub'] = Sub,
					})
				end
				
				TriggerClientEvent("masterking32:closeAllUI", xPlayer.source)
			else
				TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'بازیکن مورد نظر یافت نشد.', type = "error", timeout = 5000, layout = "bottom"})
            end
        end)
	elseif xPlayer and xPlayer.identifier == TargetIdentifier then
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'حالت خوبه؟ خوبی خوشی؟', type = "error", timeout = 5000, layout = "bottom"})
	elseif xPlayer and isGang then
		ESX.TriggerServerCallback("master_gang:GetGang", xPlayer.source, function(data)
			if data ~= false and data.gang ~= nil and data.grade == 6 then
				local xTarget = ESX.GetPlayerFromIdentifier(TargetIdentifier)
				
				job = data.gang
				if Grade == '-' then
					Grade = 0
					job = ''
				end	
				
				if xTarget then
					ESX.TriggerServerCallback("master_gang:GetGang", xTarget.source, function(data2)
						if data2 ~= false and data2.gang == data.gang then
							
							TriggerEvent("master_gang:set_gang", xTarget.source, job, Grade)
						end
					end, xTarget.source)
				else
					MySQL.Async.execute('UPDATE users SET gang = @gang, gang_grade = @gang_grade WHERE identifier = @identifier AND gang = @gang2', {
						['@identifier'] = TargetIdentifier,
						['@gang'] = job,
						['@gang2'] = data.gang,
						['@gang_grade'] = Grade,
					})
				end
				
				TriggerClientEvent("masterking32:closeAllUI", xPlayer.source)
			end
		end, xPlayer.source)
	end
end)

RegisterNetEvent('master_society:InviteToJob')
AddEventHandler('master_society:InviteToJob', function(xTarget, isGang)
	ESX.RunCustomFunction("anti_ddos", source, 'master_society:InviteToJob', {})
	if xTarget == nil then
		return
	end
	
	_source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xTarget = ESX.GetPlayerFromId(xTarget)
	if xTarget == _source then
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'خودتو میخوای دعوت کنی؟ گرفتی مارو؟', type = "error", timeout = 5000, layout = "bottom"})
	elseif xPlayer and xTarget and not isGang and xPlayer.job.name ~= xTarget.job.name and xPlayer.job ~= nil and xPlayer.job.name and xPlayer.job.grade_name == 'boss' then
		jobInvites[xTarget.source] = {}
		jobInvites[xTarget.source].Boss = xPlayer.source
		jobInvites[xTarget.source].job = xPlayer.job.name
		jobInvites[xTarget.source].isGang = false
		
		TriggerClientEvent("master_society:getInvite", xTarget.source, xPlayer.job.label_fa)
		TriggerClientEvent("masterking32:closeAllUI", xPlayer.source)
		
		Citizen.CreateThread(function()
			Citizen.Wait(200)
			TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'درخواست شما به ' .. xTarget.firstname .. ' ' .. xTarget.lastname .. ' ارسال شد.', type = "success", timeout = 5000, layout = "bottom"})
			Citizen.Wait(15000)
			if jobInvites[xTarget.source] ~= nil then
				jobInvites[xTarget.source] = nil
			end
		end)
	elseif xPlayer and isGang and xTarget then
		ESX.TriggerServerCallback("master_gang:GetGang", xPlayer.source, function(data)
			if data ~= false and data.gang ~= nil and data.grade == 6 then
				jobInvites[xTarget.source] = {}
				jobInvites[xTarget.source].Boss = xPlayer.source
				jobInvites[xTarget.source].job = data.gang
				jobInvites[xTarget.source].isGang = true
				
				TriggerClientEvent("master_society:getInvite", xTarget.source, data.gang)
				TriggerClientEvent("masterking32:closeAllUI", xPlayer.source)
				
				Citizen.CreateThread(function()
					Citizen.Wait(200)
					TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'درخواست شما به ' .. xTarget.firstname .. ' ' .. xTarget.lastname .. ' ارسال شد.', type = "success", timeout = 5000, layout = "bottom"})
					Citizen.Wait(15000)
					if jobInvites[xTarget.source] ~= nil then
						jobInvites[xTarget.source] = nil
					end
				end)
			end
		end, xPlayer.source)
	else
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'بازیکن مورد نظر یافت نشد.', type = "error", timeout = 5000, layout = "bottom"})
	end
end)

RegisterNetEvent('master_society:acceptRequest')
AddEventHandler('master_society:acceptRequest', function()
	ESX.RunCustomFunction("anti_ddos", source, 'master_society:acceptRequest', {})
	_source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer and jobInvites[xPlayer.source] ~= nil and not jobInvites[xPlayer.source].isGang then
		xPlayer.setJob(jobInvites[xPlayer.source].job, 0)
		xPlayer.setJobSub('')
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'شما درخواست را قبول کردید.', type = "success", timeout = 5000, layout = "bottom"})
		TriggerClientEvent("pNotify:SendNotification", jobInvites[xPlayer.source].Boss, { text = xPlayer.firstname .. ' ' .. xPlayer.lastname .. '، درخواست شما را قبول کرد.', type = "success", timeout = 5000, layout = "bottom"})
		
		jobInvites[xPlayer.source] = nil
		--ESX.SavePlayer(xPlayer, function(rowsChanged) end)
	elseif xPlayer and jobInvites[xPlayer.source] ~= nil and jobInvites[xPlayer.source].isGang then
		TriggerEvent("master_gang:set_gang", xPlayer.source, jobInvites[xPlayer.source].job, 1)
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = 'شما درخواست را قبول کردید.', type = "success", timeout = 5000, layout = "bottom"})
		TriggerClientEvent("pNotify:SendNotification", jobInvites[xPlayer.source].Boss, { text = xPlayer.firstname .. ' ' .. xPlayer.lastname .. '، درخواست شما را قبول کرد.', type = "success", timeout = 5000, layout = "bottom"})
		
		jobInvites[xPlayer.source] = nil
		--ESX.SavePlayer(xPlayer, function(rowsChanged) end)
	end
end)

---------------------------------------------------------------------------

AddEventHandler('master_society:registerSociety', function(name, label, account, datastore, inventory, data)
	local found = false

	local society = {
		name = name,
		label = label,
		account = account,
		datastore = datastore,
		inventory = inventory,
		data = data
	}

	for i=1, #RegisteredSocieties, 1 do
		if RegisteredSocieties[i].name == name then
			found, RegisteredSocieties[i] = true, society
			break
		end
	end

	if not found then
		table.insert(RegisteredSocieties, society)
	end
end)

AddEventHandler('esx_society:registerSociety', function(name, label, account, datastore, inventory, data)
	local found = false

	local society = {
		name = name,
		label = label,
		account = account,
		datastore = datastore,
		inventory = inventory,
		data = data
	}

	for i=1, #RegisteredSocieties, 1 do
		if RegisteredSocieties[i].name == name then
			found, RegisteredSocieties[i] = true, society
			break
		end
	end

	if not found then
		table.insert(RegisteredSocieties, society)
	end
end)
