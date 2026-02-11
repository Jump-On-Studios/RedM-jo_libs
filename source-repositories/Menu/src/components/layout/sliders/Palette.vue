<template>
  <div class="colorPicker slider">
    <h2>{{ getTitle() }}</h2>
    <div class="arrows">
      <div class="arrow left clicker" @click="menuStore.sliderLeft(props.index)"><img src="/assets/images/menu/selection_arrow_left.png"></div>
      <div class="text hapna">{{ numItem() }}</div>
      <div class="arrow right clicker" @click="menuStore.sliderRight(props.index)"><img src="/assets/images/menu/selection_arrow_right.png"></div>
    </div>
    <div class="colorSlider">
      <div :class="['keyHelpers', 'index-' + fakeIndex]" v-if="fakeIndex > 0">
        <div :class="['left', { 'qwerty': menuStore.isQwerty && index == 1 }]" ref="keyLeft">
          {{ leftKey() }}
        </div>
      </div>
      <div class="palette-strip" ref="stripRef" @mousedown="onDragStart">
        <div
          v-for="(idx, i) in enabledIndices"
          :key="idx"
          class="palette-cell"
          :style="{ backgroundColor: colors[idx] }"
        />
        <div class="palette-cursor" :style="cursorStyle" />
      </div>
      <div :class="['keyHelpers', 'index-' + fakeIndex]" v-if="fakeIndex > 0">
        <div class=" right" ref="keyRight">
          {{ rightKey() }}
        </div>
      </div>
    </div>
    <div :class="['slider-description hapna', { last: props.last }]" v-if="slider.description" v-html="slider.description" />
  </div>
</template>

<script setup>
import { onBeforeUnmount, inject, ref, computed, watch } from 'vue';
import { useLangStore } from '../../../stores/lang';
import { getPaletteColors } from '../../../services/paletteLoader'
const lang = useLangStore().lang
import { useMenuStore } from '../../../stores/menus';
const menuStore = useMenuStore()
const API = inject('API')

const props = defineProps(['index', 'slider', 'last'])
let fakeIndex = ref(props.index)
if (menuStore.cMenu.type == 'tile')
  fakeIndex.value += 1
let mounted = false

const paletteName = computed(() => API.getPalette(props.slider.palette || props.slider.tint))
const colors = ref([])
const stripRef = ref(null)
const dragging = ref(false)

const disabledSet = computed(() => new Set(props.slider.disabledTints || []))
const enabledIndices = computed(() => {
  const result = []
  for (let i = props.slider.min; i <= props.slider.max; i++) {
    if (!disabledSet.value.has(i)) result.push(i)
  }
  return result
})

const cursorStyle = computed(() => {
  const total = enabledIndices.value.length
  if (!total) return {}
  const visibleIndex = enabledIndices.value.indexOf(props.slider.current)
  if (visibleIndex === -1) return {}
  const percent = (visibleIndex / total) * 100
  const halfCell = 100 / total / 2
  const style = { left: `calc(${percent + halfCell}% - 1.4vh)` }
  if (dragging.value) style.transition = 'none'
  return style
})

function normalizeSliderState() {
  const paletteMax = colors.value.length - 1

  if (props.slider.min == null) props.slider.min = 0
  if (props.slider.current == null) props.slider.current = props.slider.min

  if (paletteMax < 0) {
    props.slider.max = -1
    return
  }

  if (props.slider.max == null || props.slider.max > paletteMax)
    props.slider.max = paletteMax
  if (props.slider.min > props.slider.max)
    props.slider.min = 0
  if (props.slider.current < props.slider.min)
    props.slider.current = props.slider.min
  if (props.slider.current > props.slider.max)
    props.slider.current = props.slider.max
  if (disabledSet.value.has(props.slider.current)) {
    const enabled = enabledIndices.value
    if (enabled.length)
      props.slider.current = enabled[0]
  }
}

let paletteRequestId = 0
watch(paletteName, async (name) => {
  const requestId = ++paletteRequestId
  colors.value = []

  if (!name) {
    normalizeSliderState()
    mounted = true
    return
  }

  const loadedColors = await getPaletteColors(name)
  if (requestId !== paletteRequestId) return
  colors.value = loadedColors
  normalizeSliderState()
  mounted = true
}, { immediate: true })

// Format the current visible tint index against the total.
function numItem() {
  const visibleIndex = enabledIndices.value.indexOf(props.slider.current)
  return API.sprintf(lang('of'), visibleIndex + 1, enabledIndices.value.length)
}
// Return the slider title, translated when needed.
function getTitle() {
  if (!props.slider.translate) return props.slider.title
  return lang(props.slider.title)
}
// Update the slider value when a new tint is selected.
function selectColor(index) {
  if (!mounted) return
  if (index === props.slider.current) return
  menuStore.setSliderCurrent({ index: props.index, value: index })
}

let cachedRect = null
let rafId = null

// Convert a pointer X position to the corresponding enabled tint.
function getCellIndexFromX(clientX) {
  const x = Math.max(0, Math.min(clientX - cachedRect.left, cachedRect.width - 1))
  const count = enabledIndices.value.length
  if (!count) return props.slider.current
  const visibleIndex = Math.min(Math.floor((x / cachedRect.width) * count), count - 1)
  return enabledIndices.value[visibleIndex]
}
// Start dragging on the palette and attach drag listeners.
function onDragStart(e) {
  e.preventDefault()
  dragging.value = true
  cachedRect = stripRef.value.getBoundingClientRect()
  selectColor(getCellIndexFromX(e.clientX))
  window.addEventListener('mousemove', onDragMove)
  window.addEventListener('mouseup', onDragEnd)
}
// Throttle drag updates to once per animation frame.
function onDragMove(e) {
  if (rafId) return
  rafId = requestAnimationFrame(() => {
    selectColor(getCellIndexFromX(e.clientX))
    rafId = null
  })
}
// Stop dragging and remove temporary listeners.
function onDragEnd() {
  dragging.value = false
  if (rafId) {
    cancelAnimationFrame(rafId)
    rafId = null
  }
  window.removeEventListener('mousemove', onDragMove)
  window.removeEventListener('mouseup', onDragEnd)
}
// Resolve the left helper key label for the active row.
function leftKey() {
  if (fakeIndex.value == 0) return '←'
  if (fakeIndex.value == 1) {
    if (menuStore.isQwerty)
      return "q"
    else
      return "a"
  }
  if (fakeIndex.value == 2) return "4"
}
// Resolve the right helper key label for the active row.
function rightKey() {
  if (fakeIndex.value == 0) return '→'
  if (fakeIndex.value == 1) return "E"
  if (fakeIndex.value == 2) return "6"
}
// Clean up listeners when the component is destroyed.
onBeforeUnmount(() => {
  mounted = false
  window.removeEventListener('mousemove', onDragMove)
  window.removeEventListener('mouseup', onDragEnd)
})
</script>
