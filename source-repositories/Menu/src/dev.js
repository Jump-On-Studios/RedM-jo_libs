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
      price: 4,
      child: "test",
      description: 'My item description',
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
          values: [1, 2, 3]
        }
      ]
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