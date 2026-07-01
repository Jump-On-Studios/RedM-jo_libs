jo.createModule("pricing")
jo.require("table")

-- todo add "item" in currencyKeys
local currencyKeys = { "money", "gold", "rol" }

local PriceClass = {}
PriceClass.__index = PriceClass

local PriceGroupClass = {}
PriceGroupClass.__index = PriceGroupClass


local function isPrice(value)
  return getmetatable(value) == PriceClass
end

local function isPriceGroup(value)
  return getmetatable(value) == PriceGroupClass
end

-- todo replace with table.Copy
local function copyPlain(value)
  if type(value) ~= "table" then return value end

  local copy = {}
  for key, entry in pairs(value) do
    copy[key] = copyPlain(entry)
  end

  return copy
end

-- todo  remove unused
local function getArrayLikeEntries(value)
  local entries = {}
  local indexes = {}
  local hasNumericKey = {}

  if type(value) ~= "table" then return indexes, entries end

  for key, entry in pairs(value) do
    local index
    if type(key) == "number" then
      index = key
    elseif type(key) == "string" then
      index = tonumber(key)
    end

    if index and index >= 1 and index == math.floor(index) then
      if type(key) == "number" then
        entries[index] = entry
        hasNumericKey[index] = true
      elseif not hasNumericKey[index] and entries[index] == nil then
        entries[index] = entry
      end
    end
  end

  for index in pairs(entries) do
    indexes[#indexes + 1] = index
  end

  table.sort(indexes)
  return indexes, entries
end

local function waitForPrice(price)
  while price.isProcessing do Wait(0) end
end

local function normalizeKeep(value)
  return value == true
end

local function normalizeQuantity(value)
  if value == nil then return 1 end
  if type(value) ~= "number" then
    error("ItemCost.quantity must be a number", 3)
  end
  return value
end

local function appendCurrencyCost(costs, key, amount)
  if amount == nil then return end
  if type(amount) ~= "number" then
    error(("Cost.%s must be a number"):format(key), 3)
  end
  costs[#costs + 1] = { [key] = amount }
end

local function appendItemCost(costs, entry)
  if entry.item == nil then return end
  if type(entry.item) ~= "string" then
    error("ItemCost.item must be a string", 3)
  end

  costs[#costs + 1] = {
    item = entry.item,
    quantity = normalizeQuantity(entry.quantity),
    keep = normalizeKeep(entry.keep)
  }
end


-- todo refactor this using table.type
local function appendCostFromScalarOrTable(costs, value)
  if value == nil then return end

  if type(value) == "number" then
    costs[#costs + 1] = { money = value }
    return
  end

  if type(value) ~= "table" then
    error(("Unsupported price entry type: %s"):format(type(value)), 3)
  end

  if isPrice(value) then
    waitForPrice(value)
    for i = 1, #value.costs do
      costs[#costs + 1] = copyPlain(value.costs[i])
    end
    return
  end

  if value.costs then
    local indexes, entries = getArrayLikeEntries(value.costs)
    for i = 1, #indexes do
      appendCostFromScalarOrTable(costs, entries[indexes[i]])
    end
    return
  end

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    appendCurrencyCost(costs, key, value[key])
  end

  appendItemCost(costs, value)

  local indexes, entries = getArrayLikeEntries(value)
  for i = 1, #indexes do
    appendCostFromScalarOrTable(costs, entries[indexes[i]])
  end
end

local function getCurrencyKey(cost)
  local found

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if cost[key] ~= nil then
      if found then
        error("A Cost can contain only one currency type", 3)
      end
      found = key
    end
  end

  return found
end

local function normalizeCost(cost)
  if type(cost) == "number" then
    return { money = cost }
  end

  if type(cost) ~= "table" then
    error(("Unsupported cost type: %s"):format(type(cost)), 3)
  end

  local currencyKey = getCurrencyKey(cost)
  local hasItem = cost.item ~= nil

  if currencyKey and hasItem then
    error("A Cost can contain only one type", 3)
  end

  if currencyKey then
    if type(cost[currencyKey]) ~= "number" then
      error(("Cost.%s must be a number"):format(currencyKey), 3)
    end
    return { [currencyKey] = cost[currencyKey] }
  end

  if hasItem then
    if type(cost.item) ~= "string" then
      error("ItemCost.item must be a string", 3)
    end
    return {
      item = cost.item,
      quantity = normalizeQuantity(cost.quantity),
      keep = normalizeKeep(cost.keep)
    }
  end

  error("Unsupported cost shape", 3)
end

local function getItemMergeKey(cost)
  return ("%s:%s"):format(cost.item, tostring(cost.keep))
end

local function mergeCosts(...)
  local inputs = { ... }
  local merged = {}
  local currencyIndexes = {}
  local itemIndexes = {}

  for inputIndex = 1, #inputs do
    local costs = inputs[inputIndex] or {}

    for i = 1, #costs do
      local cost = normalizeCost(costs[i])
      local currencyKey = getCurrencyKey(cost)

      if currencyKey then
        local index = currencyIndexes[currencyKey]
        if index then
          merged[index][currencyKey] = merged[index][currencyKey] + cost[currencyKey]
        else
          merged[#merged + 1] = cost
          currencyIndexes[currencyKey] = #merged
        end
      elseif cost.item then
        local itemKey = getItemMergeKey(cost)
        local index = itemIndexes[itemKey]
        if index then
          merged[index].quantity = merged[index].quantity + cost.quantity
        else
          merged[#merged + 1] = cost
          itemIndexes[itemKey] = #merged
        end
      end
    end
  end

  return merged
end

local function collectPriceCosts(data)
  local costs = {}

  if data == nil then
    return costs
  end

  appendCostFromScalarOrTable(costs, data)
  return mergeCosts(costs)
end

local function hasDirectCostFields(data)
  if type(data) ~= "table" then return false end


  -- todo use table.type "empty", "array", "hash", or "mixed"
  -- https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/README.md
  if data.item ~= nil then return true end

  for i = 1, #currencyKeys do
    if data[currencyKeys[i]] ~= nil then return true end
  end

  return false
end

-- todo double check this refactor
local function splitDirectCosts(data)
  local prices = {}

  for i = 1, #currencyKeys do
    local key = currencyKeys[i]
    if data[key] ~= nil then
      if key == "item" then
        prices[#prices + 1] = PriceClass.new({
          item = data.item,
          quantity = data.quantity,
          keep = data.keep
        })
      else
        prices[#prices + 1] = PriceClass.new({ [key] = data[key] })
      end
    end
  end

  return prices
end

-- todo replace with GetValue
local function normalizeOperator(operator)
  return operator == "and" and "and" or "or"
end

local function normalizePriceGroupPrices(data)
  local prices = {}

  if data == nil then
    return prices
  end

  if type(data) == "number" or isPrice(data) then
    prices[#prices + 1] = PriceClass.new(data)
    return prices
  end


  if isPriceGroup(data) then
    -- todo short return data
    for i = 1, #data.prices do
      prices[#prices + 1] = PriceClass.new(data.prices[i])
    end
    return prices
  end

  if type(data) ~= "table" then
    error(("Unsupported price group type: %s"):format(type(data)), 3)
  end

  -- todo remove this
  -- if data.prices then
  --   local indexes, entries = getArrayLikeEntries(data.prices)
  --   for i = 1, #indexes do
  --     prices[#prices + 1] = PriceClass.new(entries[indexes[i]])
  --   end
  --   return prices
  -- end

  local directPrices = splitDirectCosts(data)
  for i = 1, #directPrices do
    prices[#prices + 1] = directPrices[i]
  end


  -- todo remove this
  -- local indexes, entries = getArrayLikeEntries(data)
  -- for i = 1, #indexes do
  --   local entry = entries[indexes[i]]
  --   if type(entry) == "table" and isPriceGroup(entry) then
  --     for j = 1, #entry.prices do
  --       prices[#prices + 1] = PriceClass.new(entry.prices[j])
  --     end
  --   else
  --     prices[#prices + 1] = PriceClass.new(entry)
  --   end
  -- end

  if #prices == 0 and hasDirectCostFields(data) then
    prices[1] = PriceClass.new(data)
  end

  return prices
end

--- Creates a canonical PriceClass.
---@param data? table|number
---@return table
function PriceClass.new(data)
  -- todo if isPrice(data) then return data
  local self = {
    isProcessing = false,
    costs = collectPriceCosts(data)
  }

  return setmetatable(self, PriceClass)
end

--- Adds a price to the current PriceClass.
---@param price table|number
---@return table
function PriceClass:add(price)
  waitForPrice(self)
  self.isProcessing = true
  self = self + price
  -- local normalizedPrice = PriceClass.new(price)
  -- self.costs = mergeCosts(self.costs, normalizedPrice.costs)
  self.isProcessing = false

  return self
end

--- Returns the canonical costs list.
---@return table
function PriceClass:get()
  return self.costs
end

--- Returns the MoneyCost.
---@return table|nil
function PriceClass:getMoney()
  for i = 1, #self.costs do
    if self.costs[i].money ~= nil then return self.costs[i] end
  end
end

--- Returns the GoldCost.
---@return table|nil
function PriceClass:getGold()
  for i = 1, #self.costs do
    if self.costs[i].gold ~= nil then return self.costs[i] end
  end
end

--- Returns the RolCost.
---@return table|nil
function PriceClass:getRol()
  for i = 1, #self.costs do
    if self.costs[i].rol ~= nil then return self.costs[i] end
  end
end

--- Returns all ItemCost entries.
---@return table
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
---@param left table|number
---@param right table|number
---@return table
function PriceClass.__add(left, right)
  -- todo test isPrice
  local leftPrice = PriceClass.new(left)
  local rightPrice = PriceClass.new(right)

  return PriceClass.new({
    costs = mergeCosts(leftPrice.costs, rightPrice.costs)
  })
end

--- Creates a canonical PriceGroupClass.
---@param data? table|number
---@return table
function PriceGroupClass.new(data)
  local operator = "or"
  -- todo use data?.operator
  if type(data) == "table" then
    operator = normalizeOperator(data.operator)
  end

  local self = {
    operator = operator,
    prices = normalizePriceGroupPrices(data)
  }

  return setmetatable(self, PriceGroupClass)
end

--- Compacts an "and" PriceGroupClass into a new PriceClass.
---@return table
function PriceGroupClass:compact()
  if self.operator ~= "and" then
    error('PriceGroupClass:compact() is only allowed with operator = "and"', 2)
  end

  local costs = {}
  for i = 1, #self.prices do
    local price = PriceClass.new(self.prices[i])
    costs = mergeCosts(costs, price.costs)
  end

  return PriceClass.new({ costs = costs })
end

jo.pricing.new = PriceClass.new
jo.pricing.newGroup = PriceGroupClass.new
