<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <button
    type="button"
    class="entry-button"
    :class="[
      entry.class,
      { 'entry-button--compact': entry.id === 'close' },
    ]"
    :style="style"
    @click="onClick"
  >
    <span class="entry-button__content">
      <span v-if="entry.prompt" class="entry-button__prompt" aria-hidden="true">
        {{ entry.prompt }}
      </span>
      <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
      <span class="entry-button__label" v-html="entry.value" />
    </span>
  </button>
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

  flex: 0 0 auto;
  min-width: 0;
  min-height: 34px;
  padding: 0;
  border: 0;
  background: transparent !important;
  color: #e7e0d5;
  font-family: Crock, serif;
  font-size: 22px;
  text-transform: uppercase;

  &:hover:not(:disabled),
  &:focus-visible {
    border-color: transparent;
    background: transparent !important;
    color: var(--color-text);
    filter: none;
    outline: none;
  }

  &__content {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    white-space: nowrap;
  }

  &__prompt {
    display: inline-grid;
    place-items: center;
    width: 30px;
    height: 30px;
    border-radius: 50%;
    background: #e7e0d5;
    color: #28241f;
    font-family: Hapna, sans-serif;
    font-size: 19px;
    font-weight: 700;
    line-height: 1;
  }

  &--compact {
    min-width: 0;
    width: auto !important;
  }
}
</style>
