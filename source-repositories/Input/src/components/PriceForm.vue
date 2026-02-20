<template>
  <div class="price-form" :class="{ error: error }">
    <!-- OR mode toggle -->
    <div v-if="allowOr" class="pf-or-toggle">
      <label class="pf-checkbox">
        <input type="checkbox" v-model="useOr" />
        <span>Multiple options</span>
      </label>
    </div>

    <!-- Single option mode -->
    <div v-if="!useOr" class="pf-option-card">
      <div
        v-for="(comp, cIdx) in singleOption.components"
        :key="cIdx"
        class="pf-component-row"
      >
        <Select
          v-model="comp.type"
          :options="TYPES"
          optionLabel="label"
          optionValue="value"
          class="pf-type-select"
        />
        <template v-if="comp.type !== 'item'">
          <input
            type="number"
            v-model.number="comp.value"
            min="0"
            step="0.01"
            class="pf-input pf-input-amount"
            placeholder="0"
          />
        </template>
        <template v-else>
          <input
            type="number"
            v-model.number="comp.quantity"
            min="1"
            class="pf-input pf-input-qty"
            placeholder="1"
          />
          <span class="pf-x">×</span>
          <input
            type="text"
            v-model="comp.itemName"
            class="pf-input pf-input-grow"
            placeholder="item_name"
          />
          <label class="pf-checkbox pf-checkbox-inline">
            <input type="checkbox" v-model="comp.keep" />
            <span>Keep</span>
          </label>
        </template>
        <button
          class="pf-btn-remove"
          @click="removeComponent(singleOption, cIdx)"
          title="Remove"
        >
          ✕
        </button>
      </div>
      <button class="pf-btn-add" @click="addComponent(singleOption)">
        + Add currency
      </button>
    </div>

    <!-- OR mode -->
    <div v-else class="pf-or-container">
      <div
        v-for="(option, oIdx) in multiOptions"
        :key="oIdx"
        class="pf-option-card pf-option-bordered"
      >
        <div class="pf-option-header">
          <span class="pf-option-label">Option {{ oIdx + 1 }}</span>
          <button
            v-if="multiOptions.length > 1"
            class="pf-btn-remove"
            @click="removeOption(oIdx)"
            title="Remove option"
          >
            ✕
          </button>
        </div>
        <div
          v-for="(comp, cIdx) in option.components"
          :key="cIdx"
          class="pf-component-row"
        >
          <Select
            v-model="comp.type"
            :options="TYPES"
            optionLabel="label"
            optionValue="value"
            class="pf-type-select"
          />
          <template v-if="comp.type !== 'item'">
            <input
              type="number"
              v-model.number="comp.value"
              min="0"
              step="0.01"
              class="pf-input pf-input-amount"
              placeholder="0"
            />
          </template>
          <template v-else>
            <input
              type="number"
              v-model.number="comp.quantity"
              min="1"
              class="pf-input pf-input-qty"
              placeholder="1"
            />
            <span class="pf-x">×</span>
            <input
              type="text"
              v-model="comp.itemName"
              class="pf-input pf-input-grow"
              placeholder="item_name"
            />
            <label class="pf-checkbox pf-checkbox-inline">
              <input type="checkbox" v-model="comp.keep" />
              <span>Keep</span>
            </label>
          </template>
          <button
            class="pf-btn-remove"
            @click="removeComponent(option, cIdx)"
            title="Remove"
          >
            ✕
          </button>
        </div>
        <button class="pf-btn-add" @click="addComponent(option)">
          + Add currency
        </button>
      </div>
      <button class="pf-btn-add-option" @click="addOption">
        + Add payment option
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, nextTick } from "vue";
import Select from "primevue/select";

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
  { value: "rol", label: "Rol" },
  { value: "item", label: "Item" },
];

const TYPES = computed(() => {
  if (!props.options || props.options.length === 0) return ALL_TYPES;
  return ALL_TYPES.filter((t) => props.options.includes(t.value));
});

const useOr = ref(false);
const singleOption = ref({ components: [] });
const multiOptions = ref([{ components: [] }]);

function defaultType() {
  return TYPES.value[0]?.value ?? "money";
}

function createComponent() {
  return {
    type: defaultType(),
    value: 1,
    itemName: "",
    quantity: 1,
    keep: false,
  };
}

function addComponent(option) {
  option.components.push(createComponent());
}

function removeComponent(option, idx) {
  option.components.splice(idx, 1);
}

function addOption() {
  multiOptions.value.push({ components: [] });
}

function removeOption(idx) {
  if (multiOptions.value.length > 1) {
    multiOptions.value.splice(idx, 1);
  }
}

let initializing = false;

watch(useOr, (isOr) => {
  if (initializing) return;
  if (isOr) {
    multiOptions.value[0] = {
      components: singleOption.value.components.map((c) => ({ ...c })),
    };
  } else {
    singleOption.value = {
      components: multiOptions.value[0].components.map((c) => ({ ...c })),
    };
  }
});

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
  if (useOr.value) {
    const allEmpty = multiOptions.value.every(
      (opt) => opt.components.length === 0,
    );
    if (allEmpty) return null;
    return {
      operator: "or",
      options: multiOptions.value.map((opt) => generateOption(opt)),
    };
  } else {
    if (singleOption.value.components.length === 0) return null;
    return generateOption(singleOption.value);
  }
});

watch(
  computedValue,
  (val) => {
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
    components.push({
      type: "item",
      value: 1,
      itemName: entry.item || "",
      quantity: entry.quantity || 1,
      keep: entry.keep || false,
    });
  } else {
    for (const key of ["money", "gold", "rol"]) {
      if (entry[key] != null) {
        components.push({
          type: key,
          value: entry[key],
          itemName: "",
          quantity: 1,
          keep: false,
        });
        break;
      }
    }
  }
}

function parseOption(opt) {
  const components = [];
  if (!opt) return { components };

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
      components.push({
        type: key,
        value: namedKeys[key],
        itemName: "",
        quantity: 1,
        keep: false,
      });
    }
  }

  return { components };
}

function parseInitialValue(val) {
  if (!val) return;
  initializing = true;
  if (val.operator === "or") {
    useOr.value = true;
    let options;
    if (Array.isArray(val.options)) {
      options = val.options;
    } else {
      options = extractNumericEntries(val);
    }
    multiOptions.value = options.map((opt) => parseOption(opt));
  } else {
    useOr.value = false;
    singleOption.value = parseOption(val);
  }
  nextTick(() => {
    initializing = false;
  });
}

onMounted(() => {
  parseInitialValue(props.modelValue);
});
</script>

<style lang="scss" scoped>
.price-form {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-height: 320px;
  overflow-y: auto;
  gap: var(--element-gap);

  &.error {
    box-shadow: 0px 0px 5px var(--color-red-light);
  }
}

.pf-or-toggle {
  display: flex;
  align-items: center;
}

.pf-checkbox {
  display: flex;
  align-items: center;
  gap: 0.4em;
  cursor: pointer;
  font-size: 0.8em;
  color: rgba(255, 255, 255, 0.5);
  user-select: none;

  input[type="checkbox"] {
    width: 13px;
    height: 13px;
    accent-color: var(--color-red);
    cursor: pointer;
  }

  em {
    font-style: normal;
    font-size: 0.9em;
  }
}

.pf-checkbox-inline {
  gap: 0.3em;
  white-space: nowrap;
  color: rgba(255, 255, 255, 0.4);
}

.pf-or-container {
  display: flex;
  flex-direction: column;
  gap: var(--element-gap);
}

.pf-option-card {
  display: flex;
  flex-direction: column;
  gap: var(--element-gap);
}

.pf-option-bordered {
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: calc(var(--element-gap) * 3);
}

.pf-option-header {
  display: flex;
  align-items: center;
  gap: var(--element-gap);
}

.pf-option-label {
  font-size: 0.75em;
  color: rgba(255, 255, 255, 0.35);
  font-variant-caps: small-caps;
  letter-spacing: 0.05em;
}

.pf-component-row {
  display: flex;
  align-items: stretch;
  gap: var(--element-gap);
}

.pf-type-select {
  flex-shrink: 0;
  width: 110px;

  :deep(.p-select) {
    background-color: var(--color-background-grey);
    border: none;
    border-radius: 0;
    box-shadow: none;
    height: 100%;
  }
}

.pf-input {
  padding: var(--padding-input-Y) var(--padding-input-X);
  border: none;
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
    box-shadow: none;
  }
}

.pf-input-amount,
.pf-input-qty {
  width: 90px;
  flex-shrink: 0;
}

.pf-input-grow {
  flex: 1;
  min-width: 80px;
}

.pf-x {
  color: rgba(255, 255, 255, 0.3);
  font-size: 0.85em;
  flex-shrink: 0;
  align-self: center;
}

.pf-btn-remove {
  flex-shrink: 0;
  width: 22px;
  align-self: center;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  color: rgba(255, 255, 255, 0.25);
  font-size: 0.7em;
  cursor: pointer;
  padding: 0;
  transition: all 0.15s;

  &:hover {
    color: var(--color-red-light);
  }
}

.pf-btn-add,
.pf-btn-add-option {
  background-color: var(--color-background-grey);
  border: none;
  color: rgba(255, 255, 255, 0.5);
  padding: 0.625em 1.1em;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.2s ease;
  flex: 1;

  &:hover {
    filter: brightness(1.5);
  }
}
</style>
