fx_version 'cerulean'
game 'gta5'

description 'QB-TruckRobbery'
version '2.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
	'config.lua',
	'locales/en.lua',
}

server_script 'server/main.lua'
client_script 'client/main.lua'

lua54 'yes'
