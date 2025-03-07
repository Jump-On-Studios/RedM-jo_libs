<template>
  <div class="keyboardKey bebas"
       :class="{ holdable: props.holdTime, active: isActive }">
    <div class="progressContainer">
      <div class="progress"
           ref="progressElementRef"></div>
    </div>
    <div class="activeIndicator"></div>
    <div v-if="keymap?.text"
         class="text">
      {{ keymap.text }}
    </div>
    <img v-else-if="keymap?.image"
         :src="keymap.image"
         class="image" />
    <div v-else
         class="text">
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

const isActive = ref(false)
const progressElementRef = ref(null)
let startPressed = 0
let endPressed = 0

// Compute animation duration based on holdTime
const animationDuration = computed(() => (props.holdTime ? `${props.holdTime}ms` : '1000ms'))

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

// Show key press state and start animation if applicable
const showKeyDown = () => {
  isActive.value = true
  if (props.holdTime) startProgressAnimation()
}

// Hide key press state and stop animation if applicable
const showKeyUp = () => {
  if (!isActive.value) return
  isActive.value = false
  if (props.holdTime) stopProgressAnimation()
}

// Start progress animation by setting dynamic CSS properties
const startProgressAnimation = () => {
  const progressElement = progressElementRef.value
  if (!progressElement) return

  progressElement.style.setProperty('--duration', animationDuration.value)
  const durationMs = parseFloat(animationDuration.value)
  const offset = endPressed > 0 ? Math.max(durationMs - (Date.now() - endPressed), 0) : 0

  progressElement.style.animationName = 'none'
  progressElement.style.animationDirection = 'normal'
  progressElement.style.animationDelay = `-${offset}ms`
  startPressed = Date.now() - offset

  requestAnimationFrame(() => {
    progressElement.style.animationName = ''
  })
}

// Stop progress animation by adjusting CSS properties in reverse
const stopProgressAnimation = () => {
  const progressElement = progressElementRef.value
  if (!progressElement) return

  const durationMs = parseFloat(animationDuration.value)
  const gap = Math.min(durationMs, Date.now() - startPressed)

  progressElement.style.animationName = 'none'
  progressElement.style.animationDirection = 'reverse'
  progressElement.style.animationDelay = `${-durationMs + gap}ms`
  endPressed = Date.now() - durationMs + gap

  requestAnimationFrame(() => {
    progressElement.style.animationName = ''
  })
}

// Attach and detach event listeners
onMounted(() => {
  window.addEventListener('keydown', handleKeyDown)
  window.addEventListener('keyup', handleKeyUp)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
  window.removeEventListener('keyup', handleKeyUp)
})
</script>

<style lang="scss" scoped>
@property --scaleRTop {
  syntax: "<number>";
  initial-value: 50;
  inherits: true;
}

@property --scaleLTop {
  syntax: "<number>";
  initial-value: 0;
  inherits: true;
}

@property --scaleRight {
  syntax: "<number>";
  initial-value: 0;
  inherits: true;
}

@property --scaleBottom {
  syntax: "<number>";
  initial-value: 0;
  inherits: true;
}

@property --scaleLeft {
  syntax: "<number>";
  initial-value: 0;
  inherits: true;
}

.keyboardKey {
  --scaleRTop: 50;
  --scaleLTop: 0;
  --duration: 10000ms;
  --stroke: 0.14rem;
  --fillColor: white;
  --strokeBgColor: rgba(255, 255, 255, 0.2);

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
      background: linear-gradient(to right,
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
      background-size: 100% var(--stroke), var(--stroke) 100%, 100% var(--stroke), var(--stroke) 100%;
      background-position: top left, top right, bottom left, top left;
      background-repeat: no-repeat;
      width: calc(100% + 0.6rem);
      height: 1.8rem;
      position: absolute;

      .progress {
        --scaleRTop: 50;
        --scaleLTop: 0;
        --scaleLeft: 0;
        --scaleBottom: 0;
        --scaleRight: 0;
        width: 100%;
        height: 100%;
        position: relative;
        z-index: 4;
        background: linear-gradient(to right,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scaleLTop) * 1%),
            transparent 0%,
            transparent 50%,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scaleRTop) * 1%),
            transparent 0%),
          linear-gradient(to bottom,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scaleRight) * 1%),
            transparent 0%),
          linear-gradient(to left,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scaleBottom) * 1%),
            transparent 0%),
          linear-gradient(to top,
            var(--fillColor) 0%,
            var(--fillColor) calc(var(--scaleLeft) * 1%),
            transparent 0%);
        background-size: 100% var(--stroke), var(--stroke) 100%, 100% var(--stroke), var(--stroke) 100%;
        background-position: top left, top right, bottom left, top left;
        background-repeat: no-repeat;
        animation-name: progress;
        animation-duration: var(--duration);
        animation-direction: reverse;
        animation-fill-mode: both;
        animation-delay: calc(-1 * var(--duration));
        animation-timing-function: linear;
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

@keyframes progress {
  0% {
    --scaleRTop: 50;
    --scaleLTop: 0;
    --scaleLeft: 0;
    --scaleBottom: 0;
    --scaleRight: 0;
  }

  12.5% {
    --scaleRTop: 100;
    --scaleLTop: 0;
    --scaleLeft: 0;
    --scaleBottom: 0;
    --scaleRight: 0;
  }

  37.5% {
    --scaleRTop: 100;
    --scaleLTop: 0;
    --scaleLeft: 0;
    --scaleBottom: 0;
    --scaleRight: 100;
  }

  62.5% {
    --scaleRTop: 100;
    --scaleLTop: 0;
    --scaleLeft: 0;
    --scaleBottom: 100;
    --scaleRight: 100;
  }

  87.5% {
    --scaleRTop: 100;
    --scaleLTop: 0;
    --scaleLeft: 100;
    --scaleBottom: 100;
    --scaleRight: 100;
  }

  100% {
    --scaleRTop: 100;
    --scaleLTop: 50;
    --scaleLeft: 100;
    --scaleBottom: 100;
    --scaleRight: 100;
  }
}
</style>
