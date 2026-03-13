fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Muhaddil'
description 'FiveM script that adds vending machines'
version 'v1.0.4'

shared_scripts {
  'config.lua',
  '@ox_lib/init.lua',
}

client_script 'client/*'

server_script 'server/*'

ui_page 'NUI/NUI.html'

files {
  'locales/*.json',
  'NUI/*'
}
