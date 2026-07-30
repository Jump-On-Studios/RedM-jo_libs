<template>
  <section class="price-option">
    <header class="price-option__header">
      <div>
        <div class="price-option__title">Option {{ index + 1 }}</div>
        <div class="price-option__help">Player must pay all of these</div>
      </div>
      <button
        v-if="canRemove"
        type="button"
        class="price-icon-button"
        title="Remove payment option"
        @click="emit('remove')"
      >
        X
      </button>
    </header>

    <div v-if="option.requirements.length === 0" class="price-option__empty">
      Choose what the player must pay for this option.
    </div>

    <span v-if="error" class="price-message price-message--error">{{ error }}</span>

    <div class="price-option__requirements">
      <PriceRequirement
        v-for="(requirement, requirementIndex) in option.requirements"
        :key="requirement.key"
        :requirement="requirement"
        @remove="removeRequirement(requirementIndex)"
      />
    </div>

    <div class="price-option__add">
      <span class="price-option__help">Add requirement</span>
      <div class="price-option__types">
        <button
          v-for="choice in availableTypes"
          :key="choice.value"
          type="button"
          class="price-type-button"
          :disabled="isTypeDisabled(option, choice.value)"
          :title="buttonTitle(choice.value)"
          @click="addRequirement(choice.value)"
        >
          {{ choice.label }}
        </button>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import PriceRequirement from './PriceRequirement.vue'
import {
  createRequirement,
  isTypeDisabled,
  optionError,
  typeLabel,
  type CostTypeChoice,
  type PriceOption,
} from '@/helpers/price'
import type { PriceCostType } from '@/types/entries'

const props = defineProps<{
  option: PriceOption
  index: number
  availableTypes: CostTypeChoice[]
  canRemove: boolean
}>()

const emit = defineEmits<{ remove: [] }>()

const error = computed(() => optionError(props.option))

function buttonTitle(type: PriceCostType) {
  if (!isTypeDisabled(props.option, type)) return `Add ${typeLabel(type)}`

  return `${typeLabel(type)} is already in this option.`
}

function addRequirement(type: PriceCostType) {
  if (isTypeDisabled(props.option, type)) return

  props.option.requirements.push(createRequirement(type))
}

function removeRequirement(index: number) {
  props.option.requirements.splice(index, 1)
}
</script>

<style scoped>
.price-option {
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);
  padding: var(--gap-small);
  border: var(--border);
}

.price-option__header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--gap);
}

.price-option__title {
  font-variant-caps: small-caps;
}

.price-option__help {
  color: var(--color-text-dim);
  font-size: var(--font-size-small);
  font-variant-caps: small-caps;
}

.price-option__empty {
  padding: var(--padding-block);
  border: var(--border);
  color: var(--color-text-dim);
  text-align: center;
}

.price-option__requirements {
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);
}

.price-option__add {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.price-option__types {
  display: flex;
  gap: var(--gap-small);
}

.price-type-button {
  flex: 1;
  min-height: var(--field-height);
  border: var(--border);
  background-color: var(--color-field);
  cursor: pointer;
}

.price-type-button:hover:not(:disabled) {
  border-color: var(--color-border-strong);
  filter: brightness(1.4);
}

.price-type-button:disabled {
  color: var(--color-placeholder);
  cursor: not-allowed;
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
  font-size: var(--font-size-small);
}

.price-message--error {
  color: var(--color-red-light);
}
</style>
