<template>
  <div class="price-form" :class="{ error: error }">
    <div class="pf-header">
      <div>
        <div class="pf-title">Payment options</div>
      </div>
    </div>

    <div class="pf-options">
      <section
        v-for="(option, optionIndex) in paymentOptions"
        :key="option.key"
        class="pf-option-card"
      >
        <header class="pf-option-header">
          <div>
            <div class="pf-option-title">Option {{ optionIndex + 1 }}</div>
            <div class="pf-option-help">Player must pay all of these</div>
          </div>
          <button
            v-if="paymentOptions.length > 1"
            type="button"
            class="pf-icon-btn"
            @click="removeOption(optionIndex)"
            title="Remove payment option"
            aria-label="Remove payment option"
          >
            X
          </button>
        </header>

        <div v-if="option.components.length === 0" class="pf-empty">
          Choose what the player must pay for this option.
        </div>
        <span v-if="optionError(option)" class="pf-message pf-message-error">
          {{ optionError(option) }}
        </span>

        <div class="pf-requirements">
          <article
            v-for="(comp, componentIndex) in option.components"
            :key="comp.key"
            class="pf-requirement-card"
            :class="{ invalid: isComponentInvalid(comp) }"
          >
            <div class="pf-requirement-kind">
              <span class="pf-kind-label">{{ typeLabel(comp.type) }}</span>
            </div>

            <template v-if="comp.type === 'item'">
              <label class="pf-field pf-item-field">
                <span class="pf-field-label">Item</span>
                <input
                  type="text"
                  v-model="comp.itemName"
                  class="pf-input"
                  placeholder="item_name"
                />
              </label>
              <label class="pf-field pf-qty-field">
                <span class="pf-field-label">Qty</span>
                <input
                  type="number"
                  v-model.number="comp.quantity"
                  min="1"
                  step="1"
                  class="pf-input"
                  placeholder="1"
                />
              </label>
              <label class="pf-checkbox">
                <input type="checkbox" v-model="comp.keep" />
                <span>Keep item</span>
              </label>
            </template>

            <template v-else>
              <label class="pf-field pf-amount-field">
                <span class="pf-field-label">Amount</span>
                <input
                  type="number"
                  v-model.number="comp.value"
                  min="0"
                  step="0.01"
                  class="pf-input"
                  placeholder="0"
                />
              </label>
            </template>

            <span
              v-if="componentError(comp)"
              class="pf-message pf-message-error pf-requirement-message"
            >
              {{ componentError(comp) }}
            </span>

            <button
              type="button"
              class="pf-icon-btn pf-remove-requirement"
              @click="removeComponent(option, componentIndex)"
              title="Remove requirement"
              aria-label="Remove requirement"
            >
              X
            </button>
          </article>
        </div>

        <div class="pf-add-panel">
          <span class="pf-add-label">Add requirement</span>
          <div class="pf-type-buttons">
            <button
              v-for="type in availableTypes"
              :key="type.value"
              type="button"
              class="pf-type-btn"
              :disabled="isTypeDisabled(option, type.value)"
              :title="typeButtonTitle(option, type.value)"
              @click="addComponent(option, type.value)"
            >
              {{ type.label }}
            </button>
          </div>
        </div>
      </section>
    </div>

    <button
      v-if="allowOr"
      type="button"
      class="pf-add-option"
      @click="addOption"
    >
      + Add another way to pay
    </button>

    <div v-if="summaryLines.length > 0" class="pf-summary">
      <span v-if="priceWarning" class="pf-message pf-message-warning">
        {{ priceWarning }}
      </span>
      <template v-if="summaryLines.length === 1">
        <span class="pf-summary-label">
          {{ singleSummaryLabel }}
        </span>
        <span>{{ summaryLines[0] }}</span>
      </template>
      <template v-else>
        <span class="pf-summary-label">
          {{ priceWarning ? "Current options:" : "Player can pay either:" }}
        </span>
        <div
          v-for="(line, index) in summaryLines"
          :key="index"
          class="pf-summary-line"
        >
          <span>Option {{ index + 1 }}</span>
          <strong>{{ line }}</strong>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from "vue";

const props = defineProps({
  modelValue: { type: Object, default: null },
  options: { type: Array, default: () => ["money", "gold", "rol", "item"] },
  allowOr: { type: Boolean, default: true },
  error: { type: Boolean, default: false },
});

const emit = defineEmits(["update:modelValue"]);

const ALL_TYPES = [
  { value: "money", label: "Money" },
  { value: "gold", label: "Gold" },
  { value: "rol", label: "ROL" },
  { value: "item", label: "Item" },
];

const availableTypes = computed(() => {
  if (!props.options || props.options.length === 0) return ALL_TYPES;
  return ALL_TYPES.filter((type) => props.options.includes(type.value));
});

let nextKey = 1;
let initializing = false;
const paymentOptions = ref([createOption()]);

function createKey(prefix) {
  nextKey += 1;
  return `${prefix}-${nextKey}`;
}

function createOption(components = []) {
  return {
    key: createKey("option"),
    components,
  };
}

function defaultType() {
  return availableTypes.value[0]?.value ?? "money";
}

function createComponent(type = defaultType(), overrides = {}) {
  return {
    key: createKey("component"),
    type,
    value: 1,
    itemName: "",
    quantity: 1,
    keep: false,
    ...overrides,
  };
}

function typeLabel(type) {
  return ALL_TYPES.find((entry) => entry.value === type)?.label ?? type;
}

function isTypeDisabled(option, type) {
  return (
    type !== "item" && option.components.some((comp) => comp.type === type)
  );
}

function typeButtonTitle(option, type) {
  if (!isTypeDisabled(option, type)) return `Add ${typeLabel(type)}`;
  return `${typeLabel(type)} is already in this option.`;
}

function addComponent(option, type = defaultType()) {
  if (isTypeDisabled(option, type)) return;
  option.components.push(createComponent(type));
}

function removeComponent(option, index) {
  option.components.splice(index, 1);
}

function addOption() {
  if (!props.allowOr) return;
  paymentOptions.value.push(createOption());
}

function removeOption(index) {
  if (paymentOptions.value.length <= 1) return;
  paymentOptions.value.splice(index, 1);
}

function isComponentInvalid(comp) {
  return componentError(comp) !== null;
}

function componentError(comp) {
  if (comp.type === "item") {
    if (!comp.itemName?.trim()) return "Item name is required.";
    if (Number(comp.quantity || 0) <= 0)
      return "Quantity must be greater than 0.";
    return null;
  }
  const value = Number(comp.value || 0);
  if (comp.type === "money") {
    if (value < 0) return "Money cannot be negative.";
    return null;
  }
  if (value <= 0) {
    return "Amount must be greater than 0.";
  }
  return null;
}

function optionError(option) {
  if (option.components.length === 0) {
    return "This payment option needs at least one requirement.";
  }
  if (option.components.some(isComponentInvalid)) {
    return "Fix invalid requirements in this option.";
  }
  return null;
}

watch(
  () => props.allowOr,
  (allowOr) => {
    if (!allowOr && paymentOptions.value.length > 1) {
      paymentOptions.value = [paymentOptions.value[0]];
    }
  },
);

function generateOption(option) {
  const result = {};
  const items = [];

  for (const comp of option.components) {
    if (comp.type === "item") {
      const item = { item: comp.itemName.trim() || "item_name" };
      if ((comp.quantity || 1) > 1) item.quantity = comp.quantity;
      if (comp.keep) item.keep = true;
      items.push(item);
    } else {
      const val = parseFloat(comp.value) || 0;
      result[comp.type] = (result[comp.type] || 0) + val;
    }
  }

  if (items.length > 0) result.items = items;
  return result;
}

const computedValue = computed(() => {
  const options = props.allowOr
    ? paymentOptions.value
    : paymentOptions.value.slice(0, 1);

  if (!areOptionsValid(options)) return null;
  if (options.length === 1 || !props.allowOr) {
    return generateOption(options[0]);
  }

  return {
    operator: "or",
    options: options.map((option) => generateOption(option)),
  };
});

function areOptionsValid(options) {
  if (options.length === 0) return false;
  return options.every((option) => optionError(option) === null);
}

const priceWarning = computed(() => {
  const options = props.allowOr
    ? paymentOptions.value
    : paymentOptions.value.slice(0, 1);
  if (areOptionsValid(options)) return null;
  return "This price cannot be confirmed until every option is valid.";
});

watch(
  computedValue,
  (val) => {
    if (initializing) return;
    emit("update:modelValue", val);
  },
  { deep: true },
);

function extractNumericEntries(obj) {
  const entries = [];
  for (let i = 1; obj[String(i)] != null; i++) {
    entries.push(obj[String(i)]);
  }
  return entries;
}

function parseEntry(entry, components) {
  if (entry.item != null) {
    components.push(
      createComponent("item", {
        value: 1,
        itemName: entry.item || "",
        quantity: entry.quantity || 1,
        keep: entry.keep || false,
      }),
    );
    return;
  }

  for (const key of ["money", "gold", "rol"]) {
    if (entry[key] != null) {
      components.push(
        createComponent(key, {
          value: entry[key],
          itemName: "",
          quantity: 1,
          keep: false,
        }),
      );
      break;
    }
  }
}

function parseOption(opt) {
  const components = [];
  if (!opt) return createOption(components);

  let entries = [];
  let namedKeys = {};

  if (Array.isArray(opt)) {
    entries = opt;
  } else {
    entries = extractNumericEntries(opt);
    for (const key of Object.keys(opt)) {
      if (!/^\d+$/.test(key)) {
        namedKeys[key] = opt[key];
      }
    }
  }

  for (const entry of entries) {
    parseEntry(entry, components);
  }

  if (Array.isArray(namedKeys.items)) {
    for (const item of namedKeys.items) {
      parseEntry(item, components);
    }
  }

  for (const key of ["money", "gold", "rol"]) {
    if (namedKeys[key] != null) {
      components.push(
        createComponent(key, {
          value: namedKeys[key],
          itemName: "",
          quantity: 1,
          keep: false,
        }),
      );
    }
  }

  return createOption(components);
}

function parseInitialValue(val) {
  initializing = true;

  if (!val) {
    paymentOptions.value = [createOption()];
  } else if (val.operator === "or") {
    let options;
    if (Array.isArray(val.options)) {
      options = val.options;
    } else {
      options = extractNumericEntries(val);
    }

    const parsedOptions = options.map((option) => parseOption(option));
    if (props.allowOr) {
      paymentOptions.value = parsedOptions.length
        ? parsedOptions
        : [createOption()];
    } else {
      paymentOptions.value = [parsedOptions[0] ?? createOption()];
    }
  } else {
    paymentOptions.value = [parseOption(val)];
  }

  nextTick(() => {
    initializing = false;
    emit("update:modelValue", computedValue.value);
  });
}

function formatNumber(value) {
  const number = Number(value || 0);
  return Number.isInteger(number) ? String(number) : number.toFixed(2);
}

function summarizeComponent(comp) {
  if (comp.type === "item") {
    const name = comp.itemName?.trim() || "missing item";
    const quantity = Math.max(Number(comp.quantity || 1), 1);
    return `${formatNumber(quantity)}x ${name}${comp.keep ? " kept" : ""}`;
  }

  return `${typeLabel(comp.type)} ${formatNumber(comp.value)}`;
}

function summarizeOption(option) {
  if (!option.components.length) return "No requirement set";
  if (isFreeOption(option)) return "Free";
  return option.components.map(summarizeComponent).join(" + ");
}

function isFreeOption(option) {
  return (
    option.components.length === 1 &&
    option.components[0].type === "money" &&
    Number(option.components[0].value || 0) === 0
  );
}

const summaryLines = computed(() => {
  if (paymentOptions.value.length > 1 && props.allowOr) {
    return paymentOptions.value.map(summarizeOption);
  }
  return paymentOptions.value
    .filter((option) => option.components.length > 0)
    .map(summarizeOption);
});

const singleSummaryLabel = computed(() => {
  if (priceWarning.value) return "Current draft:";
  if (summaryLines.value[0] === "Free") return "Price:";
  return "Player pays:";
});

onMounted(() => {
  parseInitialValue(props.modelValue);
});
</script>

<style lang="scss" scoped>
.price-form {
  flex: 1;
  min-width: 0;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 0.85rem;

  &.error {
    box-shadow:
      0 0 0 1px var(--color-red-light),
      0 0 8px rgba(226, 2, 2, 0.35);
  }
}

.pf-header {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.75rem 0.85rem;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.pf-title,
.pf-option-title,
.pf-kind-label {
  color: white;
  font-variant-caps: small-caps;
}

.pf-title {
  font-size: 0.95em;
}

.pf-option-help,
.pf-field-label,
.pf-add-label,
.pf-summary-label {
  color: rgba(255, 255, 255, 0.46);
  font-size: 0.74em;
  font-variant-caps: small-caps;
}

.pf-options {
  flex: 1 1 auto;
  min-height: 0;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding-right: 0.25rem;
}

.pf-option-card {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding: 0.9rem;
  background: rgba(255, 255, 255, 0.018);
  border: 1px solid rgba(255, 255, 255, 0.09);
}

.pf-option-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 0.75rem;
}

.pf-option-title {
  font-size: 0.9em;
}

.pf-empty {
  padding: 1rem;
  color: rgba(255, 255, 255, 0.42);
  background: rgba(255, 255, 255, 0.03);
  text-align: center;
}

.pf-message {
  display: block;
  color: rgba(255, 255, 255, 0.74);
  font-size: 0.74em;
  line-height: 1.25;
}

.pf-message-error {
  color: #ff8c8c;
}

.pf-message-warning {
  color: #f0c674;
}

.pf-requirements {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.pf-requirement-card {
  --pf-kind-size: 4.1rem;

  display: grid;
  grid-template-columns:
    var(--pf-kind-size) minmax(8rem, 1fr) minmax(4.5rem, 5.5rem)
    auto 2.2rem;
  align-items: center;
  gap: 0.5rem;
  padding: 0.65rem;
  background: rgba(255, 255, 255, 0.035);
  border: 1px solid transparent;

  &.invalid {
    border-color: rgba(226, 2, 2, 0.5);
    background: rgba(119, 0, 0, 0.12);
  }
}

.pf-requirement-kind {
  width: var(--pf-kind-size);
  height: var(--pf-kind-size);
  align-self: center;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem;
  background: rgba(255, 255, 255, 0.045);
  box-sizing: border-box;
}

.pf-kind-label {
  color: rgba(255, 255, 255, 0.82);
  font-size: 0.86em;
  text-align: center;
}

.pf-field {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.pf-item-field {
  grid-column: 2;
}

.pf-qty-field {
  grid-column: 3;
}

.pf-amount-field {
  grid-column: 2 / span 3;
}

.pf-requirement-message {
  grid-column: 2 / span 3;
  grid-row: 2;
}

.pf-input {
  width: 100%;
  min-height: 2.85rem;
  padding: 0.72rem var(--padding-input-X);
  border: 1px solid transparent;
  color: white;
  background-color: var(--color-background-grey);
  border-radius: 0;
  box-shadow: none;
  box-sizing: border-box;
  font-family: inherit;
  font-size: inherit;
  color-scheme: dark;

  &:focus,
  &:focus-visible {
    outline: none;
    border-color: rgba(255, 255, 255, 0.22);
    box-shadow: none;
  }
}

.pf-checkbox {
  align-self: center;
  display: inline-flex;
  align-items: center;
  justify-self: center;
  gap: 0.42rem;
  margin-bottom: 0;
  color: rgba(255, 255, 255, 0.58);
  cursor: pointer;
  font-size: 0.78em;
  white-space: nowrap;
  user-select: none;
  margin-top: 1.4rem;

  input[type="checkbox"] {
    width: 14px;
    height: 14px;
    accent-color: var(--color-red);
    cursor: pointer;
  }
}

.pf-icon-btn {
  width: 2.2rem;
  height: 2.85rem;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  color: rgba(255, 255, 255, 0.4);
  cursor: pointer;
  font-family: inherit;
  font-size: 0.72em;
  line-height: 1;
  transition:
    border-color 0.15s ease,
    color 0.15s ease,
    background-color 0.15s ease;

  &:hover {
    background-color: rgba(119, 0, 0, 0.35);
    border-color: rgba(226, 2, 2, 0.45);
    color: white;
  }
}

.pf-remove-requirement {
  grid-column: 5;
  grid-row: 1;
  align-self: end;
}

.pf-add-panel {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  padding-top: 0.15rem;
}

.pf-type-buttons {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.4rem;
}

.pf-type-btn,
.pf-add-option {
  min-height: 2.65rem;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: var(--color-background-grey);
  color: rgba(255, 255, 255, 0.68);
  cursor: pointer;
  font-family: inherit;
  transition:
    filter 0.2s ease,
    color 0.2s ease,
    border-color 0.2s ease;

  &:hover {
    color: white;
    filter: brightness(1.18);
    border-color: rgba(255, 255, 255, 0.16);
  }

  &:disabled {
    color: rgba(255, 255, 255, 0.24);
    cursor: not-allowed;
    filter: none;
    opacity: 0.55;
  }

  &:disabled:hover {
    color: rgba(255, 255, 255, 0.24);
    border-color: rgba(255, 255, 255, 0.08);
  }
}

.pf-add-option {
  background: rgba(255, 255, 255, 0.045);
}

.pf-summary {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  padding: 0.75rem 0.85rem;
  background: rgba(255, 255, 255, 0.035);
  border-left: 3px solid rgba(255, 255, 255, 0.14);
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.82em;
}

.pf-summary-line {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  min-width: 0;

  span {
    flex: 0 0 auto;
    color: rgba(255, 255, 255, 0.46);
    font-variant-caps: small-caps;
  }

  strong {
    min-width: 0;
    overflow-wrap: anywhere;
    font-weight: 500;
  }
}

@media (max-width: 900px) {
  .pf-requirement-card {
    grid-template-columns: var(--pf-kind-size) minmax(8rem, 1fr) 2.2rem;
  }

  .pf-item-field,
  .pf-amount-field,
  .pf-requirement-message {
    grid-column: 2;
  }

  .pf-requirement-message {
    grid-row: auto;
  }

  .pf-qty-field {
    grid-column: 1;
  }

  .pf-checkbox {
    grid-column: 2;
    align-self: center;
  }

  .pf-remove-requirement {
    grid-column: 3;
  }

  .pf-type-buttons {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 620px) {
  .pf-header,
  .pf-option-header {
    flex-direction: column;
  }

  .pf-requirement-card {
    grid-template-columns: 1fr;
  }

  .pf-requirement-kind,
  .pf-item-field,
  .pf-qty-field,
  .pf-amount-field,
  .pf-requirement-message,
  .pf-checkbox,
  .pf-remove-requirement {
    grid-column: 1;
    grid-row: auto;
  }

  .pf-requirement-kind,
  .pf-checkbox,
  .pf-remove-requirement {
    align-self: start;
  }

  .pf-remove-requirement {
    width: 100%;
  }

  .pf-type-buttons {
    grid-template-columns: 1fr;
  }
}
</style>
