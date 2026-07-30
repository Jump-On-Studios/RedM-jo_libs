import { computed, toValue, type MaybeRefOrGetter, type WritableComputedRef } from 'vue'
import { useInputStore } from '@/stores/input'
import type { Entry } from '@/types/entries'

/**
 * Binds an entry component to its slot in the store, so every input type stays
 * self-contained instead of receiving its value through the row.
 */
export function useEntryValue<T>(entry: MaybeRefOrGetter<Entry>) {
  const inputStore = useInputStore()

  const value = computed({
    get: () => inputStore.values[toValue(entry).id] as T,
    set: (next: T) => inputStore.setValue(toValue(entry).id, next),
  }) as WritableComputedRef<T>

  const hasError = computed(() => inputStore.errors[toValue(entry).id] === true)

  return { value, hasError }
}
