jo.createModule("menu")
jo.require("pricing")
jo.require("framework")

---@ignore
function jo.menu.formatPrice(price)
  if price == nil then price = 0 end

  return jo.framework:addItemDataToPrice(jo.pricing.new(price):get())
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

  if jo.pricing.isPriceGroup(prices) or prices.prices ~= nil or prices.operator ~= nil then
    local group = jo.pricing.newGroup(prices)
    local formattedPrices = {
      operator = group.operator
    }

    for i = 1, #group.prices do
      formattedPrices[i] = group.prices[i]:get()
    end

    return jo.framework:addItemDataToPrice(formattedPrices)
  end

  return {
    operator = "and",
    jo.menu.formatPrice(prices)
  }
end

---@ignore
function jo.menu.isPriceFree(price)
  local prices = jo.menu.formatPrices(price)

  return #prices == 1 and jo.pricing.new({
    costs = prices[1]
  }):isFree()
end

---@ignore
function jo.menu.mergePrices(...)
  local prices = { ... }
  prices.operator = "and"

  return jo.pricing.newGroup(prices):compact():get()
end

---@ignore
function jo.menu.tax(price, percentage, roundUpItems)
  return jo.pricing.new(price):tax(percentage, roundUpItems):get()
end
