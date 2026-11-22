<template>
  <div class="input-row">
    <component
      :is="ENTRY_COMPONENTS[entry.type]"
      v-for="entry in row.columns"
      :key="entry.id"
      :entry="entry"
      @submit="emit('submit')"
    />
  </div>
</template>

<script setup lang="ts">
import { ENTRY_COMPONENTS } from "@/components/entries";
import type { Row } from "@/types/entries";

defineProps<{ row: Row }>();

const emit = defineEmits<{ submit: [] }>();
</script>

<style scoped lang="scss">
.input-row {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;

  &:has(.entry-button) {
    position: relative;
    justify-content: flex-end;
    gap: 24px;
    padding-top: 18px;

    &::before {
      content: "";
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      height: 1px;
      background: url('/assets/ui/divider_line.png') center / 100% 100% no-repeat;
      opacity: 0.65;
      pointer-events: none;
    }
  }

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

  // A textarea grows downwards: pin the label to its first line rather than
  // letting it drift to the middle of the box. The padding centres the label's
  // first line in a single-line field height, where that first line sits.
  &:has(.entry-field--textarea) {
    align-items: flex-start;

    :deep(.entry-label) {
      line-height: 1.3;
      padding-top: calc((var(--entry-field-height) - var(--font-size-small) * 1.3) / 2);
    }
  }
}
</style>
