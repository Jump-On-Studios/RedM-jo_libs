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

    // Route to mock functions based on method
    // switch (method) {
    //   case 'jo_radial:navigateToMenu':
    //     window.postMessage({ type: 'mock:navigateToMenu', data }, '*')
    //     break
    //   case 'jo_radial:back':
    //     window.postMessage({ type: 'mock:back', data }, '*')
    //     break
    //   case 'jo_radial:showSubItems':
    //     window.postMessage({ type: 'mock:showSubItems', data }, '*')
    //     break
    //   case 'jo_radial:action':
    //     window.postMessage({ type: 'mock:action', data }, '*')
    //     break
    //   case 'jo_radial:close':
    //     // Just log in dev mode, actual close is handled by the wheel store
    //     console.log('Mock close action')
    //     break
    //   default:
    //     console.log('Unknown method in dev mode:', method)
    // }

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve('mock_ok')
      }, 50) // Faster response for better UX in dev
    })
  }
}
