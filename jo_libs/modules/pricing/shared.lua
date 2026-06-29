jo.createModule("pricing")
jo.require("table")

-- * ==========================================
-- * INTERNAL CONFIGURATION
-- * ==========================================

local currencyKeys = { "money", "gold", "rol" }

---@class Price : table
local PriceClass = {}

---@class Prices : table
---@field operator "or"|"and"
local PricesClass = {}
local pricesOperators = setmetatable({}, { __mode = "k" })

PriceClass.__index = PriceClass
PricesClass.__index = function(self, key)
  if key == "operator" then return pricesOperators[self] end
  return PricesClass[key]
end

local validPriceKeys = {
  item = true,
}
for i = 1, #currencyKeys do
  validPriceKeys[currencyKeys[i]] = true
end

-- * ==========================================
-- * LOCAL HELPERS
-- * ==========================================

--- Checks whether a value is a Price object.
local function isPrice(price)
  return getmetatable(price) == PriceClass
end

--- Checks whether a value is a Prices object.
local function isPrices(prices)
  return getmetatable(prices) == PricesClass
end

--- Deep-copies a value without preserving object metatables.
local function copyWithoutMetatable(value)
  if type(value) ~= "table" then return value end

  local copy = {}
  for k, v in pairs(value) do
    copy[k] = copyWithoutMetatable(v)
  end
  return copy
end

--- Replaces a table content while keeping the same table reference.
local function replaceTable(target, source)
  for key in pairs(target) do
    target[key] = nil
  end
  for key, value in pairs(source) do
    target[key] = value
  end
  return target
end

--- Normalizes a single price entry to the shared price shape.
---@param entry any
---@return table
local function normalizeEntry(entry)
  if type(entry) ~= "table" then
    return { money = entry }
  end

  if entry.item then
    jo.require("framework", true)
    local itemData = jo.framework:getItemData(entry.item) or {}
    return table.merge({
      item = entry.item,
      quantity = entry.quantity or 1,
      keep = entry.keep or false,
      meta = entry.meta
    }, table.copy(entry), itemData)
  end

  return table.copy(entry)
end

--- Appends a normalized entry and returns the next array index.
local function addNormalizedEntry(entries, size, entry)
  entries[size] = normalizeEntry(entry)
  return size + 1
end

--- Builds the item grouping key used for merging item entries.
local function getItemMergeKey(item)
  return item.item .. ":" .. tostring(item.keep)
end

--- Compares item metadata while treating nil meta as an empty table.
local function isSameItemMeta(a, b)
  return table.isEgal(GetValue(a.meta, {}), GetValue(b.meta, {}))
end

--- Returns the currency key when the entry contains only one currency.
local function getSingleCurrencyKey(entry)
  if table.count(entry) ~= 1 then return false end

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if entry[key] then return key end
  end

  return false
end

--- Merges duplicate currencies and compatible item entries.
local function sanitizePrice(price, removeEmptyItems)
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
      if not (removeEmptyItems and (item.quantity or 1) <= 0) then
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
      end
    else
      sanitized[size] = item
      size += 1
    end
  end

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if currencyTotals[key] ~= 0 then
      sanitized[size] = { [key] = currencyTotals[key] }
      size += 1
    end
  end

  if #sanitized == 0 then
    sanitized = { { money = 0 } }
  end

  return sanitized
end

--- Sanitizes a Price object in place without replacing its reference.
local function normalizePriceInPlace(price, removeEmptyItems)
  return replaceTable(price, sanitizePrice(price, removeEmptyItems))
end

--- Attaches the Price methods to a price table.
local function setPriceMetatable(price)
  return setmetatable(price, PriceClass)
end

--- Attaches the Prices methods and stores its operator off-table.
local function setPricesMetatable(prices, operator)
  operator = operator == "and" and "and" or "or"
  prices.operator = nil
  pricesOperators[prices] = operator
  return setmetatable(prices, PricesClass)
end

--- Computes currency totals for strict removal checks.
local function getCurrencyTotals(price)
  local totals = {}
  for i = 1, #currencyKeys do
    totals[currencyKeys[i]] = 0
  end

  for i = 1, #price do
    local entry = price[i]
    for j = 1, #currencyKeys do
      local key = currencyKeys[j]
      if entry[key] then
        totals[key] += entry[key]
      end
    end
  end

  return totals
end

--- Computes the available quantity for an item entry.
local function getItemQuantity(price, item)
  local quantity = 0
  local key = getItemMergeKey(item)

  for i = 1, #price do
    local entry = price[i]
    if entry.item and getItemMergeKey(entry) == key and isSameItemMeta(entry, item) then
      quantity += entry.quantity or 1
    end
  end

  return quantity
end

--- Validates whether a price can be fully removed without mutation.
local function canRemovePrice(price, priceToRemove)
  local currencyTotals = getCurrencyTotals(price)

  for i = 1, #priceToRemove do
    local entry = priceToRemove[i]
    local currencyKey = getSingleCurrencyKey(entry)

    if currencyKey then
      if entry[currencyKey] < 0 then
        return false, "invalid_negative_price"
      end
      if currencyTotals[currencyKey] < entry[currencyKey] then
        return false, ("not_enough_%s"):format(currencyKey)
      end
      currencyTotals[currencyKey] -= entry[currencyKey]
    elseif entry.item then
      local quantity = entry.quantity or 1
      if quantity < 0 then
        return false, "invalid_negative_item_quantity"
      end
      if getItemQuantity(price, entry) < quantity then
        return false, ("not_enough_item:%s"):format(entry.item)
      end
    else
      return false, "unsupported_price_entry"
    end
  end

  return true
end

--- Removes a currency amount from matching currency entries.
local function removeCurrency(price, key, amount)
  local remaining = amount

  for i = 1, #price do
    local entry = price[i]
    if entry[key] then
      local removed = math.min(entry[key], remaining)
      entry[key] -= removed
      remaining -= removed
      if remaining <= 0 then return end
    end
  end
end

--- Removes an item quantity from matching item entries.
local function removeItem(price, item)
  local remaining = item.quantity or 1
  local key = getItemMergeKey(item)

  for i = 1, #price do
    local entry = price[i]
    if entry.item and getItemMergeKey(entry) == key and isSameItemMeta(entry, item) then
      local removed = math.min(entry.quantity or 1, remaining)
      entry.quantity = (entry.quantity or 1) - removed
      remaining -= removed
      if remaining <= 0 then return end
    end
  end
end

-- * ==========================================
-- * OBJECT METHODS
-- * ==========================================

--- Adds a price to the current price.
---@param price table|integer|number (The price to add)
---@return Price (The mutated price)
function PriceClass:add(price)
  local formattedPrice = jo.pricing.formatPrice(price)

  for i = 1, #formattedPrice do
    self[#self + 1] = table.copy(formattedPrice[i])
  end

  return normalizePriceInPlace(self)
end

--- Removes a price from the current price.
---@param price table|integer|number (The price to remove)
---@return Price|boolean,string? (The mutated price, or false and the reason)
function PriceClass:remove(price)
  local formattedPrice = jo.pricing.formatPrice(price)
  local canRemove, reason = canRemovePrice(self, formattedPrice)

  if not canRemove then
    return false, reason
  end

  for i = 1, #formattedPrice do
    local entry = formattedPrice[i]
    local currencyKey = getSingleCurrencyKey(entry)

    if currencyKey then
      removeCurrency(self, currencyKey, entry[currencyKey])
    elseif entry.item then
      removeItem(self, entry)
    end
  end

  return normalizePriceInPlace(self, true)
end

--- Applies a percentage to the current price.
---@param percentage number (The percentage to apply)
---@param roundUpItems? boolean (Whether item quantities should be rounded up)
---@return Price (The mutated price)
function PriceClass:tax(percentage, roundUpItems)
  percentage = percentage or 0

  local roundItemQuantity = roundUpItems and math.ceil or math.floor

  for i = 1, #self do
    local entry = self[i]

    for j = 1, #currencyKeys do
      local key = currencyKeys[j]
      if entry[key] then
        entry[key] *= percentage
      end
    end
    if entry.item then
      entry.quantity = roundItemQuantity((entry.quantity or 1) * percentage)
    end
  end

  return normalizePriceInPlace(self)
end

--- Checks if the price is free.
---@return boolean (Return `true` if the price is free)
function PriceClass:isFree()
  return #self == 1 and self[1].money == 0
end

--- Copies the price.
---@return Price (The copied price)
function PriceClass:copy()
  return setPriceMetatable(copyWithoutMetatable(self))
end

--- Converts the price to a plain table.
---@return table (The plain table)
function PriceClass:toTable()
  return copyWithoutMetatable(self)
end

--- Adds a price option to the prices set.
---@param price table|integer|number (The price to add)
---@return Prices (The mutated prices set)
function PricesClass:addPrice(price)
  local formattedPrice = jo.pricing.formatPrice(price)

  if self.operator == "and" and #self > 0 then
    self[1]:add(formattedPrice)
  else
    self[#self + 1] = formattedPrice
  end

  return self
end

--- Removes a price option from the prices set.
---@param index integer (The price option index)
---@return Prices (The mutated prices set)
function PricesClass:removePrice(index)
  table.remove(self, index)
  return self
end

--- Copies the prices set.
---@return Prices (The copied prices set)
function PricesClass:copy()
  local copy = {}

  for i = 1, #self do
    copy[i] = self[i]:copy()
  end

  return setPricesMetatable(copy, self.operator)
end

--- Converts the prices set to a plain table.
---@return table (The plain table)
function PricesClass:toTable()
  local plain = { operator = self.operator }

  for i = 1, #self do
    plain[i] = self[i]:toTable()
  end

  return plain
end

-- * ==========================================
-- * PUBLIC API
-- * ==========================================

--- A function to format a single price
---@param price table|integer|number (The price to format)
---@return Price (The formatted price)
function jo.pricing.formatPrice(price)
  if not price then return setPriceMetatable({ { money = 0 } }) end
  if type(price) ~= "table" then return setPriceMetatable({ { money = price } }) end
  if isPrice(price) then return price:copy() end
  if price.item then return setPriceMetatable({ normalizeEntry(price) }) end

  local result = {}
  local size = 1

  for key, value in pairs(price) do
    if key ~= "operator" then
      if type(key) == "string" and tonumber(key) == nil then
        size = addNormalizedEntry(result, size, { [key] = value })
      elseif type(value) == "table" then
        if value.item then
          size = addNormalizedEntry(result, size, value)
        else
          local extra = {}
          local start = size
          for k, v in pairs(value) do
            if k == "operator" then
              -- Nested operators are ignored: only root `operator = "or"` creates alternatives.
            elseif type(k) == "string" then
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
  end

  return setPriceMetatable(result)
end

--- A function to format price variations.
--- Only a root `operator = "or"` creates alternatives; every other shape is a single AND price.
---@param prices table|integer|number (The prices to format)
---@return Prices (The formatted prices)
function jo.pricing.formatPrices(prices)
  if not prices then return setPricesMetatable({ jo.pricing.formatPrice(0) }, "and") end
  if type(prices) ~= "table" then return setPricesMetatable({ jo.pricing.formatPrice(prices) }, "and") end
  if isPrices(prices) then return prices:copy() end
  if isPrice(prices) or prices.item then
    return setPricesMetatable({ jo.pricing.formatPrice(prices) }, "and")
  end

  if prices.operator == "or" then
    local formattedPrices = {}
    local size = 1

    for i = 1, #prices do
      formattedPrices[size] = jo.pricing.formatPrice(prices[i])
      normalizePriceInPlace(formattedPrices[size])
      size += 1
    end

    for key, price in pairs(prices) do
      if key ~= "operator" and type(key) == "string" and tonumber(key) == nil then
        formattedPrices[size] = jo.pricing.formatPrice({ [key] = price })
        normalizePriceInPlace(formattedPrices[size])
        size += 1
      end
    end

    if #formattedPrices == 0 then
      formattedPrices[1] = jo.pricing.formatPrice(0)
    end

    return setPricesMetatable(formattedPrices, "or")
  end

  local price = jo.pricing.formatPrice(prices)
  normalizePriceInPlace(price)

  return setPricesMetatable({ price }, "and")
end

--- Checks if a price is free
---@param price table|integer|number (The price to check)
---@return boolean (Return `true` if the price is free)
function jo.pricing.isPriceFree(price)
  if isPrices(price) then
    return #price == 1 and price[1]:isFree()
  end
  if type(price) == "table" and price[1] and type(price[1]) == "table" and price[1][1] then
    local prices = jo.pricing.formatPrices(price)
    return #prices == 1 and prices[1]:isFree()
  end
  return jo.pricing.formatPrice(price):isFree()
end

--- Merge prices
---@param ... table (The prices to merge)
---@return Price (The merged prices)
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
---@return Price (The taxed price)
function jo.pricing.tax(price, percentage, roundUpItems)
  return jo.pricing.formatPrice(price):tax(percentage, roundUpItems)
end
