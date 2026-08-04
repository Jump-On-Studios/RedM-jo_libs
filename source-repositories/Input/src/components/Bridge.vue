<template>
  <span></span>
</template>

<script setup lang="ts">
import { onBeforeUnmount } from 'vue'
import { useInputStore } from '@/stores/input'
import { useLangStore } from '@/stores/lang'
import type { NewInputPayload } from '@/types/entries'

const inputStore = useInputStore()
const langStore = useLangStore()

function stringRecord(value: unknown): Record<string, string> | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return null

  const entries = Object.entries(value)
  if (entries.some(([, item]) => typeof item !== 'string')) return null

  return Object.fromEntries(entries) as Record<string, string>
}

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

    case 'setStrings':
    case 'setLanguage': {
      const payload = data as { strings?: unknown } | unknown
      const strings =
        payload && typeof payload === 'object' && 'strings' in payload
          ? stringRecord(payload.strings)
          : stringRecord(payload)

      if (strings) langStore.setStrings(strings)
      break
    }
  }
}

window.addEventListener('message', onMessage)

onBeforeUnmount(() => {
  window.removeEventListener('message', onMessage)
})
</script>
