<template>
  <div class="price-form" :class="[entry.class, { error: hasError }]" :style="style">
    <div class="price-form__title">Payment options</div>

    <div
      v-if="allowOr"
      class="price-form__tabs"
      role="tablist"
      aria-label="Payment options"
    >
      <button
        v-for="(option, index) in options"
        :id="`price-option-tab-${option.key}`"
        :key="option.key"
        type="button"
        class="price-form__tab"
        :class="{ active: option.key === activeOptionKey, invalid: optionError(option) }"
        role="tab"
        :aria-selected="option.key === activeOptionKey"
        aria-controls="price-option-panel"
        @click="selectOption(option.key)"
      >
        <span>Option {{ index + 1 }}</span>
        <small>{{ option.requirements.length }}</small>
        <span v-if="optionError(option)" aria-label="invalid"> *</span>
      </button>

      <button
        type="button"
        class="price-form__tab price-form__tab--add"
        aria-label="Add another payment option"
        @click="addOption"
      >
        +
      </button>
    </div>

    <div
      id="price-option-panel"
      class="price-form__options"
      role="tabpanel"
      :aria-labelledby="
        allowOr && activeOption
          ? `price-option-tab-${activeOption.key}`
          : undefined
      "
    >
      <PriceOption
        v-if="activeOption"
        :option="activeOption"
        :index="activeOptionIndex"
        :available-types="availableTypes"
        :can-remove="options.length > 1"
        @remove="removeOption(activeOptionIndex)"
      />
    </div>

    <PriceSummary
      v-if="summaryLines.length > 0"
      :lines="summaryLines"
      :warning="warning"
      :single-label="singleLabel"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import PriceOption from './price/PriceOption.vue'
import PriceSummary from './price/PriceSummary.vue'
import { useEntryStyle } from '@/composables/useEntryStyle'
import { useEntryValue } from '@/composables/useEntryValue'
import {
  ALL_COST_TYPES,
  areOptionsValid,
  buildPriceValue,
  createOption,
  optionError,
  parsePriceValue,
  summarizeOption,
} from '@/helpers/price'
import type { PriceEntry, PriceResult } from '@/types/entries'

const props = defineProps<{ entry: PriceEntry }>()

const style = useEntryStyle(() => props.entry)
const { value, hasError } = useEntryValue<PriceResult | null>(() => props.entry)

const allowOr = computed(() => props.entry.allowOR ?? true)

const availableTypes = computed(() => {
  const allowed = props.entry.options

  if (!allowed || allowed.length === 0) return ALL_COST_TYPES

  return ALL_COST_TYPES.filter((choice) => allowed.includes(choice.value))
})

// The initial value comes from Lua in any shape jo.pricing accepts.
const options = ref(parsePriceValue(props.entry.value, allowOr.value))
const activeOptionKey = ref(options.value[0]?.key ?? null)

const activeOptionIndex = computed(() => {
  const index = options.value.findIndex((option) => option.key === activeOptionKey.value)
  return index >= 0 ? index : 0
})

const activeOption = computed(() => options.value[activeOptionIndex.value] ?? null)

const usableOptions = computed(() =>
  allowOr.value ? options.value : options.value.slice(0, 1),
)

/** Null while an option is incomplete, which makes the `required` check fail. */
const priceValue = computed(() => buildPriceValue(options.value, allowOr.value))

const warning = computed(() => {
  if (areOptionsValid(usableOptions.value)) return null

  return 'This price cannot be confirmed until every option is valid.'
})

const summaryLines = computed(() => {
  if (options.value.length > 1 && allowOr.value) return options.value.map(summarizeOption)

  return options.value
    .filter((option) => option.requirements.length > 0)
    .map(summarizeOption)
})

const singleLabel = computed(() => {
  if (warning.value) return 'Current draft:'
  if (summaryLines.value[0] === 'Free') return 'Price:'

  return 'Player pays:'
})

function addOption() {
  if (!allowOr.value) return

  const option = createOption()
  options.value.push(option)
  activeOptionKey.value = option.key
}

function removeOption(index: number) {
  if (options.value.length <= 1) return

  const removedOption = options.value[index]
  options.value.splice(index, 1)

  if (removedOption?.key === activeOptionKey.value) {
    activeOptionKey.value = options.value[index]?.key ?? options.value[index - 1]?.key ?? null
  }
}

function selectOption(key: string) {
  if (options.value.some((option) => option.key === key)) activeOptionKey.value = key
}

watch(allowOr, (allowed) => {
  if (!allowed && options.value.length > 1) {
    options.value = [options.value[0]!]
    activeOptionKey.value = options.value[0]?.key ?? null
  }
})

// Publishes the canonical payload as soon as the form is mounted, so the entry
// already holds a value before any button is pressed.
watch(priceValue, (next) => (value.value = next), { immediate: true })
</script>

<style scoped lang="scss">
.price-form {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);
  padding: var(--gap-small);
  border: var(--border);

  &__title {
    font-variant-caps: small-caps;
  }

  &__tabs {
    display: flex;
    gap: var(--gap-small);
  }

  &__tab {
    @include surface-button;

    flex: 0 1 180px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;

    small {
      color: var(--color-text-dim);
      font-size: var(--font-size-small);
    }

    &.active {
      border-color: var(--color-border-strong);
    }

    &.invalid {
      color: var(--color-red-light);
    }

    &--add {
      flex: 0 0 44px;
      font-size: var(--font-size-title);
    }
  }

  // The panel itself never scrolls, so the options carry their own scroll: this
  // is the only part that can realistically grow past the panel height.
  &__options {
    display: flex;
    flex-direction: column;
    gap: var(--gap-small);
    max-height: 420px;
    overflow-y: auto;
  }

}
</style>
