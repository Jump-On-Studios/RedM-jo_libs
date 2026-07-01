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

-- ° Coerces any supported price input into a ready PriceClass without copying existing instances.
local function asPrice(data)
  local price = isPrice(data) and data or PriceClass.new(data)

  while price.isProcessing do Wait(0) end

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
    while data.isProcessing do Wait(0) end
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

-- * ==========================================
-- * PRICE CLASS
-- * ==========================================

--- Creates a canonical PriceClass.
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

--- Adds a price to the current PriceClass.
---@param price PriceInput
---@return PriceClass
function PriceClass:add(price)
  while self.isProcessing do Wait(0) end

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

--- Returns true when the PriceClass has no costs.
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

--- Returns the MoneyCost.
---@return MoneyCost|nil
function PriceClass:getMoney()
  return table.find(self.costs, function(cost)
    return cost.money ~= nil
  end) or nil
end

--- Returns the GoldCost.
---@return GoldCost|nil
function PriceClass:getGold()
  return table.find(self.costs, function(cost)
    return cost.gold ~= nil
  end) or nil
end

--- Returns the RolCost.
---@return RolCost|nil
function PriceClass:getRol()
  return table.find(self.costs, function(cost)
    return cost.rol ~= nil
  end) or nil
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

--- Creates a new PriceClass from two prices.
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

-- * ==========================================
-- * PRICE GROUP CLASS
-- * ==========================================

--- Creates a canonical PriceGroupClass.
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

jo.pricing.PriceClass = PriceClass
jo.pricing.PriceGroupClass = PriceGroupClass
jo.pricing.new = PriceClass.new
jo.pricing.newGroup = PriceGroupClass.new
