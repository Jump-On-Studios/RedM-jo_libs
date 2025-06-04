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
      price: { item: { quantity: 2, label: "Apple", image: "https://femga.com/images/samples/ui_textures_no_bg/inventory_items/consumable_pear.png" } },
      child: "test",
      footer: 'footer',
      quantity: 5,
      quantityCircleClass: 'fgold',
      iconClass: 'fgold',
      sliders: [
        // {
        //   type: 'grid',
        //   values: [{ current: 1, min: -10, max: 10 }]
        // },
        {
          forceDisplay: true,
          values: [1],
          description: 'My item description<br>Second line',
        }
      ]
    }, {
      title: 'This is the title',
      price: 4,
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
}