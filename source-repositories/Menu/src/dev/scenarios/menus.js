// Scenarios of the documentation page about the menus (docs/jo_libs/modules/menu/menus.md)
import { luaMenu, nui } from "../lua";

const HEADER = ["header", "#title"];

export const tailorShop = [
  { title: "Stetson", icon: "hats", price: { money: 12.5 } },
  { title: "Wool coat", icon: "coats", price: { money: 35 } },
  { title: "Flannel shirt", icon: "shirts_full", price: { money: 4.25 } },
  { title: "Leather vest", icon: "vests", price: { money: 9 } },
  { title: "Work pants", icon: "pants", price: { money: 6.5 } },
  { title: "Riding boots", icon: "boots", price: { money: 15 } },
  { title: "Gloves", icon: "gloves", price: { money: 3 } },
  { title: "Bandana", icon: "neckerchiefs", price: { money: 1.75 } },
  { title: "Belt", icon: "belts", price: { money: 2.5 } },
  { title: "Spectacles", icon: "eyewear", price: { money: 5 } },
  { title: "Silver ring", icon: "jewelry_rings", price: { gold: 1 } },
  { title: "Satchel", icon: "satchels", price: { money: 20 } },
];

// Items without icon: one row per item
export const tailorNames = tailorShop.map(({ icon, ...item }) => item);

export const stableTiles = [
  { title: "Saddles", icon: "horse_saddles" },
  { title: "Blankets", icon: "horse_blankets" },
  { title: "Bridles", icon: "horse_bridles" },
  { title: "Saddlebags", icon: "horse_saddlebags" },
  { title: "Bedrolls", icon: "horse_bedrolls" },
  { title: "Horns", icon: "saddle_horns" },
  { title: "Stirrups", icon: "saddle_stirrups" },
  { title: "Lanterns", icon: "saddle_lanterns" },
  { title: "Manes", icon: "horse_manes" },
  { title: "Tails", icon: "horse_tails" },
  { title: "Masks", icon: "horse_masks" },
  { title: "Horseshoes", icon: "horseshoes" },
];

export default {
  "menu-list": {
    menus: [luaMenu("store", { title: "Tailor", subtitle: "Clothes", numberOnScreen: 12 }, tailorShop)],
  },
  "menu-tile": {
    menus: [luaMenu("stable", { title: "Stable", subtitle: "Horse equipment", type: "tile" }, stableTiles)],
  },
  "menu-number-on-screen": {
    menus: [luaMenu("store", { title: "Tailor", subtitle: "Clothes", numberOnScreen: 5 }, tailorNames)],
    index: 3,
  },
  "menu-tile-lines": {
    menus: [
      luaMenu(
        "stable",
        { title: "Stable", subtitle: "Horse equipment", type: "tile", numberOnLine: 3, numberLineOnScreen: 2 },
        stableTiles
      ),
    ],
  },
  "menu-title": {
    menus: [
      luaMenu(
        "store",
        { title: "Valentine", subtitle: "Tailor <span style='color:#d4af37'>(12)</span>" },
        tailorShop
      ),
    ],
    capture: HEADER,
  },
  "menu-image": {
    menus: [
      luaMenu(
        "store",
        {
          title: "Tailor",
          subtitle: "Clothes",
          numberOnScreen: 8,
          image: { url: nui("background_dev.jpg"), height: 140, style: "width: 100%; object-fit: cover; object-position: 50% 70%" },
        },
        tailorShop
      ),
    ],
  },
  "menu-back-button": {
    menus: [luaMenu("store", { title: "Tailor", subtitle: "Clothes", displayBackButton: true }, tailorShop)],
    capture: HEADER,
  },
  "menu-hide-background": {
    menus: [
      luaMenu(
        "store",
        { title: "Tailor", subtitle: "Clothes", numberOnScreen: 12, hideBackground: true },
        tailorShop
      ),
    ],
  },
  "menu-price": {
    menus: [
      luaMenu("barber", { title: "Barber", subtitle: "Haircuts", price: { money: 2.5 }, priceTitle: "Haircut" }, [
        { title: "Buzzed", icon: "hair_buzzed" },
        { title: "Parted left", icon: "hair_part_left" },
        { title: "Parted middle", icon: "hair_part_middle" },
        { title: "Swept back", icon: "hair_swept_back" },
        { title: "Bald", icon: "clothing_item_hair_bald", price: { money: 1 }, priceTitle: "Shave" },
      ]),
    ],
  },
  "menu-loader": {
    menus: [luaMenu("store", { title: "Tailor", subtitle: "Clothes" }, tailorShop.slice(0, 5))],
    loader: true,
  },
  "menu-lang": {
    menus: [luaMenu("store", { title: "Tailleur", subtitle: "Vêtements", numberOnScreen: 8 }, tailorShop)],
    lang: { of: "%1 sur %2", price: "Prix", devise: "€" },
  },
  "menu-css-classes": {
    menus: [
      luaMenu("classes", { title: "CSS classes", subtitle: "iconClass", numberOnScreen: 10 }, [
        { title: "No class", icon: "star" },
        { title: "fgold", icon: "star", iconClass: "fgold" },
        { title: "fred", icon: "star", iconClass: "fred" },
        { title: "fgreen", icon: "star", iconClass: "fgreen" },
        { title: "bw opacity50", icon: "star", iconClass: "bw opacity50" },
      ]),
    ],
    capture: ["#list-items"],
  },
  "menu-soft-hide": {
    menus: [luaMenu("store", { title: "Tailor", subtitle: "Clothes" }, tailorShop)],
    show: false,
    keepBackground: true,
  },
};
