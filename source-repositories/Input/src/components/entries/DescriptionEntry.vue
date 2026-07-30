<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <p class="entry-description" :class="entry.class" :style="style" v-html="entry.value" />
</template>

<script setup lang="ts">
import { useEntryStyle } from '@/composables/useEntryStyle'
import type { DescriptionEntry } from '@/types/entries'

const props = defineProps<{ entry: DescriptionEntry }>()

const style = useEntryStyle(() => props.entry)
</script>

<style scoped>
.entry-description {
  flex: 1;
  min-width: 0;
  color: var(--color-text-dim);
  text-align: center;
  white-space: normal;
  overflow-wrap: anywhere;
  word-break: break-word;
}
</style>
