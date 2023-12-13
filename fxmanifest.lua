fx_version 'cerulean'
game 'gta5'

author 'ChristianBDev & Jay60 & QBCore Framework Devs'
description 'Truck Robbery'
version '1.0.0'

shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
	'config.lua',
}

server_scripts {
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}

lua54 'yes'
