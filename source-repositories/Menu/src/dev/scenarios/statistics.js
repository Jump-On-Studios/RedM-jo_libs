// Scenarios of the documentation page about the statistics (docs/jo_libs/modules/menu/statistics.md)
import { luaMenu } from "../lua";

function withStatistics(statistics, capture = [".statistic"]) {
  return {
    menus: [
      luaMenu("statistics", { title: "Gunsmith", subtitle: "Revolvers" }, [
        { title: "Cattleman revolver", icon: "holsters_left", statistics },
        { title: "Schofield revolver", icon: "holsters_left" },
      ]),
    ],
    capture,
  };
}

const allStatistics = [
  { label: "Manufacturer", value: "Cattleman" },
  { label: "Damage", type: "bar", value: [6, 8] },
  { label: "Range", type: "bar-style", value: ["active", "active", "active fgold", "possible fgold", "", "", ""] },
  { label: "Accuracy", type: "weapon-bar", value: [65, 100] },
  { label: "Upgrade", type: "weapon-bar", value: { max: 100, bars: [{ value: 50 }, { value: 70, color: "#d4af37" }] } },
  {
    label: "Condition",
    type: "icon",
    value: [{ icon: "star", opacity: 1 }, { icon: "star", opacity: 1 }, { icon: "star", opacity: 0.3 }],
  },
  { label: "Repair", type: "price", value: { money: 2.5 } },
];

export default {
  "stats-overview": withStatistics(allStatistics, [".menu .container"]),
  "stat-text": withStatistics([
    { label: "Manufacturer", value: "Cattleman" },
    { label: "Ammo", value: "<span style='color:#d4af37'>12</span> / 36" },
  ]),
  "stat-bar": withStatistics([
    { label: "Damage", type: "bar", value: [6] },
    { label: "Fire rate", type: "bar", value: [4, 7] },
  ]),
  "stat-bar-penalty": withStatistics([{ label: "Reload speed", type: "bar", value: [3, 6], class: "penalty" }]),
  "stat-bar-style": withStatistics([
    {
      label: "Range",
      type: "bar-style",
      value: ["active", "active fgold", "active fred", "possible", "possible fred", "", ""],
    },
  ]),
  "stat-icon": withStatistics([
    { label: "Health", type: "icon", value: ["player_health", "player_health", { icon: "player_health", opacity: 0.3 }] },
    { label: "Stamina", type: "icon", value: [{ icon: "player_stamina", opacity: 1 }, { icon: "player_stamina", opacity: 0.5 }] },
  ]),
  "stat-weapon-bar": withStatistics([{ label: "Accuracy", type: "weapon-bar", value: [65, 100] }]),
  "stat-weapon-bar-segments": withStatistics([
    {
      label: "Upgrade",
      type: "weapon-bar",
      value: { max: 100, bars: [{ value: 40 }, { value: 60, color: "#27ae60" }, { value: 75, color: "#27ae60", opacity: 0.4 }] },
    },
    {
      label: "Downgrade",
      type: "weapon-bar",
      value: { max: 100, bars: [{ value: 45 }, { value: 70, color: "#c0392b" }] },
    },
  ]),
  "stat-price": withStatistics([
    { label: "Repair", type: "price", value: { money: 2.5 } },
    { label: "Upgrade", type: "price", value: [{ money: 10 }, { gold: 1 }] },
  ]),
};
