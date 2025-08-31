fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'sk8'
description 'SK8 DEVELOPMENT - Drug Selling Script'
version '1.0.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql'
}