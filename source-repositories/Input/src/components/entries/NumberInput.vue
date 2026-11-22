<template>
  <!-- Wrapped for the same reason as the text entry, see TextInput.vue. -->
  <label class="entry-field" :class="[entry.class, { error: hasError }]" :style="style">
    <input
      :id="entry.id"
      ref="field"
      v-model.number="value"
      type="number"
      class="entry-field__control"
      :placeholder="entry.placeholder"
      :min="entry.min"
      :max="entry.max"
      :step="entry.step"
      @keydown.enter="emit('submit')"
    />
  </label>
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
