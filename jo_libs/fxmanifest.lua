author "JUMP ON studios : https://jumpon-studios.com"
documentation "https://docs.jumpon-studios.com"
version "2.2.3"
package_id "1"

fx_version "adamant"

rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

game "rdr3"
lua54 "yes"

files {
	"init.lua",
	--All client side files
	"modules/**/*shared.lua",
	"modules/**/*client.lua",
	"modules/component/clothesList.lua",
	"modules/component/horseComponents.lua",
	"modules/game-events/data.lua",
	"modules/raw-keys/vk_azerty.lua",
	"modules/raw-keys/vk_qwerty.lua",
	--OLD MENU
	"html/dist/**.html",
	"html/dist/**.js",
	"html/dist/**.css",
	"html/dist/**.ttf",
	"html/dist/**.png",
	"html/dist/**.mp3",
	"html/dist/**.gif",
	--NEW NUIs
	"nui/**/**.html",
	"nui/**/**.js",
	"nui/**/**.css",
	"nui/**/**.ttf",
	"nui/**/**.png",
	"nui/**/**.webp",
	"nui/**/**.mp3",
	"nui/**/**.gif",
}

shared_scripts {
	"init.lua"
}

jo_libs {
	"version-checker"
}
