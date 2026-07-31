<template>
  <div
    class="price-form"
    :class="[entry.class, { error: hasError }]"
    :style="style"
  >
    <div class="price-form__heading">
      <span>Payment options</span>
      <small v-if="allowOr">Choose one or more ways to meet the price</small>
    </div>
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
        :class="{
          active: option.key === activeOptionKey,
          invalid: optionError(option),
        }"
        role="tab"
        :aria-selected="option.key === activeOptionKey"
        aria-controls="price-option-panel"
        @click="selectOption(option.key)"
      >
        <span class="price-form__tab-label">Option {{ index + 1 }}</span>
        <span
          v-if="option.requirements.length > 0"
          class="price-form__tab-count"
          :aria-label="`${option.requirements.length} requirements`"
        >
          {{ option.requirements.length }}
        </span>
        <span
          v-if="optionError(option)"
          class="price-form__tab-invalid"
          aria-label="invalid"
        >
          !
        </span>
      </button>

      <button
        type="button"
        class="price-form__tab price-form__tab--add"
        aria-label="Add another payment option"
        @click="addOption"
      >
        <img src="/assets/ui/plus.png" alt="" aria-hidden="true" />
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
        :can-duplicate="allowOr"
        @duplicate="duplicateOption(activeOptionIndex)"
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
import { computed, ref, watch } from "vue";
import PriceOption from "./price/PriceOption.vue";
import PriceSummary from "./price/PriceSummary.vue";
import { useEntryStyle } from "@/composables/useEntryStyle";
import { useEntryValue } from "@/composables/useEntryValue";
import {
  ALL_COST_TYPES,
  areOptionsValid,
  buildPriceValue,
  createOption,
  createRequirement,
  optionError,
  parsePriceValue,
  summarizeOption,
} from "@/helpers/price";
import type { PriceEntry, PriceResult } from "@/types/entries";

const props = defineProps<{ entry: PriceEntry }>();

const style = useEntryStyle(() => props.entry);
const { value, hasError } = useEntryValue<PriceResult | null>(
  () => props.entry,
);

const allowOr = computed(() => props.entry.allowOR ?? true);

const availableTypes = computed(() => {
  const allowed = props.entry.options;

  if (!allowed || allowed.length === 0) return ALL_COST_TYPES;

  return ALL_COST_TYPES.filter((choice) => allowed.includes(choice.value));
});

// The initial value comes from Lua in any shape jo.pricing accepts.
const options = ref(parsePriceValue(props.entry.value, allowOr.value));
const activeOptionKey = ref(options.value[0]?.key ?? null);

const activeOptionIndex = computed(() => {
  const index = options.value.findIndex(
    (option) => option.key === activeOptionKey.value,
  );
  return index >= 0 ? index : 0;
});

const activeOption = computed(
  () => options.value[activeOptionIndex.value] ?? null,
);

const usableOptions = computed(() =>
  allowOr.value ? options.value : options.value.slice(0, 1),
);

/** Null while an option is incomplete, which makes the `required` check fail. */
const priceValue = computed(() =>
  buildPriceValue(options.value, allowOr.value),
);

const warning = computed(() => {
  if (areOptionsValid(usableOptions.value)) return null;

  return "This price cannot be confirmed until every option is valid.";
});

const summaryLines = computed(() => {
  if (options.value.length > 1 && allowOr.value)
    return options.value.map(summarizeOption);

  return options.value
    .filter((option) => option.requirements.length > 0)
    .map(summarizeOption);
});

const singleLabel = computed(() => {
  if (warning.value) return "Current draft:";
  if (summaryLines.value[0] === "Free") return "Price:";

  return "Player pays:";
});

function addOption() {
  if (!allowOr.value) return;

  const option = createOption();
  options.value.push(option);
  activeOptionKey.value = option.key;
}

function duplicateOption(index: number) {
  if (!allowOr.value) return;

  const source = options.value[index];
  if (!source) return;

  const duplicate = createOption(
    source.requirements.map((requirement) =>
      createRequirement(requirement.type, {
        value: requirement.value,
        itemName: requirement.itemName,
        quantity: requirement.quantity,
        keep: requirement.keep,
      }),
    ),
  );

  options.value.splice(index + 1, 0, duplicate);
  activeOptionKey.value = duplicate.key;
}

function removeOption(index: number) {
  if (options.value.length <= 1) return;

  const removedOption = options.value[index];
  options.value.splice(index, 1);

  if (removedOption?.key === activeOptionKey.value) {
    activeOptionKey.value =
      options.value[index]?.key ?? options.value[index - 1]?.key ?? null;
  }
}

function selectOption(key: string) {
  if (options.value.some((option) => option.key === key))
    activeOptionKey.value = key;
}

watch(allowOr, (allowed) => {
  if (!allowed && options.value.length > 1) {
    options.value = [options.value[0]!];
    activeOptionKey.value = options.value[0]?.key ?? null;
  }
});

// Publishes the canonical payload as soon as the form is mounted, so the entry
// already holds a value before any button is pressed.
watch(priceValue, (next) => (value.value = next), { immediate: true });
</script>

<style scoped lang="scss">
.price-form {
  position: relative;
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding-top: 4px;
  padding: 20px 0px;

  &::before {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    left: 0;
    height: 1px;
    background: url("/assets/ui/divider_line.png") center / 100% 100% no-repeat;
    opacity: 0.55;
    pointer-events: none;
  }

  &__heading {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: var(--gap);
    min-height: 22px;

    span {
      color: var(--color-text);
      font-size: var(--font-size-small);
      font-variant-caps: small-caps;
      letter-spacing: 0.08em;
    }

    small {
      color: var(--color-text-dim);
      font-size: 13px;
    }
  }

  &__tabs {
    position: relative;
    display: flex;
    gap: 8px;

    padding-bottom: 2px;
  }

  &__tab {
    position: relative;
    flex: 0 1 180px;
    isolation: isolate;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    min-height: 42px;
    padding: 0 16px;
    border: 0;
    background: transparent;
    color: var(--color-text-dim);
    cursor: pointer;
    transition:
      color 120ms ease,
      filter 120ms ease;

    &::before {
      content: "";
      position: absolute;
      inset: 2px 0;
      z-index: -1;
      background-color: color-mix(in srgb, var(--color-field) 68%, transparent);
      -webkit-mask: url("/assets/ui/selection_box_bg_1d.png") center / 100% 100%
        no-repeat;
      mask: url("/assets/ui/selection_box_bg_1d.png") center / 100% 100%
        no-repeat;
      opacity: 0.72;
    }

    &::after {
      @include selection-frame;
      opacity: 0;
      transition: opacity 120ms ease;
    }

    &-label {
      white-space: nowrap;
    }

    &-count {
      position: absolute;
      top: -7px;
      right: -7px;
      z-index: 4;
      display: inline-grid;
      place-items: center;
      flex: none;
      width: 22px;
      height: 22px;
      border: 1px solid var(--color-border-strong);
      border-radius: 50%;
      background-color: color-mix(
        in srgb,
        var(--color-background) 68%,
        transparent
      );
      color: var(--color-text);
      font-size: 13px;
      font-weight: 600;
      line-height: 1;
    }

    &-invalid {
      color: var(--color-red-light);
      font-weight: 700;
    }

    &.active {
      color: var(--color-text);

      &::before,
      &::after {
        opacity: 1;
      }
    }

    &.invalid {
      color: var(--color-red-light);
    }

    &--add {
      flex: 0 0 44px;
      padding: 0;
      img {
        display: block;
        width: 18px;
        height: 18px;
        object-fit: contain;
        opacity: 0.78;
        transition:
          opacity 120ms ease,
          transform 120ms ease;
      }
    }

    &:hover,
    &:focus-visible {
      color: var(--color-text);

      &::after {
        opacity: 1;
      }

      &.price-form__tab--add img {
        opacity: 1;
        transform: scale(1.08);
      }
    }
  }

  // The option header and add controls stay visible; only its requirement list
  // owns the scroll area.
  &__options {
    display: flex;
    flex-direction: column;
    gap: 8px;
    background-color: color-mix(in srgb, var(--color-surface) 20%, transparent);
    padding: 20px 20px;
    border-left: 3px solid
      color-mix(in srgb, var(--color-border-strong) 58%, transparent);
    overflow: visible;
  }
}
</style>
