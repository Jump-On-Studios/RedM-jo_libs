local PriceClass = jo.pricing.PriceClass
local PriceGroupClass = jo.pricing.PriceGroupClass

local tests = {}
local testOrder = {}

local function addTest(name, callback)
  tests[name] = callback
  testOrder[#testOrder + 1] = name
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

addTest("pricing_aliases", function()
  assertTrue(jo.pricing.PriceClass == PriceClass, "PriceClass export mismatch")
  assertTrue(jo.pricing.PriceGroupClass == PriceGroupClass, "PriceGroupClass export mismatch")
  assertTrue(jo.pricing.new == PriceClass.new, "new alias mismatch")
  assertTrue(jo.pricing.newGroup == PriceGroupClass.new, "newGroup alias mismatch")
end)

addTest("price_defaults_item", function()
  local price = PriceClass.new({ item = "water" })

  assertCostCount(price, 1)
  assertItem(price, "water", 1, false)
end)

addTest("price_empty_costs", function()
  local price = PriceClass.new({ costs = {} })

  assertCostCount(price, 0)
  assertTrue(price.isProcessing == false, "empty costs price must initialize isProcessing")
end)

addTest("price_new_copies_existing_instance", function()
  local price = PriceClass.new({
    money = 2,
    item = "water"
  })
  local copy = PriceClass.new(price)

  assertTrue(copy ~= price, "PriceClass.new(existingPrice) must return a new instance")
  assertTrue(copy.costs ~= price.costs, "PriceClass.new(existingPrice) must copy costs")
  assertCurrency(copy, "money", 2)
  assertItem(copy, "water", 1, false)

  copy:add({ money = 1 })
  assertCurrency(price, "money", 2)
  assertCurrency(copy, "money", 3)
end)

addTest("price_merge_currencies", function()
  local price = PriceClass.new({
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
  local price = PriceClass.new({
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 3, keep = false }
  })

  assertCostCount(price, 1)
  assertItem(price, "water", 5, false)
end)

addTest("price_keep_items_split", function()
  local price = PriceClass.new({
    { item = "water", quantity = 2, keep = false },
    { item = "water", quantity = 1, keep = true }
  })

  assertCostCount(price, 2)
  assertItem(price, "water", 2, false)
  assertItem(price, "water", 1, true)
end)

addTest("price_add_mutates_self", function()
  local price = PriceClass.new({ money = 2 })
  local returnedPrice = price:add({
    money = 3,
    item = "water"
  })

  assertTrue(returnedPrice == price, "add() must return self")
  assertCostCount(price, 2)
  assertCurrency(price, "money", 5)
  assertItem(price, "water", 1, false)
end)

addTest("price_operator_add_is_immutable", function()
  local left = PriceClass.new({ money = 2 })
  local right = PriceClass.new({ money = 3, item = "water" })
  local result = left + right

  assertTrue(result ~= left, "__add must return a new PriceClass")
  assertTrue(result ~= right, "__add must not return the right operand")
  assertCostCount(left, 1)
  assertCurrency(left, "money", 2)
  assertCostCount(right, 2)
  assertCurrency(right, "money", 3)
  assertItem(right, "water", 1, false)
  assertCostCount(result, 2)
  assertCurrency(result, "money", 5)
  assertItem(result, "water", 1, false)
end)

addTest("price_getters", function()
  local price = PriceClass.new({
    money = 2,
    gold = 3,
    rol = 4,
    item = "water"
  })

  assertTrue(price:get() == price.costs, "get() must return costs")
  assertEqual(price:getMoney().money, 2, "getMoney() mismatch")
  assertEqual(price:getGold().gold, 3, "getGold() mismatch")
  assertEqual(price:getRol().rol, 4, "getRol() mismatch")
  assertEqual(#price:getItems(), 1, "getItems() count mismatch")
  assertNil(PriceClass.new({ gold = 1 }):getMoney(), "getMoney() must return nil when missing")
end)

addTest("group_default_or", function()
  local group = PriceGroupClass.new({
    money = 2,
    gold = 5
  })

  assertEqual(group.operator, "or", "default operator mismatch")
  assertEqual(#group.prices, 2, "group price count mismatch")
  assertCurrency(group.prices[1], "money", 2)
  assertCurrency(group.prices[2], "gold", 5)
end)

addTest("group_empty_prices", function()
  local group = PriceGroupClass.new({ prices = {} })

  assertEqual(group.operator, "or", "empty prices group operator mismatch")
  assertEqual(#group.prices, 0, "empty prices group must keep an empty prices list")
end)

addTest("group_new_copies_existing_instance", function()
  local group = PriceGroupClass.new({
    operator = "and",
    PriceClass.new({ money = 2 }),
    PriceClass.new({ gold = 3 })
  })
  local copy = PriceGroupClass.new(group)

  assertTrue(copy ~= group, "PriceGroupClass.new(existingGroup) must return a new instance")
  assertEqual(copy.operator, "and", "copied group operator mismatch")
  assertEqual(#copy.prices, 2, "copied group price count mismatch")
  assertTrue(copy.prices[1] ~= group.prices[1], "copied group must copy nested prices")
  assertCurrency(copy.prices[1], "money", 2)
  assertCurrency(copy.prices[2], "gold", 3)

  copy.prices[1]:add({ money = 1 })
  assertCurrency(group.prices[1], "money", 2)
  assertCurrency(copy.prices[1], "money", 3)
end)

addTest("group_and_compact", function()
  local group = PriceGroupClass.new({
    operator = "and",
    PriceClass.new({
      money = 2,
      item = "water"
    }),
    PriceClass.new({
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
  local group = PriceGroupClass.new({
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
  local price = PriceClass.new({
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

local function runTest(name)
  local success, err = pcall(tests[name])

  if success then
    print(("[jo_pricing_test] ^2PASS^0 %s"):format(name))
    return true
  end

  print(("[jo_pricing_test] ^1FAIL^0 %s: %s"):format(name, tostring(err)))
  return false
end

local function runAllTests()
  local passed = 0
  local failed = 0

  for i = 1, #testOrder do
    if runTest(testOrder[i]) then
      passed = passed + 1
    else
      failed = failed + 1
    end
  end

  print(("[jo_pricing_test] Summary: %s passed / %s failed"):format(passed, failed))
end

RegisterCommand("jo_pricing_test", function(_, args)
  local testName = args and args[1] or "all"

  if not testName or testName == "" or testName == "all" then
    runAllTests()
    return
  end

  if not tests[testName] then
    print(("[jo_pricing_test] Unknown test `%s`"):format(testName))
    return
  end

  local passed = runTest(testName) and 1 or 0
  print(("[jo_pricing_test] Summary: %s passed / %s failed"):format(passed, 1 - passed))
end)
