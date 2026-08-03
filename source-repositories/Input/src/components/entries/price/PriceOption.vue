<template>
  <section class="price-option">
    <header class="price-option__header">
      <span class="price-option__heading" v-i18n="'inputNuiRequirements'">
        Requirements
      </span>
      <div class="price-option__actions">
        <button
          v-if="canDuplicate"
          type="button"
          class="price-option__action"
          :title="getString('inputNuiDuplicateOption', 'Duplicate option')"
          @click="emit('duplicate')"
        >
          <span v-i18n="'inputNuiDuplicateOption'">Duplicate option</span>
        </button>
        <button
          v-if="canRemove"
          type="button"
          class="price-option__action"
          :title="getString('inputNuiRemoveOption', 'Remove option')"
          :aria-label="getString('inputNuiRemoveOption', 'Remove option')"
          @click="emit('remove')"
        >
          <span v-i18n="'inputNuiRemoveOption'">Remove option</span>
        </button>
      </div>
    </header>

    <div v-if="option.requirements.length === 0" class="price-option__empty">
      <span v-i18n="'inputNuiAddRequirementToOption'">
        Add a requirement to this option.
      </span>
    </div>

    <span
      v-if="error && option.requirements.length > 0"
      class="price-message price-message--error"
    >
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
      <span class="price-option__help" v-i18n="'inputNuiAddRequirement'">
        Add requirement
      </span>
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
          <span
            v-if="typeIcon(choice.value)"
            class="price-type-button__icon"
            :class="`is-${choice.value}`"
            aria-hidden="true"
          >
            <img :src="typeIcon(choice.value)" alt="" />
          </span>
          <span>{{ typeLabel(choice.value) }}</span>
        </button>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed } from "vue";
import PriceRequirement from "./PriceRequirement.vue";
import {
  createRequirement,
  isTypeDisabled,
  optionError,
  typeLabel,
  type CostTypeChoice,
  type PriceOption,
} from "@/helpers/price";
import { useLangStore } from "@/stores/lang";
import type { PriceCostType } from "@/types/entries";

const props = defineProps<{
  option: PriceOption;
  index: number;
  availableTypes: CostTypeChoice[];
  canRemove: boolean;
  canDuplicate: boolean;
}>();

const emit = defineEmits<{ remove: []; duplicate: [] }>();

const langStore = useLangStore();
const error = computed(() => optionError(props.option));

const requirementIcons: Partial<Record<PriceCostType, string>> = {
  money: "/assets/ui/dollar.png",
  gold: "/assets/ui/gold.png",
  item: "/assets/ui/item.png",
};

function typeIcon(type: PriceCostType) {
  return requirementIcons[type];
}

function buttonTitle(type: PriceCostType) {
  if (!isTypeDisabled(props.option, type)) {
    return `${getString("inputNuiAddCost", "Add")} ${typeLabel(type)}`;
  }

  return `${typeLabel(type)} ${getString(
    "inputNuiAlreadyInOption",
    "is already in this option.",
  )}`;
}

function getString(key: string, fallback: string) {
  return langStore.getString(key, fallback);
}

function addRequirement(type: PriceCostType) {
  if (isTypeDisabled(props.option, type)) return;

  props.option.requirements.push(createRequirement(type));
}

function removeRequirement(index: number) {
  props.option.requirements.splice(index, 1);
}
</script>

<style scoped lang="scss">
.price-option {
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);

  &__header {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: var(--gap);
    min-height: 28px;
  }

  &__heading {
    margin-right: auto;
    color: var(--color-text-dim);
    font-size: 15px;
    font-variant-caps: small-caps;
    letter-spacing: 0.08em;
  }

  &__actions {
    display: flex;
    align-items: center;
    gap: var(--gap-small);
  }

  &__action {
    display: inline-flex;
    align-items: center;
    min-height: 26px;
    padding: 0 4px;
    border-bottom: 1px solid transparent;
    background: transparent;
    color: var(--color-text-dim);
    font-size: var(--font-size-small);
    cursor: pointer;

    &:hover,
    &:focus-visible {
      border-bottom-color: var(--color-red-light);
      color: var(--color-text);
      outline: none;
    }
  }

  &__help {
    @include muted-label;
  }

  &__empty {
    padding: 24px var(--padding-block);
    color: var(--color-text-dim);
    text-align: center;
  }

  &__requirements {
    display: flex;
    flex-direction: column;
    gap: 0;
  }

  &__add {
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding-top: 8px;

    &::before {
      content: "";
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      height: 1px;
      background: url("/assets/ui/divider_line.png") center / 100% 100%
        no-repeat;
      opacity: 0.42;
      pointer-events: none;
    }
  }

  &__types {
    display: flex;
    gap: var(--gap-small);
  }
}

.price-type-button {
  @include textured-button;

  flex: 1;
  min-height: 46px;
  padding: 0 14px;
  border: 0;
  gap: 9px;

  &__icon {
    position: relative;
    display: block;
    flex: none;
    width: 24px;
    height: 24px;
    overflow: hidden;
    filter: drop-shadow(0 1px 0 rgba(0, 0, 0, 0.55));
    transition: transform 120ms ease;

    img {
      position: absolute;
      display: block;
      max-width: none;
    }

    &.is-money img {
      top: -8px;
      left: -13px;
      width: 40px;
      height: 40px;
    }

    &.is-gold img {
      inset: 0;
      width: 24px;
      height: 24px;
    }

    &.is-item img {
      top: -3px;
      left: -3px;
      width: 30px;
      height: 30px;
    }
  }

  &:hover:not(:disabled),
  &:focus-visible:not(:disabled) {
    .price-type-button__icon {
      transform: scale(1.08);
    }
  }
}

.price-message {
  @include message;

  &--error {
    color: var(--color-red-light);
  }
}
</style>
