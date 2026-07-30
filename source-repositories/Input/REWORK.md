# Rework du NUI Input — note de contexte

> Document écrit pour reprendre le travail plus tard sans avoir à re-explorer.
> Il couvre le **pourquoi**, les **décisions**, et surtout les **invariants** :
> plusieurs choix d'apparence anodine sont en réalité liés entre eux, et en
> casser un casse les autres. Ils sont marqués ⚠️.

Branche : `input.nui-rework`.

---

## Pourquoi ce rework

Le NUI Input était un monolithe : [`_archives/App.vue`](_archives/App.vue), 490 lignes,
contenait le template des 9 types d'entries, le helper `post()` vers le Lua,
l'écoute des messages, la validation et l'intégralité du CSS. Seul le formulaire
de prix avait été extrait, dans `_archives/components/PriceForm.vue`. Ajouter ou
modifier un type d'entry voulait dire toucher ce fichier unique.

Le CSS mélangeait `rem`, `em`, `vw/vh` et px, sans aucun mécanisme de mise à
l'échelle. C'était le seul repo NUI de la famille dans ce cas :

| repo | stratégie de scaling |
|---|---|
| Menu | `vh` sur absolument toutes les dimensions |
| Prompt | `font-size: 2.5vh` sur `html,body` puis `rem` partout |
| Minigame | px bruts + directive `v-ui-scaler` (`transform: scale()`) |
| **Input (avant)** | **aucune — mélange rem/em/vw/px, rendu figé à 16px** |

L'objectif du rework :

1. **un composant Vue par type d'entry**, au lieu d'un seul gros template ;
2. **tout en px sur une base 1080**, mis à l'échelle par la directive `ui-scaler`
   (stratégie Minigame, la seule cohérente avec des composants autonomes) ;
3. **toutes les fonctionnalités existantes préservées**, le module Lua n'étant
   pas touché ;
4. **V1 volontairement non stylée** : fonds plats, bordures `1px solid`. Le style
   est un chantier séparé (V2).

---

## ⚠️ Contrat avec le Lua — à ne jamais casser

[`jo_libs/modules/input/client.lua`](../../jo_libs/modules/input/client.lua) **n'a
pas été modifié** et ne doit pas l'être sans raison. Le contrat :

**Entrée** — message `window.postMessage` de forme `{ event: 'newInput', data: { rows } }`.
On garde `event`, on ne passe **pas** à `{ type, data }` comme Prompt et Minigame,
sinon il faut toucher au Lua.

**Sortie validée** — `POST jo_input:click` avec :

```js
{ action: string, result: Record<string, unknown>, priceIds: string[] }
```

`priceIds` liste les ids des entries `price`, pour que `convertNUIPrice`
(client.lua:84) sache lesquelles repasser dans `jo.pricing`.

**Sortie annulation** — `POST jo_input:click` avec le body `false` (pas un objet).
Le Lua résout sa promise à `false`.

**Formats de prix émis** — exactement ce que `jo.pricing` consomme :

```js
{ isProcessing: false, costs: [ { money: 12.5 }, { item: 'x', quantity: 1, keep: true } ] }
{ operator: 'or', prices: [ { isProcessing: false, costs: [...] }, ... ] }
```

⚠️ **Une valeur absente reste `undefined`, jamais `null`.** `JSON.stringify`
supprime alors la clé et le Lua lit `nil`, comme avant le rework. Avec `null` il
recevrait un sentinel. C'est le rôle du commentaire dans `stores/input.ts::open()`.

---

## Décisions actées (et pourquoi)

| Sujet | Choix | Raison |
|---|---|---|
| Langage | TypeScript | aligné sur Minigame, et 9 types d'entries à typer |
| État | Pinia, options API | comme Menu / Prompt / Minigame |
| `type="select"` | composant maison | PrimeVue supprimé : son CSS est en rem et il teleporte |
| `type="date"` | `@vuepic/vue-datepicker` gardé | réécrire un calendrier était hors budget V1 |
| Unités | px partout | seule exception : l'overlay, voir invariants |
| Styles | SCSS dans tous les composants | nesting + mixins partagés, voir ci-dessous |
| Base de scale | **1080** | tous les tokens px sont calibrés dessus (Minigame utilise 1024 pour ses propres layouts) |
| Source du scale | **`innerHeight`** | voir invariant 5 |
| Dev | `dev.ts` + `DebugPanel.vue` | valider les 9 types sans recompiler |

PrimeVue et `@primeuix/themes` supprimés : bundle **552 ko → 292 ko**.

---

## ⚠️ Les cinq invariants

Ce sont les pièges de la session. Chacun a coûté une itération.

### 1. L'overlay n'est pas scalé, le conteneur l'est

```
.input-overlay    position: fixed; inset: 0   ← seule exception au « tout en px »
  .input-container  v-ui-scaler + dimensions px  ← porte le transform
```

L'overlay doit couvrir l'écran quelle que soit l'échelle : il est donc en unités
viewport et **hors** du `transform`. Ne jamais déplacer la directive sur l'overlay.

### 2. Le conteneur ne doit JAMAIS scroller

`.input-container` est en `overflow: visible`. **Un conteneur qui scrolle clippe
forcément ses descendants en `position: absolute`** — c'est une règle CSS
incontournable. Remettre `overflow-y: auto` recasse instantanément le dropdown du
select et le calendrier.

C'est d'ailleurs ce que faisait l'ancien code : le conteneur ne scrollait pas non
plus (`overflow: hidden`), seule la liste d'options de prix avait son scroll
interne. `.price-form__options` a récupéré ce `max-height` + `overflow-y: auto`,
car c'est la seule partie qui peut réellement dépasser la hauteur du panneau.

### 3. Aucun teleport

Le dropdown du select est rendu dans son entry, et `VueDatePicker` est utilisé en
mode **`inline`** (pas son popup natif) avec `:teleport="false"`, enveloppé dans
un div absolu à nous. Tout ce qui sort de `.input-container` échappe au
`transform` et n'est plus scalé.

### 4. Les popups sont en absolu, pas dans le flux

Première tentative : popups dans le flux pour éviter le clipping → l'UI sautait à
chaque ouverture. Corrigé en `position: absolute; top: calc(100% + 2px)` avec
`z-index: 20` sur le wrapper quand il est ouvert. Vérifié : hauteur du conteneur
et position de la row des boutons **identiques** popup ouvert ou fermé.

### 5. `innerHeight`, pas `outerHeight`

La directive de Minigame utilise `window.outerHeight`. En jeu c'est équivalent
(CEF dessine la NUI sans chrome de fenêtre), mais **dans un navigateur de dev
`outerHeight` compte la barre de titre et les onglets** : mesuré à 415 contre
1080 pour `innerHeight`, la modale rendait à 400px au lieu de 1040. La copie
Input utilise donc `innerHeight`. Reste à confirmer en jeu que les deux valeurs
sont bien égales.

---

## Architecture

```
source-repositories/Input/
  _archives/                  ancien code, déplacé par git mv (historique préservé)
  src/
    types/entries.ts          union discriminée des 9 types + types du prix canonique
    helpers/luaHelper.ts      sendToLua() + hook onDevLuaCall pour le DebugPanel
    helpers/price.ts          logique de prix pure : parse / build / validate / summarize
    stores/input.ts           Pinia : rows, values, errors, validation, submit/cancel
    directives/ui-scaler.ts   copie de Minigame, base 1080 + innerHeight
    components/
      Bridge.vue              window.message → store
      InputModal.vue          overlay + conteneur + politique clavier
      InputRow.vue            dispatch par type via ENTRY_COMPONENTS
      entries/                un composant par type + index.ts (la map)
      entries/price/          PriceOption / PriceRequirement / PriceSummary
      debug/                  DebugPanel / DevBackground / DevComponent
    composables/              useEntryStyle / useEntryValue / useAutofocus
    styles/                   _mixins + tokens / reset / fonts / fields / datepicker (.scss)
    dev.ts                    fixtures nommées, aucun auto-fire
```

### SCSS

Tous les `<style scoped>` sont en `lang="scss"`. `styles/_mixins.scss` est
**auto-injecté dans chaque bloc** via `css.preprocessorOptions.scss.additionalData`
dans `vite.config.ts` : pas besoin de `@use` dans les composants.

⚠️ `_mixins.scss` ne doit **jamais émettre de CSS** — uniquement des `@mixin` et
des `@function`. La moindre règle y serait dupliquée dans chaque composant.

⚠️ **Les tokens restent des custom properties CSS**, pas des variables SCSS : ils
sont lus au runtime et surchargeables par élément, ce que SCSS ne permet pas. Ne
pas convertir `--color-*` en `$color-*`.

Les mixins couvrent la duplication réelle constatée : `muted-label`,
`surface-button`, `icon-button`, `message`, et le quatuor des popovers
(`popover-host`, `popover`, `popover-trigger`, `caret`) partagé entre
`SelectInput` et `DateInput`.

Le nesting utilise la concaténation BEM (`&__element`). Conséquence à connaître :
`grep entry-select__list` ne trouve plus la déclaration, seul `entry-select` la
trouve.

**Les composants d'entry sont autonomes** : ils reçoivent uniquement `:entry` et
lisent/écrivent leur valeur dans le store via `useEntryValue(() => props.entry)`.
Pas de prop drilling des valeurs depuis la modale.

⚠️ Le hack `entry.value = ref(entry.value)` de l'ancien code (un `ref` dans un
objet réactif, avec `isRef`/`entryValue` pour le déballer) a disparu : les valeurs
vivent dans `store.values[id]`. Ne pas le réintroduire.

---

## Comportements transverses à préserver

- id auto `"rowIndex:entryIndex"` si absent (désormais sur **toutes** les entries,
  pas seulement celles à résultat — les boutons sans id plantaient avant) ;
- `required` vide → clignotement `.error` **4× (300 ms on / 300 ms off, cycle 600 ms)**
  et envoi annulé ;
- `width` numérique → `%`, string → brut, avec `flex: none` ; `entry.style` fusionné ;
- Échap → annulation ; Entrée → submit, avec **garde de 1000 ms** après ouverture
  (`OPEN_ENTER_GUARD`) plus `ignoreEnter` jusqu'au keyup, pour qu'une touche
  maintenue ne valide pas le panneau suivant ;
- Entrée globale ignorée si `document.activeElement` n'est pas `BODY`, ou si le
  panneau contient un bouton ;
- autofocus du **premier** champ à résultat après 500 ms, sauf si ce premier champ
  est `date` ou `price` — auquel cas rien n'est focus (on ne passe pas au suivant).

---

## Bugs corrigés au passage

1. **`type: "button"` n'inhibait pas l'Entrée globale** contrairement à
   `type: "action"` : `hasAction` n'était mis à `true` que pour `action`, alors que
   le template acceptait les deux. Un panneau construit uniquement avec `button`
   postait `action: "Enter"`.
2. **Collision d'id bouton/champ** : `if (!result[id]) result[id] = true` écrasait
   la valeur d'un champ portant l'id du bouton, et se déclenchait sur toute valeur
   falsy (`0`, `""`). Devenu `if (!(id in result))`.
3. **Formes plates de prix ignorées** : `parseInitialValue` ne lisait que `costs` /
   `prices`, alors que `jo.pricing` accepte aussi `{ money = 10, item = "x" }` et
   les tables mixtes Lua (clés nommées + clés numériques, sérialisées en
   `{ "1": {...}, money: 10 }`). `collectRequirements` gère désormais tout ça.

---

## Outillage de dev

`npm run dev` puis le **DebugPanel** en haut à droite : un bouton par scénario
(un par type, « All types », price avec/sans OR, valeur plate, champs requis,
largeurs et classes, panneau sans bouton). Il affiche le dernier payload envoyé
au Lua, via `onDevLuaCall`.

Une entrée `.claude/launch.json` (**non commitée**) existe pour piloter le serveur
depuis le Browser pane, sur le **port 5180** — le 5173 était pris par un autre
process node.

⚠️ Deux limites du navigateur de test rencontrées, qui ne sont pas des bugs du code :
- l'action « key » du harness envoie des `keydown` avec `key`/`code` **vides** :
  pour tester le clavier il faut dispatcher des `KeyboardEvent` avec le bon `code` ;
- l'émulation de viewport ne dispatche **pas** l'événement `resize` : il faut le
  déclencher à la main pour voir la directive recalculer.

Le DebugPanel et `dev.ts` sont **absents du bundle de prod** : `App.vue` les charge
via `defineAsyncComponent` derrière `import.meta.env.DEV`, statiquement faux en
prod donc éliminé par rollup. `excludeBuildOutput` retire aussi `assets/ui` du
build — l'ancien build livrait `dev_bg.jpg` et 8 images inutilisées.

---

## Vérifications faites (toutes passées)

Payloads conformes pour un prix simple et un groupe OR · autofocus · clignotement
requis mesuré · select clavier (flèches + Entrée, sans valider le panneau) ·
calendrier inline non clippé, `yearRange` et `format` respectés · Échap → `false` ·
garde Entrée < 1 s · `width` 70 → 705px sur une row de 1007, `"200px"` → 200px ·
`ignoreRequired` → `{close: true}` seul · les 3 bugs ci-dessus · scale 1 / 1.333 /
0.667 à 1080p / 1440p / 720p, modale centrée, popups scalés avec elle.

`npm run type-check` et `npm run build` passent.

---

## Dette connue / reste à faire

- **V2 : le style.** C'est le chantier principal. Tout est en place pour ne
  toucher que le CSS.
- **Le CSS de `@vuepic/vue-datepicker` reste en rem**, il vient de `node_modules`.
  Seul îlot non-px. `styles/datepicker.css` ne fait que remapper ses variables.
- **La directive est dupliquée** entre Minigame et Input, avec deux constantes
  (1024 / 1080) et deux formules (`outerHeight` / `innerHeight`). Pour la
  promouvoir dans `_shared/`, il faudra la paramétrer — `_shared/` ne contient
  aujourd'hui que des plugins Vite, aucun code runtime.
- **`--modal-max-height: 90vh`** s'applique en espace **layout**, donc avant le
  `transform` : à 720p ça donne 648px de layout puis ×0,667 → 432px visuels, soit
  60 % de l'écran et non 90 %. Pour 90 % réels il faut une valeur px sur base 1080
  (972px).
- **Un panneau plus haut que `--modal-max-height` déborde** au lieu de scroller
  (conséquence directe de l'invariant 2 ; l'ancien code le coupait, ce n'est donc
  pas une régression). Si le cas se présente : couche de popover dédiée à
  l'intérieur du conteneur, avec positionnement calculé en `offsetTop`/`offsetLeft`
  — surtout pas en `getBoundingClientRect`, faussé par le `transform`.
- **À confirmer en jeu** : `innerHeight == outerHeight` sous CEF, et le `resize`
  au changement de résolution.

---

## Commits de la session

| commit | contenu |
|---|---|
| `a559f89` | réécriture complète, un composant par type |
| `5e6dd5e` | popups en absolu au lieu du flux (plus de saut d'UI) |
| `61896e5` | `--modal-max-height: 90vh` (commit de Brice) |
| `a784bf0` | directive `ui-scaler` branchée sur la modale |
