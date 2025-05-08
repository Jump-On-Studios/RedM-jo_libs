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
              visible: true,
            },
            {
              label: 'ENTER Prompt',
              keyboardKeys: ['ENTER'],
              visible: true,
            },
            {
              label: 'PAGE UP Prompt',
              keyboardKeys: ['PAGEUP'],
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
              visible: true,
            },
            {
              label: 'Multi press Prompt',
              keyboardKeys: ['F', 'S'],
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
