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
      price: [
        { item: 'apple', quantity: 1, label: "Trainer Licence", image: "https://femga.com/images/samples/ui_textures_no_bg/inventory_items/document_business_card_rock_carvings.png" },
        { item: 'apple', quantity: 1, label: "Trainer Licence", image: "https://femga.com/images/samples/ui_textures_no_bg/inventory_items/document_business_card_rock_carvings.png" },
        { money: 1 },
        { gold: 10 },
      ],
      // footer: "The footer",
      child: "test",
      quantity: 5,
      quantityCircleClass: 'fgold',
      iconClass: 'fgold',
      sliders: [
        {
          type: "switch",
          values: [{ label: "good" }, { label: "bad" }]
        },
        {
          type: 'grid',
          values: [{ current: 1, min: -10, max: 10 }]
        },
        {
          type: 'sprite',
          forceDisplay: true,
          values: [
            { palette: { tint0: 1, tint1: 20, tint2: 30, palette: 'tint_generic_clean' } },
            { palette: { tint0: 1, tint1: 20, palette: 'tint_generic_clean' } },
            { rgb: 'red' },
            { rgb: ['red', 'blue', "green"] },
            { sprite: 'tints/metal_engraving_2' }
          ],
          description: 'My item description<br>Second line',
        },
        {
          type: 'sprite',
          forceDisplay: true,
          values: [
            { palette: { tint0: 1, tint1: 20, tint2: 30, palette: 'tint_generic_clean' } },
            { palette: { tint0: 1, tint1: 20, palette: 'tint_generic_clean' } },
            { rgb: 'red' },
            { rgb: ['red', 'blue', "green"] },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
            { sprite: 'tints/metal_engraving_2' },
          ],
          description: 'My item description<br>Second line',
        }
      ]
    }, {
      title: 'This is the title',
      price: 4,
      description: "test",
      textRight: "The text right"
    },
    {
      title: 'This is the title',
      price: { money: 4 },
    },
    {
      title: 'This is the title',
      price: { gold: 4 },
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
      keys: ["items", 1, "sliders", 1, "title"],
      value: "New title"
    },
    {
      keys: ["items", 1, "sliders", 1, "description"],
      value: "New description"
    },
    {
      keys: ["items", 1, "price"],
      action: "delete"
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