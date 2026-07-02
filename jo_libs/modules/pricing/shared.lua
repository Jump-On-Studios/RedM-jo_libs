jo.createModule("pricing")
jo.require("table")

local currencyKeys = { "money", "gold", "rol" }

-- * ==========================================
-- * TYPES
-- * ==========================================

---@class MoneyCost
---@field money number

---@class GoldCost
---@field gold number

---@class RolCost
---@field rol number

---@class ItemCost
---@field item string
---@field quantity number
---@field keep boolean

---@alias Cost MoneyCost|GoldCost|RolCost|ItemCost
---@alias PriceInput PriceClass|Cost|Cost[]|number|table|nil
---@alias PriceGroupInput PriceGroupClass|PriceClass|PriceInput|PriceInput[]|table|nil

---@class PriceClass
---@field isProcessing boolean
---@field costs Cost[]
local PriceClass = {}
PriceClass.__index = PriceClass

---@class PriceGroupClass
---@field operator "or"|"and"
---@field prices PriceClass[]
local PriceGroupClass = {}
PriceGroupClass.__index = PriceGroupClass

-- * ==========================================
-- * LOCAL HELPERS
-- * ==========================================

-- ° Checks whether a value is already a PriceClass instance.
local function isPrice(value)
  return getmetatable(value) == PriceClass
end

-- ° Checks whether a value is already a PriceGroupClass instance.
local function isPriceGroup(value)
  return getmetatable(value) == PriceGroupClass
end

-- ° Checks whether a string is one of the supported currency cost keys.
local function isCurrencyKey(key)
  return table.find(currencyKeys, function(currencyKey)
    return currencyKey == key
  end) ~= false
end

-- ° Validates a public currency key argument and raises a clear API error.
local function assertCurrencyKey(key, level)
  if not isCurrencyKey(key) then
    error("Currency key must be money, gold or rol", level or 3)
  end
end

-- ° Validates public item lookup arguments where keep must be explicit.
local function assertItemLookup(item, keep, level)
  if type(item) ~= "string" then
    error("Item name must be a string", level or 3)
  end

  if type(keep) ~= "boolean" then
    error("Item keep must be a boolean", level or 3)
  end
end

-- ° Waits until a PriceClass is not currently mutating.
local function waitPriceReady(price)
  while price.isProcessing do Wait(0) end
end

-- ° Coerces any supported price input into a ready PriceClass without copying existing instances.
local function asPrice(data)
  local price = isPrice(data) and data or PriceClass.new(data)

  waitPriceReady(price)

  return price
end

-- ° Converts one atomic cost input into its canonical cost shape.
local function normalizeCost(data)
  if type(data) == "number" then
    return { money = data }
  end

  if type(data) ~= "table" then
    error(("Unsupported cost type: %s"):format(type(data)), 3)
  end

  local currencyKey
  local currencyValue

  -- Currencies are mutually exclusive inside one Cost.
  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if data[key] ~= nil then
      if currencyKey or data.item ~= nil then
        error("A Cost can contain only one type", 3)
      end
      if type(data[key]) ~= "number" then
        error(("Cost.%s must be a number"):format(key), 3)
      end
      currencyKey = key
      currencyValue = data[key]
    end
  end

  if currencyKey then
    return { [currencyKey] = currencyValue }
  end

  -- Item costs stay out of currencyKeys because they carry quantity and keep metadata.
  if data.item ~= nil then
    if type(data.item) ~= "string" then
      error("ItemCost.item must be a string", 3)
    end

    local quantity = data.quantity == nil and 1 or data.quantity
    if type(quantity) ~= "number" then
      error("ItemCost.quantity must be a number", 3)
    end

    return {
      item = data.item,
      quantity = quantity,
      keep = data.keep == true
    }
  end

  error("Unsupported cost shape", 3)
end

-- ° Appends one cost into a canonical costs array and merges compatible entries.
local function pushCost(costs, data)
  local cost = normalizeCost(data)

  -- Currency costs merge by currency type.
  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if cost[key] ~= nil then
      local found = table.find(costs, function(existing)
        return existing[key] ~= nil
      end)

      if found then
        found[key] = found[key] + cost[key]
      else
        costs[#costs + 1] = cost
      end
      return costs
    end
  end

  -- Item costs merge only when both item name and keep flag match.
  local found = table.find(costs, function(existing)
    return existing.item == cost.item and existing.keep == cost.keep
  end)

  if found then
    found.quantity = found.quantity + cost.quantity
  else
    costs[#costs + 1] = cost
  end

  return costs
end

-- ° Appends any supported price input into an existing canonical costs array.
local function appendPriceData(costs, data)
  if data == nil then return costs end

  if type(data) == "number" then
    pushCost(costs, data)
    return costs
  end

  -- Existing instances are copied cost-by-cost so constructors still create fresh instances.
  if isPrice(data) then
    waitPriceReady(data)
    for i = 1, #data.costs do
      pushCost(costs, data.costs[i])
    end
    return costs
  end

  if type(data) ~= "table" then
    error(("Unsupported price type: %s"):format(type(data)), 3)
  end

  -- Canonical tables can be passed directly as { costs = { ... } }.
  if data.costs ~= nil then
    local costsType = type(data.costs) == "table" and table.type(data.costs)
    if costsType ~= "array" and costsType ~= "empty" then
      error("Price.costs must be an array", 3)
    end
    for i = 1, #data.costs do
      pushCost(costs, data.costs[i])
    end
    return costs
  end

  local dataType = table.type(data)
  if dataType == "empty" then return costs end

  -- Arrays are treated as a list of price fragments.
  if dataType == "array" then
    for i = 1, #data do
      appendPriceData(costs, data[i])
    end
    return costs
  end

  if dataType ~= "hash" and dataType ~= "mixed" then
    error(("Unsupported table type: %s"):format(tostring(dataType)), 3)
  end

  local pushed = false

  -- Hash and mixed tables may contain direct cost fields.
  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if data[key] ~= nil then
      pushCost(costs, { [key] = data[key] })
      pushed = true
    end
  end

  if data.item ~= nil then
    pushCost(costs, {
      item = data.item,
      quantity = data.quantity,
      keep = data.keep
    })
    pushed = true
  end

  -- Mixed tables can combine direct fields with array fragments.
  if dataType == "mixed" then
    for i = 1, #data do
      appendPriceData(costs, data[i])
    end
  elseif not pushed then
    error("Unsupported price shape", 3)
  end

  return costs
end

-- ° Builds the canonical table used by PriceClass before the metatable is attached.
local function normalizePrice(data)
  local price = {
    isProcessing = false,
    costs = {}
  }

  appendPriceData(price.costs, data)
  return price
end

-- ° Appends any supported group input into an existing prices array.
local function appendGroupPrices(prices, data)
  if data == nil then return prices end

  if type(data) == "number" then
    prices[#prices + 1] = PriceClass.new(data)
    return prices
  end

  if isPrice(data) then
    prices[#prices + 1] = asPrice(data)
    return prices
  end

  if type(data) ~= "table" then
    error(("Unsupported price group type: %s"):format(type(data)), 3)
  end

  -- Canonical groups expose their choices through { prices = { ... } }.
  if data.prices ~= nil then
    local pricesType = type(data.prices) == "table" and table.type(data.prices)
    if pricesType ~= "array" and pricesType ~= "empty" then
      error("PriceGroupClass.prices must be an array", 3)
    end
    for i = 1, #data.prices do
      prices[#prices + 1] = asPrice(data.prices[i])
    end
    return prices
  end

  local dataType = table.type(data)
  if dataType == "empty" then return prices end

  -- Arrays represent separate alternative prices inside the group.
  if dataType == "array" then
    for i = 1, #data do
      prices[#prices + 1] = asPrice(data[i])
    end
    return prices
  end

  if dataType ~= "hash" and dataType ~= "mixed" then
    error(("Unsupported table type: %s"):format(tostring(dataType)), 3)
  end

  -- Flat group input is split into separate PriceClass entries by design.
  -- This keeps { money = 5, gold = 1 } as two choices for an "or" group.
  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if data[key] ~= nil then
      prices[#prices + 1] = PriceClass.new({ [key] = data[key] })
    end
  end

  if data.item ~= nil then
    prices[#prices + 1] = PriceClass.new({
      item = data.item,
      quantity = data.quantity,
      keep = data.keep
    })
  end

  -- Mixed tables append their array part after the direct flat entries.
  if dataType == "mixed" then
    for i = 1, #data do
      prices[#prices + 1] = asPrice(data[i])
    end
  end

  return prices
end

-- ° Builds the canonical table used by PriceGroupClass before the metatable is attached.
local function normalizeGroup(data)
  local group = {
    operator = "or",
    prices = {}
  }

  if data == nil then return group end

  -- Constructors always copy existing groups to avoid shared mutable prices arrays.
  if isPriceGroup(data) then
    group.operator = data.operator
    for i = 1, #data.prices do
      group.prices[#group.prices + 1] = PriceClass.new(data.prices[i])
    end
    return group
  end

  -- Only groups carry an operator; plain price inputs keep the default "or".
  if type(data) == "table" then
    group.operator = GetValue(data.operator, "or")
    if group.operator ~= "and" and group.operator ~= "or" then
      error('PriceGroupClass.operator must be "and" or "or"', 3)
    end
  end

  appendGroupPrices(group.prices, data)
  return group
end

-- ° Merges one or more canonical costs arrays into a new canonical costs array.
local function mergeCosts(...)
  local merged = {}
  local costLists = { ... }

  for listIndex = 1, #costLists do
    local costs = costLists[listIndex] or {}
    for i = 1, #costs do
      pushCost(merged, costs[i])
    end
  end

  return merged
end

-- ° Checks whether two canonical Cost entries represent the same value.
local function isSameCost(left, right)
  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if left[key] ~= nil or right[key] ~= nil then
      return left[key] ~= nil and left[key] == right[key]
    end
  end

  if left.item ~= nil or right.item ~= nil then
    return left.item == right.item
        and left.keep == right.keep
        and left.quantity == right.quantity
  end

  return false
end

-- ° Rounds item quantities to the nearest integer.
local function roundNearest(value)
  return value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
end

-- ° Multiplies a price without mutating the input.
local function multiplyPrice(data, multiplier, roundItemQuantity)
  if type(multiplier) ~= "number" then
    error("Price multiplier must be a number", 3)
  end

  local multipliedPrice = PriceClass.new(data)
  roundItemQuantity = roundItemQuantity or math.floor

  for i = 1, #multipliedPrice.costs do
    local cost = multipliedPrice.costs[i]

    for j = 1, #currencyKeys do
      local key = currencyKeys[j]
      if cost[key] ~= nil then
        cost[key] = cost[key] * multiplier
      end
    end

    if cost.item ~= nil then
      cost.quantity = roundItemQuantity((cost.quantity or 1) * multiplier)
    end
  end

  multipliedPrice.costs = mergeCosts(multipliedPrice.costs)
  return multipliedPrice
end

-- ° Subtracts a price from another price without mutating either operand.
local function subtractPrice(left, right)
  return left + multiplyPrice(right, -1)
end

-- * ==========================================
-- * PRICE CLASS
-- * ==========================================

--- Creates a canonical PriceClass.
---@autodoc:config ignore:true
---@param data? PriceInput
---@return PriceClass
function PriceClass.new(data)
  return setmetatable(normalizePrice(data), PriceClass)
end

--- Creates a new independent copy of the current PriceClass.
---@return PriceClass
function PriceClass:copy()
  return PriceClass.new(self)
end

--- Returns true when another price has the same costs.
---@param other PriceInput
---@return boolean
function PriceClass:equals(other)
  local success, otherPrice = pcall(asPrice, other)
  if not success then return false end

  return PriceClass.__eq(self, otherPrice)
end

--- Adds a price to the current PriceClass.
---@param price PriceInput
---@return PriceClass
function PriceClass:add(price)
  waitPriceReady(self)

  local normalizedPrice = asPrice(price)

  -- Keep isProcessing consistent even when merging raises an error.
  self.isProcessing = true
  local success, err = pcall(function()
    self.costs = mergeCosts(self.costs, normalizedPrice.costs)
  end)
  self.isProcessing = false

  if not success then
    error(err, 2)
  end

  return self
end

--- Returns the canonical costs list.
---@return Cost[]
function PriceClass:get()
  return self.costs
end

--- Removes every cost from the current PriceClass.
---@return PriceClass
function PriceClass:clear()
  waitPriceReady(self)

  self.costs = {}
  return self
end

--- Returns true when the PriceClass has no payable costs.
---@return boolean
function PriceClass:isFree()
  for i = 1, #self.costs do
    local cost = self.costs[i]
    if cost.money ~= nil and cost.money ~= 0 then return false end
    if cost.gold ~= nil and cost.gold ~= 0 then return false end
    if cost.rol ~= nil and cost.rol ~= 0 then return false end
    if cost.item ~= nil and cost.quantity ~= 0 then return false end
  end

  return true
end

--- Returns true when the PriceClass contains only currency costs.
---@return boolean
function PriceClass:isCurrencyOnly()
  if #self.costs == 0 then return false end

  for i = 1, #self.costs do
    if self.costs[i].item ~= nil then return false end
  end

  return true
end

--- Returns true when the PriceClass contains only item costs.
---@return boolean
function PriceClass:isItemOnly()
  if #self.costs == 0 then return false end

  for i = 1, #self.costs do
    if self.costs[i].item == nil then return false end
  end

  return true
end

--- Returns the money amount.
---@return number|nil
function PriceClass:getMoney()
  local cost = table.find(self.costs, function(cost)
    return cost.money ~= nil
  end)

  return cost and cost.money or nil
end

--- Returns the gold amount.
---@return number|nil
function PriceClass:getGold()
  local cost = table.find(self.costs, function(cost)
    return cost.gold ~= nil
  end)

  return cost and cost.gold or nil
end

--- Returns the rol amount.
---@return number|nil
function PriceClass:getRol()
  local cost = table.find(self.costs, function(cost)
    return cost.rol ~= nil
  end)

  return cost and cost.rol or nil
end

--- Returns true when a currency cost exists.
---@param key "money"|"gold"|"rol"
---@return boolean
function PriceClass:hasCurrency(key)
  assertCurrencyKey(key, 2)

  return table.find(self.costs, function(cost)
    return cost[key] ~= nil
  end) ~= false
end

--- Removes a currency cost from the current PriceClass.
---@param key "money"|"gold"|"rol"
---@return PriceClass
function PriceClass:removeCurrency(key)
  assertCurrencyKey(key, 2)

  waitPriceReady(self)

  for i = #self.costs, 1, -1 do
    if self.costs[i][key] ~= nil then
      table.remove(self.costs, i)
      break
    end
  end

  return self
end

--- Returns all ItemCost entries.
---@return ItemCost[]
function PriceClass:getItems()
  local items = {}

  for i = 1, #self.costs do
    if self.costs[i].item ~= nil then
      items[#items + 1] = self.costs[i]
    end
  end

  return items
end

--- Returns an ItemCost by item name and keep flag.
---@param item string
---@param keep boolean
---@return ItemCost|nil
function PriceClass:getItem(item, keep)
  assertItemLookup(item, keep, 2)

  return table.find(self.costs, function(cost)
    return cost.item == item and cost.keep == keep
  end) or nil
end

--- Returns true when an ItemCost exists for an item name and keep flag.
---@param item string
---@param keep boolean
---@return boolean
function PriceClass:hasItem(item, keep)
  return self:getItem(item, keep) ~= nil
end

--- Removes an ItemCost from the current PriceClass.
---@param item string
---@param keep boolean
---@return PriceClass
function PriceClass:removeItem(item, keep)
  assertItemLookup(item, keep, 2)

  waitPriceReady(self)

  for i = #self.costs, 1, -1 do
    local cost = self.costs[i]
    if cost.item == item and cost.keep == keep then
      table.remove(self.costs, i)
      break
    end
  end

  return self
end

--- Creates a new PriceClass from two prices.
---@autodoc:config ignore:true
---@param left PriceInput
---@param right PriceInput
---@return PriceClass
function PriceClass.__add(left, right)
  local leftPrice = asPrice(left)
  local rightPrice = asPrice(right)

  return PriceClass.new({
    costs = mergeCosts(leftPrice.costs, rightPrice.costs)
  })
end

--- Multiplies a PriceClass by a numeric multiplier.
---@autodoc:config ignore:true
---@param left PriceClass|number
---@param right PriceClass|number
---@return PriceClass
function PriceClass.__mul(left, right)
  local price
  local multiplier

  if isPrice(left) and type(right) == "number" then
    price = left
    multiplier = right
  elseif type(left) == "number" and isPrice(right) then
    price = right
    multiplier = left
  else
    error("PriceClass multiplication requires one PriceClass and one number", 2)
  end

  return multiplyPrice(price, multiplier, roundNearest)
end

--- Returns the number of canonical costs.
---@autodoc:config ignore:true
---@param price PriceClass
---@return number
function PriceClass.__len(price)
  waitPriceReady(price)

  return #price.costs
end

--- Compares two PriceClass instances by value.
---@autodoc:config ignore:true
---@param left PriceClass
---@param right PriceClass
---@return boolean
function PriceClass.__eq(left, right)
  if not isPrice(left) or not isPrice(right) then return false end

  waitPriceReady(left)
  waitPriceReady(right)

  if #left.costs ~= #right.costs then return false end

  for i = 1, #left.costs do
    local found = false

    for j = 1, #right.costs do
      if isSameCost(left.costs[i], right.costs[j]) then
        found = true
        break
      end
    end

    if not found then return false end
  end

  return true
end

-- * ==========================================
-- * PRICE GROUP CLASS
-- * ==========================================

--- Creates a canonical PriceGroupClass.
---@autodoc:config ignore:true
---@param data? PriceGroupInput
---@return PriceGroupClass
function PriceGroupClass.new(data)
  return setmetatable(normalizeGroup(data), PriceGroupClass)
end

--- Creates a new independent copy of the current PriceGroupClass.
---@return PriceGroupClass
function PriceGroupClass:copy()
  return PriceGroupClass.new(self)
end

--- Returns true when the group contains no prices.
---@return boolean
function PriceGroupClass:isEmpty()
  return #self.prices == 0
end

--- Removes every price from the group.
---@return PriceGroupClass
function PriceGroupClass:clear()
  self.prices = {}
  return self
end

--- Returns the number of prices in the group.
---@return number
function PriceGroupClass:count()
  return #self.prices
end

--- Returns the number of prices in the group.
---@autodoc:config ignore:true
---@param group PriceGroupClass
---@return number
function PriceGroupClass.__len(group)
  return #group.prices
end

--- Returns a PriceClass by index.
---@param index number
---@return PriceClass|nil
function PriceGroupClass:get(index)
  if type(index) ~= "number" then
    error("PriceGroupClass:get(index) requires a number index", 2)
  end

  return self.prices[index]
end

--- Replaces an existing PriceClass by index.
---@param index number
---@param price PriceInput
---@return PriceGroupClass
function PriceGroupClass:set(index, price)
  if type(index) ~= "number" then
    error("PriceGroupClass:set(index, price) requires a number index", 2)
  end

  if index < 1 or index > #self.prices then
    error("PriceGroupClass:set(index, price) index is out of bounds", 2)
  end

  self.prices[index] = asPrice(price)
  return self
end

--- Inserts a PriceClass into the group.
---@param price PriceInput
---@param index? number
---@return PriceGroupClass
function PriceGroupClass:insert(price, index)
  local normalizedPrice = asPrice(price)

  if index == nil then
    self.prices[#self.prices + 1] = normalizedPrice
    return self
  end

  table.insert(self.prices, index, normalizedPrice)
  return self
end

--- Removes a PriceClass from the group by index.
---@param index number
---@return PriceClass|nil
function PriceGroupClass:remove(index)
  if type(index) ~= "number" then
    error("PriceGroupClass:remove(index) requires a number index", 2)
  end

  return table.remove(self.prices, index)
end

--- Compacts an "and" PriceGroupClass into a new PriceClass.
---@return PriceClass
function PriceGroupClass:compact()
  if self.operator ~= "and" then
    error('PriceGroupClass:compact() is only allowed with operator = "and"', 2)
  end

  local price = PriceClass.new()
  for i = 1, #self.prices do
    price:add(self.prices[i])
  end

  return price
end

-- * ==========================================
-- * PUBLIC API
-- * ==========================================

--- Creates a canonical PriceClass.
---@param data? PriceInput
---@return PriceClass
function jo.pricing.new(data)
  return PriceClass.new(data)
end

--- Creates a canonical PriceGroupClass.
---@param data? PriceGroupInput
---@return PriceGroupClass
function jo.pricing.newGroup(data)
  return PriceGroupClass.new(data)
end

--- Converts a price input into a canonical costs list.
---@param price PriceInput
---@return Cost[]
function jo.pricing.get(price)
  return PriceClass.new(price):get()
end

--- Splits a price into tax and remaining prices.
---@param price PriceInput
---@param percentage? number
---@param roundUpItems? boolean
---@return  PriceClass,PriceClass
function jo.pricing.tax(price, percentage, roundUpItems)
  percentage = percentage or 0

  local basePrice = PriceClass.new(price)
  local roundItemQuantity = roundUpItems and math.ceil or math.floor
  local taxPrice = multiplyPrice(basePrice, percentage, roundItemQuantity)
  local remainingPrice = subtractPrice(basePrice, taxPrice)

  return taxPrice, remainingPrice
end

--- Returns true when a value is a PriceClass instance.
---@param value any
---@return boolean
function jo.pricing.isPrice(value)
  return isPrice(value)
end

--- Returns true when a value is a PriceGroupClass instance.
---@param value any
---@return boolean
function jo.pricing.isPriceGroup(value)
  return isPriceGroup(value)
end
