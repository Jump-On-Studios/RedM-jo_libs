import { useLangStore } from '@/stores/lang'
import type { Directive, DirectiveBinding } from 'vue'
import { watchEffect } from 'vue'

interface I18nElement extends HTMLElement {
  _i18nKey?: string
  _i18nDefault?: string
  _i18nStopHandle?: () => void
}

/** Replaces an element's content with its current language string. */
export const i18n: Directive = {
  beforeMount(el: I18nElement, binding: DirectiveBinding) {
    const key = binding.value
    const defaultContent = el.innerHTML

    el._i18nKey = key
    el._i18nDefault = defaultContent

    const stopHandle = watchEffect(() => {
      const langStore = useLangStore()
      el.innerHTML = langStore.getString(key, defaultContent)
    })

    el._i18nStopHandle = stopHandle
  },

  updated(el: I18nElement, binding: DirectiveBinding) {
    if (el._i18nKey === binding.value) return

    el._i18nKey = binding.value
    el._i18nStopHandle?.()

    const stopHandle = watchEffect(() => {
      const langStore = useLangStore()
      el.innerHTML = langStore.getString(binding.value, el._i18nDefault || '')
    })

    el._i18nStopHandle = stopHandle
  },

  unmounted(el: I18nElement) {
    el._i18nStopHandle?.()
  },
}
