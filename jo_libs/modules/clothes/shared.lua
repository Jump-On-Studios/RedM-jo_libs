jo.clothes = setmetatable({},{
  __index = self
})

jo.clothes.order = {
	'ponchos',
	'cloaks',
  'hair_accessories',
  'dresses',
  'gloves',
	'coats',
	'coats_closed',
	'vests',
	'suspenders',
	'neckties',
	'neckwear',
	'shirts_full',
	'spats',
  'gunbelts',
	'gauntlets',
  'holsters_left',
	'loadouts',
	'belt_buckles',
  'belts',
  'skirts',
  'pants',
  'boots',
	'boot_accessories',
	'accessories',
	'satchels',
	'jewelry_rings_right',
	'jewelry_rings_left',
	'jewelry_bracelets',
	'aprons',
	'chaps',
  'badges',
  'gunbelt_accs',
  'eyewear',
  'armor',
	'masks',
	'masks_large',
	'hats',
  'hair',
  'beards_complete',
  'teeth'
}

jo.clothes.VORPCategories = {
  Hat = "hats",
  Mask = "masks",
  Shirt = "shirts_full",
  Suspender = "suspenders",
  Vest = "vests",
  Coat = "coats",
  Poncho = "ponchos",
  Cloak = "cloaks",
  Glove = "gloves",
  RingRh = "jewelry_rings_right",
  RingLh = "jewelry_rings_left",
  Bracelet = "jewelry_bracelets",
  Gunbelt = "gunbelts",
  Belt = "belts",
  Buckle = "belt_buckles",
  Holster = "holsters_left",
  Pant = "pants",
  Chap = "chaps",
  Spurs = "boot_accessories",
  CoatClosed = "coats_closed",
  --Ties = "neckties",
  NeckTies = "neckties",
  Skirt = "skirts",
  Boots = "boots",
  EyeWear = "eyewear",
  NeckWear = "neckwear",
  Spats = "spats",
  GunbeltAccs = "gunbelt_accs",
  Gauntlets = "gauntlets",
  Loadouts = "loadouts",
  Accessories = "accessories",
  Satchels = "satchels",
  dresses = "dresses",
  Dress = "dresses",
  armor = "armor",
  Badge = "badges",
  bow = "hair_accessories"
}

---@param category string the category name
---@return string category the right category name
function jo.clothes.fixCategoryName(category)
  if jo.clothes.VORPCategories[category] then
    return jo.clothes.VORPCategories[category]
  end
  return category
end

---@param data any the clothes data
---@return table
function jo.clothes.formatClothesData(data)
  if type(data) == "table" then
    if type(data.hash) == "table" then --for VORP
      return data.hash
    end
    return data
  end
  if type(data) ~= "number" then data = tonumber(data) end
  if data == 0 or data == -1 or data == 1 or data == nil then
    data = false
  end
  return {
    hash = data
  }
end

---@param clothesList table
function jo.clothes.cleanClothesTable(clothesList)
  local list = {}
  for _,cat in pairs (jo.clothes.order) do
    list[cat] = 0
  end
  for cat,hash in pairs (clothesList or {}) do
    if list[cat] then
      list[cat] = jo.clothes.formatClothesData(hash)
    end
  end
  return list
end