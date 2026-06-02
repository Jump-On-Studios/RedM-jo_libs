import { useLangStore } from '@/stores/lang'
import type { Directive, DirectiveBinding } from 'vue'
import { watchEffect } from 'vue'

// Interface for elements with i18n properties
interface I18nElement extends HTMLElement {
  _i18nKey?: string
  _i18nDefault?: string
  _i18nStopHandle?: () => void
}

/**
 * Directive for easy internationalization in templates
 * Usage: v-i18n="key"
 * Example: <div v-i18n="mainTitle">Default text</div>
 *
 * This will replace the element's content with the value from langStore
 * corresponding to the key. If the key doesn't exist, it keeps the original content.
 */
export const i18n: Directive = {
  beforeMount(el: I18nElement, binding: DirectiveBinding) {
    const key = binding.value

    // Save the original content as the fallback
    const defaultContent = el.innerHTML
    el._i18nKey = key
    el._i18nDefault = defaultContent

    // Set up reactive watcher that updates when langStore changes
    const stopHandle = watchEffect(() => {
      const langStore = useLangStore()

      // Get the translated text
      const translatedText = langStore.getString(key, defaultContent)

      // Update the element
      el.innerHTML = translatedText
    })

    // Store the stop handle for cleanup
    el._i18nStopHandle = stopHandle
  },

  updated(el: I18nElement, binding: DirectiveBinding) {
    // If the key changes, update it
    if (el._i18nKey !== binding.value) {
      el._i18nKey = binding.value

      // If we already have a watcher, clean it up
      if (el._i18nStopHandle) {
        el._i18nStopHandle()
      }

      // Set up a new watcher with the updated key
      const stopHandle = watchEffect(() => {
        const langStore = useLangStore()
        const translatedText = langStore.getString(binding.value, el._i18nDefault || '')
        el.innerHTML = translatedText
      })

      el._i18nStopHandle = stopHandle
    }
  },

  unmounted(el: I18nElement) {
    // Clean up the watcher when the element is unmounted
    if (el._i18nStopHandle) {
      el._i18nStopHandle()
    }
  },
}
