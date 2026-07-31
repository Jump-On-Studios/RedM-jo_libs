<template>
  <div class="price-summary">
    <span v-if="warning" class="price-message price-message--warning">
      {{ warning }}
    </span>

    <template v-if="lines.length === 1">
      <span class="price-summary__label">{{ singleLabel }}</span>
      <span>{{ lines[0] }}</span>
    </template>

    <template v-else>
      <span class="price-summary__label">Preview</span>
      <div
        v-for="(line, index) in lines"
        :key="index"
        class="price-summary__line"
      >
        <span>Option {{ index + 1 }}</span>
        <strong>{{ line }}</strong>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  lines: string[];
  warning: string | null;
  singleLabel: string;
}>();
</script>

<style scoped lang="scss">
.price-summary {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 7px;
  margin-top: 2px;
  padding: 12px 16px 13px;
  border-left: 3px solid var(--color-border-strong);
  font-size: var(--font-size-small);

  &::before {
    content: "";
    position: absolute;
    inset: 0;
    pointer-events: none;
    background: url("/assets/ui/help_text_1c.png") center / 100% 100% no-repeat;
    opacity: 0.1;
  }

  &__label {
    @include muted-label;
    position: relative;
    color: var(--color-text);
    letter-spacing: 0.04em;
  }

  &__line {
    display: flex;
    align-items: baseline;
    gap: var(--gap-small);
    min-width: 0;
    position: relative;

    span {
      flex: none;
      color: var(--color-text-dim);
      font-variant-caps: small-caps;
    }

    strong {
      min-width: 0;
      font-weight: 500;
      overflow-wrap: anywhere;
    }
  }
}

.price-message {
  @include message;
  position: relative;

  &--warning {
    color: var(--color-warning);
  }
}
</style>
