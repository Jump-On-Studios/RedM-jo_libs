jo.require("pricing")

local PriceClass = jo.pricing.PriceClass
local PriceGroupClass = jo.pricing.PriceGroupClass

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

addTest("price_copy_copies_existing_instance", function()
  local price = PriceClass.new({
    money = 2,
    item = "water"
  })
  local copy = price:copy()

  assertTrue(copy ~= price, "PriceClass:copy() must return a new instance")
  assertTrue(copy.costs ~= price.costs, "PriceClass:copy() must copy costs")
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

addTest("price_is_free", function()
  assertTrue(PriceClass.new():isFree(), "empty price must be free")
  assertTrue(PriceClass.new({ costs = {} }):isFree(), "empty costs price must be free")
  assertTrue(PriceClass.new({ money = 0 }):isFree(), "zero money price must be free")
  assertTrue(PriceClass.new({ money = 0, gold = 0, rol = 0 }):isFree(), "zero currencies price must be free")
  assertTrue(PriceClass.new({ item = "water", quantity = 0 }):isFree(), "zero quantity item price must be free")
  assertTrue(not PriceClass.new({ money = -1 }):isFree(), "negative money cost must not be free")
  assertTrue(not PriceClass.new({ item = "water" }):isFree(), "item price must not be free")
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

addTest("group_copy_copies_existing_instance", function()
  local group = PriceGroupClass.new({
    operator = "and",
    PriceClass.new({ money = 2 }),
    PriceClass.new({ gold = 3 })
  })
  local copy = group:copy()

  assertTrue(copy ~= group, "PriceGroupClass:copy() must return a new instance")
  assertEqual(copy.operator, "and", "copied group operator mismatch")
  assertEqual(#copy.prices, 2, "copied group price count mismatch")
  assertTrue(copy.prices ~= group.prices, "copied group must copy prices")
  assertTrue(copy.prices[1] ~= group.prices[1], "copied group must copy nested prices")
  assertCurrency(copy.prices[1], "money", 2)
  assertCurrency(copy.prices[2], "gold", 3)

  copy.prices[1]:add({ money = 1 })
  assertCurrency(group.prices[1], "money", 2)
  assertCurrency(copy.prices[1], "money", 3)
end)

addTest("group_insert_appends_price", function()
  local group = PriceGroupClass.new()
  local returnedGroup = group:insert({ money = 2 })

  assertTrue(returnedGroup == group, "insert() must return self")
  assertEqual(#group.prices, 1, "insert() must append when index is missing")
  assertCurrency(group.prices[1], "money", 2)
end)

addTest("group_insert_at_index", function()
  local group = PriceGroupClass.new({
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
  local group = PriceGroupClass.new({
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
  local group = PriceGroupClass.new({
    { money = 1 }
  })
  local success = pcall(function()
    group:remove()
  end)

  assertTrue(not success, "remove() must error without an index")
  assertEqual(#group.prices, 1, "remove() without index must not mutate prices")
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
        assertPriceShape(PriceClass.new(case.input), case.expected)
        return
      end

      if case.kind == "group" then
        assertGroupShape(PriceGroupClass.new(case.input), case.expected)
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
