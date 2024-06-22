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

* Animation
* Blip
* Callback
* Clothes
* Database
* Dataview
* Entity
* Framework bridge
* Hook
* Me
* Menu
* Notification
* Ped texture
* Print
* Prompt
* String
* Table
* Timeout
* UI
* Utils

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

If you're interested in constributing to Jo Libraries, please open a PR.

## 🔗 Download

https://github.com/kaddarem-tebex/RedM-jo_libs/releases/latest
