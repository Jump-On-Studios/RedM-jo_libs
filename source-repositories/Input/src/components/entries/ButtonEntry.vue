<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <button
    type="button"
    class="entry-button"
    :class="entry.class"
    :style="style"
    @click="onClick"
  >
    <span class="entry-button__content">
      <img
        v-if="entry.icon"
        class="entry-button__icon"
        :src="entry.icon"
        alt=""
        aria-hidden="true"
      />
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
  @include textured-button;

  flex: 0 0 auto;
  min-width: 0;
  min-height: 54px;
  padding: 8px 32px;
  letter-spacing: 0.02em;

  &:hover:not(:disabled),
  &:focus-visible {
    color: var(--button-hover-text, var(--button-text, var(--color-text)));
  }

  &__content {
    position: relative;
    z-index: 1;
    display: inline-flex;
    align-items: center;
    gap: 10px;
    white-space: nowrap;
  }

  &__icon {
    flex: none;
    width: 24px;
    height: 24px;
    object-fit: contain;
    filter: drop-shadow(0 1px 0 rgba(0, 0, 0, 0.55));
  }

  &.success {
    --button-surface: color-mix(
      in srgb,
      var(--color-green) 48%,
      var(--color-field)
    );
  }

  &.danger {
    --button-surface: color-mix(
      in srgb,
      var(--color-red) 58%,
      var(--color-field)
    );
  }

  &.warning {
    --button-surface: color-mix(
      in srgb,
      var(--color-warning) 28%,
      var(--color-field)
    );
    --button-text: var(--color-warning);
  }

  &.muted {
    --button-surface: color-mix(
      in srgb,
      var(--color-field) 70%,
      var(--color-background)
    );
    --button-text: var(--color-text-dim);
  }

  &.flat {
    background: transparent;
    color: var(--button-text, var(--color-text-dim));
    filter: none;

    &::before,
    &::after {
      opacity: 0;
    }

    &:hover:not(:disabled),
    &:focus-visible:not(:disabled) {
      color: var(--button-hover-text, var(--color-text));
      filter: none;

      &::after {
        opacity: 0;
      }
    }

    &:focus-visible {
      outline: 2px solid var(--color-border-strong);
      outline-offset: 3px;
    }
  }
}
</style>
