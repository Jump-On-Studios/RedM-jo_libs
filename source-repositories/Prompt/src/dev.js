const SendNUIMessage = window.postMessage

export function initGroup() {
  setTimeout(() => {
    SendNUIMessage({
      type: 'setGroup',
      data: {
        title:
          '<img src="https://raw.githubusercontent.com/BryceCanyonCounty/rdr3-nativedb-data/master/blips/images/blip_ambient_horse.png" /> Stable Shop',
        position: 'bottom-right',
        visible: false,
        nextPageKey: 'A',
        prompts: [
          [
            {
              label: 'Hold Prompt',
              keyboardKeys: ['M'],
              holdTime: 1000,
              visible: true,
            },
            {
              label: 'SPACE Prompt',
              keyboardKeys: ['SPACE'],
              price: [{ money: 12.5 }],
              visible: true,
            },
            {
              label: 'ENTER Prompt',
              keyboardKeys: ['ENTER'],
              price: [{ gold: 3 }],
              visible: true,
            },
            {
              label: 'PAGE UP Prompt',
              keyboardKeys: ['PAGEUP'],
              price: [
                {
                  item: 'horseBrush',
                  quantity: 2,
                  image: 'item',
                  label: 'Brush',
                },
              ],
              visible: true,
            },
            {
              label: 'PAGE DOWN Prompt',
              keyboardKeys: ['PAGEDOWN'],
              visible: true,
            },
            {
              label: 'HOME Prompt',
              keyboardKeys: ['HOME'],
              visible: true,
            },
            {
              label: 'Backspace Prompt',
              keyboardKeys: ['BACKSPACE'],
              visible: true,
            },
          ],
          [
            {
              label: 'Page 2 ',
              keyboardKeys: ['P'],
              price: [{ money: 0 }],
              visible: true,
            },
            {
              label: 'Multi press Prompt',
              keyboardKeys: ['F', 'S'],
              price: [
                {
                  item: 'water',
                  quantity: 2,
                  image: 'item',
                  label: 'Water',
                },
                { money: 5 },
              ],
              visible: true,
            },
          ],
        ],
      },
    })
  }, 200)
}

export function SendNUIKey(key, type) {
  SendNUIMessage({
    type,
    data: {
      key,
    },
  })
}

export function SendNUINextPage() {
  SendNUIMessage({
    type: 'nextPage',
  })
}
