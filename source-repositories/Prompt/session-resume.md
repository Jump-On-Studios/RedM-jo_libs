# Session Resume - Prompt NUI price display

## Context

This repo is the Vue/Vite NUI source for `jo_libs` prompt UI:

- Source repo: `source-repositories/Prompt`
- Built NUI output: `jo_libs/nui/prompt`
- Lua module using it: `jo_libs/modules/prompt-nui/client.lua`

The user wanted to reuse the Menu NUI price display feature in Prompt NUI. The reference implementation is:

- `source-repositories/Menu/src/components/layout/PriceDisplay.vue`
- Menu Lua price formatting lives in `jo_libs/modules/menu/shared.lua` as `jo.menu.formatPrice`

Goal: prompts can display complex prices with the same price structure as the Menu: money, gold, and item prices with images. `rol` is intentionally postponed.

## Decisions Made

- The new Lua signature must not break existing code.
- Final signature chosen:

```lua
GroupClass:addPrompt(key, label, holdTime, page, price)
```

- Existing calls like `addPrompt(key, label, holdTime, page)` must keep working.
- Price is displayed immediately after the prompt label and before the keyboard keys.
- PrimeVue / `v-tooltip` from the Menu is not needed and must not be added.
- Item images are not owned by the Prompt module in production.
  - In production, Lua/framework code should send `price.image` as a `nui://...` URL or another URL containing `://`.
  - Prompt keeps only one local fallback image for Chrome dev testing.
- The Prompt module must not include the Menu full `icons/` folder.
- `money_line.png` should live directly in `public/assets/images`, not in a `menu/` subfolder.

## What Was Implemented

### Lua: `jo_libs/modules/prompt-nui/client.lua`

Changes made:

- Added `jo.require("menu")` so Prompt can use `jo.menu.formatPrice`.
- Added `price = false` to `PromptClass`.
- Added Lua annotation:

```lua
---@field price table|boolean
```

- Added:

```lua
function PromptClass:setPrice(price)
    self.price = price and jo.menu.formatPrice(price) or false
    self:refreshNUI("price")
end
```

- Updated `GroupClass:addPrompt`:

```lua
function GroupClass:addPrompt(key, label, holdTime, page, price)
```

- During prompt creation, it now calls:

```lua
prompt:setPrice(price)
```

Compatibility note: `page = page or 1` remains, so old calls with a 4th `page` argument still work.

### Vue: new `src/components/PriceDisplay.vue`

Created by adapting Menu's `PriceDisplay.vue`.

Important differences from Menu:

- No PrimeVue.
- No `v-tooltip`.
- Local language strings only:

```js
devise: '$'
free: 'Free'
```

- `getImage(url)` behavior:

```js
function getImage(url) {
  if (isNUIImage(url)) return url
  return './assets/images/icons/item.png'
}
```

So:

- `nui://...`, `https://...`, etc. are used as-is.
- Non-URL image names fall back to the one local dev image.

Supported render paths currently:

- `money`
- `gold`
- `item`
- `money = 0` as `Free`

`rol` is not rendered yet.

### Vue: `src/components/Prompt.vue`

Changes made:

- Imported `PriceDisplay`.
- Inserted after the label:

```vue
<PriceDisplay :price="prompt.price" right />
```

- Added CSS variable on `.prompt`:

```scss
--price-height: 1.8rem;
```

The row order is now:

- normal/right prompts: label -> price -> keys
- left prompts still use the existing `.isLeft { flex-direction: row-reverse; }`

### Dev fixtures: `src/dev.js`

Added sample prices so Chrome dev mode can visually test:

- money: `[{ money: 12.5 }]`
- gold: `[{ gold: 3 }]`
- item: local fallback with `image: 'item'`
- free: `[{ money: 0 }]`
- mixed item + money

These are only dev fixtures.

### Assets

Current intended source assets in Prompt:

- `public/assets/images/gold.png`
- `public/assets/images/money_line.png`
- `public/assets/images/icons/item.png`

Important: the large copied Menu icons folder was removed. There should only be one file under `public/assets/images/icons`: `item.png`.

Built output should mirror this after `npm run build`:

- `jo_libs/nui/prompt/assets/images/gold.png`
- `jo_libs/nui/prompt/assets/images/money_line.png`
- `jo_libs/nui/prompt/assets/images/icons/item.png`

There should be no `assets/images/menu/` folder.

## Build / Verification

`npm run build` was run successfully after implementation and after moving `money_line.png`.

Build warnings seen:

- Vue `:deep` combinator deprecation warnings from existing code.
- Font references (`crock.ttf`, `BebasNeue-Regular.ttf`) unresolved at build time but kept for runtime resolution.

These warnings existed/are non-blocking for this work.

## Current Git State Expectations

Expected modified/untracked areas include:

- `jo_libs/modules/prompt-nui/client.lua`
- `jo_libs/nui/prompt/*` build output
- `source-repositories/Prompt/src/components/Prompt.vue`
- `source-repositories/Prompt/src/components/PriceDisplay.vue`
- `source-repositories/Prompt/src/dev.js`
- `source-repositories/Prompt/public/assets/images/gold.png`
- `source-repositories/Prompt/public/assets/images/money_line.png`
- `source-repositories/Prompt/public/assets/images/icons/item.png`

Expected not to exist:

- `source-repositories/Prompt/public/assets/images/menu/`
- `jo_libs/nui/prompt/assets/images/menu/`
- the full Menu `icons/` folder in Prompt

## User Feedback / Corrections During Session

The first implementation copied the entire Menu `public/assets/images/icons/` directory. The user clarified that this was wrong because item images in Prompt will come from Lua as `nui://...` URLs from other resources such as `vorp_inventory`.

Correction applied:

- Removed the mass-copied icon folders.
- Kept only one local fallback image for Chrome dev testing.
- `PriceDisplay.vue` now uses URL images as-is and falls back to `item.png` only for non-URL image values.

The user also requested no `public/assets/images/menu/` folder. `money_line.png` was moved up to `public/assets/images/money_line.png`, and the CSS reference was updated.

## Things To Watch Next

- Check visual alignment of price text in Chrome or in-game NUI. The screenshot showed prices rendering with the prompt label style; if font/size should match Menu more closely, tune `PriceDisplay.vue` CSS.
- Decide whether `PriceDisplay` should explicitly set `font-family` rather than inherit from the prompt row.
- Confirm production item payloads from Lua include `image = "nui://..."` or another `://` URL.
- If `rol` support is needed later, Menu currently normalizes `rol` in Lua but does not render it in `PriceDisplay.vue`; it needs a separate visual design/asset decision.

