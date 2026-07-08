<template>
  <img v-if="src" class="menu-image" :src="src" :style="computedStyle" />
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  // Accepts either a string (URL / nui:// path) or a table:
  // { url|src, width?, height?, radius?, style? }
  image: {
    type: [String, Object, Boolean],
    default: false,
  },
})

const normalized = computed(() => {
  const img = props.image
  if (!img) return false
  if (typeof img === 'string') return { url: img }
  return {
    url: img.url || img.src,
    width: img.width,
    height: img.height,
    radius: img.radius,
    style: img.style,
  }
})

const src = computed(() => (normalized.value ? normalized.value.url : false))

function toCssSize(value) {
  if (value === undefined || value === null) return undefined
  return typeof value === 'number' ? `${value}px` : value
}

const computedStyle = computed(() => {
  if (!normalized.value) return []
  const n = normalized.value
  const style = {}
  const width = toCssSize(n.width)
  const height = toCssSize(n.height)
  const radius = toCssSize(n.radius)
  if (width !== undefined) style.width = width
  if (height !== undefined) style.height = height
  if (radius !== undefined) style.borderRadius = radius
  // `style` may be a raw CSS string or a style object; Vue merges arrays of both.
  return [style, n.style || {}]
})
</script>

<style scoped lang="scss">
.menu-image {
  display: block;
  max-width: 100%;
}
</style>
