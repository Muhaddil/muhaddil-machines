local buying = false                                     -- Variable to prevent multiple purchases
local LastWaterCoolerUse = 0                             -- Variable to prevent multiple uses of the water cooler
local TimeoutDuration = Config.WaterCoolerTimeout * 1000 -- Timeout duration for water coolers in milliseconds
local DrinkCount = 0                                     -- Variable to count the number of drinks
local framework = Config.Framework

function InitFramework()
    if framework == "auto" then
        if exports['es_extended'] then
            framework = "esx"
        elseif exports['qb-core'] then
            framework = "qb"
        elseif pcall(require, '@ox_core.lib.init') then
            framework = "ox"
        else
            framework = "esx"
        end
    end

    if framework == "esx" then
        ESX = exports['es_extended']:getSharedObject()
    elseif framework == "qb" then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif framework == "ox" then
        Ox = require '@ox_core.lib.init'
    else
        ESX = exports['es_extended']:getSharedObject() -- fallback
    end

    return framework
end

InitFramework()
lib.locale()

function DebugPrint(...) -- Debug print function
    if Config.DebugMode then
        print(...)
    end
end

function Notify(msgtitle, msg, time, type2) -- Notification function
    if Config.UseOXNotifications then
        lib.notify({
            title = msgtitle,
            description = msg,
            showDuration = true,
            type = type2,
        })
    else
        if framework == 'qb' then
            QBCore.Functions.Notify(msg, type2, time)
        elseif framework == 'esx' then
            TriggerEvent('esx:showNotification', msg, type2, time)
        elseif framework == 'ox' then
            lib.notify({
                title = msgtitle,
                description = msg,
                showDuration = true,
                type = type2,
            })
        end
    end
end

RegisterNetEvent("muhaddil-machines:Notify")
AddEventHandler("muhaddil-machines:Notify", function(msgtitle, msg, time, type)
    Notify(msgtitle, msg, time, type)
end)

function loadAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
end

function playAnimation(ped, animDict, animName)
    loadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, 8.0, 5.0, -1, 1, 1, false, false, false)
    Citizen.Wait(4500)
    ClearPedTasks(ped)
    RemoveAnimDict(animDict)
end

function vendingAnimation(entity)
    local ped = PlayerPedId()
    local position = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.97, 0.05)
    local heading = GetEntityHeading(entity)
    local prop_name = 'ng_proc_sodacan_01a'
    buying = true

    TaskTurnPedToFaceEntity(ped, entity, -1)
    if not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.0, 0.1, false, true, 0) then
        TaskGoStraightToCoord(ped, position.x, position.y, position.z, 1.0, 20000, heading, 0.1)
        Citizen.Wait(1000)
    end
    TaskTurnPedToFaceEntity(ped, entity, -1)
    Citizen.Wait(1000)

    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local x, y, z = table.unpack(GetEntityCoords(playerPed))

        if Config.VisibleProp then
            local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
            local boneIndex = GetPedBoneIndex(playerPed, 18905)
        end

        RequestAmbientAudioBank("VENDING_MACHINE", false)
        HintAmbientAudioBank("VENDING_MACHINE", 0)
        if Config.VisibleProp then
            AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false,
                true, 1, true)
        end
        playAnimation(playerPed, Config.Animations.sodamachines[1], Config.Animations.sodamachines[2])
        Citizen.Wait(1000)

        ClearPedSecondaryTask(playerPed)
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
        ReleaseAmbientAudioBank()

        buying = false
    end)
end

function openNUI(sourceType, machineName, entity, items, title)
    SetNuiFocus(true, true)

    local nuiLocales = {
        items = locale('nui_items'),
        tap_to_select = locale('nui_tap_to_select'),
        cash_or_bank = locale('nui_cash_or_bank'),
        no_items = locale('nui_no_items'),
        tap_to_buy = locale('nui_tap_to_buy'),
        select_quantity = locale('nui_select_quantity'),
        unit_price = locale('nui_unit_price'),
        total = locale('nui_total'),
        back = locale('nui_back'),
        purchase = locale('nui_purchase'),
        purchased = locale('nui_purchased'),
        failed = locale('nui_failed'),
        esc_to_close = locale('nui_esc_to_close'),
        online = locale('nui_online')
    }

    SendNUIMessage({
        action        = 'open',
        sourceType    = sourceType,
        machineName   = machineName,
        items         = items,
        title         = title,
        inputMaxValue = Config.InputMaxValue,
        locales       = nuiLocales
    })
end

function closeNUI()
    SetNuiFocus(false, false)
end

RegisterNUICallback('selectItem', function(data, cb)
    local sourceType  = data.sourceType or 'machine'
    local machineName = data.machineName
    local itemName    = data.itemName
    local itemPrice   = data.itemPrice
    local cantidad    = tonumber(data.quantity) or 1

    if not itemName or not machineName or cantidad <= 0 then
        cb({ ok = false })
        return
    end

    Citizen.CreateThread(function()
        if sourceType == 'machine' then
            vendingAnimation(GetClosestObjectOfType(
                GetEntityCoords(PlayerPedId()), 3.0, GetHashKey(
                    Config.machines[machineName] and Config.machines[machineName].model or ''
                ), false, false, false
            ))
            Citizen.Wait(4500)
        elseif sourceType == 'stand' then
            standAnimation(GetClosestObjectOfType(
                GetEntityCoords(PlayerPedId()), 3.0, GetHashKey(
                    Config.Stands[machineName] and Config.Stands[machineName].model or ''
                ), false, false, false
            ))
        elseif sourceType == 'news' then
            newsAnimation(GetClosestObjectOfType(
                GetEntityCoords(PlayerPedId()), 3.0, GetHashKey(
                    Config.NewsSellers[machineName] and Config.NewsSellers[machineName].model or ''
                ), false, false, false
            ))
        end

        TriggerServerEvent('muhaddil-machines:buy', sourceType, machineName, itemName, cantidad)
    end)

    cb({ ok = true })
end)

RegisterNUICallback('close', function(data, cb)
    closeNUI()
    buying = false
    cb({ ok = true })
end)

function showVendingMenu(vendingMachineName, entity, items)
    if buying then return end
    openNUI('machine', vendingMachineName, entity, items, locale('vending_machine'))
end

function interactWithWaterCooler(entity)
    local currentTime = GetGameTimer()

    if Config.ShowWaitNotification then
        if currentTime - LastWaterCoolerUse < TimeoutDuration then
            DebugPrint(locale('wait_before_use'))
            Notify(locale('slow_down'), locale('wait_message'), 5000, "error")
            return
        end
    end

    if IsAnimated then return end
    IsAnimated = true
    LastWaterCoolerUse = currentTime

    local prop_name = 'prop_cs_paper_cup'
    local ped = PlayerPedId()
    local position = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.97, 0.05)
    local heading = GetEntityHeading(entity)

    if not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.1, 0.1, false, true, 0) then
        TaskGoStraightToCoord(ped, position.x, position.y, position.z, 1.0, 20000, heading, 0.1)
        Wait(1000)
    end
    TaskTurnPedToFaceEntity(ped, entity, -1)

    lib.progressBar({
        duration = 2000,
        label = locale('filling_glass'),
    })

    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local x, y, z = table.unpack(GetEntityCoords(playerPed))
        local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
        local boneIndex = GetPedBoneIndex(playerPed, 18905)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1,
            true)

        local animDict = 'mp_player_intdrink'
        local animName = 'loop_bottle'

        playAnimation(playerPed, animDict, animName)

        if Config.CountDrinksPlace == 'before' then
            DrinkCount = DrinkCount + 1
        end

        if Config.KillPlayerOnExcess then
            local warningThreshold = math.ceil(Config.MaxDrinksBeforeKill / 2)
            print(warningThreshold)

            if DrinkCount >= Config.MaxDrinksBeforeKill then
                SetEntityHealth(playerPed, 0)
                Notify(locale('too_much_water'), locale('died_from_water'), 5000, "error")
                DrinkCount = 0
            elseif DrinkCount >= warningThreshold then
                Notify(locale('fresh_water'), locale('keep_drinking_warning'), 3000, "info")
            else
                Notify(locale('fresh_water'), locale('drank_water'), 3000, "info")
            end
        else
            Notify(locale('fresh_water'), locale('drank_water'), 3000, "info")
        end

        IsAnimated = false
        ClearPedSecondaryTask(playerPed)
        DeleteObject(prop)
        RemoveAnimDict(animDict)

        TriggerServerEvent('muhaddil-machines:RemoveThirst')

        if Config.CountDrinksPlace == 'after' then
            DrinkCount = DrinkCount + 1
        end
    end)
end

function WaterCoolerTarget()
    for waterCoolerName, data in pairs(Config.WaterCoolers) do
        if Config.Target == 'ox' then
            exports.ox_target:addModel(joaat(data.model), {
                {
                    label = locale('drink_water'),
                    icon = 'fa-solid fa-glass-water',
                    onSelect = function(d)
                        local entity = d.entity
                        interactWithWaterCooler(entity)
                    end
                }
            })
        elseif Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(joaat(data.model), {
                options = {
                    {
                        label = locale('drink_water'),
                        icon = "fas fa-glass-water",
                        action = function(entity)
                            interactWithWaterCooler(entity)
                        end
                    }
                },
                distance = 2.0
            })
        end
    end
end

function standAnimation(entity)
    local ped = PlayerPedId()
    local position = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.97, 0.05)
    local heading = GetEntityHeading(entity)
    buying = true

    TaskTurnPedToFaceEntity(ped, entity, -1)
    if not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.1, 0.0, 0.1, false, true, 0) then
        TaskGoStraightToCoord(ped, position.x, position.y, position.z, 1.0, 20000, heading, 0.1)
        Citizen.Wait(1000)
    end
    TaskTurnPedToFaceEntity(ped, entity, -1)
    Citizen.Wait(1000)

    playAnimation(ped, Config.Animations.stand[1], Config.Animations.stand[2])
    Citizen.Wait(1000)

    ClearPedSecondaryTask(ped)

    buying = false
end

function standMenu(standName, entity, items)
    if buying then return end
    openNUI('stand', standName, entity, items, locale('food_stand'))
end

function newsAnimation(entity)
    local ped = PlayerPedId()
    local position = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.97, 0.05)
    local heading = GetEntityHeading(entity)
    buying = true

    TaskTurnPedToFaceEntity(ped, entity, -1)
    if not IsEntityAtCoord(ped, position.x, position.y, position.z, 0.0, 0.0, 0.0, false, true, 0) then
        TaskGoStraightToCoord(ped, position.x, position.y, position.z, 1.0, 20000, heading, 0.1)
        Citizen.Wait(1000)
    end
    TaskTurnPedToFaceEntity(ped, entity, -1)
    Citizen.Wait(1000)

    loadAnimDict(Config.Animations.newsSellers[1])
    TaskPlayAnim(ped, Config.Animations.newsSellers[1], Config.Animations.newsSellers[2], 8.0, 5.0, -1, 1, 1, false,
        false, false)
    Citizen.Wait(2500)
    ClearPedTasks(ped)
    RemoveAnimDict(Config.Animations.newsSellers[1])

    ClearPedSecondaryTask(ped)

    buying = false
end

function newsMenu(newsName, entity, items)
    if buying then return end
    openNUI('news', newsName, entity, items, locale('news_seller'))
end

function setupTargeting()
    for vendingMachineName, data in pairs(Config.machines) do
        local targetOptions = {
            label = locale('open_vending_machine'),
            icon = 'fa-solid fa-basket-shopping',
            ox = function(d)
                if buying then return end
                local entity = d.entity
                showVendingMenu(vendingMachineName, entity, data.items)
            end,
            qb = function(entity)
                if buying then return end
                showVendingMenu(vendingMachineName, entity, data.items)
            end
        }

        if Config.Target == 'ox' then
            exports.ox_target:addModel(joaat(data.model), {
                {
                    label = targetOptions.label,
                    icon = targetOptions.icon,
                    onSelect = targetOptions.ox
                }
            })
        elseif Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(joaat(data.model), {
                options = {
                    {
                        label = targetOptions.label,
                        icon = targetOptions.icon,
                        action = targetOptions.qb
                    }
                },
                distance = 2.0
            })
        end
    end

    for standName, data in pairs(Config.Stands) do
        local targetOptions = {
            label = locale('open_food_stand'),
            icon = 'fa-solid fa-utensils',
            ox = function(d)
                if buying then return end
                local entity = d.entity
                standMenu(standName, entity, data.items)
            end,
            qb = function(entity)
                if buying then return end
                standMenu(standName, entity, data.items)
            end
        }

        if Config.Target == 'ox' then
            exports.ox_target:addModel(joaat(data.model), {
                {
                    label = targetOptions.label,
                    icon = targetOptions.icon,
                    onSelect = targetOptions.ox
                }
            })
        elseif Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(joaat(data.model), {
                options = {
                    {
                        label = targetOptions.label,
                        icon = targetOptions.icon,
                        action = targetOptions.qb
                    }
                },
                distance = 2.0
            })
        end
    end

    for newsName, data in pairs(Config.NewsSellers) do
        local targetOptions = {
            label = locale('open_news_seller'),
            icon = 'fa-solid fa-newspaper',
            ox = function(d)
                if buying then return end
                local entity = d.entity
                newsMenu(newsName, entity, data.items)
            end,
            qb = function(entity)
                if buying then return end
                newsMenu(newsName, entity, data.items)
            end
        }

        if Config.Target == 'ox' then
            exports.ox_target:addModel(joaat(data.model), {
                {
                    label = targetOptions.label,
                    icon = targetOptions.icon,
                    onSelect = targetOptions.ox
                }
            })
        elseif Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(joaat(data.model), {
                options = {
                    {
                        label = targetOptions.label,
                        icon = targetOptions.icon,
                        action = targetOptions.qb
                    }
                },
                distance = 2.0
            })
        end
    end
end

local spawnedNPCs = {} -- { propEntity = { ped = ped, npcData = npcData } }

local hasActiveNPCs = false
for _, data in pairs(Config.Stands) do
    if data.npc and data.npc.active then
        hasActiveNPCs = true
        break
    end
end

CreateThread(function()
    if not hasActiveNPCs then return end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for standName, data in pairs(Config.Stands) do
            if data.npc and data.npc.active then
                local modelHash = GetHashKey(data.model)
                local obj = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, data.npc
                .spawnDistance, modelHash, false, false, false)

                if DoesEntityExist(obj) and not spawnedNPCs[obj] then
                    local dist = #(playerCoords - GetEntityCoords(obj))
                    if dist < data.npc.spawnDistance then
                        SpawnNPCAtProp(obj, data.npc)
                    end
                end
            end
        end

        for propEntity, entry in pairs(spawnedNPCs) do
            if type(entry) ~= 'table' then
                spawnedNPCs[propEntity] = nil
            else
                local dist = #(playerCoords - GetEntityCoords(propEntity))
                if dist > entry.npcData.despawnDistance then
                    if DoesEntityExist(entry.ped) then
                        DeletePed(entry.ped)
                        DebugPrint('NPC eliminado, distancia: ' .. tostring(dist))
                    end
                    spawnedNPCs[propEntity] = nil
                end
            end
        end

        Citizen.Wait(2000)
    end
end)

function SpawnNPCAtProp(propEntity, npcData)
    local npcModel = GetHashKey(npcData.model)

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Citizen.Wait(0)
    end

    local propCoords = GetEntityCoords(propEntity)
    local propHeading = GetEntityHeading(propEntity)
    local offset = npcData.offset
    local rad = math.rad(propHeading)
    local nx = propCoords.x + offset.x * math.cos(rad) - offset.y * math.sin(rad)
    local ny = propCoords.y + offset.x * math.sin(rad) + offset.y * math.cos(rad)
    local nz = propCoords.z + offset.z

    local ped = CreatePed(4, npcModel, nx, ny, nz, propHeading + npcData.heading_offset, false, true)

    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedDiesWhenInjured(ped, false)

    local animDict = 'missfam5_yoga'
    local animName = 'base_idle_b'
    loadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, 1.0, 1.0, -1, 1, 0, false, false, false)

    SetModelAsNoLongerNeeded(npcModel)
    spawnedNPCs[propEntity] = { ped = ped, npcData = npcData }
    DebugPrint('NPC spawneado en stand: ' .. tostring(ped))
end

CreateThread(function()
    Wait(100)
    setupTargeting()
    WaterCoolerTarget()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, entry in pairs(spawnedNPCs) do
            local ped = type(entry) == 'table' and entry.ped or entry
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
        end
    end
end)
