fx_version 'bodacious'
game 'gta5'

description 'Provides a more child-friendly experiance for FiveM, inspired by FFFR for GTA5 SP'

author 'Jackson92'
version '0.1 [beta]'

shared_script 'config.lua'
server_script 'scripts/server.lua'
client_scripts {
	'@NativeUI/NativeUI.lua',
	'scripts/client.lua'
}