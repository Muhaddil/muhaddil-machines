local buying = false                                     -- Variable to prevent multiple purchases
local LastWaterCoolerUse = 0                             -- Variable to prevent multiple uses of the water cooler
local TimeoutDuration = Config.WaterCoolerTimeout * 1000 -- Timeout duration for water coolers in milliseconds
local DrinkCount = 0                                     -- Variable to count the number of drinks

if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "ox" then
    Ox = require '@ox_core.lib.init'
else
    ESX = exports['es_extended']:getSharedObject()
end

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
            style = {
                backgroundColor = 'rgba(0, 0, 0, 0.75)',
                color = 'rgba(255, 255, 255, 1)',
                ['.description'] = {
                    color = '#909296',
                    backgroundColor = 'transparent'
                }
            }
        })
    else
        if Config.Framework == 'qb' then
            QBCore.Functions.Notify(msg, type2, time)
        elseif Config.Framework == 'esx' then
            TriggerEvent('esx:showNotification', msg, type2, time)
        elseif Config.Framework == 'ox' then
            lib.notify({
                title = msgtitle,
                description = msg,
                showDuration = true,
                type = type2,
                style = {
                    backgroundColor = 'rgba(0, 0, 0, 0.75)',
                    color = 'rgba(255, 255, 255, 1)',
                    ['.description'] = {
                        color = '#909296',
                        backgroundColor = 'transparent'
                    }
                }
            })
        end
    end
end

RegisterNetEvent("muhaddil-machines:Notify")
AddEventHandler("muhaddil-machines:Notify", function(msgtitle, msg, time, type)
    Notify(msgtitle, msg, time, type)
end)

local function loadAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
end

local function playAnimation(ped, animDict, animName)
    loadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, 8.0, 5.0, -1, 1, 1, false, false, false)
    Citizen.Wait(4500)
    ClearPedTasks(ped)
    RemoveAnimDict(animDict)
end

local function vendingAnimation(entity)
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


local function showQuantityDialog(item, vendingMachineName, entity)
    local input = lib.inputDialog("Selecciona la cantidad", {
        { type = 'number', label = 'Cantidad', min = 1, max = Config.InputMaxValue, default = 1 }
    })

    if not input then return end
    local cantidad = input[1]

    if cantidad and cantidad > 0 then
        local ped = PlayerPedId()
        if buying then return end
        buying = true

        vendingAnimation(entity)

        Citizen.Wait(4500)

        TriggerServerEvent('muhaddil-machines:buy', 'machine', vendingMachineName, item.name, cantidad)
    else
        Notify('Error', 'Cantidad no válida', 5000, "error")
    end

    buying = false
end

local function replacePrice(inputString, price)
    return inputString:gsub("%%price%%", tostring(price))
end

local function showVendingMenu(vendingMachineName, entity, items)
    local options = {}

    for _, item in pairs(items) do
        table.insert(options, {
            title = replacePrice(item.label, item.price),
            icon = item.icon or 'fa-solid fa-bottle-water',
            onSelect = function()
                if buying then return end
                showQuantityDialog(item, vendingMachineName, entity)
            end
        })
    end

    lib.registerContext({
        id = 'vending_menu_' .. vendingMachineName,
        title = 'Máquina expendedora',
        canClose = true,
        options = options
    })

    lib.showContext('vending_menu_' .. vendingMachineName)
end

local function interactWithWaterCooler(entity)
    local currentTime = GetGameTimer()

    if Config.ShowWaitNotification then
        if currentTime - LastWaterCoolerUse < TimeoutDuration then
            DebugPrint("Debes esperar antes de usar nuevamente la fuente de agua.")
            Notify('¡Echa el freno madaleno!', 'Relaja, espera un poco antes de volver a usar la máquina', 5000, "error")
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
        label = 'Llenado Vaso',
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
                Notify('Demasiada agua', 'Has bebido demasiada agua y has muerto.', 5000, "error")
                DrinkCount = 0
            elseif DrinkCount >= warningThreshold then
                Notify('Agua fresca', 'Sigues bebiendo... ten cuidado.', 3000, "info")
            else
                Notify('Agua fresca', 'Has tomado un vaso de agua.', 3000, "info")
            end
        else
            Notify('Agua fresca', 'Has tomado un vaso de agua.', 3000, "info")
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

local function WaterCoolerTarget()
    for waterCoolerName, data in pairs(Config.WaterCoolers) do
        if Config.Target == 'ox' then
            exports.ox_target:addModel(joaat(data.model), {
                {
                    label = "Beber Agua",
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
                        label = "Beber Agua",
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

local function standAnimation(entity)
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

local function showQuantityDialogStands(item, standName, entity)
    local input = lib.inputDialog("Selecciona la cantidad", {
        { type = 'number', label = 'Cantidad', min = 1, max = Config.InputMaxValue, default = 1 }
    })

    if not input then return end
    local cantidad = input[1]

    if cantidad and cantidad > 0 then
        local ped = PlayerPedId()
        if buying then return end
        buying = true

        standAnimation(entity)

        TriggerServerEvent('muhaddil-machines:buy', 'stand', standName, item.name, cantidad)
    else
        Notify('Error', 'Cantidad no válida', 5000, "error")
    end

    buying = false
end

local function standMenu(standName, entity, items)
    local options = {}

    for _, item in pairs(items) do
        table.insert(options, {
            title = replacePrice(item.label, item.price),
            icon = item.icon or 'fa-solid fa-bottle-water',
            onSelect = function()
                if buying then return end
                showQuantityDialogStands(item, standName, entity)
            end
        })
    end

    lib.registerContext({
        id = 'stand_menu_' .. standName,
        title = 'Puesto de Comida',
        canClose = true,
        options = options
    })

    lib.showContext('stand_menu_' .. standName)
end

local function newsAnimation(entity)
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


local function showQuantityDialogNews(item, newsName, entity)
    local input = lib.inputDialog("Selecciona la cantidad", {
        { type = 'number', label = 'Cantidad', min = 1, max = Config.InputMaxValue, default = 1 }
    })

    if not input then return end
    local cantidad = input[1]

    if cantidad and cantidad > 0 then
        local ped = PlayerPedId()
        if buying then return end
        buying = true

        newsAnimation(entity)

        TriggerServerEvent('muhaddil-machines:buy', 'news', newsName, item.name, cantidad)
    else
        Notify('Error', 'Cantidad no válida', 5000, "error")
    end

    buying = false
end

local function newsMenu(newsName, entity, items)
    local options = {}

    for _, item in pairs(items) do
        table.insert(options, {
            title = replacePrice(item.label, item.price),
            icon = item.icon or 'fa-solid fa-bottle-water',
            onSelect = function()
                if buying then return end
                showQuantityDialogNews(item, newsName, entity)
            end
        })
    end

    lib.registerContext({
        id = 'news_menu_' .. newsName,
        title = 'Venta de Noticias',
        canClose = true,
        options = options
    })

    lib.showContext('news_menu_' .. newsName)
end

local function setupTargeting()
    for vendingMachineName, data in pairs(Config.machines) do
        local targetOptions = {
            label = "Abrir Máquina Expendedora",
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
            label = "Abrir Puesto de Comida",
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
            label = "Abrir Venta de Noticias",
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

CreateThread(function()
    Wait(100)
    setupTargeting()
    WaterCoolerTarget()
    -- standsTarget()
end)
