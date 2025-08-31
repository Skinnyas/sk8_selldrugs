ESX = exports['es_extended']:getSharedObject()

local currentDeal = {
    active = false,
    drugType = nil,
    drugCount = 0,
    clientPed = nil,
    clientBlip = nil,
    dealStarted = false,
    targetAdded = false
}

RegisterNetEvent('sk8_selldrugs:startDeal')
AddEventHandler('sk8_selldrugs:startDeal', function(drugType, drugCount, streetCreditData)
    if currentDeal.active then return end
    
    currentDeal.active = true
    currentDeal.drugType = drugType
    currentDeal.drugCount = drugCount
    
    if Config.StreetCredit.enabled and streetCreditData then
        SendNUIMessage({
            action = 'showStreetCredit',
            streetCreditData = streetCreditData
        })
    end
    
    StartPhoneAnimation()
end)

function StartPhoneAnimation()
    local playerPed = PlayerPedId()
    
    if lib.progressBar({
        duration = 8000,
        label = Config.Notifications.dealStarted,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = Config.Animations.phone.dict,
            clip = Config.Animations.phone.anim,
            flag = Config.Animations.phone.flag
        }
    }) then
        ClearPedTasks(playerPed)
        lib.notify({
            title = 'Drug Deal',
            description = Config.Notifications.clientComing,
            type = 'inform',
            duration = 5000
        })
        
        CreateTimer(function()
            SpawnClient()
        end, math.random(5000, 10000))
    else
        CancelDeal()
    end
end

function SpawnClient()
    if not currentDeal.active then return end
    
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    
    local spawnPos = GetRandomSpawnPosition(playerPos)
    local drugConfig = Config.DrugItems[currentDeal.drugType]
    local randomModel = drugConfig.clientModels[math.random(#drugConfig.clientModels)]
    
    lib.requestModel(randomModel, 10000)
    
    currentDeal.clientPed = CreatePed(4, randomModel, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
    SetEntityAsMissionEntity(currentDeal.clientPed, true, true)
    SetPedFleeAttributes(currentDeal.clientPed, 0, 0)
    SetPedDiesWhenInjured(currentDeal.clientPed, false)
    SetPedCanPlayGestureAnims(currentDeal.clientPed, true)
    SetPedCanRagdollFromPlayerImpact(currentDeal.clientPed, false)
    SetEntityInvincible(currentDeal.clientPed, true)
    
    SetPedConfigFlag(currentDeal.clientPed, 208, true)
    SetPedConfigFlag(currentDeal.clientPed, 229, true)
    SetPedConfigFlag(currentDeal.clientPed, 281, true)
    SetBlockingOfNonTemporaryEvents(currentDeal.clientPed, true)
    SetPedPathCanUseLadders(currentDeal.clientPed, true)
    SetPedPathCanDropFromHeight(currentDeal.clientPed, true)
    SetPedPathPreferToAvoidWater(currentDeal.clientPed, true)
    
    SetupNPCNavigation(currentDeal.clientPed, playerPos)
    
    currentDeal.clientBlip = AddBlipForEntity(currentDeal.clientPed)
    SetBlipSprite(currentDeal.clientBlip, 480)
    SetBlipDisplay(currentDeal.clientBlip, 4)
    SetBlipScale(currentDeal.clientBlip, 0.8)
    SetBlipColour(currentDeal.clientBlip, 1)
    SetBlipAsShortRange(currentDeal.clientBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Klient")
    EndTextCommandSetBlipName(currentDeal.clientBlip)
    
    MonitorClientArrival(playerPos)
end

function GetRandomSpawnPosition(playerPos)
    local bestPos = nil
    local bestScore = -1
    local attempts = 0
    
    while attempts < Config.ClientSettings.spawnAttempts do
        attempts = attempts + 1
        
        local roadPos = GetNearbyRoadPosition(playerPos, attempts)
        if roadPos then
            if IsSpawnPositionSafe(roadPos, playerPos) then
                local score = CalculateSpawnScore(roadPos, playerPos)
                if score > bestScore then
                    bestScore = score
                    bestPos = roadPos
                end
            end
        end
    end
    
    return bestPos or GetFallbackSpawnPosition(playerPos)
end

function GetNearbyRoadPosition(playerPos, attempt)
    local angle = (math.random() * 2 * math.pi) + (attempt * 0.5)
    local distance = math.random(Config.ClientSettings.spawnDistance.min, Config.ClientSettings.spawnDistance.max)
    
    local searchX = playerPos.x + math.cos(angle) * distance
    local searchY = playerPos.y + math.sin(angle) * distance
    local searchZ = playerPos.z
    
    local roadFound, roadPos, heading = GetClosestRoad(searchX, searchY, searchZ, 1, 15.0, false)
    if roadFound then
        local roadZ = roadPos.z
        local found, groundZ = GetGroundZFor_3dCoord(roadPos.x, roadPos.y, roadZ + 10.0, false)
        if found then
            roadZ = groundZ
        end
        
        local heightDiff = math.abs(roadZ - playerPos.z)
        if heightDiff <= 5.0 then
            return vector3(roadPos.x, roadPos.y, roadZ + 1.0)
        end
    end
    
    return nil
end

function GetFallbackSpawnPosition(playerPos)
    for i = 1, 8 do
        local angle = (i - 1) * (math.pi / 4)
        local distance = Config.ClientSettings.spawnDistance.min + 10
        
        local x = playerPos.x + math.cos(angle) * distance
        local y = playerPos.y + math.sin(angle) * distance
        local z = playerPos.z
        
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 50.0, false)
        if found then
            local testPos = vector3(x, y, groundZ + 1.0)
            if IsSpawnPositionSafe(testPos, playerPos) then
                return testPos
            end
        end
    end
    
    return vector3(playerPos.x + Config.ClientSettings.spawnDistance.min, playerPos.y + Config.ClientSettings.spawnDistance.min, playerPos.z)
end

function IsSpawnPositionSafe(spawnPos, playerPos)
    local distance = #(spawnPos - playerPos)
    if distance < Config.ClientSettings.spawnDistance.min or distance > Config.ClientSettings.spawnDistance.max + 10 then
        return false
    end
    
    local raycast = StartExpensiveSynchronousShapeTestLosProbe(
        spawnPos.x, spawnPos.y, spawnPos.z + 2.0, 
        spawnPos.x, spawnPos.y, spawnPos.z - 3.0, 
        1, 0, 4
    )
    local _, hit, _, _, _ = GetShapeTestResult(raycast)
    if not hit then
        return false
    end
    
    local buildingRaycast = StartExpensiveSynchronousShapeTestLosProbe(
        spawnPos.x, spawnPos.y, spawnPos.z + 1.0,
        spawnPos.x, spawnPos.y, spawnPos.z + 20.0,
        1, 0, 4
    )
    local _, buildingHit, _, _, _ = GetShapeTestResult(buildingRaycast)
    if buildingHit then
        return false
    end
    
    local playerRaycast = StartExpensiveSynchronousShapeTestLosProbe(
        playerPos.x, playerPos.y, playerPos.z + 1.5,
        spawnPos.x, spawnPos.y, spawnPos.z + 1.5,
        1, 0, 4
    )
    local _, playerBlockHit, _, _, _ = GetShapeTestResult(playerRaycast)
    if not playerBlockHit then
        return false
    end
    
    return true
end

function CalculateSpawnScore(spawnPos, playerPos)
    local score = 100
    local distance = #(spawnPos - playerPos)
    
    score = score + (distance * 0.8)
    
    local nearbyVehicles = ESX.Game.GetVehiclesInArea(spawnPos, Config.ClientSettings.safeZoneRadius)
    score = score - (#nearbyVehicles * 15)
    
    local nearbyPlayers = ESX.Game.GetPlayersInArea(spawnPos, Config.ClientSettings.safeZoneRadius * 2)
    score = score - (#nearbyPlayers * 25)
    
    local roadFound, roadPos, heading = GetClosestRoad(spawnPos.x, spawnPos.y, spawnPos.z, 1, 5.0, false)
    if roadFound then
        local roadDistance = #(spawnPos - roadPos)
        if roadDistance <= 3.0 then
            score = score + 50
        elseif roadDistance <= 8.0 then
            score = score + 25
        end
    else
        score = score - 30
    end
    
    local playerRaycast = StartExpensiveSynchronousShapeTestLosProbe(
        playerPos.x, playerPos.y, playerPos.z + 1.5,
        spawnPos.x, spawnPos.y, spawnPos.z + 1.5,
        1, 0, 4
    )
    local _, blocked, _, _, _ = GetShapeTestResult(playerRaycast)
    if not blocked then
        score = score - 40
    else
        score = score + 30
    end
    
    return score
end

function SetupNPCNavigation(ped, targetPos)
    local pedPos = GetEntityCoords(ped)
    local distance = #(pedPos - targetPos)
    
    ClearPedTasks(ped)
    
    if distance > 10.0 then
        TaskGoToCoordAnyMeans(ped, targetPos.x, targetPos.y, targetPos.z, 1.8, 0, false, 786603, 0xbf800000)
        SetPedMoveRateOverride(ped, 1.3)
    else
        TaskGoStraightToCoord(ped, targetPos.x, targetPos.y, targetPos.z, 1.2, 15000, 0.0, 0)
        SetPedMoveRateOverride(ped, 1.0)
    end
end

function MonitorClientArrival(targetPos)
    CreateThread(function()
        local startTime = GetGameTimer()
        
        AddTargetToClient()
        
        while currentDeal.active and DoesEntityExist(currentDeal.clientPed) do
            local playerPos = GetEntityCoords(PlayerPedId())
            local clientPos = GetEntityCoords(currentDeal.clientPed)
            local distance = #(clientPos - playerPos)
            
            if distance > Config.ClientSettings.arrivalRadius then
                SetupNPCNavigation(currentDeal.clientPed, playerPos)
            elseif distance <= Config.ClientSettings.arrivalRadius and not currentDeal.targetAdded then
                currentDeal.targetAdded = true
                
                ClearPedTasks(currentDeal.clientPed)
                TaskTurnPedToFaceEntity(currentDeal.clientPed, PlayerPedId(), 2000)
                
                lib.notify({
                    title = 'Drug Deal',
                    description = Config.Notifications.clientArrived,
                    type = 'success',
                    duration = 5000
                })
                
                SetTimeout(Config.ClientSettings.despawnTime, function()
                    if currentDeal.active and not currentDeal.dealStarted then
                        CleanupDeal()
                        lib.notify({
                            title = 'Drug Deal',
                            description = Config.Notifications.clientLeft,
                            type = 'error',
                            duration = 5000
                        })
                    end
                end)
                
                break
            end
            
            if GetGameTimer() - startTime > Config.ClientSettings.maxWaitTime then
                CleanupDeal()
                lib.notify({
                    title = 'Drug Deal',
                    description = 'Klient se neukázal',
                    type = 'error',
                    duration = 5000
                })
                break
            end
            
            Wait(1000)
        end
    end)
end

function AddTargetToClient()
    if currentDeal.targetAdded then return end
    
    local drugConfig = Config.DrugItems[currentDeal.drugType]
    
    Wait(1000)
    
    exports.ox_target:addLocalEntity(currentDeal.clientPed, {
        {
            name = 'sell_drugs',
            icon = 'fas fa-pills',
            label = drugConfig.sellText .. ' (x' .. currentDeal.drugCount .. ')',
            onSelect = function()
                StartDealTransaction()
            end,
            canInteract = function(entity, distance, coords, name)
                local playerPos = GetEntityCoords(PlayerPedId())
                local clientPos = GetEntityCoords(currentDeal.clientPed)
                local dist = #(clientPos - playerPos)
                return currentDeal.active and not currentDeal.dealStarted and dist <= Config.ClientSettings.interactionRadius + 2.0
            end,
            distance = Config.ClientSettings.interactionRadius + 2.0
        }
    })
    
    currentDeal.targetAdded = true
end

function StartDealTransaction()
    if currentDeal.dealStarted then return end
    
    currentDeal.dealStarted = true
    
    local playerPed = PlayerPedId()
    local clientPed = currentDeal.clientPed
    
    TaskTurnPedToFaceEntity(playerPed, clientPed, 2000)
    TaskTurnPedToFaceEntity(clientPed, playerPed, 2000)
    
    Wait(2000)
    
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_DRUG_DEALER_HARD', 0, true)
    TaskStartScenarioInPlace(clientPed, 'WORLD_HUMAN_DRUG_DEALER_HARD', 0, true)
    
    if lib.progressBar({
        duration = 5000,
        label = 'Prodáváš dope...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        local playerPos = GetEntityCoords(playerPed)
        TriggerServerEvent('sk8_selldrugs:completeDeal', currentDeal.drugType, currentDeal.drugCount, playerPos)
        
        ClearPedTasks(playerPed)
        ClearPedTasks(clientPed)
        
        ClearPedTasks(clientPed)
        TaskWanderStandard(clientPed, 10.0, 10)
        SetEntityAsNoLongerNeeded(clientPed)
        SetPedAsNoLongerNeeded(clientPed)
        
        currentDeal.active = false
        currentDeal.dealStarted = false
        
        SetTimeout(Config.ClientSettings.wanderTime, function()
            if DoesEntityExist(clientPed) then
                DeleteEntity(clientPed)
            end
        end)
        
        SetTimeout(3000, function()
            CleanupDeal()
            
            if Config.StreetCredit.enabled then
                SendNUIMessage({
                    action = 'hideStreetCredit'
                })
            end
        end)
    end
end

function CleanupDeal()
    if currentDeal.clientPed and DoesEntityExist(currentDeal.clientPed) then
        if currentDeal.targetAdded then
            exports.ox_target:removeLocalEntity(currentDeal.clientPed, 'sell_drugs')
        end
        if not currentDeal.dealStarted then
            DeleteEntity(currentDeal.clientPed)
        end
    end
    
    if currentDeal.clientBlip and DoesBlipExist(currentDeal.clientBlip) then
        RemoveBlip(currentDeal.clientBlip)
    end
    
    currentDeal.active = false
    currentDeal.drugType = nil
    currentDeal.drugCount = 0
    currentDeal.clientPed = nil
    currentDeal.clientBlip = nil
    currentDeal.dealStarted = false
    currentDeal.targetAdded = false
end

function CancelDeal()
    TriggerServerEvent('sk8_selldrugs:cancelDeal')
    CleanupDeal()
    
    if Config.StreetCredit.enabled then
        SendNUIMessage({
            action = 'hideStreetCredit'
        })
    end
end

function CreateTimer(callback, delay)
    SetTimeout(delay, callback)
end

RegisterNetEvent('sk8_selldrugs:notify')
AddEventHandler('sk8_selldrugs:notify', function(message, type)
    lib.notify({
        title = 'Drug Deal',
        description = message,
        type = type,
        duration = 5000
    })
end)

RegisterNetEvent('sk8_selldrugs:updateStreetCredit')
AddEventHandler('sk8_selldrugs:updateStreetCredit', function(streetCreditData, levelUp)
    if Config.StreetCredit.enabled then
        SendNUIMessage({
            action = 'updateStreetCredit',
            streetCreditData = streetCreditData,
            levelUp = levelUp
        })
    end
end)

RegisterNetEvent('sk8_selldrugs:dealReported')
AddEventHandler('sk8_selldrugs:dealReported', function()
    CancelDeal()
    
    lib.notify({
        title = 'Drug Deal',
        description = Config.Notifications.dealReported,
        type = 'error',
        duration = 8000
    })
end)

RegisterNetEvent('sk8_selldrugs:showPoliceAlert')
AddEventHandler('sk8_selldrugs:showPoliceAlert', function(reportData)
    SendNUIMessage({
        action = 'showPoliceAlert',
        reportData = reportData
    })
    
    local alertBlip = AddBlipForRadius(reportData.coords.x, reportData.coords.y, reportData.coords.z, reportData.radius)
    SetBlipHighDetail(alertBlip, true)
    SetBlipColour(alertBlip, Config.DealFailure.reportBlipSettings.color)
    SetBlipAlpha(alertBlip, 128)
    SetBlipAsShortRange(alertBlip, false)
    
    local centerBlip = AddBlipForCoord(reportData.coords.x, reportData.coords.y, reportData.coords.z)
    SetBlipSprite(centerBlip, Config.DealFailure.reportBlipSettings.sprite)
    SetBlipDisplay(centerBlip, 4)
    SetBlipScale(centerBlip, Config.DealFailure.reportBlipSettings.scale)
    SetBlipColour(centerBlip, Config.DealFailure.reportBlipSettings.color)
    SetBlipAsShortRange(centerBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.DealFailure.reportBlipSettings.name)
    EndTextCommandSetBlipName(centerBlip)
    
    SetTimeout(Config.DealFailure.reportBlipSettings.duration, function()
        if DoesBlipExist(alertBlip) then
            RemoveBlip(alertBlip)
        end
        if DoesBlipExist(centerBlip) then
            RemoveBlip(centerBlip)
        end
        
        SendNUIMessage({
            action = 'hidePoliceAlert'
        })
    end)
end)

RegisterCommand('teststreetcredit', function()
    if Config.StreetCredit.enabled then
        local testData = {
            level = 3,
            levelName = 'Dealer',
            currentXP = 180,
            requiredXP = 150,
            nextRequiredXP = 300,
            multiplier = 1.2,
            duration = 5000
        }
        
        SendNUIMessage({
            action = 'showStreetCredit',
            streetCreditData = testData
        })
    end
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupDeal()
        
        if Config.StreetCredit.enabled then
            SendNUIMessage({
                action = 'hideStreetCredit'
            })
        end
    end
end)