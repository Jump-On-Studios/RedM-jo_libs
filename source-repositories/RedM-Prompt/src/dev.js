const SendNUIMessage = window.postMessage

export function initGroup() {
  setTimeout(() => {
    SendNUIMessage({
      type: 'updateGroup',
      data: {
        title: 'Stable Shop',
        position: 'top-right',
        visible: false,
        nextPageKey: "A",
        prompts: [
          [
            {
              label: 'Press Prompt',
              keyboardKeys: ['E'],
            },
            {
              label: 'Multi press Prompt',
              keyboardKeys: ['F', 'S'],
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
          ],
          [
            {
              label: 'Page 2 ',
              keyboardKeys: ['P'],
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
