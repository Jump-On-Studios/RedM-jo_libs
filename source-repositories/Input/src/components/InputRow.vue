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
import { ENTRY_COMPONENTS } from "@/components/entries";
import type { Entry } from "@/types/entries";

defineProps<{ row: Entry[] }>();

const emit = defineEmits<{ submit: [] }>();
</script>

<style scoped lang="scss">
.input-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;

  &:has(.entry-label) {
    gap: 16px;

    :deep(.entry-label) {
      flex: 0 0 94px;
      color: var(--color-text-dim);
      font-size: var(--font-size-small);
      font-variant-caps: small-caps;
      letter-spacing: 0.04em;
    }
  }
}
</style>
