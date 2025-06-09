jo.menu = {}

--- A function to format the prices variations
---@param price table (The price to format)
---@return table (The formatted price)
function jo.menu.formatPricesVariations(price)
  if type(price) ~= "table" then return { { { money = price } } } end
  if table.type(price) == "hash" then
    local prices = {}
    if price.money then
      table.insert(prices, { { money = price.money } })
    end
    if price.gold then
      table.insert(prices, { { gold = price.gold } })
    end
    if price.item then
      table.insert(prices, { { item = price.item, quantity = price.quantity or 1, keep = price.keep or false } })
    end
    return prices
  end
  return price
end
