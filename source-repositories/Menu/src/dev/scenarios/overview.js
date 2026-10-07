// Scenarios of the documentation home page (docs/jo_libs/modules/menu/index.md)
import { luaMenu } from "../lua";

const tailorItems = [
  {
    title: "Hats",
    icon: "hats",
    textRight: "12",
    child: "hats",
    description: "Cowboy hats, bowlers and caps for every occasion.",
  },
  { title: "Coats", icon: "coats", textRight: "8", child: "coats" },
  { title: "Shirts", icon: "shirts_full", textRight: "15", child: "shirts" },
  { title: "Vests", icon: "vests", textRight: "6", child: "vests" },
  { title: "Pants", icon: "pants", textRight: "9", child: "pants" },
  { title: "Boots", icon: "boots", textRight: "7", child: "boots" },
  { title: "Gloves", icon: "gloves", textRight: "4", child: "gloves" },
  { title: "Accessories", icon: "accessories", textRight: "21", child: "accessories" },
];

const hatsItems = [
  {
    title: "Stetson",
    icon: "hats",
    iconRight: "tick",
    description: "A wide brim hat made of felt, perfect to protect you from the sun.",
    price: { money: 12.5 },
    sliders: [{ title: "Variation", current: 2, values: ["Brown", "Black", "Grey", "White"] }],
    statistics: [
      { label: "Warmth", type: "bar", value: [4, 6] },
      { label: "Durability", type: "weapon-bar", value: [70, 100] },
    ],
  },
  { title: "Bowler", icon: "hats", price: { money: 8 } },
  { title: "Flat cap", icon: "hats", price: { money: 3.25 } },
  { title: "Gambler", icon: "hats", price: { gold: 2 } },
  { title: "Top hat", icon: "hats", price: { money: 25, gold: 1 }, disabled: true },
];

const lockerItems = [
  { title: "Stetson", icon: "hats", price: { money: 12.5 } },
  { title: "Bowler", icon: "hats", price: { money: 8 } },
  { title: "Flat cap", icon: "hats", price: { money: 3.25 } },
];

export default {
  // MenuItem:updateValue() then MenuClass:push(): the item is bought
  "events-update-before": {
    menus: [luaMenu("hats", { title: "Tailor", subtitle: "Hats" }, lockerItems)],
    capture: ["#item-0", "#item-1", "#item-2"],
  },
  "events-update-after": {
    menus: [luaMenu("hats", { title: "Tailor", subtitle: "Hats" }, lockerItems)],
    capture: ["#item-0", "#item-1", "#item-2"],
    after: (post) =>
      post("updateMenuValues", {
        menu: "hats",
        updated: [
          { keys: ["items", 1, "textRight"], action: "update", value: "Owned" },
          { keys: ["items", 1, "price"], action: "delete" },
          { keys: ["items", 2, "disabled"], action: "update", value: true },
        ],
      }),
  },
  "overview-list": {
    menus: [luaMenu("tailor", { title: "Tailor", subtitle: "Clothes", numberOnScreen: 12 }, tailorItems)],
  },
  "overview-shop": {
    menus: [luaMenu("hats", { title: "Tailor", subtitle: "Hats" }, hatsItems)],
  },
  "overview-navigation": {
    menus: [
      luaMenu("tailor", { title: "Tailor", subtitle: "Clothes", numberOnScreen: 12 }, tailorItems),
      luaMenu("hats", { title: "Tailor", subtitle: "Hats" }, hatsItems),
    ],
    current: "hats",
    history: ["tailor"],
  },
  "overview-tile": {
    menus: [
      luaMenu(
        "wardrobe",
        { title: "Wardrobe", subtitle: "My outfits", type: "tile", numberLineOnScreen: 3 },
        [
          { title: "Ranch outfit", icon: "outfits", iconRight: "tick", description: "Your current outfit" },
          { title: "Sunday best", icon: "outfit" },
          { title: "Hunting gear", icon: "loadouts" },
          { title: "Winter coat", icon: "coats_closed" },
          { title: "Poncho", icon: "ponchos" },
          { title: "Gunslinger", icon: "gunbelts" },
          { title: "Dress", icon: "dresses" },
          { title: "Overalls", icon: "overalls_full" },
          { title: "Cloak", icon: "cloaks" },
          { title: "Save the outfit", icon: "save" },
        ]
      ),
    ],
  },
};
