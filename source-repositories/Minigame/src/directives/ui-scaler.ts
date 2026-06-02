// ui-scaler.ts
// Custom directive for scaling UI elements based on screen height
import type { Directive, DirectiveBinding } from 'vue'

// Define a custom HTMLElement interface that includes our handler
interface UiScalableElement extends HTMLElement {
  _uiScalerResizeHandler?: () => void
  _originalStyles?: {
    left?: string
    right?: string
    width?: string
  }
}

// Reference height (1024px)
const referenceHeight = 1024

export const uiScaler: Directive<UiScalableElement, string> = {
  mounted(el: UiScalableElement, binding: DirectiveBinding<string>): void {
    // Store original styles for elements that need width compensation
    el._originalStyles = {
      left: el.style.left || getComputedStyle(el).left,
      right: el.style.right || getComputedStyle(el).right,
      width: el.style.width || getComputedStyle(el).width,
    }

    // Function to calculate and apply the scale
    const applyScale = (): void => {
      const scale = window.outerHeight / referenceHeight

      // Parse binding value for origin and mode
      const bindingParts = binding.value?.split(' ') || ['center', 'center']
      const hasWidthResponsive = bindingParts.includes('width-responsive')

      // Extract transform origin (filter out 'width-responsive')
      const originParts = bindingParts.filter((part) => part !== 'width-responsive')
      const origin = originParts.length >= 2 ? originParts.join(' ') : 'center center'

      // Apply the transform and transform-origin
      el.style.transformOrigin = origin
      el.style.transform = `scale(${scale})`

      // Handle width compensation for responsive elements
      if (hasWidthResponsive) {
        const parentWidth = el.parentElement?.clientWidth || window.innerWidth

        // Check if element uses left/right positioning
        const hasLeftRight =
          el._originalStyles?.left !== 'auto' && el._originalStyles?.right !== 'auto'

        if (hasLeftRight) {
          // Calculate intended width from left/right values
          const leftValue = parseFloat(el._originalStyles?.left || '0')
          const rightValue = parseFloat(el._originalStyles?.right || '0')
          const intendedWidth = parentWidth - leftValue - rightValue

          // Set width that will result in correct width after scaling
          el.style.width = `${intendedWidth / scale}px`

          // Also adjust the left position to account for transform origin
          if (origin.includes('left')) {
            // No adjustment needed for left origin
          } else if (origin.includes('right')) {
            // Adjust position to maintain right edge
            const widthDiff = intendedWidth - intendedWidth / scale
            el.style.left = `${leftValue - widthDiff}px`
          } else {
            // Center origin - adjust to maintain center
            const widthDiff = intendedWidth - intendedWidth / scale
            el.style.left = `${leftValue + widthDiff / 2}px`
          }
        } else if (el._originalStyles?.width?.includes('%')) {
          // Handle percentage-based widths
          const percentageMatch = el._originalStyles.width.match(/(\d+(?:\.\d+)?)%/)
          if (percentageMatch) {
            const percentage = parseFloat(percentageMatch[1] || '0')
            const intendedWidth = (parentWidth * percentage) / 100
            el.style.width = `${intendedWidth / scale}px`
          }
        }
      }
    }

    // Apply initial scale
    applyScale()

    // Add resize event listener to handle screen changes
    window.addEventListener('resize', applyScale)

    // Store the event listener for cleanup
    el._uiScalerResizeHandler = applyScale
  },

  updated(el: UiScalableElement, binding: DirectiveBinding<string>): void {
    // Update if binding value changes
    if (binding.value !== binding.oldValue) {
      // Re-run the scaling logic with new parameters
      if (el._uiScalerResizeHandler) {
        el._uiScalerResizeHandler()
      }
    }
  },

  unmounted(el: UiScalableElement): void {
    // Clean up event listener when element is unmounted
    if (el._uiScalerResizeHandler) {
      window.removeEventListener('resize', el._uiScalerResizeHandler)
    }
  },
}

// Local component usage example
export const vUiScaler = uiScaler

// Global registration example
// In your main.ts:
// import { createApp } from 'vue';
// import App from './App.vue';
// import { uiScaler } from './ui-scaler';
//
// const app = createApp(App);
// app.directive('ui-scaler', uiScaler);
// app.mount('#app');

// Usage examples:
// Regular scaling (current behavior):
// <div v-ui-scaler="'bottom left'">...</div>
//
// With width compensation (for responsive containers):
// <div v-ui-scaler="'top left width-responsive'">...</div>
