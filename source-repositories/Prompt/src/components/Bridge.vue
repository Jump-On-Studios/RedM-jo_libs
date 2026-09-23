<template><span></span></template>
<script setup>
import { useGroupStore } from '@/stores/group'
import { SendNUIKey, SendNUINextPage } from '@/dev'

const groupStore = useGroupStore()
const isDev = import.meta.env.DEV

window.addEventListener('message', (event) => {
  // console.log(event)
  const { type, data } = event.data

  switch (type) {
    case 'setGroup':
      groupStore.setGroup(data)
      break
    case 'keyDown':
      // console.log(type, data)
      groupStore.updatePressedKeys(data.key, true)
      break
    case 'keyUp':
      // console.log(type, data)
      forwardedKeys.delete(data.key)
      groupStore.updatePressedKeys(data.key, false)
      break
    case 'nextPage':
      groupStore.nextPage()
      break
    case 'updatePrompt':
      groupStore.updatePrompt(data)
      break
    case 'updateGroup':
      groupStore.updateGroup(data)
      break
    case 'forceHide':
      groupStore.forceHide(data.value)
      break
  }
})

// * ===============================================================================
// * Keyboard events received while a NUI has the focus (e.g. a menu is open)
// * The raw keymaps don't fire in that case: the keys are forwarded to the Lua,
// * which handles them like the raw keys (prompt lookup, next page, pressed state)
// * ===============================================================================

const specialKeys = {
  ' ': 'space',
  arrowup: 'up',
  arrowdown: 'down',
  arrowleft: 'left',
  arrowright: 'right',
}

const normalizeKey = (key) => {
  const lowerKey = (key || '').toLowerCase()
  return specialKeys[lowerKey] || lowerKey
}

// Keys whose keyDown was forwarded, to forward their keyUp only once
const forwardedKeys = new Set()

const sendKeyToLua = (type, key) => {
  if (isDev) {
    if (type === 'keyDown' && groupStore.prompts.length > 1 && key === groupStore.nextPageKey?.toLowerCase()) {
      SendNUINextPage()
      return
    }
    SendNUIKey(key, type)
    return
  }
  // eslint-disable-next-line no-undef
  fetch(`https://${GetParentResourceName()}/${type}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify({ key }),
  })
}

window.addEventListener('keydown', (event) => {
  if (event.repeat) return
  const key = normalizeKey(event.key)
  if (!key || forwardedKeys.has(key)) return
  if (groupStore.prompts.length === 0 || groupStore.forcedHide) return
  forwardedKeys.add(key)
  sendKeyToLua('keyDown', key)
})

window.addEventListener('keyup', (event) => {
  const key = normalizeKey(event.key)
  if (!forwardedKeys.delete(key)) return
  sendKeyToLua('keyUp', key)
})
</script>
