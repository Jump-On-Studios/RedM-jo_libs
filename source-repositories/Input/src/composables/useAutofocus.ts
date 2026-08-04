import { onBeforeUnmount, onMounted } from 'vue'
import { useInputStore } from '@/stores/input'

/** The panel is given time to settle before stealing the keyboard focus. */
const FOCUS_DELAY = 500

/**
 * Focuses the element when its entry is the one the store elected to receive
 * the initial focus.
 */
export function useAutofocus(entryId: () => string, target: () => HTMLElement | null | undefined) {
  const inputStore = useInputStore()
  let timer = 0

  onMounted(() => {
    if (inputStore.autofocusId !== entryId()) return

    timer = window.setTimeout(() => target()?.focus(), FOCUS_DELAY)
  })

  onBeforeUnmount(() => {
    window.clearTimeout(timer)
  })
}
