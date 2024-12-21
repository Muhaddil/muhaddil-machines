Config = Config or {}

Config.DebugMode = true
Config.Framework = 'esx'
Config.UseOXNotifications = true

Config.ThirstRemoval = 150000 -- (WaterCooler)
Config.WaterCoolerTimeout = 30
Config.VisibleProp = false
Config.InputMaxValue = 10 --
Config.KillPlayerOnExcess = true -- Enable one of the two (WaterCooler)
Config.ShowWaitNotification = false -- Enable one of the two (WaterCooler)
Config.MaxDrinksBeforeKill = 3 -- (WaterCooler)
Config.CountDrinksPlace = 'before' -- 'before' or 'after', it varies in the result of the Config.MaxDrinksBeforeKill (WaterCooler)

Config.Animations = {
    stand = {
        "special_ped@baygor@monologue_2@monologue_2h",
        "you_can_ignore_me_7"
    },
    sodamachines = {
        "mini@sprunk@first_person",
        "plyr_buy_drink_pt1"
    },
}

Config.machines = {
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
        offset = vec3(0, 0, 0)
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

Config.WaterCoolers = {
    {model = 'prop_watercooler_dark',},
    {model = 'prop_watercooler',},
}

Config.Stands = {
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
}

Config.NewsSellers = {
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
}
