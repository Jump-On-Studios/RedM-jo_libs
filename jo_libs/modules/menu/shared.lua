jo.menu = {}
jo.require("table")

--- Helper function to normalize a single entry
---@param entry any
---@return table
local function normalizeEntry(entry)
  if type(entry) ~= "table" then
    return { money = entry }
  end

  if entry.item then
    return table.merge({
      item = entry.item,
      quantity = entry.quantity or 1,
      keep = entry.keep or false,
      meta = entry.meta
    }, jo.framework:getItemData(entry.item))
  end

  return entry
end

--- A function to format a single price
---@param price table|integer|number (The price to format)
---@return table (The formatted price)
function jo.menu.formatPrice(price)
  if not price then return { { money = 0 } } end
  if type(price) ~= "table" then return { { money = price } } end

  local result = {}
  local size = 1

  for key, value in pairs(price) do
    if type(key) == "string" then
      result[size] = normalizeEntry({ [key] = value })
      size += 1
    elseif type(value) == "table" then
      if value.item then
        result[size] = normalizeEntry(value)
        size += 1
      else
        for k, v in pairs(value) do
          if type(k) == "string" then
            result[size] = normalizeEntry({ [k] = v })
            size += 1
          else
            result[size] = normalizeEntry(v)
            size += 1
          end
        end
      end
    else
      result[size] = normalizeEntry(value)
      size += 1
    end
  end

  return result
end

--- A function to format price variations
---@param prices table|integer|number (The prices to format)
---@return table (The formatted prices)
function jo.menu.formatPrices(prices)
  if not prices then return { { { money = 0 } } } end
  if type(prices) ~= "table" then return { { { money = prices } } } end

  local operator = prices.operator or "or"
  local formattedPrices = {}
  local size = 1

  -- Process each price entry
  for key, price in pairs(prices) do
    if key ~= "operator" then
      if type(key) == "string" then
        formattedPrices[size] = jo.menu.formatPrice({ [key] = price })
        size += 1
      elseif type(price) ~= "table" then
        formattedPrices[size] = { { money = price } }
        size += 1
      else
        formattedPrices[size] = jo.menu.formatPrice(price)
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
    local price = formattedPrices[i]
    local sanitized = {}
    size = 1
    local moneyTotal = 0
    local goldTotal = 0
    local rolTotal = 0
    local items = {}

    for j = 1, #price do
      local item = price[j]
      if item.money then
        moneyTotal = moneyTotal + item.money
      elseif item.gold then
        goldTotal = goldTotal + item.gold
      elseif item.rol then
        rolTotal = rolTotal + item.rol
      elseif item.item then
        local key = item.item .. ":" .. tostring(item.keep)
        if not items[key] then
          items[key] = {}
        end
        local found = false
        for y = 1, #items[key] do
          if table.isEgal(GetValue(items[key][y].meta, {}), GetValue(item.meta, {})) then
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

    if moneyTotal > 0 then
      sanitized[size] = { money = moneyTotal }
      size += 1
    end
    if goldTotal > 0 then
      sanitized[size] = { gold = goldTotal }
      size += 1
    end
    if rolTotal > 0 then
      sanitized[size] = { rol = rolTotal }
      size += 1
    end

    formattedPrices[i] = sanitized
  end

  return formattedPrices
end

--- Checks if a price is free
---@param price table|integer|number (The price to check)
---@return boolean (Return `true` if the price is free)
function jo.menu.isPriceFree(price)
  return type(price) == "table" and #price == 1 and (price[1].money == 0 or price[1][1].money == 0)
end

local function runTests()
  local tests = {
    { name = "Simple number", price = 5 },
    { name = "Complex mixed", price = { 10, { item = "water", money = 5, gold = 3, { gold = 7 }, { 10 } }, operator = "or" } },
    { name = "Multi currency", price = { money = 5, gold = 3, operator = "or" } },
    { name = "Merge same meta", price = { { money = 10, gold = 1, { item = "water", quantity = 2, meta = { a = 1 } } }, { money = 10, gold = 1, { item = "water", quantity = 2, meta = { a = 1 } } }, operator = "and" } },
    { name = "Merge meta different", price = { { { item = "water", quantity = 2, meta = { a = 1, b = 1 } } }, { { item = "water", quantity = 2, meta = { a = 1 } } }, operator = "and" } },
  }

  jo.require("debugger")

  for _, test in ipairs(tests) do
    log("=> " .. test.name)
    jo.debugger.perfomance("test", function()
      log(jo.menu.formatPrices(test.price))
    end)
  end
end

-- runTests()
