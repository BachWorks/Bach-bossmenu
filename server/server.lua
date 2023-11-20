local QBCore = exports["qb-core"]:GetCoreObject()
local Accounts = {}

RegisterNetEvent("bach-bossmenu:loadStash")
AddEventHandler("bach-bossmenu:loadStash", function(job)
	local source = source
	local Player = QBCore.Functions.GetPlayer(source)
	local name = "bach-bossmenu" .. job
	exports.ox_inventory:RegisterStash(name, "Lager", 200, 500000)
	Wait(100)
	TriggerClientEvent("bach-bossmenu:openStash", source, name)
end)

function GetAccount(account)
    return Accounts[account] or 0
end

function AddMoney(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end

    Accounts[account] = Accounts[account] + amount
    MySQL.insert(
        "INSERT INTO management_funds (job_name, amount, type) VALUES (:job_name, :amount, :type) ON DUPLICATE KEY UPDATE amount = :amount",
        {
            ["job_name"] = account,
            ["amount"] = Accounts[account],
            ["type"] = "boss",
        }
    )
end

function RemoveMoney(account, amount)
    local isRemoved = false
    if amount > 0 then
        if not Accounts[account] then
            Accounts[account] = 0
        end

        if Accounts[account] >= amount then
            Accounts[account] = Accounts[account] - amount
            isRemoved = true
        end

        MySQL.update(
            'UPDATE management_funds SET amount = ? WHERE job_name = ? and type = "boss"',
            { Accounts[account], account }
        )
    end
    return isRemoved
end

MySQL.ready(function()
    local bossmenu = MySQL.query.await('SELECT job_name,amount FROM management_funds WHERE type = "boss"', {})
    if not bossmenu then
        return
    end

    for _, v in ipairs(bossmenu) do
        Accounts[v.job_name] = v.amount
    end
end)

RegisterNetEvent("bach-bossmenu:server:withdrawMoney", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local job = Player.PlayerData.job.name
    if RemoveMoney(job, amount) then
        Player.Functions.AddMoney("cash", amount, Lang:t('success.withdrawn_money') .. amount .. " $")
        TriggerEvent(
            "qb-log:server:CreateLog",
            "bossmenu",
            "Withdraw Money",
            "blue",
            Player.PlayerData.name .. " withdrew " .. amount .. " $ (" .. job .. ")",
            false
        )
        TriggerClientEvent("QBCore:Notify", src, Lang:t("success.withdrawn_money") .. amount .. " $", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, Lang:t("error.not_enough_money"), "error")
    end
end)

RegisterNetEvent("bach-bossmenu:server:depositMoney", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney("cash", amount) then
        local job = Player.PlayerData.job.name
        AddMoney(job, amount)
        TriggerEvent(
            "qb-log:server:CreateLog",
            "bossmenu",
            "Deposit Money",
            "blue",
            Player.PlayerData.name .. " deposited " .. amount .. " $ (" .. job .. ")",
            false
        )
        TriggerClientEvent("QBCore:Notify", src, Lang:t("success.deposited_money") .. amount .. " $", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, Lang:t("error.not_enough_money"), "error")
    end
end)

QBCore.Functions.CreateCallback("bach-bossmenu:server:GetAccount", function(_, cb, jobname)
    local result = GetAccount(jobname)
    cb(result)
end)

QBCore.Functions.CreateCallback("bach-bossmenu:server:GetEmployees", function(source, cb, jobname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local employees = {}
    local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%" .. jobname .. "%'", {})
    if players[1] ~= nil then
        for _, value in pairs(players) do
            local isOnline = QBCore.Functions.GetPlayerByCitizenId(value.citizenid)
            if isOnline then
                employees[#employees + 1] = {
                    empSource = isOnline.PlayerData.citizenid,
                    grade = isOnline.PlayerData.job.grade,
                    gradeLevel = isOnline.PlayerData.job.grade.level,
                    gradeLabel = isOnline.PlayerData.job.grade.name,
                    isboss = isOnline.PlayerData.job.isboss,
                    name = isOnline.PlayerData.charinfo.firstname .. " " .. isOnline.PlayerData.charinfo.lastname,
                    online = "🟢",
                    jobname = jobname,
                }
            else
                employees[#employees + 1] = {
                    empSource = value.citizenid,
                    grade = json.decode(value.job).grade,
                    gradeLabel = json.decode(value.job).grade.name,
                    gradeLevel = json.decode(value.job).grade.level,
                    isboss = json.decode(value.job).isboss,
                    name = json.decode(value.charinfo).firstname .. " " .. json.decode(value.charinfo).lastname,
                    online = "❌",
                    jobname = jobname,
                }
            end
        end
        table.sort(employees, function(a, b)
            return a.grade.level > b.grade.level
        end)
    end
    cb(employees)
end)

QBCore.Functions.CreateCallback("bach-bossmenu:server:GetEmployeesNumber", function(source, cb, jobname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local playerCount = 0

    local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%" .. jobname .. "%'", {})
    if players[1] ~= nil then
        for _, value in pairs(players) do
            if json.decode(value.job).name == jobname then
                playerCount = playerCount + 1
            end
        end
    end
    cb(playerCount)
end)

RegisterNetEvent("bach-bossmenu:server:GradeUpdate", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data.cid)
    if data.grade > Player.PlayerData.job.grade.level then
        TriggerClientEvent("QBCore:Notify", src, "You cannot promote to this rank!", "error")
        return
    end

    if Employee then
        if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grade) then
            TriggerClientEvent("QBCore:Notify", src, "Successfully promoted!", "success")
            TriggerClientEvent(
                "QBCore:Notify",
                Employee.PlayerData.source,
                "You have been promoted to " .. data.gradename .. ".",
                "success"
            )
        else
            TriggerClientEvent("QBCore:Notify", src, "Promotion grade not found.", "error")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "Person is not in the city.", "error")
    end
end)

RegisterNetEvent("bach-bossmenu:server:GradeUpdate", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(data.cid)

    if data.grade > Player.PlayerData.job.grade.level then
        TriggerClientEvent("QBCore:Notify", src, Lang:t("error.promotion_not_allowed"), "error")
        return
    end

    if Employee then
        if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grade) then
            TriggerClientEvent("QBCore:Notify", src, Lang:t("success.promoted_employee"), "success")
            TriggerClientEvent(
                "QBCore:Notify",
                Employee.PlayerData.source,
                "You have been promoted to " .. data.gradename .. ".",
                "success"
            )
        else
            TriggerClientEvent("QBCore:Notify", src, Lang:t("error.grade_not_found"), "error")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, Lang:t("error.employee_not_in_city"), "error")
    end
end)

RegisterNetEvent("bach-bossmenu:server:FireEmployee", function(target)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Employee = QBCore.Functions.GetPlayerByCitizenId(target)

    if Employee then
        if target ~= Player.PlayerData.citizenid then
            if Employee.PlayerData.job.grade.level > Player.PlayerData.job.grade.level then
                TriggerClientEvent("QBCore:Notify", src, Lang:t("error.cannot_fire_yourself"), "error")
                return
            end
            if Employee.Functions.SetJob("unemployed", "0") then
                TriggerEvent(
                    "qb-log:server:CreateLog",
                    "bossmenu",
                    "Job Fire",
                    "red",
                    Player.PlayerData.charinfo.firstname
                        .. " "
                        .. Player.PlayerData.charinfo.lastname
                        .. " successfully fired "
                        .. Employee.PlayerData.charinfo.firstname
                        .. " "
                        .. Employee.PlayerData.charinfo.lastname
                        .. " ("
                        .. Player.PlayerData.job.name
                        .. ")",
                    false
                )
                TriggerClientEvent("QBCore:Notify", src, Lang:t("success.employee_fired"), "success")
                TriggerClientEvent(
                    "QBCore:Notify",
                    Employee.PlayerData.source,
                    "You have been fired! Good luck.",
                    "error"
                )
            else
                TriggerClientEvent("QBCore:Notify", src, "Error..", "error")
            end
        else
            TriggerClientEvent("QBCore:Notify", src, Lang:t("error.cannot_fire_yourself"), "error")
        end
    else
        local player = MySQL.query.await("SELECT * FROM players WHERE citizenid = ? LIMIT 1", { target })
        if player[1] ~= nil then
            Employee = player[1]
            Employee.job = json.decode(Employee.job)
            if Employee.job.grade.level > Player.PlayerData.job.grade.level then
                TriggerClientEvent("QBCore:Notify", src, Lang:t("error.cannot_fire_yourself"), "error")
                return
            end
            local job = {}
            job.name = "unemployed"
            job.label = "Unemployed"
            job.payment = QBCore.Shared.Jobs[job.name].grades["0"].payment or 500
            job.onduty = true
            job.isboss = false
            job.grade = {}
            job.grade.name = nil
            job.grade.level = 0
            MySQL.update("UPDATE players SET job = ? WHERE citizenid = ?", { json.encode(job), target })
            TriggerClientEvent("QBCore:Notify", src, Lang:t("success.employee_fired"), "success")
            TriggerEvent(
                "qb-log:server:CreateLog",
                "bossmenu",
                "Job Fire",
                "red",
                Player.PlayerData.charinfo.firstname
                    .. " "
                    .. Player.PlayerData.charinfo.lastname
                    .. " successfully fired "
                    .. Employee.PlayerData.charinfo.firstname
                    .. " "
                    .. Employee.PlayerData.charinfo.lastname
                    .. " ("
                    .. Player.PlayerData.job.name
                    .. ")",
                false
            )
        else
            TriggerClientEvent("QBCore:Notify", src, "Civilian is not in the city.", "error")
        end
    end
end)


QBCore.Functions.CreateCallback("bach-bossmenu:getplayers", function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = QBCore.Functions.GetPlayer(v)
			players[#players + 1] = {
				id = v,
				coords = GetEntityCoords(targetped),
				name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
				citizenid = ped.PlayerData.citizenid,
				sources = GetPlayerPed(ped.PlayerData.source),
				sourceplayer = ped.PlayerData.source,
			}
		end
	end
	table.sort(players, function(a, b)
		return a.name < b.name
	end)
	cb(players)
end)

-- Save Jobs On Updating. Made it like this for less perfomance drops
RegisterNetEvent("Bach-bossmenu:saveJob-Gang", function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if not Player then
		return
	end
	Player.Functions.Save()
end)