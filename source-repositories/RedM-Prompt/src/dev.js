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
              label:
                ' <img src="https://raw.githubusercontent.com/BryceCanyonCounty/rdr3-nativedb-data/master/blips/images/blip_ambient_horse.png" /> <span style="color:red">Press Prompt</span>',
              keyboardKeys: ['E'],
              visible: true,
            },
            {
              label: 'Hold Prompt',
              keyboardKeys: ['M'],
              holdTime: 1000,
              visible: true,
            },
            {
              label: 'CTRL Prompt',
              keyboardKeys: ['LCONTROL'],
              visible: true,
            },
            {
              label: 'SPACE Prompt',
              keyboardKeys: ['SPACE'],
              visible: true,
              disabled: true,
            },
            {
              label: 'NOT VISIBLE PROMPT',
              keyboardKeys: ['N'],
              visible: false,
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
