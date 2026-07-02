jo.createModule("menu")
jo.require("pricing")

local PriceClass = jo.pricing.PriceClass
local PriceGroupClass = jo.pricing.PriceGroupClass

---@ignore
function jo.menu.formatPrice(price)
  if price == nil then price = 0 end

  return PriceClass.new(price):get()
end

---@ignore
function jo.menu.formatPrices(prices)
  if prices == nil then
    return {
      operator = "and",
      jo.menu.formatPrice(0)
    }
  end

  if type(prices) ~= "table" then
    return {
      operator = "and",
      jo.menu.formatPrice(prices)
    }
  end

  if getmetatable(prices) == PriceGroupClass or prices.operator == "or" then
    local group = PriceGroupClass.new(prices)
    local formattedPrices = {
      operator = group.operator
    }

    for i = 1, #group.prices do
      formattedPrices[i] = group.prices[i]:get()
    end

    return formattedPrices
  end

  return {
    operator = "and",
    jo.menu.formatPrice(prices)
  }
end

---@ignore
function jo.menu.isPriceFree(price)
  local prices = jo.menu.formatPrices(price)

  return #prices == 1 and PriceClass.new({
    costs = prices[1]
  }):isFree()
end

---@ignore
function jo.menu.mergePrices(...)
  local prices = { ... }
  prices.operator = "and"

  return PriceGroupClass.new(prices):compact():get()
end

---@ignore
function jo.menu.tax(price, percentage, roundUpItems)
  return PriceClass.new(price):tax(percentage, roundUpItems):get()
end
