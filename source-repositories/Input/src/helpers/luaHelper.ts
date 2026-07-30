/** Callback name registered by the Lua side. */
export const CLICK_CALLBACK = 'jo_input:click'

type DevListener = (method: string, data: unknown) => void

const devListeners = new Set<DevListener>()

/** Lets the debug panel display what would have been sent to Lua. */
export function onDevLuaCall(listener: DevListener): () => void {
  devListeners.add(listener)
  return () => devListeners.delete(listener)
}

/**
 * Posts a message to the Lua resource. In dev the call is only logged and
 * broadcast to the debug panel, since there is no NUI host to answer it.
 */
export async function sendToLua(method: string, data: unknown): Promise<unknown> {
  if (import.meta.env.DEV) {
    console.log('[jo_input] sendToLua', method, data)
    devListeners.forEach((listener) => listener(method, data))
    return 'mock_ok'
  }

  const body = data === undefined ? '{}' : JSON.stringify(data)

  try {
    const response = await fetch(`https://${GetParentResourceName()}/${method}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
    })
    const payload = await response.json()

    if (payload?.length === 0 || payload === 'ok') return true

    return payload
  } catch (error) {
    return error
  }
}
