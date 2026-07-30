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

<style scoped lang="scss">
.entry-button {
  @include surface-button;

  flex: 1;
  padding: var(--padding-input-y) var(--padding-input-x);
}
</style>
