<template>
  <!--
    The painted surface is the label, not the input: an <input> renders no
    ::before or ::after, so it cannot carry the two bitmap layers itself. Being
    a label, clicking anywhere on the box focuses the control.
  -->
  <label class="entry-field" :class="[entry.class, { error: hasError }]" :style="style">
    <span class="entry-field__caps" aria-hidden="true" />
    <input
      :id="entry.id"
      ref="field"
      v-model="value"
      type="text"
      class="entry-field__control"
      :placeholder="entry.placeholder"
      @keydown.enter="emit('submit')"
    />
  </label>
</template>

<script setup lang="ts">
import { useTemplateRef } from 'vue'
import { useAutofocus } from '@/composables/useAutofocus'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import type { TextEntry } from '@/types/entries'

const props = defineProps<{ entry: TextEntry }>()

const emit = defineEmits<{ submit: [] }>()

const field = useTemplateRef<HTMLInputElement>('field')
const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<string>(() => props.entry)

useAutofocus(
  () => props.entry.id,
  () => field.value,
)
</script>
