jo.createModule("menu")
jo.require("pricing")

---@ignore
jo.menu.formatPrice = jo.pricing.formatPrice
---@ignore
jo.menu.formatPrices = jo.pricing.formatPrices
---@ignore
jo.menu.isPriceFree = jo.pricing.isPriceFree
---@ignore
jo.menu.mergePrices = jo.pricing.mergePrices
---@ignore
jo.menu.tax = jo.pricing.tax
