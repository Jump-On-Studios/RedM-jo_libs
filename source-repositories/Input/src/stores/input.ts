import { defineStore } from 'pinia'
import { toRaw } from 'vue'
import { CLICK_CALLBACK, sendToLua } from '@/helpers/luaHelper'
import {
  isButtonType,
  isFocusableType,
  isResultEntry,
  isResultType,
  type Entry,
  type NewInputPayload,
  type Row,
} from '@/types/entries'

/** Number of blinks played on a missing required field. */
const ERROR_BLINK_COUNT = 4
const ERROR_BLINK_INTERVAL = 600
const ERROR_BLINK_DURATION = 300

/** Enter is ignored right after opening, so a held key does not submit at once. */
export const OPEN_ENTER_GUARD = 1000

/** Pending blink timers, cleared whenever the panel is closed or reopened. */
const errorTimers: number[] = []

/** Strips Vue proxies so the payload can be serialized for Lua. */
function toPlain<T>(value: T): T {
  const raw = toRaw(value)

  if (raw === null || raw === undefined || typeof raw !== 'object') return raw

  return JSON.parse(JSON.stringify(raw))
}

function isEmpty(value: unknown): boolean {
  return value === '' || value === null || value === undefined
}

interface InputState {
  visible: boolean
  rows: Row[]
  /** Current value of every result entry, keyed by entry id. */
  values: Record<string, unknown>
  /** Entries currently blinking because they are required and empty. */
  errors: Record<string, boolean>
  /** True when the panel owns at least one button, which disables the global Enter. */
  hasButton: boolean
  /** Entry that takes the initial focus, if any. */
  autofocusId: string | null
  openedAt: number
}

export const useInputStore = defineStore('input', {
  state: (): InputState => ({
    visible: false,
    rows: [],
    values: {},
    errors: {},
    hasButton: false,
    autofocusId: null,
    openedAt: 0,
  }),

  getters: {
    priceIds(state): string[] {
      const ids: string[] = []

      state.rows.forEach((row) => {
        row.columns.forEach((entry) => {
          if (entry.type === 'price') ids.push(entry.id)
        })
      })

      return ids
    },
  },

  actions: {
    open(payload: NewInputPayload) {
      this.clearErrorTimers()

      const rows: Row[] = []
      const values: Record<string, unknown> = {}
      let hasButton = false
      let autofocusId: string | null = null
      let autofocusResolved = false

      const incomingRows = Array.isArray(payload?.rows) ? payload.rows : []

      incomingRows.forEach((row, rowIndex) => {
        const normalizedColumns: Entry[] = []
        // An empty `columns` is encoded as `{}` by the Lua json encoder, not as
        // an array, so the shape has to be checked rather than trusted.
        const columns = Array.isArray(row?.columns) ? row.columns : []

        columns.forEach((entry, entryIndex) => {
          const normalized = { ...entry } as Entry

          if (normalized.id === undefined) {
            normalized.id = `${rowIndex}:${entryIndex}`
          }

          if (isButtonType(normalized.type)) hasButton = true

          if (isResultType(normalized.type)) {
            // Kept as undefined when absent: JSON.stringify then drops the key
            // and Lua reads nil, exactly like before the rework.
            values[normalized.id] = normalized.value

            // Only the very first result entry can take the focus: when it is a
            // date or a price, nothing is focused at all.
            if (!autofocusResolved) {
              autofocusResolved = true
              if (isFocusableType(normalized.type)) autofocusId = normalized.id
            }
          }

          normalizedColumns.push(normalized)
        })

        // Spread first: any row-level key the Lua caller declared is kept.
        rows.push({ ...row, columns: normalizedColumns })
      })

      this.rows = rows
      this.values = values
      this.errors = {}
      this.hasButton = hasButton
      this.autofocusId = autofocusId
      this.openedAt = Date.now()
      this.visible = true
    },

    setValue(id: string, value: unknown) {
      this.values[id] = value
    },

    /** True while the Enter key must be ignored after the panel opened. */
    isEnterGuarded(): boolean {
      return Date.now() - this.openedAt < OPEN_ENTER_GUARD
    },

    flashError(id: string) {
      for (let index = 0; index < ERROR_BLINK_COUNT; index++) {
        const start = index * ERROR_BLINK_INTERVAL

        errorTimers.push(
          window.setTimeout(() => {
            this.errors[id] = true
          }, start),
          window.setTimeout(() => {
            this.errors[id] = false
          }, start + ERROR_BLINK_DURATION),
        )
      }
    },

    clearErrorTimers() {
      errorTimers.forEach((timer) => window.clearTimeout(timer))
      errorTimers.length = 0
    },

    /**
     * Builds the result payload, or returns null when a required entry is empty.
     * Empty entries blink before the submission is cancelled.
     */
    collect(): Record<string, unknown> | null {
      const result: Record<string, unknown> = {}
      let valid = true

      this.rows.forEach((row) => {
        row.columns.forEach((entry) => {
          if (!isResultEntry(entry)) return

          result[entry.id] = toPlain(this.values[entry.id])

          if (entry.required && isEmpty(result[entry.id])) {
            this.flashError(entry.id)
            valid = false
          }
        })
      })

      return valid ? result : null
    },

    async submit(actionId: string, ignoreRequired = false) {
      if (!this.visible) return

      let result: Record<string, unknown> = {}
      let priceIds: string[] = []

      if (!ignoreRequired) {
        const collected = this.collect()
        if (!collected) return

        result = collected
        priceIds = this.priceIds
      }

      // Buttons report themselves as `true`, without ever overwriting an entry
      // that happens to share the same id.
      if (!(actionId in result)) result[actionId] = true

      this.close()
      await sendToLua(CLICK_CALLBACK, { action: actionId, result, priceIds })
    },

    async cancel() {
      if (!this.visible) return

      this.close()
      await sendToLua(CLICK_CALLBACK, false)
    },

    close() {
      this.clearErrorTimers()
      this.visible = false
      this.rows = []
      this.values = {}
      this.errors = {}
      this.hasButton = false
      this.autofocusId = null
    },
  },
})
