<template>
  <article class="price-requirement" :class="{ 'is-invalid': error }">
    <span class="price-requirement__kind">{{ typeLabel(requirement.type) }}</span>

    <template v-if="requirement.type === 'item'">
      <label class="price-field">
        <span class="price-field__label">Item</span>
        <input
          v-model="requirement.itemName"
          type="text"
          class="entry-input"
          placeholder="item_name"
        />
      </label>
      <label class="price-field price-field--narrow">
        <span class="price-field__label">Qty</span>
        <input
          v-model.number="requirement.quantity"
          type="number"
          min="1"
          step="1"
          class="entry-input"
          placeholder="1"
        />
      </label>
      <label class="price-checkbox">
        <input v-model="requirement.keep" type="checkbox" />
        <span>Keep item</span>
      </label>
    </template>

    <template v-else>
      <label class="price-field">
        <span class="price-field__label">Amount</span>
        <input
          v-model.number="requirement.value"
          type="number"
          min="0"
          step="0.01"
          class="entry-input"
          placeholder="0"
        />
      </label>
    </template>

    <button
      type="button"
      class="price-icon-button"
      title="Remove requirement"
      @click="emit('remove')"
    >
      X
    </button>

    <span v-if="error" class="price-message price-message--error">{{ error }}</span>
  </article>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { requirementError, typeLabel, type PriceRequirement } from '@/helpers/price'

const props = defineProps<{ requirement: PriceRequirement }>()

const emit = defineEmits<{ remove: [] }>()

const error = computed(() => requirementError(props.requirement))
</script>

<style scoped>
.price-requirement {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: var(--gap-small);
  padding: var(--gap-small);
  border: var(--border);
}

.price-requirement.is-invalid {
  border-color: var(--color-red-light);
}

.price-requirement__kind {
  flex: none;
  width: 90px;
  align-self: center;
  color: var(--color-text-dim);
  font-variant-caps: small-caps;
}

.price-field {
  flex: 1;
  min-width: 140px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.price-field--narrow {
  flex: none;
  width: 120px;
  min-width: 0;
}

.price-field__label {
  color: var(--color-text-dim);
  font-size: var(--font-size-small);
  font-variant-caps: small-caps;
}

.price-checkbox {
  flex: none;
  display: flex;
  align-items: center;
  gap: var(--gap-small);
  height: var(--field-height);
  color: var(--color-text-dim);
  font-size: var(--font-size-small);
  cursor: pointer;
}

.price-checkbox input {
  width: 16px;
  height: 16px;
  accent-color: var(--color-red);
  cursor: pointer;
}

.price-icon-button {
  flex: none;
  width: 44px;
  height: var(--field-height);
  border: var(--border);
  background-color: var(--color-field);
  cursor: pointer;
}

.price-icon-button:hover {
  border-color: var(--color-red-light);
}

.price-message {
  flex: 1 0 100%;
  font-size: var(--font-size-small);
}

.price-message--error {
  color: var(--color-red-light);
}
</style>
