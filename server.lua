ESX = exports['es_extended']:getSharedObject()

local activeDealers = {}

RegisterCommand('selldrug', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local hasDrugs, drugType, drugCount = CheckPlayerDrugs(xPlayer)
    
    if not hasDrugs then
        TriggerClientEvent('sk8_selldrugs:notify', source, Config.Notifications.noDrugs, 'error')
        return
    end
    
    if activeDealers[source] then
        TriggerClientEvent('sk8_selldrugs:notify', source, 'Již máš aktivní deal', 'error')
        return
    end
    
    activeDealers[source] = {
        drugType = drugType,
        drugCount = drugCount,
        startTime = GetGameTimer()
    }
    
    local streetCreditData = nil
    if Config.StreetCredit.enabled then
        local streetCredit = GetPlayerStreetCredit(source)
        local levelData = GetLevelData(streetCredit.level)
        local nextLevelData = GetLevelData(streetCredit.level + 1)
        
        streetCreditData = {
            level = streetCredit.level,
            levelName = levelData.name,
            currentXP = streetCredit.points,
            requiredXP = levelData.required,
            nextRequiredXP = nextLevelData and nextLevelData.required or streetCredit.points,
            multiplier = levelData.multiplier,
            duration = Config.StreetCredit.barSettings.duration
        }
    end
    
    TriggerClientEvent('sk8_selldrugs:startDeal', source, drugType, drugCount, streetCreditData)
end, false)

function CheckPlayerDrugs(xPlayer)
    local inventory = exports.ox_inventory:GetInventory(xPlayer.source, false)
    if not inventory or not inventory.items then return false end
    
    for slot, item in pairs(inventory.items) do
        if Config.DrugItems[item.name] and item.count > 0 then
            local maxSell = math.min(item.count, 10)
            local sellAmount = math.random(1, maxSell)
            return true, item.name, sellAmount
        end
    end
    
    return false
end

RegisterServerEvent('sk8_selldrugs:completeDeal')
AddEventHandler('sk8_selldrugs:completeDeal', function(drugType, amount, playerCoords)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not activeDealers[source] then return end
    
    local dealerData = activeDealers[source]
    if dealerData.drugType ~= drugType then return end
    
    local drugConfig = Config.DrugItems[drugType]
    if not drugConfig then return end
    
    if Config.DealFailure.enabled then
        local failChance = math.random(1, 100)
        if failChance <= Config.DealFailure.chance then
            activeDealers[source] = nil
            TriggerClientEvent('sk8_selldrugs:dealReported', source)
            
            local reportData = {
                coords = playerCoords,
                radius = Config.DealFailure.reportBlipSettings.radius,
                drugType = drugType,
                timestamp = os.time()
            }
            
            SendPoliceAlert(reportData)
            return
        end
    end
    
    local sellPrice = math.random(drugConfig.sellPrice.min, drugConfig.sellPrice.max)
    
    if Config.StreetCredit.enabled then
        local streetCreditData = GetPlayerStreetCredit(source)
        local multiplier = GetLevelMultiplier(streetCreditData.level)
        sellPrice = math.floor(sellPrice * multiplier)
    end
    
    local totalPrice = sellPrice * amount
    
    local hasItem = exports.ox_inventory:RemoveItem(source, drugType, amount)
    if hasItem then
        xPlayer.addMoney(totalPrice)
        
        if Config.StreetCredit.enabled then
            local points = Config.StreetCredit.pointsPerDeal[drugType] or 1
            local earnedPoints = points * amount
            UpdatePlayerStreetCredit(source, earnedPoints)
        end
        
        TriggerClientEvent('sk8_selldrugs:notify', source, string.format(Config.Notifications.dealComplete, totalPrice), 'success')
        activeDealers[source] = nil
    else
        TriggerClientEvent('sk8_selldrugs:notify', source, 'Nemáš dostatek drog', 'error')
    end
end)

RegisterServerEvent('sk8_selldrugs:cancelDeal')
AddEventHandler('sk8_selldrugs:cancelDeal', function()
    local source = source
    activeDealers[source] = nil
    TriggerClientEvent('sk8_selldrugs:notify', source, Config.Notifications.dealCancelled, 'info')
end)

function GetPlayerStreetCredit(source)
    local result = MySQL.Sync.fetchAll('SELECT * FROM sk8_street_credit WHERE identifier = ?', {
        ESX.GetPlayerFromId(source).identifier
    })
    
    if result[1] then
        return {
            points = result[1].points,
            level = result[1].level
        }
    else
        MySQL.insert('INSERT INTO sk8_street_credit (identifier, points, level) VALUES (?, ?, ?)', {
            ESX.GetPlayerFromId(source).identifier, 0, 1
        })
        return { points = 0, level = 1 }
    end
end

function UpdatePlayerStreetCredit(source, earnedPoints)
    local xPlayer = ESX.GetPlayerFromId(source)
    local streetCreditData = GetPlayerStreetCredit(source)
    
    local newPoints = streetCreditData.points + earnedPoints
    local newLevel = CalculateLevel(newPoints)
    local oldLevel = streetCreditData.level
    
    MySQL.update('UPDATE sk8_street_credit SET points = ?, level = ? WHERE identifier = ?', {
        newPoints, newLevel, xPlayer.identifier
    })
    
    local levelData = GetLevelData(newLevel)
    local nextLevelData = GetLevelData(newLevel + 1)
    
    local streetCreditUIData = {
        level = newLevel,
        levelName = levelData.name,
        currentXP = newPoints,
        requiredXP = levelData.required,
        nextRequiredXP = nextLevelData and nextLevelData.required or newPoints,
        multiplier = levelData.multiplier,
        duration = Config.StreetCredit.barSettings.duration
    }
    
    if newLevel > oldLevel then
        TriggerClientEvent('sk8_selldrugs:updateStreetCredit', source, streetCreditUIData, true)
        TriggerClientEvent('sk8_selldrugs:notify', source, string.format(Config.Notifications.levelUp, newLevel, levelData.name), 'success')
    else
        TriggerClientEvent('sk8_selldrugs:updateStreetCredit', source, streetCreditUIData, false)
    end
end

function CalculateLevel(points)
    for i = #Config.StreetCredit.levels, 1, -1 do
        if points >= Config.StreetCredit.levels[i].required then
            return Config.StreetCredit.levels[i].level
        end
    end
    return 1
end

function GetLevelData(level)
    for _, levelData in ipairs(Config.StreetCredit.levels) do
        if levelData.level == level then
            return levelData
        end
    end
    return Config.StreetCredit.levels[1]
end

function GetLevelMultiplier(level)
    local levelData = GetLevelData(level)
    return levelData.multiplier
end

function SendPoliceAlert(reportData)
    local xPlayers = ESX.GetExtendedPlayers()
    
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        if xPlayer and xPlayer.job then
            for j = 1, #Config.DealFailure.policeJobs do
                if xPlayer.job.name == Config.DealFailure.policeJobs[j] then
                    TriggerClientEvent('sk8_selldrugs:showPoliceAlert', xPlayer.source, reportData)
                    break
                end
            end
        end
    end
end

AddEventHandler('playerDropped', function()
    local source = source
    if activeDealers[source] then
        activeDealers[source] = nil
    end
end)