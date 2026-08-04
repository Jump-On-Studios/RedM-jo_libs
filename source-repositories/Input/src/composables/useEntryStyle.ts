import { computed, toValue, type CSSProperties, type MaybeRefOrGetter } from 'vue'
import type { Entry } from '@/types/entries'

/**
 * Turns `entry.width` and `entry.style` into an inline style.
 * A numeric width is read as a percentage of the row, a string is used as-is,
 * and both opt the entry out of the default `flex: 1` sharing.
 */
export function useEntryStyle(entry: MaybeRefOrGetter<Entry>) {
  return computed<CSSProperties>(() => {
    const current = toValue(entry)
    const style: CSSProperties = {}

    if (current.width !== undefined) {
      style.flex = 'none'
      style.width = typeof current.width === 'string' ? current.width : `${current.width}%`
    }

    return { ...style, ...(current.style ?? {}) }
  })
}
