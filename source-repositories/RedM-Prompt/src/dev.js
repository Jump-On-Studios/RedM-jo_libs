const SendNUIMessage = window.postMessage

export function initGroup() {
  setTimeout(() => {
    SendNUIMessage({
      type: 'updateGroup',
      data: {
        title: '<img src="https://raw.githubusercontent.com/BryceCanyonCounty/rdr3-nativedb-data/master/blips/images/blip_ambient_horse.png" /> Stable Shop',
        position: 'bottom-right',
        visible: false,
        nextPageKey: "A",
        prompts: [
          [
            {
              label: 'Press Prompt',
              keyboardKeys: ['E'],
            },
            {
              label: 'Hold Prompt',
              keyboardKeys: ['M'],
              holdTime: 1000,
            },
            {
              label: 'CTRL Prompt',
              keyboardKeys: ['LCONTROL'],
            },
            {
              label: 'SPACE Prompt',
              keyboardKeys: ['SPACE'],
            },
          ],
          [
            {
              label: 'Page 2 ',
              keyboardKeys: ['P'],
            },
            {
              label: 'Multi press Prompt',
              keyboardKeys: ['F', 'S'],
            },
          ]
        ],
      },
    })
  }, 200)
}

export function SendNUIKey(key, type) {
  SendNUIMessage({
    type,
    data: {
      key
    },
  })
}

export function SendNUINextPage() {
  SendNUIMessage({
    type: "nextPage"
  })
}
