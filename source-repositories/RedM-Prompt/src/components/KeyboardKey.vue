<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const props = defineProps({
  kkey: String,
  holdTime: Number,
})

const isActive = ref(false)

const handleKeyDown = (event) => {
  if (event.key.toUpperCase() === props.kkey.toUpperCase()) {
    isActive.value = true
  }
}

const handleKeyUp = (event) => {
  if (event.key.toUpperCase() === props.kkey.toUpperCase()) {
    isActive.value = false
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeyDown)
  window.addEventListener('keyup', handleKeyUp)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
  window.removeEventListener('keyup', handleKeyUp)
})
</script>

<template>
  <div class="keyboardKey bebas" :class="{ holdable: props.holdTime, active: isActive }">
    {{ props.kkey }}
  </div>
</template>

<style lang="scss" scoped>
.keyboardKey {
  position: relative;
  background: #fff;
  color: #000;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  min-height: 30px;
  min-width: 30px;
  padding: 0 12px;

  &:not(:first-child) {
    margin-left: 5px;
  }

  &.holdable {
    outline: 4px solid rgba($color: #000000, $alpha: 0.5);

    &::after {
      content: '';
      width: calc(100% + 15px);
      height: 44px;
      position: absolute;
      background: rgba($color: #fff, $alpha: 0.3);
      z-index: -1;
    }
  }

  // Example style for the active state; customize as needed
  &.active {
    background: red;
  }
}
</style>
