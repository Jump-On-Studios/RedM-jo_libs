// Dev scenarios: open http://localhost:5173/?scenario=<name> to display a predefined menu
// Add `&clean` to hide the dev buttons (for the documentation screenshots)
// Open http://localhost:5173/?scenario=list to get the list of the scenarios in the console
//
// A scenario is an object:
// {
//   menus: [luaMenu(...)],     menus sent with `updateMenu`, the first one is the current menu
//   current: "id",             (optional) the current menu
//   history: ["id"],           (optional) menus opened before the current one, to display the back arrow
//   index: 1,                  (optional) the active item, 1-based like in Lua
//   lang: {},                  (optional) translated strings sent with `updateLang`
//   position: "right",         (optional) menu position sent with `updateMenuPosition`
//   loader: true,              (optional) display the loader
//   show: false,               (optional) don't display the menu
//   keepBackground: true,      (optional) with `show: false`, keep the background of the menu
//   after: (post) => {},       (optional) called once the menu is displayed
//   capture: ["#item-0"],      (optional) CSS selectors of the area to capture for the documentation, the whole menu by default
//   hide: [".palette-cursor"], (optional) CSS selectors of the elements to hide
// }

import overview from "./scenarios/overview";
import menus from "./scenarios/menus";
import items from "./scenarios/items";
import sliders from "./scenarios/sliders";
import statistics from "./scenarios/statistics";

export const scenarios = { ...overview, ...menus, ...items, ...sliders, ...statistics };
window.devScenarioNames = Object.keys(scenarios);

const params = new URLSearchParams(window.location.search);
export const scenarioName = params.get("scenario");
export const cleanMode = params.has("clean");

function post(event, data = {}) {
  window.postMessage({ event, ...data });
}

export function runScenario(name) {
  const scenario = scenarios[name];
  if (!scenario) {
    console.log("Available scenarios:", Object.keys(scenarios).join(", "));
    return false;
  }

  if (scenario.hide) {
    const style = document.createElement("style");
    style.textContent = `${scenario.hide.join(", ")} { visibility: hidden !important; }`;
    document.head.appendChild(style);
  }
  post("updateLang", { lang: scenario.lang });
  if (scenario.position) post("updateMenuPosition", { menuRight: scenario.position });
  scenario.menus.forEach((menu) => post("updateMenu", { menu }));

  setTimeout(() => {
    const current = scenario.current || scenario.menus[0].id;
    const history = scenario.history || [];
    [...history, current].forEach((id, i) => post("setCurrentMenu", { menu: id, keepHistoric: i > 0, reset: false }));
    if (scenario.index) post("setCurrentIndex", { menu: current, index: scenario.index });
    if (scenario.loader) post("displayLoader", { show: true });
    if (scenario.show !== false) {
      post("updateShow", { show: true, cancelAnimation: true });
    } else if (scenario.keepBackground) {
      post("updateShow", { show: true, cancelAnimation: true });
      setTimeout(() => post("updateShow", { show: false, cancelAnimation: true, keepBackground: true }), 50);
    }
    if (scenario.after) setTimeout(() => scenario.after(post), 100);
    // Read by the screenshot script
    window.devScenarioCapture = scenario.capture || [".menu .container"];
    setTimeout(() => document.body.setAttribute("data-scenario-ready", name), 600);
  }, 200);
  return true;
}
