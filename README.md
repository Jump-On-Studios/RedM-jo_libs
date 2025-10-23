<p align="center">
  <a href="https://docs.jumpon-studios.com/jo_libs/">
    <img alt="Jo Libraries for RedM" src="https://jumpon-studios.com/images/thumbnails/jo-libraries.webp"/>
  </a>
</p>

<p align="center">
  A utility-first RedM libraries for rapidly building menu & scripts.
</p>

<p align="center">
  <a href="https://github.com/Jump-On-Studios/RedM-jo_libs/releases/tag/v1.6.1"><img alt="Latest release" src="https://img.shields.io/github/v/release/Jump-On-Studios/RedM-jo_libs?logo=github"/></a>
  <a href="https://github.com/Jump-On-Studios/RedM-jo_libs/releases/latest/download/jo_libs.zip"><img alt="Total download" src="https://img.shields.io/github/downloads/Jump-On-Studios/RedM-jo_libs/total"/></a>
  <img alt="License" src="https://img.shields.io/github/license/Jump-On-Studios/RedM-jo_libs"/>
</p>

---

## 📚 Documentation

For the full documentation, visit [docs.jumpon-studios.com](https://docs.jumpon-studios.com/jo_libs).

## 🌐 Global Functions

* [jo.async](https://docs.jumpon-studios.com/jo_libs/global-functions#jo-async)
* [jo.ready](https://docs.jumpon-studios.com/jo_libs/global-functions#jo-ready)
* [jo.stopped](https://docs.jumpon-studios.com/jo_libs/global-functions#jo-stopped)

## 🧷 Modules

* [Animation](https://docs.jumpon-studios.com/jo_libs/modules/animation/)
* [Blip](https://docs.jumpon-studios.com/jo_libs/modules/blip/)
* [Callback](https://docs.jumpon-studios.com/jo_libs/modules/callback/)
* [Component](https://docs.jumpon-studios.com/jo_libs/modules/component/)
* [Database](https://docs.jumpon-studios.com/jo_libs/modules/database/)
* [Dataview](https://docs.jumpon-studios.com/jo_libs/modules/dataview/)
* [Date](https://docs.jumpon-studios.com/jo_libs/modules/date/)
* [Debugger](https://docs.jumpon-studios.com/jo_libs/modules/debugger/)
* [Emit](https://docs.jumpon-studios.com/jo_libs/modules/emit/)
* [Entity](https://docs.jumpon-studios.com/jo_libs/modules/entity/)
* [File](https://docs.jumpon-studios.com/jo_libs/modules/file/)
* [Framework](https://docs.jumpon-studios.com/jo_libs/modules/framework-bridge/)
* [Events](https://docs.jumpon-studios.com/jo_libs/modules/game-events/)
* [Gizmo](https://docs.jumpon-studios.com/jo_libs/modules/gizmo/)
* [Hook](https://docs.jumpon-studios.com/jo_libs/modules/hook/)
* [Input](https://docs.jumpon-studios.com/jo_libs/modules/input/)
* [Light](https://docs.jumpon-studios.com/jo_libs/modules/light/)
* [Math](https://docs.jumpon-studios.com/jo_libs/modules/math/)
* [Menu](https://docs.jumpon-studios.com/jo_libs/modules/menu/)
* [Notification](https://docs.jumpon-studios.com/jo_libs/modules/notification/)
* [Nui](https://docs.jumpon-studios.com/jo_libs/modules/nui/)
* [Ped Texture](https://docs.jumpon-studios.com/jo_libs/modules/ped-texture/)
* [Player](https://docs.jumpon-studios.com/jo_libs/modules/player/)
* [Print](https://docs.jumpon-studios.com/jo_libs/modules/print/)
* [Promise](https://docs.jumpon-studios.com/jo_libs/modules/promise/)
* [Prompts](https://docs.jumpon-studios.com/jo_libs/modules/prompts/)
* [Prompts NUI](https://docs.jumpon-studios.com/jo_libs/modules/prompts/prompt-nui/)
* [Keys](https://docs.jumpon-studios.com/jo_libs/modules/raw-keys/)
* [Screen](https://docs.jumpon-studios.com/jo_libs/modules/screen/)
* [String](https://docs.jumpon-studios.com/jo_libs/modules/string/)
* [Table](https://docs.jumpon-studios.com/jo_libs/modules/table/)
* [Timeout](https://docs.jumpon-studios.com/jo_libs/modules/timeout/)
* [UI](https://docs.jumpon-studios.com/jo_libs/modules/ui/)
* [Utils](https://docs.jumpon-studios.com/jo_libs/modules/utils/)
* [Waiter](https://docs.jumpon-studios.com/jo_libs/modules/waiter/)

## ❔ Usage
1. To use libraries, add the initiator as a shared script inside of your **fxmanifest.lua** file.
```lua
shared_scripts {
  '@jo_libs/init.lua'
}
```
2. List modules you want use inside the **fxmanifest.lua** (in lowercase)
 ```lua
jo_libs {
  'print',
  'table',
}
```
3. You can now use the libraries inside of your resource with the jo global variable.

## 👥 Community

For help, discussion, support or any other conversations:
[Join the Jump On Studios Discord Server](https://discord.gg/invite/8rqVHnSb2K)

## ➕ Contributing

If you're interested in constributing to Jo Libraries, please open a [new PR](https://github.com/Jump-On-Studios/RedM-jo_libs/pulls).

## 🔗 Download

https://github.com/kaddarem-tebex/RedM-jo_libs/releases/latest
