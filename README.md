<p align="center">
  <a href="https://docs.jumpon-studios.com/jo_libs/">
    <img alt="Jo Libraries for RedM" src="https://shop.jumpon-studios.com/images/thumbnails/jo-libraries.webp"/>
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

## 🧷 Modules

* [Animation](https://docs.jumpon-studios.com/jo_libs/modules/animation/)
* [Blip](https://docs.jumpon-studios.com/jo_libs/modules/blip/)
* [Callback](https://docs.jumpon-studios.com/jo_libs/modules/callback/)
* Clothes
* [Database](https://docs.jumpon-studios.com/jo_libs/modules/database/)
* [Dataview](https://docs.jumpon-studios.com/jo_libs/modules/dataview/)
* [Entity](https://docs.jumpon-studios.com/jo_libs/modules/entity/)
* [Framework bridge](https://docs.jumpon-studios.com/jo_libs/modules/framework-bridge/)
* [Hook](https://docs.jumpon-studios.com/jo_libs/modules/hook/)
* [Me](https://docs.jumpon-studios.com/jo_libs/modules/me/)
* [Menu](https://docs.jumpon-studios.com/jo_libs/modules/menu/)
* [Notification](https://docs.jumpon-studios.com/jo_libs/modules/notification/)
* Ped texture
* Print
* [Prompt](https://docs.jumpon-studios.com/jo_libs/modules/prompt/)
* String
* [Table](https://docs.jumpon-studios.com/jo_libs/modules/table/)
* Timeout
* UI
* [Utils](https://docs.jumpon-studios.com/jo_libs/modules/utils/)

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
[Join the Jump On Studios Discord Server](https://discord.gg/7xy7WEABTC)

## ➕ Contributing

If you're interested in constributing to Jo Libraries, please open a [new PR](https://github.com/Jump-On-Studios/RedM-jo_libs/pulls).

## 🔗 Download

https://github.com/kaddarem-tebex/RedM-jo_libs/releases/latest
