<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <label class="entry-label" :class="entry.class" :style="style" :for="entry.for" v-html="entry.value" />
</template>

<script setup lang="ts">
import { useEntryStyle } from '@/composables/useEntryStyle'
import type { LabelEntry } from '@/types/entries'

const props = defineProps<{ entry: LabelEntry }>()

const style = useEntryStyle(() => props.entry)
</script>

<style scoped>
.entry-label {
  flex: 1;
  min-width: 0;
  overflow-wrap: anywhere;
}
</style>
