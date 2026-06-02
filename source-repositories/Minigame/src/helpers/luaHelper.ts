export async function sendToLua(method: string, data: object) {
  if (import.meta.env.PROD) {
    const ndata = data === undefined ? '{}' : JSON.stringify(data)
    const settings = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: ndata,
    }
    try {
      const fetchResponse = await fetch(
        // @ts-expect-error : GetParentResourceName()
        'https://' + GetParentResourceName() + '/' + method,
        settings,
      )
      const data = await fetchResponse.json()
      if (data.length == 0 || data === 'ok') {
        return true
      }
      return data
    } catch (e) {
      return e
    }
  } else {
    // Development mode - simulate Lua callbacks with mock responses
    console.log('Dev mode - Mock Lua call:', method, data)

    switch (method) {
      case 'jo_minigame:finished':
        window.postMessage(
          {
            type: 'jo_minigame:mockLuaCallback',
            data,
          },
          '*',
        )
        break
    }

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve('mock_ok')
      }, 50) // Faster response for better UX in dev
    })
  }
}
