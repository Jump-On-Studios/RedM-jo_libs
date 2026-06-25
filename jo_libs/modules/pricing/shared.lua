jo.createModule("pricing")
jo.require("table")

local currencyKeys = { "money", "gold", "rol" }

local validPriceKeys = {
  item = true,
}
for i = 1, #currencyKeys do
  validPriceKeys[currencyKeys[i]] = true
end

--- Helper function to normalize a single entry
---@param entry any
---@return table
local function normalizeEntry(entry)
  if type(entry) ~= "table" then
    return { money = entry }
  end

  if entry.item then
    jo.require("framework", true)
    return table.merge({
      item = entry.item,
      quantity = entry.quantity or 1,
      keep = entry.keep or false,
      meta = entry.meta
    }, entry, jo.framework:getItemData(entry.item))
  end

  return entry
end

local function addNormalizedEntry(entries, size, entry)
  entries[size] = normalizeEntry(entry)
  return size + 1
end

local function getItemMergeKey(item)
  return item.item .. ":" .. tostring(item.keep)
end

local function isSameItemMeta(a, b)
  return table.isEgal(GetValue(a.meta, {}), GetValue(b.meta, {}))
end

local function getSingleCurrencyKey(entry)
  if table.count(entry) ~= 1 then return false end

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if entry[key] then return key end
  end

  return false
end

local function sanitizePrice(price)
  local sanitized = {}
  local size = 1
  local currencyTotals = {
    money = 0,
    gold = 0,
    rol = 0,
  }
  local items = {}

  for i = 1, #price do
    local item = price[i]
    local currencyKey = getSingleCurrencyKey(item)

    if currencyKey then
      currencyTotals[currencyKey] += item[currencyKey]
    elseif item.item then
      local key = getItemMergeKey(item)
      if not items[key] then
        items[key] = {}
      end

      local found = false
      for y = 1, #items[key] do
        if isSameItemMeta(items[key][y], item) then
          items[key][y].quantity += item.quantity
          found = true
        end
      end

      if not found then
        sanitized[size] = item
        items[key][#items[key] + 1] = sanitized[size]
        size += 1
      end
    else
      sanitized[size] = item
      size += 1
    end
  end

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if currencyTotals[key] > 0 then
      sanitized[size] = { [key] = currencyTotals[key] }
      size += 1
    end
  end

  if #sanitized == 0 then
    sanitized = { { money = 0 } }
  end

  return sanitized
end

--- A function to format a single price
---@param price table|integer|number (The price to format)
---@return table (The formatted price)
function jo.pricing.formatPrice(price)
  if not price then return { { money = 0 } } end
  if type(price) ~= "table" then return { { money = price } } end

  local result = {}
  local size = 1

  for key, value in pairs(price) do
    if type(key) == "string" and tonumber(key) == nil then
      size = addNormalizedEntry(result, size, { [key] = value })
    elseif type(value) == "table" then
      if value.item then
        size = addNormalizedEntry(result, size, value)
      else
        local extra = {}
        local start = size
        for k, v in pairs(value) do
          if type(k) == "string" then
            if validPriceKeys[k] then
              size = addNormalizedEntry(result, size, { [k] = v })
            else
              extra[k] = v
            end
          else
            size = addNormalizedEntry(result, size, v)
          end
        end
        for i = start, size - 1 do
          result[i] = table.merge(result[i], extra)
        end
      end
    else
      size = addNormalizedEntry(result, size, value)
    end
  end

  return result
end

--- A function to format price variations
---@param prices table|integer|number (The prices to format)
---@return table (The formatted prices)
function jo.pricing.formatPrices(prices)
  if not prices then return { { { money = 0 } } } end
  if type(prices) ~= "table" then return { { { money = prices } } } end

  local operator = prices.operator or "or"
  local formattedPrices = {}
  local size = 1

  -- Process each price entry
  for key, price in pairs(prices) do
    if key ~= "operator" then
      if type(key) == "string" then
        formattedPrices[size] = jo.pricing.formatPrice({ [key] = price })
        size += 1
      elseif type(price) ~= "table" then
        formattedPrices[size] = { { money = price } }
        size += 1
      else
        formattedPrices[size] = jo.pricing.formatPrice(price)
        size += 1
      end
    end
  end

  -- Merge all prices if operator is "and"
  if operator == "and" and #formattedPrices > 1 then
    local merged = formattedPrices[1]
    for i = 2, #formattedPrices do
      table.mergeAfter(merged, formattedPrices[i])
    end
    formattedPrices = { merged }
  end

  -- Sanitize prices (combine same currency types) in a single pass
  for i = 1, #formattedPrices do
    formattedPrices[i] = sanitizePrice(formattedPrices[i])
  end

  return formattedPrices
end

--- Checks if a price is free
---@param price table|integer|number (The price to check)
---@return boolean (Return `true` if the price is free)
function jo.pricing.isPriceFree(price)
  return type(price) == "table" and #price == 1 and (price[1]?.money == 0 or price[1][1]?.money == 0)
end

--- Merge prices
---@param ... table (The prices to merge)
---@return table (The merged prices)
function jo.pricing.mergePrices(...)
  local prices = { ... }
  prices = table.copy(prices)
  prices.operator = "and"
  return jo.pricing.formatPrices(prices)[1]
end

--- Gets the tax price from a price and a percentage
---@param price table|integer|number (The price to tax)
---@param percentage number (The percentage to apply. Example: `0.2` returns 20% of the price)
---@param roundUpItems? boolean (Whether item quantities should be rounded up. Defaults to `false`)
---@return table (The taxed price)
function jo.pricing.tax(price, percentage, roundUpItems)
  percentage = percentage or 0

  local formattedPrice = jo.pricing.formatPrice(price)
  local taxedPrice = {}
  local roundItemQuantity = roundUpItems and math.ceil or math.floor

  for i = 1, #formattedPrice do
    local entry = table.copy(formattedPrice[i])

    for j = 1, #currencyKeys do
      local key = currencyKeys[j]
      if entry[key] then
        entry[key] *= percentage
      end
    end
    if entry.item then
      entry.quantity = roundItemQuantity((entry.quantity or 1) * percentage)
    end

    taxedPrice[i] = entry
  end

  return taxedPrice
end
