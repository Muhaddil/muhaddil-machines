Config = Config or {}

Config.DebugMode = true -- Enable debug mode
Config.Framework = 'ox' -- 'esx', 'qb' or 'ox'
Config.UseOXNotifications = true -- Use OX Notifications or framework notifications
Config.Target = 'ox' -- 'qb' to use qbtarget or 'ox' to use ox_target
Config.Inventory = 'ox'-- 'qs', 'ox' or leave blank
Config.NewQBInventory = false -- If you're using the new QB Inventory

Config.ThirstRemoval = 150000 -- Amount of thirst removed by water coolers
Config.WaterCoolerTimeout = 30 -- Timeout duration for water coolers in seconds
Config.VisibleProp = false -- Show the prop when buying a drink
Config.InputMaxValue = 10 -- Maximum value for the input
Config.KillPlayerOnExcess = true -- Enable one of the two (WaterCooler)
Config.ShowWaitNotification = false -- Enable one of the two (WaterCooler)
Config.MaxDrinksBeforeKill = 3 -- (WaterCooler)
Config.CountDrinksPlace = 'before' -- 'before' or 'after', it varies in the result of the Config.MaxDrinksBeforeKill (WaterCooler)

Config.Animations = { -- Animations for the vending machines
    stand = { -- Stand animations
        "special_ped@baygor@monologue_2@monologue_2h",
        "you_can_ignore_me_7"
    },
    sodamachines = { -- Soda machine animations
        "mini@sprunk@first_person",
        "plyr_buy_drink_pt1"
    },
    newsSellers = { -- News seller animations
        "anim@amb@nightclub@mini@drinking@drinking_shots@ped_c@normal",
        "pickup"
    },
}

Config.machines = { -- Vending machines
    {
        model = 'prop_vend_soda_02',
        items = {
            {
                name = "water",
                label = 'Agua ($%price%)',
                price = 30
            },
            {
                name = "cocacola",
                label = 'Cola ($%price%)',
                icon = 'fa fa-mug-saucer',
                price = 50
            },
            {
                name = "energyspeed",
                label = 'Bebida Energética ($%price%)',
                icon = 'fa fa-bolt',
                price = 40
            },
            {
                name = "capisun_a",
                label = 'Capi Sun ($%price%)',
                icon = 'fa fa-sun',
                price = 40
            }
        },
    },
    {
        model = 'prop_vend_water_01',
        items = {
            {
                name = "water",
                label = 'Agua ($%price%)',
                price = 30
            },
            {
                name = "cocacola",
                label = 'Cola ($%price%)',
                icon = 'fa fa-mug-saucer',
                price = 50
            },
            {
                name = "energyspeed",
                label = 'Bebida Energética ($%price%)',
                icon = 'fa fa-bolt',
                price = 40
            },
            {
                name = "capisun_a",
                label = 'Capi Sun ($%price%)',
                icon = 'fa fa-sun',
                price = 40
            }
        },
    },
    {
        model = 'prop_vend_snak_01',
        items = {
            {
                name = "churros_a",
                label = 'Churros ($%price%)',
                icon = 'fa fa-bread-slice',
                price = 15
            },
            {
                name = "cupcake",
                label = 'CupCake ($%price%)',
                icon = 'fa fa-cookie',
                price = 12
            },
            {
                name = "burrito_a",
                label = 'Burrito ($%price%)',
                icon = 'fa-solid fa-bread-slice',
                price = 20
            },
            {
                name = "doughnut_a",
                label = 'Donut ($%price%)',
                icon = 'fa-solid fa-bread-slice',
                price = 40
            }
        },
    },
    {
        model = 'prop_vend_snak_01_tu',
        items = {
            {
                name = "churros_a",
                label = 'Churros ($%price%)',
                icon = 'fa fa-bread-slice',
                price = 15
            },
            {
                name = "cupcake",
                label = 'CupCake ($%price%)',
                icon = 'fa fa-cookie',
                price = 12
            },
            {
                name = "burrito_a",
                label = 'Burrito ($%price%)',
                icon = 'fa-solid fa-bread-slice',
                price = 20
            },
            {
                name = "doughnut_a",
                label = 'Donut ($%price%)',
                icon = 'fa-solid fa-bread-slice',
                price = 40
            }
        },
    },

    {
        model = 'prop_vend_coffe_01',
        items = {
            {
                name = "coffe",
                label = 'Café ($%price%)',
                icon = 'fa fa-mug-hot',
                price = 50
            },
            {
                name = "icetea",
                label = 'Té Helado ($%price%)',
                icon = 'fa fa-ice-cream',
                price = 60
            },
            {
                name = "milk",
                label = 'Leche ($%price%)',
                icon = 'fa fa-glass-milk',
                price = 55
            },
        },
    }
}

Config.WaterCoolers = { -- Water coolers
    {model = 'prop_watercooler_dark',},
    {model = 'prop_watercooler',},
}

Config.Stands = { -- Stands
    {
        model = 'prop_hotdogstand_01',
        items = {
            {
                name = "hotdog_a",
                label = 'HotDog ($%price%)',
                icon = 'fa fa-hotdog',
                price = 30
            },
            {
                name = "cocacola",
                label = 'Cola ($%price%)',
                icon = 'fa fa-mug-saucer',
                price = 50
            },
            {
                name = "pretzel_a",
                label = 'Bretzel ($%price%)',
                icon = 'fa fa-bread-slice',
                price = 40
            },
        },
    },
    {
        model = 'prop_burgerstand_01',
        items = {
            {
                name = "hamburger",
                label = 'Hamburguesa ($%price%)',
                icon = 'fa fa-hamburger',
                price = 30
            },
            {
                name = "cocacola",
                label = 'Cola ($%price%)',
                icon = 'fa fa-mug-saucer',
                price = 50
            },
            {
                name = "bagel",
                label = 'Rosquilla ($%price%)',
                icon = 'fa-solid fa-bread-slice',
                price = 40
            },
        },
    },
    {
        model = 'prop_fruitstand_b',
        items = {
            {
                name = "apple",
                label = 'Manzana ($%price%)',
                icon = 'fa fa-apple',
                price = 10
            },
            {
                name = "banana",
                label = 'Banana ($%price%)',
                icon = 'fa fa-banana',
                price = 12
            },
        },
    },
    {
        model = 'prop_tool_bench02',
        items = {
            {
                name = "repairkit",
                label = 'Kit de Reparación ($%price%)',
                icon = 'fa fa-wrench',
                price = 1000
            },
            {
                name = "bodykit",
                label = 'Body Kit ($%price%)',
                icon = 'fa fa-screwdriver',
                price = 250
            },
        },
    },
}

Config.NewsSellers = { -- News sellers
    {
        model = 'prop_news_disp_06a',
        items = {
            {
                name = "newspaper",
                label = 'Periódico ($%price%)',
                icon = 'fa fa-newspaper',
                price = 30
            },
        },
    },
    {
        model = 'prop_news_disp_01a',
        items = {
            {
                name = "newspaper",
                label = 'Periódico ($%price%)',
                icon = 'fa fa-newspaper',
                price = 30
            },
        },
    },
    {
        model = 'prop_news_disp_03a',
        items = {
            {
                name = "newspaper",
                label = 'Periódico ($%price%)',
                icon = 'fa fa-newspaper',
                price = 30
            },
        },
    },
}
