const SendNUIMessage = window.postMessage

export function initGroup() {
  setTimeout(() => {
    SendNUIMessage({
      type: 'updateGroup',
      data: {
        title: 'Stable Shop',
        position: 'top-right',
        prompts: [
          {
            label: 'Press Prompt',
            keyboardKeys: ['E'],
          },
          {
            label: 'Multi press Prompt',
            keyboardKeys: ['F', 'A'],
          },
          {
            label: 'Hold Prompt',
            keyboardKeys: ['M'],
            holdTime: 1000,
          },
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
