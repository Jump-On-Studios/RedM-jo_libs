<template>
  <div class="price-form" :class="[entry.class, { error: hasError }]" :style="style">
    <div class="price-form__title">Payment options</div>

    <div class="price-form__options">
      <PriceOption
        v-for="(option, index) in options"
        :key="option.key"
        :option="option"
        :index="index"
        :available-types="availableTypes"
        :can-remove="options.length > 1"
        @remove="removeOption(index)"
      />
    </div>

    <button v-if="allowOr" type="button" class="price-form__add" @click="addOption">
      + Add another way to pay
    </button>

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

  options.value.push(createOption())
}

function removeOption(index: number) {
  if (options.value.length <= 1) return

  options.value.splice(index, 1)
}

watch(allowOr, (allowed) => {
  if (!allowed && options.value.length > 1) options.value = [options.value[0]!]
})

// Publishes the canonical payload as soon as the form is mounted, so the entry
// already holds a value before any button is pressed.
watch(priceValue, (next) => (value.value = next), { immediate: true })
</script>

<style scoped>
.price-form {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);
  padding: var(--gap-small);
  border: var(--border);
}

.price-form__title {
  font-variant-caps: small-caps;
}

.price-form__options {
  display: flex;
  flex-direction: column;
  gap: var(--gap-small);
}

.price-form__add {
  min-height: var(--field-height);
  border: var(--border);
  background-color: var(--color-field);
  cursor: pointer;
}

.price-form__add:hover {
  border-color: var(--color-border-strong);
  filter: brightness(1.4);
}
</style>
