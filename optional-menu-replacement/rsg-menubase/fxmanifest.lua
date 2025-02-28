author "JUMP ON studios : http://jumpon-studios.com"
documentation "https://docs.jumpon-studios.com"
description "Replace MenuAPI by jo_menu"

game "rdr3"
fx_version "adamant"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

lua54 "yes"

client_scripts {
	"@jo_libs/init.lua",
	"client.lua",
}

dependencies {
	"jo_libs"
}

ui_page "nui://jo_libs/nui/menu/index.html"

jo_libs {
	"menu"
}
