jo.require("pricing")

local newPrice = jo.pricing.new
local newGroup = jo.pricing.newGroup

local TESTS = {}

local function addTest(name, callback)
  TESTS[name] = callback
end

local function fail(message)
  error(message, 3)
end

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    fail(("%s. Expected `%s`, got `%s`"):format(message, tostring(expected), tostring(actual)))
  end
end

local function assertTrue(value, message)
  if not value then
    fail(message)
  end
end

local function assertNil(value, message)
  if value ~= nil then
    fail(("%s. Expected nil, got `%s`"):format(message, tostring(value)))
  end
end

local function assertSame(actual, expected, message)
  if not rawequal(actual, expected) then
    fail(message)
  end
end

local function assertNotSame(actual, expected, message)
  if rawequal(actual, expected) then
    fail(message)
  end
end

local function findCurrency(price, key)
  for i = 1, #price.costs do
    if price.costs[i][key] ~= nil then return price.costs[i] end
  end
end

local function findItem(price, item, keep)
  for i = 1, #price.costs do
    local cost = price.costs[i]
    if cost.item == item and cost.keep == keep then
      return cost
    end
  end
end

local function assertCurrency(price, key, amount)
  local cost = findCurrency(price, key)
  assertTrue(cost ~= nil, ("missing %s cost"):format(key))
  assertEqual(cost[key], amount, ("%s amount mismatch"):format(key))
end

local function assertItem(price, item, quantity, keep)
  local cost = findItem(price, item, keep)
  assertTrue(cost ~= nil, ("missing item cost %s keep=%s"):format(item, tostring(keep)))
  assertEqual(cost.quantity, quantity, ("item %s quantity mismatch"):format(item))
end

local function assertCostCount(price, count)
  assertEqual(#price.costs, count, "cost count mismatch")
end

local function assertPriceShape(price, expected)
  assertCostCount(price, expected.count or 0)

  if expected.money ~= nil then assertCurrency(price, "money", expected.money) end
  if expected.gold ~= nil then assertCurrency(price, "gold", expected.gold) end
  if expected.rol ~= nil then assertCurrency(price, "rol", expected.rol) end

  local items = expected.items or {}
  for i = 1, #items do
    assertItem(price, items[i].item, items[i].quantity, items[i].keep)
  end
end

local function assertGroupShape(group, expected)
  assertEqual(group.operator, expected.operator, "group operator mismatch")
  assertEqual(#group.prices, #expected.prices, "group price count mismatch")

  for i = 1, #expected.prices do
    assertPriceShape(group.prices[i], expected.prices[i])
  end
end

addTest("pricing_aliases", function()
  assertNil(jo.pricing.PriceClass, "PriceClass must not be exposed")
  assertNil(jo.pricing.PriceGroupClass, "PriceGroupClass must not be exposed")
  assertEqual(type(jo.pricing.new), "function", "new must be exposed")
  assertEqual(type(jo.pricing.newGroup), "function", "newGroup must be exposed")
  assertEqual(type(jo.pricing.tax), "function", "tax must be exposed")
  assertEqual(type(jo.pricing.isPrice), "function", "isPrice must be exposed")
  assertEqual(type(jo.pricing.isPriceGroup), "function", "isPriceGroup must be exposed")

  local price = newPrice({ money = 1 })
  local group = newGroup({ { money = 1 } })

  assertTrue(jo.pricing.isPrice(price), "isPrice() must detect PriceClass instances")
  assertTrue(not jo.pricing.isPrice({ costs = price.costs }), "isPrice() must reject plain canonical tables")
  assertTrue(jo.pricing.isPriceGroup(group), "isPriceGroup() must detect PriceGroupClass instances")
  assertTrue(not jo.pricing.isPriceGroup({ operator = "or", prices = group.prices }), "isPriceGroup() must reject plain canonical tables")
end)

addTest("price_defaults_item", function()
  local price = newPrice({ item = "water" })

  assertCostCount(price, 1)
  assertItem(price, "water", 1, false)
end)

addTest("price_empty_costs", function()
  local price = newPrice({ costs = {} })

  assertCostCount(price, 0)
  assertTrue(price.isProcessing == false, "empty costs price must initialize isProcessing")
end)

addTest("price_new_copies_existing_instance", function()
  local price = newPrice({
    money = 2,
    item = "water"
  })
  local copy = newPrice(price)

  assertNotSame(copy, price, "newPrice(existingPrice) must return a new instance")
  assertNotSame(copy.costs, price.costs, "newPrice(existingPrice) must copy costs")
  assertCurrency(copy, "money", 2)
  assertItem(copy, "water", 1, false)

  copy:add({ money = 1 })
  assertCurrency(price, "money", 2)
  assertCurrency(copy, "money", 3)
end)

addTest("price_copy_copies_existing_instance", function()
  local price = newPrice({
    money = 2,
    item = "water"
  })
  local copy = price:copy()

  assertNotSame(copy, price, "PriceClass:copy() must return a new instance")
  assertNotSame(copy.costs, price.costs, "PriceClass:copy() must copy costs")
  assertCurrency(copy, "money", 2)
  assertItem(copy, "water", 1, false)

  copy:add({ money = 1 })
  assertCurrency(price, "money", 2)
  assertCurrency(copy, "money", 3)
end)

addTest("price_merge_currencies", function()
  local price = newPrice({
    { money = 12 },
    { gold = 2 },
    { rol = 1 },
    { money = 4 },
    { gold = 3 },
    { rol = 2 }
  })

  assertCostCount(price, 3)
  assertCurrency(price, "money", 16)
  assertCurrency(price, "gold", 5)
  assertCurrency(price, "rol", 3)
end)

addTest("price_merge_items_same_keep", function()
  local price = newPrice({
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 3, keep = false }
  })

  assertCostCount(price, 1)
  assertItem(price, "water", 5, false)
end)

addTest("price_keep_items_split", function()
  local price = newPrice({
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 1, keep = true }
  })

  assertCostCount(price, 2)
  assertItem(price, "water", 2, false)
  assertItem(price, "water", 1, true)
end)

addTest("price_add_mutates_self", function()
  local price = newPrice({ money = 2 })
  local returnedPrice = price:add({
    money = 3,
    item = "water"
  })

  assertSame(returnedPrice, price, "add() must return self")
  assertCostCount(price, 2)
  assertCurrency(price, "money", 5)
  assertItem(price, "water", 1, false)
end)

addTest("price_operator_add_is_immutable", function()
  local left = newPrice({ money = 2 })
  local right = newPrice({ money = 3, item = "water" })
  local result = left + right

  assertNotSame(result, left, "__add must return a new PriceClass")
  assertNotSame(result, right, "__add must not return the right operand")
  assertCostCount(left, 1)
  assertCurrency(left, "money", 2)
  assertCostCount(right, 2)
  assertCurrency(right, "money", 3)
  assertItem(right, "water", 1, false)
  assertCostCount(result, 2)
  assertCurrency(result, "money", 5)
  assertItem(result, "water", 1, false)
end)

addTest("price_operator_len_counts_costs", function()
  assertEqual(#newPrice(), 0, "__len must count zero costs")
  assertEqual(#newPrice({ money = 1, item = "water" }), 2, "__len must count canonical costs")
end)

addTest("price_operator_mul_is_immutable", function()
  local price = newPrice({
    money = 10,
    gold = 2,
    rol = 4,
    item = "water",
    quantity = 3
  })
  local result = price * 1.5

  assertNotSame(result, price, "__mul must return a new PriceClass")
  assertCostCount(price, 4)
  assertCurrency(price, "money", 10)
  assertCurrency(price, "gold", 2)
  assertCurrency(price, "rol", 4)
  assertItem(price, "water", 3, false)
  assertCostCount(result, 4)
  assertCurrency(result, "money", 15)
  assertCurrency(result, "gold", 3)
  assertCurrency(result, "rol", 6)
  assertItem(result, "water", 5, false)
end)

addTest("price_operator_mul_rounds_items_to_nearest", function()
  local roundedDown = newPrice({
    item = "water",
    quantity = 1
  }) * 1.4
  local roundedUp = newPrice({
    item = "water",
    quantity = 1
  }) * 1.51

  assertItem(roundedDown, "water", 1, false)
  assertItem(roundedUp, "water", 2, false)
end)

addTest("price_operator_mul_supports_reversed_operands", function()
  local price = newPrice({
    money = 5,
    item = "water",
    quantity = 2
  })
  local leftResult = price * 2
  local rightResult = 2 * price

  assertTrue(leftResult == rightResult, "__mul must support number * PriceClass")
  assertCurrency(rightResult, "money", 10)
  assertItem(rightResult, "water", 4, false)
end)

addTest("price_operator_mul_rejects_invalid_multiplier", function()
  local price = newPrice({ money = 5 })

  assertTrue(not pcall(function()
    return price * "2"
  end), "__mul must reject non-number right operands")

  assertTrue(not pcall(function()
    return "2" * price
  end), "__mul must reject non-number left operands")
end)

addTest("price_operator_div_is_immutable", function()
  local price = newPrice({
    money = 15,
    gold = 3,
    rol = 6,
    item = "water",
    quantity = 5
  })
  local result = price / 2

  assertNotSame(result, price, "__div must return a new PriceClass")
  assertCostCount(price, 4)
  assertCurrency(price, "money", 15)
  assertCurrency(price, "gold", 3)
  assertCurrency(price, "rol", 6)
  assertItem(price, "water", 5, false)
  assertCostCount(result, 4)
  assertCurrency(result, "money", 7.5)
  assertCurrency(result, "gold", 1.5)
  assertCurrency(result, "rol", 3)
  assertItem(result, "water", 3, false)
end)

addTest("price_operator_div_rejects_invalid_divisor", function()
  local price = newPrice({ money = 5 })

  assertTrue(not pcall(function()
    return price / 0
  end), "__div must reject division by zero")

  assertTrue(not pcall(function()
    return price / "2"
  end), "__div must reject non-number right operands")

  assertTrue(not pcall(function()
    return 2 / price
  end), "__div must reject number / PriceClass")
end)

addTest("price_equals_compares_by_value", function()
  local left = newPrice({
    money = 5,
    { item = "water", quantity = 2 },
    { item = "acid", quantity = 1 },
    { gold = 1 }
  })
  local right = newPrice({
    { gold = 1 },
    { item = "acid", quantity = 1 },
    { item = "water", quantity = 2 },
    { money = 5 }
  })

  assertTrue(left == right, "__eq must compare canonical costs by value")
  assertTrue(left:equals(right), "equals() must compare PriceClass values")
  assertTrue(left:equals({
    { item = "water", quantity = 2 },
    { item = "acid", quantity = 1 },
    { money = 5 },
    { gold = 1 }
  }), "equals() must accept normalizable price input")
end)

addTest("price_equals_detects_differences", function()
  local price = newPrice({
    money = 5,
    item = "water"
  })

  assertTrue(price ~= newPrice({ money = 6, item = "water" }), "__eq must detect currency differences")
  assertTrue(price ~= newPrice({ money = 5, item = "water", keep = true }), "__eq must detect item keep differences")
  assertTrue(price ~= newPrice({ money = 5, item = "water", quantity = 2 }), "__eq must detect item quantity differences")
  assertTrue(not price:equals({ unsupported = true }), "equals() must return false for unsupported price input")
end)

addTest("price_getters", function()
  local price = newPrice({
    money = 2,
    gold = 3,
    rol = 4,
    item = "water"
  })

  assertSame(price:getCosts(), price.costs, "getCosts() must return costs")
  assertEqual(price:getMoney(), 2, "getMoney() mismatch")
  assertEqual(price:getGold(), 3, "getGold() mismatch")
  assertEqual(price:getRol(), 4, "getRol() mismatch")
  assertEqual(#price:getItems(), 1, "getItems() count mismatch")
  assertNil(newPrice({ gold = 1 }):getMoney(), "getMoney() must return nil when missing")
end)

addTest("price_get_item_and_has_item", function()
  local price = newPrice({
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 1, keep = true },
    { item = "acid", quantity = 3, keep = false }
  })

  assertEqual(price:getItem("water", false).quantity, 2, "getItem() must find keep=false item")
  assertEqual(price:getItem("water", true).quantity, 1, "getItem() must find keep=true item")
  assertTrue(price:hasItem("acid", false), "hasItem() must find existing item")
  assertTrue(not price:hasItem("acid", true), "hasItem() must respect keep flag")
  assertNil(price:getItem("unknown", false), "getItem() must return nil when missing")
end)

addTest("price_item_methods_require_keep", function()
  local price = newPrice({ item = "water" })

  assertTrue(not pcall(function()
    price:getItem("water")
  end), "getItem() must require keep")
  assertTrue(not pcall(function()
    price:hasItem("water")
  end), "hasItem() must require keep")
  assertTrue(not pcall(function()
    price:removeItem("water")
  end), "removeItem() must require keep")
end)

addTest("price_has_currency", function()
  local price = newPrice({
    money = 2,
    item = "water"
  })

  assertTrue(price:hasCurrency("money"), "hasCurrency() must find existing currency")
  assertTrue(not price:hasCurrency("gold"), "hasCurrency() must return false for missing currency")
end)

addTest("price_currency_methods_reject_invalid_key", function()
  local price = newPrice({ money = 2 })

  assertTrue(not pcall(function()
    price:hasCurrency("cash")
  end), "hasCurrency() must reject invalid currency keys")
  assertTrue(not pcall(function()
    price:removeCurrency("cash")
  end), "removeCurrency() must reject invalid currency keys")
end)

addTest("price_remove_currency_mutates_self", function()
  local price = newPrice({
    money = 2,
    gold = 3,
    item = "water"
  })
  local returnedPrice = price:removeCurrency("gold")

  assertSame(returnedPrice, price, "removeCurrency() must return self")
  assertCostCount(price, 2)
  assertCurrency(price, "money", 2)
  assertNil(price:getGold(), "removeCurrency() must remove the targeted currency")
  assertItem(price, "water", 1, false)

  price:removeCurrency("rol")
  assertCostCount(price, 2)
end)

addTest("price_remove_item_mutates_self", function()
  local price = newPrice({
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 1, keep = true },
    { item = "acid", quantity = 3, keep = false }
  })
  local returnedPrice = price:removeItem("water", true)

  assertSame(returnedPrice, price, "removeItem() must return self")
  assertCostCount(price, 2)
  assertItem(price, "water", 2, false)
  assertNil(price:getItem("water", true), "removeItem() must remove only the exact item + keep")
  assertItem(price, "acid", 3, false)

  price:removeItem("missing", false)
  assertCostCount(price, 2)
end)

addTest("price_clear_mutates_self", function()
  local price = newPrice({
    money = 2,
    item = "water"
  })
  local returnedPrice = price:clear()

  assertSame(returnedPrice, price, "clear() must return self")
  assertCostCount(price, 0)
end)

addTest("price_currency_only_and_item_only", function()
  assertTrue(newPrice({ money = 2, gold = 3 }):isCurrencyOnly(), "currency-only price must be currency-only")
  assertTrue(not newPrice({ money = 2, gold = 3 }):isItemOnly(), "currency-only price must not be item-only")
  assertTrue(newPrice({
    { item = "water" },
    { item = "acid" }
  }):isItemOnly(), "item-only price must be item-only")
  assertTrue(not newPrice({
    { item = "water" },
    { item = "acid" }
  }):isCurrencyOnly(), "item-only price must not be currency-only")
  assertTrue(not newPrice({ money = 2, item = "water" }):isCurrencyOnly(), "mixed price must not be currency-only")
  assertTrue(not newPrice({ money = 2, item = "water" }):isItemOnly(), "mixed price must not be item-only")
  assertTrue(not newPrice():isCurrencyOnly(), "empty price must not be currency-only")
  assertTrue(not newPrice():isItemOnly(), "empty price must not be item-only")
end)

addTest("price_is_free", function()
  assertTrue(newPrice():isFree(), "empty price must be free")
  assertTrue(newPrice({ costs = {} }):isFree(), "empty costs price must be free")
  assertTrue(newPrice({ money = 0 }):isFree(), "zero money price must be free")
  assertTrue(newPrice({ money = 0, gold = 0, rol = 0 }):isFree(), "zero currencies price must be free")
  assertTrue(newPrice({ item = "water", quantity = 0 }):isFree(), "zero quantity item price must be free")
  assertTrue(not newPrice({ money = -1 }):isFree(), "negative money cost must not be free")
  assertTrue(not newPrice({ item = "water" }):isFree(), "item price must not be free")
end)

addTest("pricing_tax_splits_tax_and_remaining_prices", function()
  local price = newPrice({
    money = 10,
    gold = 2,
    rol = 4,
    item = "water",
    quantity = 3
  })
  local taxPrice, remainingPrice = jo.pricing.tax(price, 0.5)

  assertCostCount(price, 4)
  assertCurrency(price, "money", 10)
  assertCurrency(price, "gold", 2)
  assertCurrency(price, "rol", 4)
  assertItem(price, "water", 3, false)

  assertCostCount(taxPrice, 4)
  assertCurrency(taxPrice, "money", 5)
  assertCurrency(taxPrice, "gold", 1)
  assertCurrency(taxPrice, "rol", 2)
  assertItem(taxPrice, "water", 1, false)

  assertCostCount(remainingPrice, 4)
  assertCurrency(remainingPrice, "money", 5)
  assertCurrency(remainingPrice, "gold", 1)
  assertCurrency(remainingPrice, "rol", 2)
  assertItem(remainingPrice, "water", 2, false)
end)

addTest("pricing_tax_rounds_items_up", function()
  local taxPrice, remainingPrice = jo.pricing.tax({
    item = "water",
    quantity = 3
  }, 0.5, true)

  assertCostCount(taxPrice, 1)
  assertItem(taxPrice, "water", 2, false)
  assertCostCount(remainingPrice, 1)
  assertItem(remainingPrice, "water", 1, false)
end)

addTest("pricing_tax_default_zero", function()
  local price = newPrice({
    money = 10,
    item = "water",
    quantity = 3
  })
  local taxPrice, remainingPrice = jo.pricing.tax(price)

  assertTrue(taxPrice:isFree(), "tax() without percentage must return a free tax price")
  assertCurrency(taxPrice, "money", 0)
  assertItem(taxPrice, "water", 0, false)
  assertTrue(remainingPrice == price, "tax() without percentage must return the input value as remaining")
  assertNotSame(remainingPrice, price, "tax() must not return the input instance as remaining")
end)

addTest("group_default_or", function()
  local group = newGroup({
    money = 2,
    gold = 5
  })

  assertEqual(group.operator, "or", "default operator mismatch")
  assertEqual(#group.prices, 2, "group price count mismatch")
  assertCurrency(group.prices[1], "money", 2)
  assertCurrency(group.prices[2], "gold", 5)
end)

addTest("group_empty_prices", function()
  local group = newGroup({ prices = {} })

  assertEqual(group.operator, "or", "empty prices group operator mismatch")
  assertEqual(#group.prices, 0, "empty prices group must keep an empty prices list")
end)

addTest("group_operator_len_counts_prices", function()
  assertEqual(#newGroup(), 0, "__len must count zero group prices")
  assertEqual(#newGroup({ { money = 1 }, { gold = 2 } }), 2, "__len must count group prices")
end)

addTest("group_helpers", function()
  local group = newGroup({
    { money = 1 },
    { gold = 3 }
  })

  assertTrue(not group:isEmpty(), "isEmpty() must return false when prices exist")
  assertEqual(group:count(), 2, "count() must return the number of prices")
  assertCurrency(group:get(1), "money", 1)
  assertCurrency(group:get(2), "gold", 3)
  assertNil(group:get(3), "get() must return nil for a missing index")

  local returnedGroup = group:clear()
  assertSame(returnedGroup, group, "clear() must return self")
  assertTrue(group:isEmpty(), "clear() must empty prices")
  assertEqual(group:count(), 0, "count() must return zero after clear")
end)

addTest("group_new_copies_existing_instance", function()
  local group = newGroup({
    operator = "and",
    newPrice({ money = 2 }),
    newPrice({ gold = 3 })
  })
  local copy = newGroup(group)

  assertNotSame(copy, group, "newGroup(existingGroup) must return a new instance")
  assertEqual(copy.operator, "and", "copied group operator mismatch")
  assertEqual(#copy.prices, 2, "copied group price count mismatch")
  assertNotSame(copy.prices[1], group.prices[1], "copied group must copy nested prices")
  assertCurrency(copy.prices[1], "money", 2)
  assertCurrency(copy.prices[2], "gold", 3)

  copy.prices[1]:add({ money = 1 })
  assertCurrency(group.prices[1], "money", 2)
  assertCurrency(copy.prices[1], "money", 3)
end)

addTest("group_copy_copies_existing_instance", function()
  local group = newGroup({
    operator = "and",
    newPrice({ money = 2 }),
    newPrice({ gold = 3 })
  })
  local copy = group:copy()

  assertNotSame(copy, group, "PriceGroupClass:copy() must return a new instance")
  assertEqual(copy.operator, "and", "copied group operator mismatch")
  assertEqual(#copy.prices, 2, "copied group price count mismatch")
  assertNotSame(copy.prices, group.prices, "copied group must copy prices")
  assertNotSame(copy.prices[1], group.prices[1], "copied group must copy nested prices")
  assertCurrency(copy.prices[1], "money", 2)
  assertCurrency(copy.prices[2], "gold", 3)

  copy.prices[1]:add({ money = 1 })
  assertCurrency(group.prices[1], "money", 2)
  assertCurrency(copy.prices[1], "money", 3)
end)

addTest("group_insert_appends_price", function()
  local group = newGroup()
  local returnedGroup = group:insert({ money = 2 })

  assertSame(returnedGroup, group, "insert() must return self")
  assertEqual(#group.prices, 1, "insert() must append when index is missing")
  assertCurrency(group.prices[1], "money", 2)
end)

addTest("group_insert_at_index", function()
  local group = newGroup({
    { money = 1 },
    { gold = 3 }
  })

  group:insert({ item = "water" }, 2)

  assertEqual(#group.prices, 3, "insert(index) must add one price")
  assertCurrency(group.prices[1], "money", 1)
  assertItem(group.prices[2], "water", 1, false)
  assertCurrency(group.prices[3], "gold", 3)
end)

addTest("group_remove_by_index", function()
  local group = newGroup({
    { money = 1 },
    { item = "water" },
    { gold = 3 }
  })
  local removed = group:remove(2)

  assertEqual(#group.prices, 2, "remove(index) must remove one price")
  assertItem(removed, "water", 1, false)
  assertCurrency(group.prices[1], "money", 1)
  assertCurrency(group.prices[2], "gold", 3)
end)

addTest("group_remove_requires_index", function()
  local group = newGroup({
    { money = 1 }
  })
  local success = pcall(function()
    group:remove()
  end)

  assertTrue(not success, "remove() must error without an index")
  assertEqual(#group.prices, 1, "remove() without index must not mutate prices")
end)

addTest("group_set_replaces_existing_price", function()
  local group = newGroup({
    { money = 1 },
    { gold = 3 }
  })
  local existingPrice = newPrice({ item = "water" })
  local returnedGroup = group:set(2, existingPrice)

  assertSame(returnedGroup, group, "set() must return self")
  assertEqual(#group.prices, 2, "set() must not change price count")
  assertCurrency(group.prices[1], "money", 1)
  assertSame(group.prices[2], existingPrice, "set() must reuse an existing PriceClass through asPrice")
  assertItem(group.prices[2], "water", 1, false)

  group:set(1, { rol = 4 })
  assertCurrency(group.prices[1], "rol", 4)
end)

addTest("group_set_rejects_invalid_index", function()
  local group = newGroup({
    { money = 1 }
  })

  assertTrue(not pcall(function()
    group:set()
  end), "set() must error without an index")
  assertTrue(not pcall(function()
    group:set("1", { gold = 2 })
  end), "set() must error with a non-number index")
  assertTrue(not pcall(function()
    group:set(0, { gold = 2 })
  end), "set() must error with an out-of-bounds index")
  assertTrue(not pcall(function()
    group:set(2, { gold = 2 })
  end), "set() must error when replacing a missing price")
  assertEqual(#group.prices, 1, "failed set() calls must not mutate prices")
  assertCurrency(group.prices[1], "money", 1)
end)

addTest("group_and_compact", function()
  local group = newGroup({
    operator = "and",
    newPrice({
      money = 2,
      item = "water"
    }),
    newPrice({
      money = 5,
      gold = 1,
      { item = "water", quantity = 3 }
    })
  })
  local price = group:compact()

  assertCostCount(price, 3)
  assertCurrency(price, "money", 7)
  assertCurrency(price, "gold", 1)
  assertItem(price, "water", 4, false)
end)

addTest("group_or_compact_errors", function()
  local group = newGroup({
    operator = "or",
    money = 2,
    gold = 5
  })
  local success = pcall(function()
    group:compact()
  end)

  assertTrue(not success, "compact() must error with operator = or")
end)

addTest("mixed_inputs_normalized", function()
  local price = newPrice({
    money = 2,
    gold = 4,
    item = "water",
    {
      item = "acid",
      quantity = 3
    },
    {
      { money = 5 },
      { item = "acid", quantity = 2 }
    },
    6
  })

  assertCostCount(price, 4)
  assertCurrency(price, "money", 13)
  assertCurrency(price, "gold", 4)
  assertItem(price, "water", 1, false)
  assertItem(price, "acid", 5, false)
end)

addTest("simplified_config_matrix", function()
  local simplifiedConfigCases = {
    {
      name = "clothing_numeric_integer",
      kind = "price",
      input = 5,
      expected = { count = 1, money = 5 }
    },
    {
      name = "clothing_numeric_decimal",
      kind = "price",
      input = 4.25,
      expected = { count = 1, money = 4.25 }
    },
    {
      name = "stable_zero_price",
      kind = "price",
      input = 0,
      expected = { count = 1, money = 0 }
    },
    {
      name = "clothing_disabled_sentinel_is_plain_money",
      kind = "price",
      input = -1,
      expected = { count = 1, money = -1 }
    },
    {
      name = "stable_inline_currencies",
      kind = "price",
      input = { money = 50, gold = 2 },
      expected = { count = 2, money = 50, gold = 2 }
    },
    {
      name = "pricing_all_currency_types",
      kind = "price",
      input = { money = 50, gold = 2, rol = 7 },
      expected = { count = 3, money = 50, gold = 2, rol = 7 }
    },
    {
      name = "stable_item_default_quantity",
      kind = "price",
      input = { item = "apple" },
      expected = {
        count = 1,
        items = {
          { item = "apple", quantity = 1, keep = false }
        }
      }
    },
    {
      name = "stable_item_keep_true",
      kind = "price",
      input = { item = "horse_license", keep = true },
      expected = {
        count = 1,
        items = {
          { item = "horse_license", quantity = 1, keep = true }
        }
      }
    },
    {
      name = "stable_mixed_money_and_kept_item",
      kind = "price",
      input = { money = 10, { item = "apple", quantity = 1, keep = true } },
      expected = {
        count = 2,
        money = 10,
        items = {
          { item = "apple", quantity = 1, keep = true }
        }
      }
    },
    {
      name = "stable_nested_array_money_and_item",
      kind = "price",
      input = { { money = 100 }, { item = "apple" } },
      expected = {
        count = 2,
        money = 100,
        items = {
          { item = "apple", quantity = 1, keep = false }
        }
      }
    },
    {
      name = "stable_distance_fields_are_ignored",
      kind = "price",
      input = {
        { money = 100, gold = 1, multiplyWithDistance = true },
        { gold = 3, multiplyWithDistance = false },
        { item = "ticket", quantity = 1, keep = false, multiplyWithDistance = false }
      },
      expected = {
        count = 3,
        money = 100,
        gold = 4,
        items = {
          { item = "ticket", quantity = 1, keep = false }
        }
      }
    },
    {
      name = "clothing_or_money_gold_item",
      kind = "group",
      input = {
        operator = "or",
        { money = 5, item = "water" },
        { gold = 5 },
        { money = 2, { item = "water", quantity = 3 } }
      },
      expected = {
        operator = "or",
        prices = {
          {
            count = 2,
            money = 5,
            items = {
              { item = "water", quantity = 1, keep = false }
            }
          },
          { count = 1, gold = 5 },
          {
            count = 2,
            money = 2,
            items = {
              { item = "water", quantity = 3, keep = false }
            }
          }
        }
      }
    },
    {
      name = "stable_or_license_gold_money",
      kind = "group",
      input = {
        operator = "or",
        { { item = "horse_license", keep = true } },
        { gold = 1 },
        { money = 100 }
      },
      expected = {
        operator = "or",
        prices = {
          {
            count = 1,
            items = {
              { item = "horse_license", quantity = 1, keep = true }
            }
          },
          { count = 1, gold = 1 },
          { count = 1, money = 100 }
        }
      }
    },
    {
      name = "stable_default_or_array_choices",
      kind = "group",
      input = {
        { { item = "apple", quantity = 1, keep = true }, { money = 1 } },
        { gold = 10 }
      },
      expected = {
        operator = "or",
        prices = {
          {
            count = 2,
            money = 1,
            items = {
              { item = "apple", quantity = 1, keep = true }
            }
          },
          { count = 1, gold = 10 }
        }
      }
    },
    {
      name = "stable_model_or_mixed_options",
      kind = "group",
      input = {
        operator = "or",
        { { item = "apple", quantity = 10, keep = true }, money = 10 },
        { gold = 152 }
      },
      expected = {
        operator = "or",
        prices = {
          {
            count = 2,
            money = 10,
            items = {
              { item = "apple", quantity = 10, keep = true }
            }
          },
          { count = 1, gold = 152 }
        }
      }
    }
  }

  for i = 1, #simplifiedConfigCases do
    local case = simplifiedConfigCases[i]
    local success, err = pcall(function()
      if case.kind == "price" then
        assertPriceShape(newPrice(case.input), case.expected)
        return
      end

      if case.kind == "group" then
        assertGroupShape(newGroup(case.input), case.expected)
        return
      end

      fail(("Unsupported simplified config case kind `%s` for `%s`"):format(tostring(case.kind), case.name))
    end)

    if not success then
      fail(("simplified config case `%s` failed: %s"):format(case.name, tostring(err)))
    end
  end
end)

return TESTS
