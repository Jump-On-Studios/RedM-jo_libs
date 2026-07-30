<template>
  <input
    :id="entry.id"
    ref="field"
    v-model="value"
    type="text"
    class="entry-input"
    :class="[entry.class, { error: hasError }]"
    :style="style"
    :placeholder="entry.placeholder"
    @keydown.enter="emit('submit')"
  />
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
