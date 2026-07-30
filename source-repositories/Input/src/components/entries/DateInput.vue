<template>
  <div
    ref="root"
    class="entry-date"
    :class="[entry.class, { 'is-open': isOpen }]"
    :style="style"
    @keydown="onKeyDown"
  >
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
      The calendar uses the `inline` mode rather than the library popup, so it is
      never teleported out of the panel, and our own absolute wrapper overlays it
      on the rows below instead of pushing them down. Everything stays inside the
      element the ui-scaler directive will scale.
    -->
    <div v-if="isOpen" class="entry-date__popover">
      <VueDatePicker
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

<style scoped lang="scss">
.entry-date {
  @include popover-host;

  &__popover {
    @include popover;
  }

  &__trigger {
    @include popover-trigger;
  }

  &__placeholder {
    color: var(--color-placeholder);
  }

  &__caret {
    @include caret;
  }
}
</style>
