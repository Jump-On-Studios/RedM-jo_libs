export default {}

if (import.meta.env.DEV) {
  const SendNUIMessage = window.postMessage

  setTimeout(() => {
    SendNUIMessage({
      type: 'updateGroup',
      data: {
        title: 'Stable Shop',
        position: 'top-left',
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
            keyboardKeys: ['SPACE'],
            holdTime: 1000,
          },
        ],
      },
    })
  }, 200)
}
