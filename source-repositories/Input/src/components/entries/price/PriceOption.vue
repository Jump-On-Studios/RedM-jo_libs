<template>
  <section class="price-option">
    <header class="price-option__header">
      <div class="price-option__actions">
        <button
          v-if="canDuplicate"
          type="button"
          class="price-option__action"
          title="Duplicate payment option"
          @click="emit('duplicate')"
        >
          Duplicate
        </button>
        <button
          v-if="canRemove"
          type="button"
          class="price-option__action"
          title="Remove payment option"
          aria-label="Remove payment option"
          @click="emit('remove')"
        >
          Remove
        </button>
      </div>
    </header>

    <div v-if="option.requirements.length === 0" class="price-option__empty">
      Add a requirement to this option.
    </div>

    <span v-if="error && option.requirements.length > 0" class="price-message price-message--error">
      {{ error }}
    </span>

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
  canDuplicate: boolean
}>()

const emit = defineEmits<{ remove: []; duplicate: [] }>()

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

<style scoped lang="scss">
.price-option {
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);

  &__header {
    display: flex;
    align-items: flex-start;
    justify-content: flex-end;
    gap: var(--gap);
  }

  &__actions {
    display: flex;
    align-items: center;
    gap: var(--gap-small);
  }

  &__action {
    padding: 4px 0;
    border: 0;
    background: transparent;
    color: var(--color-text-dim);
    font-size: var(--font-size-small);
    cursor: pointer;
  }

  &__help {
    @include muted-label;
  }

  &__empty {
    padding: var(--padding-block);
    color: var(--color-text-dim);
    text-align: center;
  }

  &__requirements {
    display: flex;
    flex-direction: column;
    gap: 0;
  }

  &__add {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  &__types {
    display: flex;
    gap: var(--gap-small);
  }
}

.price-type-button {
  @include surface-button;

  flex: 1;
}

.price-message {
  @include message;

  &--error {
    color: var(--color-red-light);
  }
}
</style>
