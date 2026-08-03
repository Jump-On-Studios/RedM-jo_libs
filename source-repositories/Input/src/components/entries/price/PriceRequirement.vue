<template>
  <article class="price-requirement" :class="{ 'is-invalid': error }">
    <span class="price-requirement__kind">
      <span
        v-if="requirementIcon(requirement.type)"
        class="price-requirement__icon"
        :class="`is-${requirement.type}`"
        aria-hidden="true"
      >
        <img :src="requirementIcon(requirement.type)" alt="" />
      </span>
      <span>{{ typeLabel(requirement.type) }}</span>
    </span>

    <template v-if="requirement.type === 'item'">
      <label class="price-field">
        <span class="entry-field__caps" aria-hidden="true" />
        <span class="price-field__label" v-i18n="'inputNuiItem'">Item</span>
        <input
          v-model="requirement.itemName"
          type="text"
          class="entry-input"
          placeholder="item_name"
        />
      </label>
      <label class="price-field price-field--narrow">
        <span class="entry-field__caps" aria-hidden="true" />
        <span class="price-field__label" v-i18n="'inputNuiQuantity'">Qty</span>
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
        <span v-i18n="'inputNuiKeep'">Keep</span>
      </label>
    </template>

    <template v-else>
      <label class="price-field">
        <span class="entry-field__caps" aria-hidden="true" />
        <span class="price-field__label" v-i18n="'inputNuiAmount'">
          Amount
        </span>
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
      :title="getString('inputNuiRemoveRequirement', 'Remove requirement')"
      @click="emit('remove')"
    >
      <img src="/assets/ui/trash.png" alt="" aria-hidden="true" />
    </button>

    <span v-if="error" class="price-message price-message--error">{{ error }}</span>
  </article>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { requirementError, typeLabel, type PriceRequirement } from '@/helpers/price'
import { useLangStore } from '@/stores/lang'
import type { PriceCostType } from '@/types/entries'

const props = defineProps<{ requirement: PriceRequirement }>()

const emit = defineEmits<{ remove: [] }>()

const langStore = useLangStore()
const error = computed(() => requirementError(props.requirement))

const requirementIcons: Partial<Record<PriceCostType, string>> = {
  money: '/assets/ui/dollar.png',
  gold: '/assets/ui/gold.png',
  item: '/assets/ui/item.png',
}

function requirementIcon(type: PriceCostType) {
  return requirementIcons[type]
}

function getString(key: string, fallback: string) {
  return langStore.getString(key, fallback)
}
</script>

<style scoped lang="scss">
.price-requirement {
  position: relative;
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: var(--gap-small);
  padding: 10px 0 12px;

  & + & {
    padding-top: 6px;
  }

  &.is-invalid {
    color: var(--color-red-light);
  }

  &__kind {
    flex: none;
    width: 90px;
    align-self: center;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--color-text-dim);
    font-size: var(--font-size-small);
    font-variant-caps: small-caps;
    letter-spacing: 0.04em;
  }

  &__icon {
    position: relative;
    display: block;
    flex: none;
    width: 18px;
    height: 18px;
    overflow: hidden;
    filter: drop-shadow(0 1px 0 rgba(0, 0, 0, 0.55));

    img {
      position: absolute;
      display: block;
      max-width: none;
    }

    &.is-money img {
      top: -3px;
      left: -8px;
      width: 24px;
      height: 24px;
    }

    &.is-gold img {
      top: 2px;
      left: 2px;
      width: 14px;
      height: 14px;
    }

    &.is-item img {
      top: -1px;
      left: -2px;
      width: 19px;
      height: 19px;
    }
  }
}

.price-field {
  position: relative;
  isolation: isolate;
  flex: 1;
  min-width: 140px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-height: 66px;
  padding: 9px 13px 7px;
  border: 0;
  background: transparent;
  color: var(--color-text);

  &::before {
    content: "";
    position: absolute;
    inset: 0;
    left: calc(var(--entry-field-cap) - var(--entry-field-cap-overlap));
    right: calc(var(--entry-field-cap) - var(--entry-field-cap-overlap));
    z-index: 0;
    background-color: var(--color-field);
    // Keep only the source middle between the native left/right caps.
    -webkit-mask: url('/assets/ui/selection_box_bg_1d.png') center / 135% 100% no-repeat;
    mask: url('/assets/ui/selection_box_bg_1d.png') center / 135% 100% no-repeat;
  }

  &::after {
    @include selection-frame;
    z-index: 2;
    opacity: 0;
    transition: opacity 120ms ease;
  }

  &:focus-within::after {
    opacity: 1;
  }

  input {
    position: relative;
    min-height: 30px;
    padding: 0;
    border: 0;
    background: transparent;
    color: var(--color-text);
    outline: none;
    z-index: 1;
  }

  input::placeholder {
    color: var(--color-placeholder);
    opacity: 1;
  }

  &--narrow {
    flex: none;
    width: 120px;
    min-width: 0;
  }

  &__label {
    @include muted-label;
    position: relative;
    z-index: 1;
    padding-left: 3px;
  }
}

.price-checkbox {
  position: relative;
  align-self: center;
  flex: none;
  display: flex;
  align-items: center;
  gap: var(--gap-small);
  height: var(--field-height);
  color: var(--color-text-dim);
  font-size: var(--font-size-small);
  cursor: pointer;

  input {
    position: absolute;
    width: 1px;
    height: 1px;
    opacity: 0;
    cursor: pointer;

    &:focus-visible {
      & + span::before {
        outline: 2px solid var(--color-red-light);
        outline-offset: 3px;
      }
    }
  }

  span {
    position: relative;
    display: inline-flex;
    align-items: center;
    gap: 7px;

    &::before {
      content: "";
      display: block;
      width: 24px;
      height: 24px;
      background: var(--color-field);
      background-image: url('/assets/ui/selection_box_square.png');
      background-position: center;
      background-size: 100% 100%;
    }
  }

  &:has(input:checked) span::before {
    background-color: var(--color-red);
    box-shadow: inset 0 0 0 4px var(--color-field);
  }

  &:has(input:checked) span::after {
    content: "✓";
    position: absolute;
    left: 4px;
    color: var(--color-text);
    font-size: 15px;
    line-height: 20px;
  }
}

.price-icon-button {
  @include icon-button;

  align-self: center;
  display: grid;
  place-items: center;
  width: 36px;
  height: var(--field-height);
  border: 0;
  background: transparent;
  color: var(--color-red-light);

  img {
    display: block;
    width: 22px;
    height: 22px;
    opacity: 0.8;
    transition: opacity 120ms ease, transform 120ms ease;
  }

  &:hover,
  &:focus-visible {
    border: 0;
    background: transparent;
    outline: none;

    img {
      opacity: 1;
      transform: scale(1.08);
    }
  }
}

.price-message {
  @include message;

  // Pushed onto its own line of the wrapping flex row.
  flex: 1 0 100%;

  &--error {
    color: var(--color-red-light);
  }
}
</style>
