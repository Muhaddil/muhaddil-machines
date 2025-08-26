fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'FiveM script that adds vending machines'
version 'v1.0.2'

shared_scripts {
	'config.lua',
    '@ox_lib/init.lua',
}

client_script 'client.lua'

server_script 'server/*'