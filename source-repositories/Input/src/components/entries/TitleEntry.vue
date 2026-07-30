<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <h2 class="entry-title" :class="entry.class" :style="style" v-html="entry.value" />
</template>

<script setup lang="ts">
import { useEntryStyle } from '@/composables/useEntryStyle'
import type { TitleEntry } from '@/types/entries'

const props = defineProps<{ entry: TitleEntry }>()

const style = useEntryStyle(() => props.entry)
</script>

<style scoped>
.entry-title {
  flex: 1;
  padding: var(--padding-block) var(--padding-input-x);
  border: var(--border);
  background-color: var(--color-surface);
  font-size: var(--font-size-title);
  font-weight: bold;
  font-variant-caps: small-caps;
  text-align: center;
}
</style>
