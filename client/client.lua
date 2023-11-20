local QBCore = exports["qb-core"]:GetCoreObject()
local PlayerJob = QBCore.Functions.GetPlayerData().job

local function comma_value(amount)
	local formatted = amount
	while true do
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if (k == 0) then
			break
		end
	end
	return formatted
end

AddEventHandler("onResourceStart", function(resource)
	if resource == GetCurrentResourceName() then
		PlayerJob = QBCore.Functions.GetPlayerData().job
	end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
	PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function()
	TriggerServerEvent("Bach-bossmenu:saveJob-Gang")
end)

RegisterNUICallback("bach-bossmenu:getJob", function(_, cb)
	PlayerJob = QBCore.Functions.GetPlayerData().job
	cb(PlayerJob.label)
end)

RegisterNUICallback("bach-bossmenu:getBOSS", function(_, cb)
	PlayerJob = QBCore.Functions.GetPlayerData().job
	cb(PlayerJob.isboss)
end)

RegisterNUICallback("bach-bossmenu:getRanks", function(_, cb)
	PlayerJob = QBCore.Functions.GetPlayerData().job
	local ranks = {}
	for k, v in pairs(QBCore.Shared.Jobs[PlayerJob.name].grades) do
		table.insert(ranks, {
			navn = v.name,
			id = tonumber(k),
		})
	end
	cb(ranks)
end)

RegisterNUICallback("bach-bossmenu:updateGrade", function(data, cb)
	PlayerJob = QBCore.Functions.GetPlayerData().job
	if not PlayerJob.isboss then
		return
	end
	-- print(data.gradename)
	local cid = data.cid
	local grade = data.grade
	local gradename = data.gradename
	print(cid)
	TriggerServerEvent("bach-bossmenu:server:GradeUpdate", data)
	-- UI
	SendNUIMessage({
		action = "setVisible",
		data = false,
	})
	Wait(20)
	SendNUIMessage({
		action = "setVisible",
		data = true,
	})
	cb("updated")
end)

RegisterNUICallback("bach-bossmenu:fireEmployee", function(data, cb)
	TriggerServerEvent("bach-bossmenu:server:FireEmployee", data.source)

	SendNUIMessage({
		action = "setVisible",
		data = false,
	})
	Wait(1)
	SendNUIMessage({
		action = "setVisible",
		data = true,
	})
	cb("fired")
end)

RegisterNUICallback("bach-bossmenu:getNearbyPlayers", function(_, cb)
	QBCore.Functions.TriggerCallback("bach-bossmenu:getplayers", function(players)
		local nearbyPlayers = {}

		for _, v in pairs(players) do
			if v and v ~= PlayerId() then
				table.insert(nearbyPlayers, v)
			end
		end

		if #nearbyPlayers > 0 then
			for _, player in ipairs(nearbyPlayers) do
				Wait(100)
			end
		else
			lib.notify({
				title = "Boss Menu",
				description = "No-one is nearby",
				type = "error",
				icon = "fa-solid fa-exclamation",
			})
		end

		cb(players)
	end)
end)

RegisterNUICallback("bach-bossmenu:hireEmployee", function(data, cb)
	TriggerServerEvent("bach-bossmenu:server:HireEmployee", data.source)
	SendNUIMessage({
		action = "setVisible",
		data = false,
	})
	Wait(1)
	SendNUIMessage({
		action = "setVisible",
		data = true,
	})
	cb("fired")
end)

RegisterNUICallback("bach-bossmenu:getEmployees", function(_, cb)
	QBCore.Functions.TriggerCallback("bach-bossmenu:server:GetEmployees", function(em)
		for _, v in pairs(em) do
			cb(em)
		end
	end, PlayerJob.name)
end)

RegisterNUICallback("bach-bossmenu:getEmployeesAmount", function(_, cb)
	QBCore.Functions.TriggerCallback("bach-bossmenu:server:GetEmployeesNumber", function(amount)
		cb(amount)
	end, PlayerJob.name)
end)

-- money stuff
RegisterNUICallback("bach-bossmenu:getAccount", function(_, cb)
	QBCore.Functions.TriggerCallback("bach-bossmenu:server:GetAccount", function(moneyShi)
		cb(comma_value(moneyShi))
	end, PlayerJob.name)
end)

RegisterNUICallback("bach-bossmenu:moneyDep", function(data, cb)
	if data.choosen == "heav" then
		TriggerServerEvent("bach-bossmenu:server:withdrawMoney", tonumber(data.amount))
	elseif data.choosen == "indseat" then
		TriggerServerEvent("bach-bossmenu:server:depositMoney", tonumber(data.amount))
	end
	SendNUIMessage({
		action = "setVisible",
		data = false,
	})
	Wait(1)
	SendNUIMessage({
		action = "setVisible",
		data = true,
	})
	cb("depote")
end)

RegisterNUICallback("bach-bossmenu:personalHandle", function(data, cb)
	if data.choosen == "stash" then
		if Config.Inventory == "qb" then
			TriggerServerEvent("inventory:server:OpenInventory", "stash", "bach-bossmenu" .. PlayerJob.name)
			TriggerEvent("inventory:client:SetCurrentStash", "bach-bossmenu" .. PlayerJob.name)
			TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.4)
		elseif Config.Inventory == "ox" then
			TriggerServerEvent("bach-bossmenu:loadStash", PlayerJob.name)
			TriggerServerEvent("InteractSound_SV:PlayOnSource", "StashOpen", 0.4)
		end
	elseif data.choosen == "outfits" then
		TriggerEvent("qb-clothing:client:openOutfitMenu") -- Kan laves om til hvad du bruger
	end
	SetNuiFocus(false, false)
	SendNUIMessage({
		action = "setVisible",
		data = false,
	})
	cb("done")
end)

RegisterNetEvent("bach-bossmenu:openStash")
AddEventHandler("bach-bossmenu:openStash", function(id)
	TriggerEvent("ox_inventory:openInventory", "stash", id)
end)

RegisterCommand("bossmenu", function()
	SendNUIMessage({
		action = "setVisible",
		data = true,
	})
	SetNuiFocus(true, true)
end)

RegisterNUICallback("hideUI", function(_, cb)
	cb({})
	SetNuiFocus(false, false)
end)
