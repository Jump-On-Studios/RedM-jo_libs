import PreviewSlider from "./components/layout/PreviewSlider.vue"

export default {}

let menu = {
  id: 'home',
  title: 'Main title',
  // type: 'tile',
  numberOnLine: 4,
  numberLineOnScreen: 2,
  subtitle: 'The menu title',
  numberOnScreen: 8,
  items: [
    {
      title: 'This is the title',
      icon: "female",
      iconSize: "small",
      priceTitle: "Price",
      previewSlider: true,
      price:
        [{ item: "horseLicense", keep: true }],
      // footer: "The footer",
      child: "test",
      quantity: 5,
      quantityCircleClass: 'fgold',
      iconClass: 'fgold',
      sliders: [
        // {
        //   type: "switch",
        //   values: [{ label: "good" }, { label: "bad" }]
        // },
        // {
        //   type: 'grid',
        //   values: [{ current: 1, min: -10, max: 10 }]
        // },
        {
          type: 'sprite',
          forceDisplay: true,
          values: [
            { palette: { tint0: 1, tint1: 20, tint2: 30, palette: 'tint_generic_clean' }, icon: 'lock', iconClass: 'fred' },
            { palette: { tint0: 1, tint1: 20, palette: 'tint_generic_clean' }, icon: 'star', iconClass: 'fgold' },
            { rgb: 'red', icon: 'star', iconClass: 'fgold' },
            { rgb: ['red', 'blue', "green"], icon: 'star', iconClass: 'fgold' },
            { sprite: 'tints/metal_engraving_2', icon: 'star', iconClass: 'fgold' }
          ],
          description: 'My item description<br>Second line',
        },
        // {
        //   type: 'sprite',
        //   forceDisplay: true,
        //   values: [
        //     { palette: { tint0: 1, tint1: 20, tint2: 30, palette: 'tint_generic_clean' } },
        //     { palette: { tint0: 1, tint1: 20, palette: 'tint_generic_clean' } },
        //     { rgb: 'red' },
        //     { rgb: ['red', 'blue', "green"] },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //     { sprite: 'tints/metal_engraving_2' },
        //   ],
        //   description: 'My item description<br>Second line',
        // }
      ]
    }, {
      title: 'This is the title',
      price: 4,
      description: "test",
      textRight: "The text right"
    },
    {
      title: 'This is the title',
      price: { money: 0 },
    },
    {
      title: 'This is the title',
      price: 0,
    },
    {
      title: 'This is the title',
      price: { gold: 4, money: 4 },
    }
  ]
}

if (import.meta.env.DEV) {
  window.postMessage({
    event: 'updateLang',
  })

  window.postMessage({
    event: 'updateMenu',
    menu: menu
  })

  let newValues = [
    {
      keys: ["items", 1],
      action: "delete"
    },
    {
      keys: ["currentIndex"],
      action: "update",
      value: 1
    }
  ]

  // setTimeout(() => {
  //   window.postMessage({
  //     event: "updateMenuValues",
  //     menu: "home",
  //     updated: newValues,
  //   })
  // }, 2000);

  // window.postMessage({
  //   event: 'setCurrentIndex',
  //   menu: 'home',
  //   index: 5
  // })

  setTimeout(function () {

    window.postMessage({
      event: 'setCurrentMenu',
      menu: 'home',
      keepHistoric: true
    })
    window.postMessage({
      event: "updateShow",
      show: true
    })
  }, 200)

  // setTimeout(() => {
  //   window.postMessage({
  //     event: "displayLoader",
  //     show: true
  //   })
  // }, 3000);
}