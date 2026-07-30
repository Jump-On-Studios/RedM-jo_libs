// Shapes exchanged with the Lua side (jo_libs/modules/input/client.lua).
// The Lua module sends `{ event: "newInput", data: { rows } }` and expects
// `{ action, result, priceIds }` back, so these types mirror that contract.

export type EntryType =
  | 'title'
  | 'description'
  | 'label'
  | 'text'
  | 'number'
  | 'date'
  | 'select'
  | 'price'
  | 'button'
  | 'action'

/** Entry types that contribute a value to the result sent back to Lua. */
export const RESULT_TYPES = ['text', 'number', 'date', 'select', 'price'] as const

/** Entry types rendered as a clickable button. `action` is the legacy name. */
export const BUTTON_TYPES = ['button', 'action'] as const

/** Result types that can receive the initial keyboard focus. */
export const FOCUSABLE_TYPES = ['text', 'number', 'select'] as const

export type ResultType = (typeof RESULT_TYPES)[number]
export type ButtonType = (typeof BUTTON_TYPES)[number]

export interface CommonEntry {
  /** Always defined once the store has normalized the payload. */
  id: string
  class?: string
  style?: Record<string, string>
  /** Number is read as a percentage, string is used as-is. */
  width?: number | string
}

export interface TitleEntry extends CommonEntry {
  type: 'title'
  value: string
}

export interface DescriptionEntry extends CommonEntry {
  type: 'description'
  value: string
}

export interface LabelEntry extends CommonEntry {
  type: 'label'
  value: string
  for?: string
}

export interface TextEntry extends CommonEntry {
  type: 'text'
  value?: string
  placeholder?: string
  required?: boolean
}

export interface NumberEntry extends CommonEntry {
  type: 'number'
  value?: number
  placeholder?: string
  min?: number
  max?: number
  step?: number
  required?: boolean
}

export interface DateEntry extends CommonEntry {
  type: 'date'
  value?: string
  placeholder?: string
  yearRange?: [number, number]
  /** Used both as the display format and as the model type. */
  format?: string
  required?: boolean
}

export interface SelectOption {
  value: unknown
  label: string
}

export interface SelectEntry extends CommonEntry {
  type: 'select'
  value?: SelectOption | null
  placeholder?: string
  options?: SelectOption[]
  required?: boolean
}

export interface PriceEntry extends CommonEntry {
  type: 'price'
  value?: unknown
  /** Cost types the player is allowed to pick. */
  options?: PriceCostType[]
  /** Allows several alternative payment options. */
  allowOR?: boolean
  required?: boolean
}

export interface ButtonEntry extends CommonEntry {
  type: ButtonType
  value: string
  id: string
  /** Skips validation and sends an empty result. */
  ignoreRequired?: boolean
}

export type Entry =
  | TitleEntry
  | DescriptionEntry
  | LabelEntry
  | TextEntry
  | NumberEntry
  | DateEntry
  | SelectEntry
  | PriceEntry
  | ButtonEntry

/** Entries carrying a value, and therefore a `required` flag. */
export type ResultEntry = TextEntry | NumberEntry | DateEntry | SelectEntry | PriceEntry

/** Raw entry as received from Lua, before the store assigns a fallback id. */
export interface IncomingEntry extends Record<string, unknown> {
  type: EntryType
  id?: string
}

export interface NewInputPayload {
  rows: IncomingEntry[][]
}

// * ==========================================
// * PRICING
// * ==========================================
// Mirrors jo_libs/modules/pricing/shared.lua so that `convertNUIPrice` can feed
// the emitted object straight into jo.pricing.new() / jo.pricing.newGroup().

export type PriceCostType = 'money' | 'gold' | 'rol' | 'item'

export type CurrencyCostType = Exclude<PriceCostType, 'item'>

export type CurrencyCost = {
  [key in CurrencyCostType]?: number
}

export interface ItemCost {
  item: string
  quantity: number
  keep: boolean
}

export type Cost = CurrencyCost | ItemCost

/** Canonical PriceClass payload. */
export interface PriceValue {
  isProcessing: boolean
  costs: Cost[]
}

/** Canonical PriceGroupClass payload. */
export interface PriceGroupValue {
  operator: 'or'
  prices: PriceValue[]
}

export type PriceResult = PriceValue | PriceGroupValue

// * ==========================================
// * RESULT
// * ==========================================

export interface InputResult {
  action: string
  result: Record<string, unknown>
  /** Ids of the `price` entries, so Lua knows which values to normalize. */
  priceIds: string[]
}

export function isResultType(type: EntryType): type is ResultType {
  return (RESULT_TYPES as readonly string[]).includes(type)
}

export function isResultEntry(entry: Entry): entry is ResultEntry {
  return isResultType(entry.type)
}

export function isButtonType(type: EntryType): type is ButtonType {
  return (BUTTON_TYPES as readonly string[]).includes(type)
}

export function isFocusableType(type: EntryType): boolean {
  return (FOCUSABLE_TYPES as readonly string[]).includes(type)
}
