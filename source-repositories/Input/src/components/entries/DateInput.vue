<template>
  <div ref="root" class="entry-date" :class="entry.class" :style="style" @keydown="onKeyDown">
    <button
      ref="field"
      type="button"
      class="entry-input entry-date__trigger"
      :class="{ error: hasError }"
      @click="toggle"
    >
      <span :class="{ 'entry-date__placeholder': !displayValue }">
        {{ displayValue || entry.placeholder || '' }}
      </span>
      <span class="entry-date__caret">{{ isOpen ? '▲' : '▼' }}</span>
    </button>

    <!--
      The calendar uses the `inline` mode instead of the default popup: it stays
      in the flow, inside the element the ui-scaler directive will scale, and the
      scrollable panel cannot clip it.
    -->
    <VueDatePicker
      v-if="isOpen"
      v-model="value"
      inline
      auto-apply
      dark
      prevent-min-max-navigation
      :teleport="false"
      :enable-time-picker="false"
      :year-range="yearRange"
      :start-date="startDate"
      :format="entry.format"
      :model-type="entry.format"
      @update:model-value="close"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, useTemplateRef } from 'vue'
import VueDatePicker from '@vuepic/vue-datepicker'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import type { DateEntry } from '@/types/entries'

const props = defineProps<{ entry: DateEntry }>()

const emit = defineEmits<{ submit: [] }>()

const field = useTemplateRef<HTMLButtonElement>('field')
const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<string | Date | null>(() => props.entry)

const isOpen = ref(false)

const yearRange = computed<[number, number]>(() => props.entry.yearRange ?? [1900, 2100])

/** Opens the calendar on the first allowed year rather than on today. */
const startDate = computed(() => new Date(yearRange.value[0], 0, 1))

const displayValue = computed(() => {
  const current = value.value

  if (!current) return ''
  if (typeof current === 'string') return current
  if (current instanceof Date) return current.toLocaleDateString()

  return String(current)
})

function close() {
  isOpen.value = false
  field.value?.focus()
}

function toggle() {
  if (isOpen.value) close()
  else isOpen.value = true
}

/** Keeps the panel from submitting or closing while the calendar is open. */
function onKeyDown(event: KeyboardEvent) {
  if (event.code === 'Escape') {
    if (!isOpen.value) return

    event.preventDefault()
    event.stopPropagation()
    close()
    return
  }

  if (event.code !== 'Enter') return

  event.preventDefault()
  event.stopPropagation()

  if (isOpen.value) return

  emit('submit')
}
</script>

<style scoped>
.entry-date {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.entry-date__trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--gap-small);
  width: 100%;
  cursor: pointer;
  text-align: left;
}

.entry-date__placeholder {
  color: var(--color-placeholder);
}

.entry-date__caret {
  flex: none;
  color: var(--color-text-dim);
  font-size: var(--font-size-small);
}
</style>
