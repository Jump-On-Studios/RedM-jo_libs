jo.require("framework")

local TESTS = {}

-------------
-- VARIABLES
-------------

SkinJSON = "[]"
ClothesJSON = "[]"

-------------
-- END VARIABLES
-------------

function TESTS.skin()
  local prints = {
    skinBase = false,
    skinConverted = false,
    skinReverted = false,
    skinMatch = true
  }

  --Load framework data
  jo.file.load(("_unit-test.framework-bridge.%s.server_data"):format(jo.framework:getFrameworkDetected().folder))

  -------------
  -- SKIN TEST
  -------------
  --Read skin data
  local originalSkin = json.decode(SkinJSON)
  if prints.skinBase then
    gprint("==== FROM ====")
    print(json.encode(originalSkin, { indent = true }))
  end

  --Convert to standard
  local standard = jo.framework:standardizeSkin(originalSkin)
  if prints.skinConverted then
    gprint("==== Standard =====")
    print(json.encode(standard, { indent = true }))
  end

  --Revert to framework
  local reverted = jo.framework:revertSkin(standard)
  if prints.skinReverted then
    gprint("===== reverted =====")
    print(json.encode(reverted, { indent = true }))
  end

  --Compare the original framework data with reversed data
  if prints.skinMatch then
    print("===== DON'T MATCH =====")
    local errorCount = 0
    for key, value in pairs(originalSkin) do
      if ((not reverted[key]) or not (reverted[key] == value or table.isEgal(reverted[key], value, true))) and not (value == 0 and not reverted[key]) then
        errorCount += 1
        print("--- Value changed:", key, "\tFrom:", value, (" (%s)"):format(type(value)), "To:", reverted[key], (" (%s)"):format(type(reverted[key])))
      end
    end
    print(("==== ERROR: %d ===="):format(errorCount))
    print("Number key in original", table.count(originalSkin))
    print("Number key in reverted", table.count(reverted))
  end
end

function TESTS.clothes()
  local prints = {
    clothesBase = true,
    clothesConverted = true,
    clothesReverted = false,
    clothesMatch = true
  }

  --Load framework data
  jo.file.load(("_unit-test.framework-bridge.%s.server_data"):format(jo.framework:get()))

  -------------
  -- CLOTHES TEST
  -------------
  --Read skin data
  local originalClothes = json.decode(ClothesJSON)
  if prints.clothesBase then
    gprint("==== FROM ====")
    print(json.encode(originalClothes, { indent = true }))
  end

  --Convert to standard
  local standard = jo.framework:standardizeClothes(originalClothes)
  if prints.clothesConverted then
    gprint("==== Standard =====")
    print(json.encode(standard, { indent = true }))
  end

  --Revert to framework
  local reverted = jo.framework:revertClothes(standard)
  if prints.clothesReverted then
    gprint("===== reverted =====")
    print(json.encode(reverted, { indent = true }))
  end

  --Compare the original framework data with reversed data
  if prints.clothesMatch then
    print("===== DON'T MATCH =====")
    local errorCount = 0
    for key, value in pairs(originalClothes) do
      if ((not reverted[key]) or not (reverted[key] == value or table.isEgal(reverted[key], value, true))) and not (value == 0 and not reverted[key]) then
        errorCount += 1
        print("--- Value changed:", key, "\tFrom:", value, (" (%s)"):format(type(value)), "To:", reverted[key], (" (%s)"):format(type(reverted[key])))
      end
    end
    print(("==== ERROR: %d ===="):format(errorCount))
    print("Number key in original", table.count(originalClothes))
    print("Number key in reverted", table.count(reverted))
  end
end


return TESTS
