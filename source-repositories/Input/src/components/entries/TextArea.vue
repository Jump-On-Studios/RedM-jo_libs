<template>
  <!--
    Same painted label as TextInput, around a <textarea>. Enter adds a new line
    here, so the field submits on Ctrl+Enter instead, through the same submit
    event (and Enter guards) as TextInput.
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
        @keydown.enter="onEnter"
    />
  </label>
</template>

<script setup lang="ts">
import { useTemplateRef } from 'vue'
import { useAutofocus } from '@/composables/useAutofocus'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import { useInputStore } from '@/stores/input'
import type { TextAreaEntry } from '@/types/entries'

const props = defineProps<{ entry: TextAreaEntry }>()
const emit = defineEmits<{ submit: [] }>()

const field = useTemplateRef<HTMLTextAreaElement>('field')
const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<string>(() => props.entry)

useAutofocus(
    () => props.entry.id,
    () => field.value,
)

const inputStore = useInputStore()

/**
 * Set once this field sees a fresh Enter press. Until then, key repeats come
 * from an Enter still held since the previous panel and are swallowed, as is
 * any Enter inside the open guard, so they cannot fill the box with new lines.
 */
let freshEnter = false

function onEnter(event: KeyboardEvent) {
    if (event.ctrlKey) {
        event.preventDefault()
        emit('submit')
        return
    }

    if (inputStore.isEnterGuarded()) {
        event.preventDefault()
        return
    }

    if (!event.repeat) freshEnter = true
    else if (!freshEnter) event.preventDefault()
}
</script>

<style scoped lang="scss">
.entry-field--textarea {
  align-items: flex-start;
}

.entry-field__textarea {
  display: block;
  width: 100%;
  resize: vertical;
  font: inherit;
  line-height: 1.35;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
</style>