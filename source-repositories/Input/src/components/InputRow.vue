<template>
  <div class="input-row">
    <component
      :is="ENTRY_COMPONENTS[entry.type]"
      v-for="entry in row"
      :key="entry.id"
      :entry="entry"
      @submit="emit('submit')"
    />
  </div>
</template>

<script setup lang="ts">
import { ENTRY_COMPONENTS } from '@/components/entries'
import type { Entry } from '@/types/entries'

defineProps<{ row: Entry[] }>()

const emit = defineEmits<{ submit: [] }>()
</script>

<style scoped lang="scss">
.input-row {
  display: flex;
  align-items: center;
  gap: var(--gap-small);
  width: 100%;
}
</style>
