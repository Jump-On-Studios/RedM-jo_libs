<template>
  <input
    :id="entry.id"
    ref="field"
    v-model.number="value"
    type="number"
    class="entry-input"
    :class="[entry.class, { error: hasError }]"
    :style="style"
    :placeholder="entry.placeholder"
    :min="entry.min"
    :max="entry.max"
    :step="entry.step"
    @keydown.enter="emit('submit')"
  />
</template>

<script setup lang="ts">
import { useTemplateRef } from 'vue'
import { useAutofocus } from '@/composables/useAutofocus'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import type { NumberEntry } from '@/types/entries'

const props = defineProps<{ entry: NumberEntry }>()

const emit = defineEmits<{ submit: [] }>()

const field = useTemplateRef<HTMLInputElement>('field')
const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<number>(() => props.entry)

useAutofocus(
  () => props.entry.id,
  () => field.value,
)
</script>
