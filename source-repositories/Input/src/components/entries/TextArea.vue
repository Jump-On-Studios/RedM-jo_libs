<template>
  <!--
    Same painted label as TextInput, around a <textarea>. Enter adds a new line
    here, so unlike TextInput there is no @keydown.enter submit: the panel only
    submits on Enter when nothing is focused.
  -->
  <label class="entry-field entry-field--textarea" :class="[entry.class, { error: hasError }]" :style="style">
    <textarea
        :id="entry.id"
        ref="field"
        v-model="value"
        class="entry-field__control entry-field__textarea"
        :placeholder="entry.placeholder"
        :rows="entry.rows ?? 4"
        :maxlength="entry.maxLength"
    />
  </label>
</template>

<script setup lang="ts">
import { useTemplateRef } from 'vue'
import { useAutofocus } from '@/composables/useAutofocus'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import type { TextAreaEntry } from '@/types/entries'

const props = defineProps<{ entry: TextAreaEntry }>()

const field = useTemplateRef<HTMLTextAreaElement>('field')
const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<string>(() => props.entry)

useAutofocus(
    () => props.entry.id,
    () => field.value,
)
</script>

<style scoped lang="scss">
.entry-field--textarea {
  align-items: flex-start;
}

.entry-field__textarea {
  display: block;
  width: 100%;
  min-height: calc(var(--entry-field-font-size) * 4);
  resize: vertical;
  font: inherit;
  line-height: 1.35;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
</style>