import type {
  Cost,
  CurrencyCostType,
  PriceCostType,
  PriceResult,
  PriceValue,
} from '@/types/entries'
import { useLangStore } from '@/stores/lang'

/** Editable form of a single cost inside a payment option. */
export interface PriceRequirement {
  key: string
  type: PriceCostType
  value: number
  itemName: string
  quantity: number
  keep: boolean
}

/** One way to pay: every requirement it holds must be paid together. */
export interface PriceOption {
  key: string
  requirements: PriceRequirement[]
}

export interface CostTypeChoice {
  value: PriceCostType
  label: string
}

export const ALL_COST_TYPES: CostTypeChoice[] = [
  { value: 'money', label: 'Money' },
  { value: 'gold', label: 'Gold' },
  { value: 'rol', label: 'ROL' },
  { value: 'item', label: 'Item' },
]

const COST_TYPE_KEYS: Record<PriceCostType, string> = {
  money: 'inputNuiMoney',
  gold: 'inputNuiGold',
  rol: 'inputNuiRol',
  item: 'inputNuiItem',
}

const CURRENCY_TYPES: CurrencyCostType[] = ['money', 'gold', 'rol']

let nextKey = 0

function createKey(prefix: string): string {
  nextKey += 1
  return `${prefix}-${nextKey}`
}

export function createRequirement(
  type: PriceCostType = 'money',
  overrides: Partial<PriceRequirement> = {},
): PriceRequirement {
  return {
    key: createKey('requirement'),
    type,
    value: 1,
    itemName: '',
    quantity: 1,
    keep: false,
    ...overrides,
  }
}

export function createOption(requirements: PriceRequirement[] = []): PriceOption {
  return {
    key: createKey('option'),
    requirements,
  }
}

export function typeLabel(type: PriceCostType): string {
  const fallback = ALL_COST_TYPES.find((choice) => choice.value === type)?.label ?? type

  return useLangStore().getString(COST_TYPE_KEYS[type], fallback)
}

/** Currencies are unique inside an option, items can be repeated. */
export function isTypeDisabled(option: PriceOption, type: PriceCostType): boolean {
  return type !== 'item' && option.requirements.some((requirement) => requirement.type === type)
}

// * ==========================================
// * VALIDATION
// * ==========================================

export function requirementError(requirement: PriceRequirement): string | null {
  if (requirement.type === 'item') {
    if (!requirement.itemName?.trim()) {
      return useLangStore().getString('inputNuiItemNameRequired', 'Item name is required.')
    }
    if (Number(requirement.quantity || 0) <= 0) {
      return useLangStore().getString(
        'inputNuiQuantityPositive',
        'Quantity must be greater than 0.',
      )
    }
    return null
  }

  const value = Number(requirement.value || 0)

  // Money is the only cost allowed to be free.
  if (requirement.type === 'money') {
    if (value < 0) {
      return useLangStore().getString('inputNuiMoneyNegative', 'Money cannot be negative.')
    }
    return null
  }

  if (value <= 0) {
    return useLangStore().getString(
      'inputNuiAmountPositive',
      'Amount must be greater than 0.',
    )
  }

  return null
}

export function optionError(option: PriceOption): string | null {
  if (option.requirements.length === 0) {
    return useLangStore().getString(
      'inputNuiOptionRequirement',
      'This payment option needs at least one requirement.',
    )
  }

  if (option.requirements.some((requirement) => requirementError(requirement) !== null)) {
    return useLangStore().getString(
      'inputNuiOptionInvalidRequirements',
      'Fix invalid requirements in this option.',
    )
  }

  return null
}

export function areOptionsValid(options: PriceOption[]): boolean {
  if (options.length === 0) return false

  return options.every((option) => optionError(option) === null)
}

// * ==========================================
// * OUTPUT
// * ==========================================

function generatePrice(option: PriceOption): PriceValue {
  const costs: Cost[] = []

  for (const requirement of option.requirements) {
    if (requirement.type === 'item') {
      costs.push({
        item: requirement.itemName.trim() || 'item_name',
        quantity: requirement.quantity || 1,
        keep: requirement.keep === true,
      })
    } else {
      costs.push({ [requirement.type]: parseFloat(String(requirement.value)) || 0 })
    }
  }

  return { isProcessing: false, costs }
}

/**
 * Builds the canonical payload expected by jo.pricing on the Lua side, or null
 * while an option is still invalid so the `required` check can reject it.
 */
export function buildPriceValue(options: PriceOption[], allowOr: boolean): PriceResult | null {
  const usable = allowOr ? options : options.slice(0, 1)

  if (!areOptionsValid(usable)) return null

  const firstOption = usable[0]
  if (!firstOption) return null

  if (usable.length === 1 || !allowOr) return generatePrice(firstOption)

  return {
    operator: 'or',
    prices: usable.map(generatePrice),
  }
}

// * ==========================================
// * INPUT
// * ==========================================

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null
}

/**
 * Collects requirements out of any price shape jo.pricing accepts: a canonical
 * `{ costs }` object, an array of fragments, a bare number, or a flat table such
 * as `{ money = 10, item = "x" }`. Lua mixed tables arrive as objects holding
 * both named keys and numeric ones, so those are walked too.
 */
function collectRequirements(data: unknown, requirements: PriceRequirement[]): void {
  if (data === null || data === undefined) return

  if (typeof data === 'number') {
    requirements.push(createRequirement('money', { value: data }))
    return
  }

  if (Array.isArray(data)) {
    data.forEach((fragment) => collectRequirements(fragment, requirements))
    return
  }

  if (!isRecord(data)) return

  if (Array.isArray(data.costs)) {
    data.costs.forEach((cost) => collectRequirements(cost, requirements))
    return
  }

  for (const type of CURRENCY_TYPES) {
    const amount = data[type]
    if (typeof amount === 'number') {
      requirements.push(createRequirement(type, { value: amount }))
    }
  }

  if (typeof data.item === 'string') {
    requirements.push(
      createRequirement('item', {
        itemName: data.item,
        quantity: typeof data.quantity === 'number' ? data.quantity : 1,
        keep: data.keep === true,
      }),
    )
  }

  for (const [key, fragment] of Object.entries(data)) {
    if (/^\d+$/.test(key)) collectRequirements(fragment, requirements)
  }
}

function parseOption(data: unknown): PriceOption {
  const requirements: PriceRequirement[] = []

  collectRequirements(data, requirements)

  return createOption(requirements)
}

/** Rebuilds the editable options from the value provided by the Lua caller. */
export function parsePriceValue(data: unknown, allowOr: boolean): PriceOption[] {
  if (!data) return [createOption()]

  if (isRecord(data) && Array.isArray(data.prices)) {
    const parsed = data.prices.map(parseOption)

    if (!allowOr) return [parsed[0] ?? createOption()]

    return parsed.length > 0 ? parsed : [createOption()]
  }

  return [parseOption(data)]
}

// * ==========================================
// * SUMMARY
// * ==========================================

function formatNumber(value: unknown): string {
  const number = Number(value || 0)

  return Number.isInteger(number) ? String(number) : number.toFixed(2)
}

function summarizeRequirement(requirement: PriceRequirement): string {
  if (requirement.type === 'item') {
    const name =
      requirement.itemName?.trim() ||
      useLangStore().getString('inputNuiMissingItem', 'missing item')
    const quantity = Math.max(Number(requirement.quantity || 1), 1)
    const kept = requirement.keep
      ? ` ${useLangStore().getString('inputNuiKept', 'kept')}`
      : ''

    return `${formatNumber(quantity)}x ${name}${kept}`
  }

  return `${typeLabel(requirement.type)} ${formatNumber(requirement.value)}`
}

export function isFreeOption(option: PriceOption): boolean {
  const only = option.requirements[0]

  return (
    option.requirements.length === 1 &&
    only?.type === 'money' &&
    Number(only.value || 0) === 0
  )
}

export function summarizeOption(option: PriceOption): string {
  if (option.requirements.length === 0) {
    return useLangStore().getString('inputNuiNoRequirementSet', 'No requirement set')
  }
  if (isFreeOption(option)) return useLangStore().getString('inputNuiFree', 'Free')

  return option.requirements.map(summarizeRequirement).join(' + ')
}
