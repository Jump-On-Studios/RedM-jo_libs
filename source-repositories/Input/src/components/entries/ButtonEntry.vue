<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <button
    type="button"
    class="entry-button"
    :class="entry.class"
    :style="style"
    v-html="entry.value"
    @click="onClick"
  />
</template>

<script setup lang="ts">
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useInputStore } from '@/stores/input'
import type { ButtonEntry } from '@/types/entries'

const props = defineProps<{ entry: ButtonEntry }>()

const inputStore = useInputStore()
const style = useEntryStyle(() => props.entry)

function onClick() {
  inputStore.submit(props.entry.id, props.entry.ignoreRequired)
}
</script>

<style scoped>
.entry-button {
  flex: 1;
  min-height: var(--field-height);
  padding: var(--padding-input-y) var(--padding-input-x);
  border: var(--border);
  background-color: var(--color-field);
  cursor: pointer;
}

.entry-button:hover {
  border-color: var(--color-border-strong);
  filter: brightness(1.4);
}
</style>
