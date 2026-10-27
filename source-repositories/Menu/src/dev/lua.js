// Build the menus as the Lua module sends them to the NUI (jo.menu.create + MenuClass:addItem + MenuClass:send),
// so the dev scenarios render exactly like in game

const MENU_DEFAULTS = {
  title: "Jump On",
  subtitle: "",
  type: "list",
  numberOnScreen: 8,
  currentIndex: 1,
  distanceToClose: false,
};

const ITEM_DEFAULTS = {
  title: "",
  subtitle: "",
  footer: "",
  child: false,
  sliders: [],
  price: false,
  data: [],
  visible: true,
  description: "",
  prefix: false,
  statistics: [],
  disabled: false,
  textRight: false,
  bufferOnChange: true,
};

// jo.menu.create(id, data) + menu:addItem(item) for each item
export function luaMenu(id, data = {}, items = []) {
  const menu = { ...MENU_DEFAULTS, ...data, id };
  menu.numberOnScreen = Math.min(data.numberOnScreen || 8, 13);
  menu.items = items.map((item, i) => ({ ...ITEM_DEFAULTS, ...item, index: i + 1 }));
  return menu;
}

// Full URL of an image shipped with the menu, like `nui://jo_libs/nui/menu/assets/images/<path>` in game
export function nui(path) {
  return `${window.location.origin}/assets/images/${path}`;
}
