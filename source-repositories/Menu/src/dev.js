import PreviewSlider from "./components/layout/PreviewSlider.vue";

export default {};

let menu = {
  id: "home",
  title: "Main title",
  // type: "tile",
  numberLineOnScreen: 3,
  subtitle: "The menu title",
  displayBackButton: true,
  items: [
    {
      title: "This is the title",
      icon: "female",
      // iconSize: "small",
      // priceTitle: "Price",
      previewSlider: true,
      price: false,
      // price: [{ item: "horseLicense", keep: true }],
      // footer: "The footer",
      child: "test",
      quantity: 5,
      quantityCircleClass: "fgold",
      iconClass: "fgold",
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
          type: "sprite",
          forceDisplay: true,
          values: [
            {
              palette: {
                tint0: 23,
                tint1: 35,
                tint2: 42,
                palette: "metaped_tint_makeup",
              },
              icon: "lock",
              iconClass: "fred",
              tagColor: "green",
              tagText: "1x",
            },
            {
              palette: { tint0: 1, tint1: 20, palette: "tint_generic_clean" },
              icon: "star",
              iconClass: "fgold",
            },
            { rgb: "red", icon: "star", iconClass: "fgold" },
            {
              rgb: ["red", "blue", "green"],
              icon: "star",
              iconClass: "fgold",
              tagColor: "gold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
            {
              sprite: "tints/metal_engraving_2",
              icon: "star",
              iconClass: "fgold",
            },
          ],
          description: "My item description<br>Second line",
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
      ],
    },
    {
      title: "This is the title",
      icon: "male",
      description: "test",
      textRight: "The text right",
      sliders: [
        {
          type: "palette",
          title: "tint",
          tint: "tint_makeup",
          //min: 12,
          //max: 14,
          //disabledTints: [33, 34, 35, 36, 37, 38],
        },
      ],
    },
    {
      icon: "outfit",
      title: "This is the title",
    },
    {
      icon: "pants",
      title: "This is the title",
    },
    {
      icon: "vests",
      title: "This is the title",
    },
    {
      icon: "hats",
      title: "This is the title",
    },
    {
      icon: "eyewear",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
    {
      icon: "boots",
      title: "This is the title",
    },
  ],
};

if (import.meta.env.DEV) {
  window.postMessage({
    event: "updateLang",
  });

  window.postMessage({
    event: "updateMenu",
    menu: menu,
  });

  let newValues = [
    {
      keys: ["items", 1],
      action: "delete",
    },
    {
      keys: ["currentIndex"],
      action: "update",
      value: 1,
    },
  ];

  setTimeout(function () {
    window.postMessage({
      event: "setCurrentMenu",
      menu: "home",
      keepHistoric: false,
    });
    window.postMessage({
      event: "updateShow",
      show: true,
    });
  }, 200);
}
