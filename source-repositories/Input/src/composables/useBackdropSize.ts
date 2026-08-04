import { onBeforeUnmount, onMounted } from 'vue'

/**
 * Publishes the backdrop box, in layout px, as custom properties on the panel.
 *
 * The nine patches place themselves with plain calc(), but the two stretched
 * ones also have to offset their mask, and `mask-position` resolves percentages
 * against the image rather than the box — so they cannot express that offset
 * without knowing the box as an absolute length.
 *
 * offsetWidth and offsetHeight are read rather than the bounding rect: they are
 * untransformed layout px, which is the space the custom properties are read
 * in, so the ui-scaler scale never enters the calculation.
 */
export function useBackdropSize(target: () => HTMLElement | null | undefined) {
  let observer: ResizeObserver | undefined

  function measure() {
    const el = target()
    if (!el) return

    const bleed = parseFloat(getComputedStyle(el).getPropertyValue('--modal-bleed')) || 0

    el.style.setProperty('--backdrop-width', `${el.offsetWidth + bleed * 2}px`)
    el.style.setProperty('--backdrop-height', `${el.offsetHeight + bleed * 2}px`)
  }

  onMounted(() => {
    const el = target()
    if (!el) return

    measure()
    observer = new ResizeObserver(measure)
    observer.observe(el)
  })

  onBeforeUnmount(() => {
    observer?.disconnect()
  })
}
