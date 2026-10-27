// Scenarios of the documentation page about the sliders (docs/jo_libs/modules/menu/sliders.md)
import { luaMenu } from "../lua";

const SLIDERS = [".sliders .slider", ".slider-description"];

function withSliders(sliders, itemData = {}, capture = SLIDERS, menuData = {}) {
  return {
    menus: [
      luaMenu("sliders", { title: "Sliders", subtitle: "Example", ...menuData }, [
        { title: "Bandana", icon: "neckerchiefs", sliders, ...itemData },
        { title: "Stetson", icon: "hats" },
      ]),
    ],
    capture,
  };
}

const metals = ["gold", "silver", "copper", "brass", "nickle", "iron", "steel_blued", "steel_blackened"];

// Every palette shipped with the menu, see `palette-<name>` scenarios
export const palettes = [
  "tint_generic_clean",
  "tint_hair",
  "tint_horse",
  "tint_horse_leather",
  "tint_leather",
  "tint_makeup",
  "tint_eye",
  "metaped_tint_generic_clean",
  "metaped_tint_hair",
  "metaped_tint_horse",
  "metaped_tint_horse_leather",
  "metaped_tint_leather",
  "metaped_tint_makeup",
  "metaped_tint_eye",
  "metaped_tint_animal",
  "metaped_tint_combined",
  "metaped_tint_combined_leather",
  "metaped_tint_hat",
  "metaped_tint_mpadv",
  "generic_wagon_palette",
];

const paletteScenarios = {};
palettes.forEach((name) => {
  paletteScenarios[`palette-${name}`] = {
    ...withSliders([{ type: "palette", title: name, tint: name, current: 0 }], {}, [".palette-strip"]),
    hide: [".palette-cursor"],
  };
});

export default {
  "sliders-overview": withSliders(
    [
      { title: "Style", current: 2, values: ["Classic", "Rolled", "Open", "Tied"] },
      { type: "palette", title: "Color", tint: "tint_generic_clean", current: 18 },
      { type: "grid", title: "Position", labels: ["Left", "Right", "Up", "Down"], values: [
        { current: 0.2, min: -1, max: 1 },
        { current: 0.6, min: -1, max: 1 },
      ] },
    ],
    { previewPalette: true },
    [".menu .container"]
  ),
  "slider-default": withSliders([{ title: "Variation", current: 3, values: ["Brown", "Black", "Grey", "White", "Red"] }]),
  "slider-default-description": withSliders([
    { title: "Variation", current: 2, values: ["Brown", "Black", "Grey"], description: "Hold <b>Shift</b> to rotate the hat" },
  ]),
  "slider-default-price": withSliders(
    [
      {
        title: "Size",
        current: 2,
        values: [
          { label: "Small", price: { money: 5 } },
          { label: "Medium", price: { money: 8 } },
          { label: "Large", price: { money: 12, gold: 1 } },
        ],
      },
    ],
    { price: { money: 5 } },
    [".menu .container"]
  ),
  "slider-switch": {
    menus: [
      luaMenu("sliders", { title: "Sliders", subtitle: "Example" }, [
        {
          title: "Hat",
          icon: "hats",
          sliders: [{ type: "switch", current: 2, values: [{ label: "On head" }, { label: "In hand" }, { label: "Hidden" }] }],
        },
        {
          title: "Bandana",
          icon: "neckerchiefs",
          sliders: [{ type: "switch", current: 1, values: [{ label: "Up" }, { label: "Down" }] }],
        },
      ]),
    ],
    capture: ["#item-0", "#item-1"],
  },
  "slider-grid": withSliders([
    { type: "grid", title: "Width", labels: ["Thin", "Wide"], values: [{ current: 0.3, min: 0, max: 1 }] },
  ]),
  "slider-grid-2d": withSliders([
    {
      type: "grid",
      title: "Position",
      labels: ["Left", "Right", "Up", "Down"],
      values: [
        { current: 0.4, min: -1, max: 1, gap: 0.05 },
        { current: -0.5, min: -1, max: 1, gap: 0.05 },
      ],
    },
  ]),
  "slider-palette": withSliders([{ type: "palette", title: "Color", tint: "tint_makeup", current: 14 }]),
  "slider-palette-range": withSliders([
    { type: "palette", title: "Color", tint: "tint_generic_clean", min: 10, max: 30, disabledTints: [12, 13, 14, 20], current: 16 },
  ]),
  "slider-palette-multiple": withSliders(
    [
      { type: "palette", title: "Primary color", tint: "tint_generic_clean", current: 5 },
      { type: "palette", title: "Secondary color", tint: "tint_generic_clean", current: 40 },
      { type: "palette", title: "Tertiary color", tint: "tint_generic_clean", current: 90 },
    ],
    { previewPalette: true },
    [".menu .container"]
  ),
  "slider-sprite": withSliders([
    {
      type: "sprite",
      title: "Metal",
      current: 2,
      values: metals.map((metal) => ({ sprite: `tints/metal_swatch_${metal}` })),
    },
  ]),
  "slider-color": withSliders([
    {
      type: "color",
      title: "Color",
      current: 1,
      values: [
        { rgb: "#8B4513" },
        { rgb: ["#2c3e50", "#c0392b"] },
        { rgb: ["#f1c40f", "#27ae60", "#2980b9"] },
        { rgb: ["#f1c40f", "#27ae60", "#2980b9"], style: "vertical-lines" },
        { palette: { palette: "tint_generic_clean", tint0: 10, tint1: 40, tint2: 90 } },
      ],
    },
  ]),
  "slider-sprite-tags": withSliders([
    {
      type: "sprite",
      title: "Engraving",
      current: 1,
      values: [
        { sprite: "tints/gunsmith_engraving_1", tagColor: "green", tagText: "New" },
        { sprite: "tints/gunsmith_engraving_2", icon: "lock", iconClass: "fred" },
        { sprite: "tints/gunsmith_engraving_3", tagColor: "gold" },
        { sprite: "tints/gunsmith_engraving_4", icon: "star", iconClass: "fgold" },
        { sprite: "tints/gunsmith_engraving_5", tagText: "x2", tagColor: "#c0392b", tagTextColor: "white" },
      ],
    },
  ]),
  "slider-sprite-tick": withSliders([
    {
      type: "sprite",
      title: "Metal",
      current: 4,
      displayTick: true,
      tickIndex: 1,
      values: metals.slice(0, 6).map((metal) => ({ sprite: `tints/metal_swatch_${metal}` })),
    },
  ]),
  ...paletteScenarios,
};
