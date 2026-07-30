<template>
  <div ref="root" class="entry-select" :class="[entry.class, { 'is-open': isOpen }]" :style="style">
    <button
      ref="field"
      type="button"
      class="entry-input entry-select__trigger"
      :class="{ error: hasError }"
      @click="toggle"
      @keydown="onKeyDown"
    >
      <span :class="{ 'entry-select__placeholder': !value }">
        {{ value?.label ?? entry.placeholder ?? '' }}
      </span>
      <span class="entry-select__caret">{{ isOpen ? '▲' : '▼' }}</span>
    </button>

    <!--
      Overlays the rows below instead of pushing them down, and is never
      teleported: it stays inside the panel so the ui-scaler directive scales it
      along with everything else.
    -->
    <ul v-if="isOpen" class="entry-select__list">
      <li v-for="(option, index) in options" :key="index">
        <button
          type="button"
          class="entry-select__option"
          :class="{
            'is-active': index === activeIndex,
            'is-selected': isSelected(option),
          }"
          @click="select(option)"
          @mousemove="activeIndex = index"
        >
          {{ option.label }}
        </button>
      </li>
      <li v-if="options.length === 0" class="entry-select__empty">No option available</li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, ref, useTemplateRef, watch } from 'vue'
import { useAutofocus } from '@/composables/useAutofocus'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import type { SelectEntry, SelectOption } from '@/types/entries'

const props = defineProps<{ entry: SelectEntry }>()

const root = useTemplateRef<HTMLDivElement>('root')
const field = useTemplateRef<HTMLButtonElement>('field')
const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<SelectOption | null>(() => props.entry)

const isOpen = ref(false)
const activeIndex = ref(-1)

const options = computed<SelectOption[]>(() => props.entry.options ?? [])

useAutofocus(
  () => props.entry.id,
  () => field.value,
)

function isSelected(option: SelectOption) {
  return value.value?.value === option.value
}

function open() {
  isOpen.value = true
  activeIndex.value = options.value.findIndex(isSelected)
}

function close() {
  isOpen.value = false
}

function toggle() {
  if (isOpen.value) close()
  else open()
}

function select(option: SelectOption) {
  value.value = option
  close()
  field.value?.focus()
}

function move(offset: number) {
  const total = options.value.length
  if (total === 0) return

  activeIndex.value = (activeIndex.value + offset + total) % total
}

/**
 * The panel listens for Enter and Escape on the window, so every key the list
 * consumes must be stopped here to avoid submitting or cancelling the panel.
 */
function onKeyDown(event: KeyboardEvent) {
  switch (event.code) {
    case 'Escape':
      if (!isOpen.value) return
      event.preventDefault()
      event.stopPropagation()
      close()
      return

    case 'Enter':
    case 'Space':
      event.preventDefault()
      event.stopPropagation()
      if (!isOpen.value) {
        open()
        return
      }
      {
        const option = options.value[activeIndex.value]
        if (option) select(option)
      }
      return

    case 'ArrowDown':
    case 'ArrowUp':
      event.preventDefault()
      event.stopPropagation()
      if (!isOpen.value) {
        open()
        return
      }
      move(event.code === 'ArrowDown' ? 1 : -1)
  }
}

function onDocumentPointerDown(event: PointerEvent) {
  if (root.value?.contains(event.target as Node)) return

  close()
}

watch(isOpen, (opened) => {
  if (opened) document.addEventListener('pointerdown', onDocumentPointerDown)
  else document.removeEventListener('pointerdown', onDocumentPointerDown)
})

onBeforeUnmount(() => {
  document.removeEventListener('pointerdown', onDocumentPointerDown)
})
</script>

<style scoped>
.entry-select {
  position: relative;
  flex: 1;
  min-width: 0;
}

/* Raised while open so the list covers the rows underneath. */
.entry-select.is-open {
  z-index: 20;
}

.entry-select__trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--gap-small);
  width: 100%;
  cursor: pointer;
  text-align: left;
}

.entry-select__placeholder {
  color: var(--color-placeholder);
}

.entry-select__caret {
  flex: none;
  color: var(--color-text-dim);
  font-size: var(--font-size-small);
}

.entry-select__list {
  position: absolute;
  top: calc(100% + 2px);
  left: 0;
  right: 0;
  max-height: 220px;
  overflow-y: auto;
  border: var(--border);
  background-color: var(--color-surface);
}

.entry-select__option {
  display: block;
  width: 100%;
  padding: var(--padding-input-y) var(--padding-input-x);
  cursor: pointer;
  text-align: left;
}

.entry-select__option.is-active {
  background-color: var(--color-field);
}

.entry-select__option.is-selected {
  border-left: 3px solid var(--color-border-strong);
}

.entry-select__empty {
  padding: var(--padding-input-y) var(--padding-input-x);
  color: var(--color-text-dim);
}
</style>
