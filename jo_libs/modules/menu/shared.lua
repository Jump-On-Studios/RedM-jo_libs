jo.createModule("menu")
jo.require("pricing")

jo.menu.formatPrice = jo.pricing.formatPrice
jo.menu.formatPrices = jo.pricing.formatPrices
jo.menu.isPriceFree = jo.pricing.isPriceFree
jo.menu.mergePrices = jo.pricing.mergePrices
