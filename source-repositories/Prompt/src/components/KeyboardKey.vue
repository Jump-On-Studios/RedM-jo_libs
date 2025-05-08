<template>
  <div class="keyboardKey bebas" :class="{ holdable: props.holdTime, active: isActive }">
    <div class="progressContainer">
      <div class="progress" :style="{
        '--duration': animationDuration,
        '--animation-state': animationState,
        '--animation-direction': animationDirection,
        '--animation-delay': animationDelay,
        '--scale-r-top': scaleRTop,
        '--scale-l-top': scaleLTop,
        '--scale-right': scaleRight,
        '--scale-bottom': scaleBottom,
        '--scale-left': scaleLeft,
      }"></div>
    </div>
    <div class="activeIndicator"></div>
    <div v-if="keymap?.text" class="text">
      {{ keymap.text }}
    </div>
    <img v-else-if="keymap?.image" :src="keymap.image" class="image" />
    <div v-else class="text">
      {{ props.kkey }}
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref, computed } from 'vue'
import { SendNUIKey, SendNUINextPage } from '@/dev'
import { keymaps } from '@/data/keymaps'
import { useGroupStore } from '@/stores/group'

// Define component props
const props = defineProps({
  kkey: { type: String, required: true },
  holdTime: { type: Number, default: 0 },
  isNextPage: { type: Boolean, default: false },
})

// Create a computed keymap to avoid repetitive lookups in the template
const keymap = computed(() => keymaps[props.kkey])

// Animation states
const isActive = ref(false)
const animationState = ref('paused')
const animationDirection = ref('normal')
const animationDelay = ref('0ms')

// Scale values directly as reactive refs
const scaleRTop = ref(50)
const scaleLTop = ref(0)
const scaleRight = ref(0)
const scaleBottom = ref(0)
const scaleLeft = ref(0)

// Time tracking variables
let startPressed = 0
let endPressed = 0
let animationTimer = null

// Compute animation duration based on holdTime
const animationDuration = computed(() => (props.holdTime ? `${props.holdTime}ms` : '1000ms'))
const durationMs = computed(() => props.holdTime || 1000)

// Subscribe to the group store changes and trigger key animations accordingly
const groupStore = useGroupStore()
groupStore.$subscribe((mutation, state) => {
  if (state.pressedKeys.hasOwnProperty(props.kkey)) {
    showKeyDown()
  } else {
    showKeyUp()
  }
})

// Handle keydown event (only in DEV mode)
const handleKeyDown = (event) => {
  if (event.repeat) return
  if (import.meta.env.DEV && event.key.toUpperCase() === props.kkey.toUpperCase()) {
    if (props.isNextPage) SendNUINextPage()
    SendNUIKey(props.kkey, 'keyDown')
  }
}

// Handle keyup event (only in DEV mode)
const handleKeyUp = (event) => {
  if (import.meta.env.DEV && event.key.toUpperCase() === props.kkey.toUpperCase()) {
    SendNUIKey(props.kkey, 'keyUp')
  }
}

// Reset animation values to initial state
const resetAnimation = () => {
  scaleRTop.value = 50
  scaleLTop.value = 0
  scaleRight.value = 0
  scaleBottom.value = 0
  scaleLeft.value = 0
}

// Calculate current animation progress based on elapsed time
const calculateProgress = (elapsed, total) => {
  const progress = Math.min(1, elapsed / total)

  // Apply the same animation logic from the keyframes but in JS
  if (progress <= 0.125) {
    // 0% to 12.5%
    const segmentProgress = progress / 0.125
    scaleRTop.value = 50 + segmentProgress * 50
    scaleLTop.value = 0
    scaleRight.value = 0
    scaleBottom.value = 0
    scaleLeft.value = 0
  } else if (progress <= 0.375) {
    // 12.5% to 37.5%
    const segmentProgress = (progress - 0.125) / 0.25
    scaleRTop.value = 100
    scaleLTop.value = 0
    scaleRight.value = segmentProgress * 100
    scaleBottom.value = 0
    scaleLeft.value = 0
  } else if (progress <= 0.625) {
    // 37.5% to 62.5%
    const segmentProgress = (progress - 0.375) / 0.25
    scaleRTop.value = 100
    scaleLTop.value = 0
    scaleRight.value = 100
    scaleBottom.value = segmentProgress * 100
    scaleLeft.value = 0
  } else if (progress <= 0.875) {
    // 62.5% to 87.5%
    const segmentProgress = (progress - 0.625) / 0.25
    scaleRTop.value = 100
    scaleLTop.value = 0
    scaleRight.value = 100
    scaleBottom.value = 100
    scaleLeft.value = segmentProgress * 100
  } else {
    // 87.5% to 100%
    const segmentProgress = (progress - 0.875) / 0.125
    scaleRTop.value = 100
    scaleRight.value = 100
    scaleBottom.value = 100
    scaleLeft.value = 100
    scaleLTop.value = segmentProgress * 50
  }
}

// Show key press state and start animation if applicable
const showKeyDown = () => {
  isActive.value = true
  if (props.holdTime) {
    // Clear any existing animation
    if (animationTimer) {
      clearInterval(animationTimer)
      animationTimer = null
    }

    // Calculate where to start from, if we're resuming a partial animation
    const offset = endPressed > 0 ? Math.max(durationMs.value - (Date.now() - endPressed), 0) : 0
    startPressed = Date.now() - offset

    // Calculate initial state based on offset
    if (offset > 0) {
      calculateProgress(offset, durationMs.value)
    } else {
      resetAnimation()
    }

    // Set up animation timer that updates the CSS variables
    animationTimer = setInterval(() => {
      const elapsed = Date.now() - startPressed

      if (elapsed >= durationMs.value) {
        // Animation complete
        calculateProgress(durationMs.value, durationMs.value)
        clearInterval(animationTimer)
        animationTimer = null

        resetAnimation()
        isActive.value = false
      } else {
        // Animation in progress
        calculateProgress(elapsed, durationMs.value)
      }
    }, 16) // ~60fps
  }
}

// Hide key press state and stop animation if applicable
const showKeyUp = () => {
  if (!isActive.value) return
  isActive.value = false

  if (props.holdTime) {
    // Clear forward animation timer
    if (animationTimer) {
      clearInterval(animationTimer)
      animationTimer = null
    }

    // Calculate progress so far
    const elapsed = Date.now() - startPressed
    const progress = Math.min(elapsed, durationMs.value)

    // Store the current time for potential resumption
    endPressed = Date.now() - (durationMs.value - progress)

    // Set up reverse animation
    startPressed = Date.now()

    // Calculate what percentage of the full animation was completed
    const forwardProgress = Math.min(1, progress / durationMs.value)

    animationTimer = setInterval(() => {
      const reverseElapsed = Date.now() - startPressed
      // Calculate how much of the forward progress we've reversed
      const reverseProgressRatio = Math.min(1, reverseElapsed / progress)
      // Calculate the effective progress point in the original animation
      const effectiveProgress = forwardProgress * (1 - reverseProgressRatio)

      // Apply the same keyframe logic but with the reversed progress
      if (effectiveProgress <= 0) {
        resetAnimation()
      } else if (effectiveProgress <= 0.125) {
        // 0% to 12.5%
        const segmentProgress = effectiveProgress / 0.125
        scaleRTop.value = 50 + segmentProgress * 50
        scaleLTop.value = 0
        scaleRight.value = 0
        scaleBottom.value = 0
        scaleLeft.value = 0
      } else if (effectiveProgress <= 0.375) {
        // 12.5% to 37.5%
        const segmentProgress = (effectiveProgress - 0.125) / 0.25
        scaleRTop.value = 100
        scaleLTop.value = 0
        scaleRight.value = segmentProgress * 100
        scaleBottom.value = 0
        scaleLeft.value = 0
      } else if (effectiveProgress <= 0.625) {
        // 37.5% to 62.5%
        const segmentProgress = (effectiveProgress - 0.375) / 0.25
        scaleRTop.value = 100
        scaleLTop.value = 0
        scaleRight.value = 100
        scaleBottom.value = segmentProgress * 100
        scaleLeft.value = 0
      } else if (effectiveProgress <= 0.875) {
        // 62.5% to 87.5%
        const segmentProgress = (effectiveProgress - 0.625) / 0.25
        scaleRTop.value = 100
        scaleLTop.value = 0
        scaleRight.value = 100
        scaleBottom.value = 100
        scaleLeft.value = segmentProgress * 100
      } else {
        // 87.5% to 100%
        const segmentProgress = (effectiveProgress - 0.875) / 0.125
        scaleRTop.value = 100
        scaleLTop.value = segmentProgress * 50
        scaleRight.value = 100
        scaleBottom.value = 100
        scaleLeft.value = 100
      }

      if (reverseElapsed >= progress || effectiveProgress <= 0) {
        // Reverse animation complete
        resetAnimation()
        clearInterval(animationTimer)
        animationTimer = null
        isActive.value = false
      }
    }, 16) // ~60fps
  }
}

// Attach and detach event listeners
onMounted(() => {
  window.addEventListener('keydown', handleKeyDown)
  window.addEventListener('keyup', handleKeyUp)
  resetAnimation()
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
  window.removeEventListener('keyup', handleKeyUp)

  if (animationTimer) {
    clearInterval(animationTimer)
    animationTimer = null
  }
})
</script>

<style lang="scss" scoped>
.keyboardKey {
  --stroke: 0.14rem;
  --fillColor: white;
  --strokeBgColor: rgba(255, 255, 255, 0.5);

  position: relative;
  color: #000;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  box-shadow: 1px 1px rgba(0, 0, 0, 0.3);

  .text {
    background: #fff;
    height: 1.23rem;
    min-width: 1.23rem;
    padding: 0 0.49rem;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .image {
    height: 1.23rem;
  }

  &:not(:first-child) {
    margin-left: 0.205rem;
  }

  &.holdable {
    .progressContainer {
      background:
        linear-gradient(to right,
          var(--strokeBgColor) 0%,
          var(--strokeBgColor) calc(100% - var(--stroke)),
          transparent 0%),
        linear-gradient(to bottom,
          var(--strokeBgColor) 0%,
          var(--strokeBgColor) calc(100% - var(--stroke)),
          transparent 0%),
        linear-gradient(to left,
          var(--strokeBgColor) 0%,
          var(--strokeBgColor) calc(100% - var(--stroke)),
          transparent 0%),
        linear-gradient(to top,
          var(--strokeBgColor) 0%,
          var(--strokeBgColor) calc(100% - var(--stroke)),
          transparent 0%);
      background-size:
        100% var(--stroke),
        var(--stroke) 100%,
        100% var(--stroke),
        var(--stroke) 100%;
      background-position:
        top left,
        top right,
        bottom left,
        top left;
      background-repeat: no-repeat;
      width: calc(100% + 0.6rem);
      height: 1.8rem;
      position: absolute;

      .progress {
        width: 100%;
        height: 100%;
        position: relative;
        z-index: 4;
        background:
          linear-gradient(to right,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scale-l-top) * 1%),
            transparent 0%,
            transparent 50%,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scale-r-top) * 1%),
            transparent 0%),
          linear-gradient(to bottom,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scale-right) * 1%),
            transparent 0%),
          linear-gradient(to left,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scale-bottom) * 1%),
            transparent 0%),
          linear-gradient(to top,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scale-left) * 1%),
            transparent 0%);
        background-size:
          100% var(--stroke),
          var(--stroke) 100%,
          100% var(--stroke),
          var(--stroke) 100%;
        background-position:
          top left,
          top right,
          bottom left,
          top left;
        background-repeat: no-repeat;
      }
    }
  }

  .activeIndicator {
    width: calc(100% + 0.6rem);
    height: 1.8rem;
    position: absolute;
    background: rgba(192, 192, 192, 0.9);
    z-index: 3;
    display: none;
  }

  &.active {
    .activeIndicator {
      display: block;
    }
  }
}
</style>
