<template>
  <span></span>
</template>

<script setup lang="ts">
import { onBeforeUnmount } from 'vue'
import { useInputStore } from '@/stores/input'
import type { NewInputPayload } from '@/types/entries'

const inputStore = useInputStore()

/**
 * Single entry point for the messages sent by SendNUIMessage on the Lua side.
 * The payload shape `{ event, data }` is part of the contract with
 * jo_libs/modules/input/client.lua and must not change.
 */
function onMessage(message: MessageEvent) {
  const { event, data } = (message.data ?? {}) as { event?: string; data?: unknown }

  switch (event) {
    case 'newInput':
      inputStore.open(data as NewInputPayload)
      break
  }
}

window.addEventListener('message', onMessage)

onBeforeUnmount(() => {
  window.removeEventListener('message', onMessage)
})
</script>
