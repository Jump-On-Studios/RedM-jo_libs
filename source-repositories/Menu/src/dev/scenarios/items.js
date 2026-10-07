// Scenarios of the documentation page about the items (docs/jo_libs/modules/menu/items.md)
import { luaMenu, nui } from "../lua";

const items = (count) => Array.from({ length: count }, (_, i) => `#item-${i}`);

function single(menuData, list, capture, extra = {}) {
  return { menus: [luaMenu("items", { title: "Items", subtitle: "Example", ...menuData }, list)], capture, ...extra };
}

export default {
  "item-title": single(
    {},
    [
      { title: "Stetson", subtitle: "Brown felt", icon: "hats" },
      { title: "Bowler <span style='color:#d4af37'>★</span>", icon: "hats" },
    ],
    items(2)
  ),
  "item-prefix": single(
    {},
    [
      { title: "Legendary saddle", prefix: "star", icon: "horse_saddles" },
      { title: "Locked saddle", prefix: "lock", icon: "horse_saddles" },
      { title: "Damaged saddle", prefix: "warning", icon: "horse_saddles" },
    ],
    items(3)
  ),
  "item-icon": single(
    {},
    [
      { title: "Icon of the menu", icon: "horse_saddles" },
      { title: "Image URL", icon: nui("tints/metal_swatch_gold.png") },
      { title: "Small icon", icon: "horse_saddles", iconSize: "small" },
      { title: "Without icon" },
    ],
    items(4)
  ),
  "item-icon-right": single(
    {},
    [
      { title: "Equipped", icon: "horse_saddles", iconRight: "tick" },
      { title: "Locked", icon: "horse_saddles", iconRight: "lock" },
    ],
    items(2)
  ),
  "item-text-right": single(
    {},
    [
      { title: "Saddles", icon: "horse_saddles", textRight: "12" },
      { title: "Horse", icon: "toast_horse_bond", textRight: "Level 4", textRightClass: "tiny" },
    ],
    items(2)
  ),
  "item-description": single(
    {},
    [
      {
        title: "Stetson",
        icon: "hats",
        description: "A wide brim hat made of felt.<br><b>Protects you from the sun.</b>",
      },
    ],
    [".description > *"]
  ),
  "item-footer": single(
    {},
    [{ title: "Stetson", icon: "hats", footer: "Press <b>Enter</b> to buy this hat" }],
    [".footer-text"]
  ),
  "item-image": single(
    {},
    [
      {
        title: "Valentine",
        icon: "toast_horse_bond",
        image: { url: nui("background_dev.jpg"), width: 300, height: 140, radius: 8, style: "object-fit: cover; object-position: 50% 70%" },
        description: "Fast travel to Valentine.",
      },
    ],
    [".description > *"]
  ),
  "item-color": single(
    {},
    [
      { title: "Red title", icon: "player_health", color: "#e74c3c" },
      {
        title: "Full color",
        icon: "player_health",
        color: { title: "#f1c40f", background: "rgba(241, 196, 15, 0.15)", accent: "#f1c40f", icon: "#f1c40f" },
      },
      { title: "Default", icon: "player_health" },
    ],
    items(3)
  ),
  "item-disabled": single(
    {},
    [
      { title: "Available", icon: "horse_saddles" },
      { title: "Disabled", icon: "horse_saddles", disabled: true, prefix: "lock" },
    ],
    items(2)
  ),
  "item-price-money": single({}, [{ title: "Flannel shirt", icon: "shirts_full", price: 4.25 }], [".price"]),
  "item-price-gold": single({}, [{ title: "Silver ring", icon: "jewelry_rings", price: { gold: 3 } }], [".price"]),
  "item-price-mixed": single({}, [{ title: "Saddle", icon: "horse_saddles", price: { money: 25, gold: 2 } }], [".price"]),
  "item-price-items": single(
    {},
    [
      {
        title: "Wagon repair",
        icon: "wagon",
        price: [
          { money: 5 },
          { item: "horseshoe", quantity: 3, label: "Horseshoe", image: "horseshoes" },
          { item: "wheel", quantity: 1, label: "Wheel", image: "wheel", quantityStyle: "circle" },
        ],
      },
    ],
    [".price"]
  ),
  "item-price-free": single({}, [{ title: "Old hat", icon: "hats", price: 0 }], [".price"]),
  "item-price-title": single(
    {},
    [{ title: "Stable slot", icon: "toast_horse_bond", price: { money: 10 }, priceTitle: "Rent per day" }],
    [".price"]
  ),
  "item-price-right": single(
    {},
    [
      { title: "Flannel shirt", icon: "shirts_full", price: 4.25, priceRight: true },
      { title: "Saddle", icon: "horse_saddles", priceRight: { gold: 2 } },
      { title: "Old hat", icon: "hats", price: 0, priceRight: true },
    ],
    items(3)
  ),
  "item-tile-extras": {
    menus: [
      luaMenu("tiles", { title: "Items", subtitle: "Tile menu", type: "tile", numberLineOnScreen: 1 }, [
        { title: "Quantity", icon: "satchels", quantity: 12 },
        { title: "Gold quantity", icon: "satchels", quantity: 3, quantityCircleClass: "fgold" },
        { title: "Quality", icon: "horse_saddles", quality: 2 },
        { title: "Stars", icon: "horse_saddles", stars: [3, 5] },
      ]),
    ],
    capture: ["#list-items"],
  },
  "item-tile-icon-right": {
    menus: [
      luaMenu("tiles", { title: "Items", subtitle: "Tile menu", type: "tile", numberLineOnScreen: 1 }, [
        { title: "Equipped", icon: "horse_saddles", iconRight: "tick" },
        { title: "Locked", icon: "horse_saddles", iconRight: "lock", iconClass: "bw" },
        { title: "New", icon: "horse_saddles", iconRight: "star" },
        { title: "Default", icon: "horse_saddles" },
      ]),
    ],
    capture: ["#list-items"],
  },
  "item-tile-padding": {
    menus: [
      luaMenu("tiles", { title: "Items", subtitle: "Tile menu", type: "tile", numberLineOnScreen: 1 }, [
        { title: "Default padding", icon: nui("tints/metal_swatch_copper.png") },
        { title: "tilePadding = 0.5", icon: nui("tints/metal_swatch_copper.png"), tilePadding: 0.5 },
        { title: "tilePadding = 0", icon: nui("tints/metal_swatch_copper.png"), tilePadding: 0 },
      ]),
    ],
    capture: ["#list-items"],
  },
  "item-preview-palette": single(
    {},
    [
      {
        title: "Bandana",
        icon: "neckerchiefs",
        previewPalette: true,
        sliders: [
          { type: "palette", title: "Main color", tint: "tint_makeup", current: 22 },
          { type: "palette", title: "Second color", tint: "tint_makeup", current: 44 },
        ],
      },
      { title: "Hat", icon: "hats" },
    ],
    ["#item-0"]
  ),
};
