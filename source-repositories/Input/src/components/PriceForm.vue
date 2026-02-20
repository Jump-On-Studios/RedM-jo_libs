<template>
  <div class="price-form" :class="{ error: error }">
    <!-- OR mode toggle -->
    <div v-if="allowOr" class="pf-or-toggle">
      <label class="pf-checkbox">
        <input type="checkbox" v-model="useOr" />
        <span>OR mode <em>(player chooses one option)</em></span>
      </label>
    </div>

    <!-- Single option mode -->
    <div v-if="!useOr" class="pf-option-card">
      <div v-for="(comp, cIdx) in singleOption.components" :key="cIdx" class="pf-component-row">
        <Select v-model="comp.type" :options="TYPES" optionLabel="label" optionValue="value" class="pf-type-select" />
        <template v-if="comp.type !== 'item'">
          <input type="number" v-model.number="comp.value" min="0" step="0.01" class="pf-input pf-input-amount" placeholder="0" />
        </template>
        <template v-else>
          <input type="number" v-model.number="comp.quantity" min="1" class="pf-input pf-input-qty" placeholder="1" />
          <span class="pf-x">×</span>
          <input type="text" v-model="comp.itemName" class="pf-input pf-input-grow" placeholder="item_name" />
          <label class="pf-checkbox pf-checkbox-inline">
            <input type="checkbox" v-model="comp.keep" />
            <span>Keep</span>
          </label>
        </template>
        <button class="pf-btn-remove" @click="removeComponent(singleOption, cIdx)" title="Remove">✕</button>
      </div>
      <button class="pf-btn-add" @click="addComponent(singleOption)">+ Add</button>
    </div>

    <!-- OR mode -->
    <div v-else>
      <div v-for="(option, oIdx) in multiOptions" :key="oIdx" class="pf-option-card">
        <div class="pf-option-header">
          <span class="pf-option-label">Option {{ oIdx + 1 }}</span>
          <button v-if="multiOptions.length > 1" class="pf-btn-remove" @click="removeOption(oIdx)" title="Remove option">✕</button>
        </div>
        <div v-for="(comp, cIdx) in option.components" :key="cIdx" class="pf-component-row">
          <Select v-model="comp.type" :options="TYPES" optionLabel="label" optionValue="value" class="pf-type-select" />
          <template v-if="comp.type !== 'item'">
            <input type="number" v-model.number="comp.value" min="0" step="0.01" class="pf-input pf-input-amount" placeholder="0" />
          </template>
          <template v-else>
            <input type="number" v-model.number="comp.quantity" min="1" class="pf-input pf-input-qty" placeholder="1" />
            <span class="pf-x">×</span>
            <input type="text" v-model="comp.itemName" class="pf-input pf-input-grow" placeholder="item_name" />
            <label class="pf-checkbox pf-checkbox-inline">
              <input type="checkbox" v-model="comp.keep" />
              <span>Keep</span>
            </label>
          </template>
          <button class="pf-btn-remove" @click="removeComponent(option, cIdx)" title="Remove">✕</button>
        </div>
        <button class="pf-btn-add" @click="addComponent(option)">+ Add</button>
      </div>
      <button class="pf-btn-add-option" @click="addOption">+ Add payment option</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import Select from 'primevue/select'

const props = defineProps({
  modelValue: { type: Object, default: null },
  options: { type: Array, default: () => ['money', 'gold', 'rol', 'item'] },
  allowOr: { type: Boolean, default: true },
  error: { type: Boolean, default: false },
})

const emit = defineEmits(['update:modelValue'])

const ALL_TYPES = [
  { value: 'money', label: 'Money' },
  { value: 'gold', label: 'Gold' },
  { value: 'rol', label: 'Rol' },
  { value: 'item', label: 'Item' },
]

const TYPES = computed(() => {
  if (!props.options || props.options.length === 0) return ALL_TYPES
  return ALL_TYPES.filter(t => props.options.includes(t.value))
})

const useOr = ref(false)
const singleOption = ref({ components: [] })
const multiOptions = ref([{ components: [] }])

function defaultType() {
  return TYPES.value[0]?.value ?? 'money'
}

function createComponent() {
  return { type: defaultType(), value: 1, itemName: '', quantity: 1, keep: false }
}

function addComponent(option) {
  option.components.push(createComponent())
}

function removeComponent(option, idx) {
  option.components.splice(idx, 1)
}

function addOption() {
  multiOptions.value.push({ components: [] })
}

function removeOption(idx) {
  if (multiOptions.value.length > 1) {
    multiOptions.value.splice(idx, 1)
  }
}

watch(useOr, (isOr) => {
  if (isOr) {
    multiOptions.value[0] = { components: singleOption.value.components.map(c => ({ ...c })) }
  } else {
    singleOption.value = { components: multiOptions.value[0].components.map(c => ({ ...c })) }
  }
})

function generateOption(option) {
  const result = {}
  const items = []
  for (const comp of option.components) {
    if (comp.type === 'item') {
      const item = { item: comp.itemName.trim() || 'item_name' }
      if ((comp.quantity || 1) > 1) item.quantity = comp.quantity
      if (comp.keep) item.keep = true
      items.push(item)
    } else {
      const val = parseFloat(comp.value) || 0
      result[comp.type] = (result[comp.type] || 0) + val
    }
  }
  if (items.length > 0) result.items = items
  return result
}

const computedValue = computed(() => {
  if (useOr.value) {
    const allEmpty = multiOptions.value.every(opt => opt.components.length === 0)
    if (allEmpty) return null
    return { operator: 'or', options: multiOptions.value.map(opt => generateOption(opt)) }
  } else {
    if (singleOption.value.components.length === 0) return null
    return generateOption(singleOption.value)
  }
})

watch(computedValue, (val) => {
  emit('update:modelValue', val)
}, { deep: true })

function parseOption(opt) {
  const components = []
  if (opt.items) {
    opt.items.forEach(item => {
      components.push({ type: 'item', value: 1, itemName: item.item || '', quantity: item.quantity || 1, keep: item.keep || false })
    })
  }
  for (const key of ['money', 'gold', 'rol']) {
    if (opt[key] != null) {
      components.push({ type: key, value: opt[key], itemName: '', quantity: 1, keep: false })
    }
  }
  return { components }
}

function parseInitialValue(val) {
  if (!val) return
  if (val.operator === 'or' && Array.isArray(val.options)) {
    useOr.value = true
    multiOptions.value = val.options.map(opt => parseOption(opt))
  } else {
    useOr.value = false
    singleOption.value = parseOption(val)
  }
}

onMounted(() => {
  parseInitialValue(props.modelValue)
})
</script>

<style lang="scss" scoped>
.price-form {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--element-gap);
  box-sizing: border-box;

  &.error {
    box-shadow: 0px 0px 5px var(--color-red-light);
  }
}

.pf-or-toggle {
  padding: 0.3em var(--padding-input-X);
}

.pf-checkbox {
  display: flex;
  align-items: center;
  gap: 0.5em;
  cursor: pointer;
  font-size: 0.85em;
  color: white;
  user-select: none;

  input[type="checkbox"] {
    width: 14px;
    height: 14px;
    accent-color: var(--color-red);
    cursor: pointer;
  }

  em {
    font-style: normal;
    color: rgba(255, 255, 255, 0.5);
    font-size: 0.9em;
  }
}

.pf-checkbox-inline {
  gap: 0.3em;
  white-space: nowrap;
}

.pf-option-card {
  background-color: var(--color-background-dark);
  padding: var(--element-gap) var(--padding-input-X);
  display: flex;
  flex-direction: column;
  gap: var(--element-gap);
}

.pf-option-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pf-option-label {
  font-size: 0.8em;
  color: rgba(255, 255, 255, 0.5);
  font-variant-caps: small-caps;
  letter-spacing: 0.05em;
}

.pf-component-row {
  display: flex;
  align-items: center;
  gap: var(--element-gap);
}

.pf-type-select {
  flex-shrink: 0;
  width: 110px;
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

.pf-input-amount {
  width: 90px;
  flex-shrink: 0;
}

.pf-input-qty {
  width: 52px;
  flex-shrink: 0;
  text-align: center;
}

.pf-input-grow {
  flex: 1;
  min-width: 80px;
}

.pf-x {
  color: rgba(255, 255, 255, 0.4);
  font-size: 0.9em;
  flex-shrink: 0;
}

.pf-btn-remove {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  color: rgba(255, 255, 255, 0.3);
  font-size: 0.75em;
  cursor: pointer;
  padding: 0;
  transition: color 0.15s;

  &:hover {
    color: var(--color-red-light);
  }
}

.pf-btn-add {
  align-self: flex-start;
  background: transparent;
  border: 1px dashed rgba(255, 255, 255, 0.2);
  color: rgba(255, 255, 255, 0.5);
  padding: 0.25em 0.75em;
  font-size: 0.8em;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s;

  &:hover {
    border-color: rgba(255, 255, 255, 0.5);
    color: white;
  }
}

.pf-btn-add-option {
  width: 100%;
  background: transparent;
  border: 1px dashed rgba(255, 255, 255, 0.2);
  color: rgba(255, 255, 255, 0.5);
  padding: 0.35em 0.75em;
  font-size: 0.8em;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s;
  text-align: center;

  &:hover {
    border-color: rgba(255, 255, 255, 0.5);
    color: white;
  }
}
</style>
