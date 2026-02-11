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
      <div class="palette-strip">
        <div
          v-for="(color, i) in colors"
          :key="i"
          class="palette-cell"
          :style="{ backgroundColor: color }"
          @click="selectColor(i)"
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
import { onBeforeUnmount, inject, ref, computed, onBeforeMount } from 'vue';
import palettesData from '../../../data/palettes.json'
import { useLangStore } from '../../../stores/lang';
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
const colors = computed(() => palettesData[paletteName.value] || [])

const cursorStyle = computed(() => {
  const total = colors.value.length
  if (!total) return {}
  const percent = (props.slider.current / total) * 100
  const halfCell = 100 / total / 2
  return { left: `calc(${percent + halfCell}% - 1.4vh)` }
})

onBeforeMount(() => {
  mounted = true
})

function numItem() {
  return API.sprintf(lang('of'), props.slider.current + 1, props.slider.max + 1)
}
function getTitle() {
  if (!props.slider.translate) return props.slider.title
  return lang(props.slider.title)
}
function selectColor(index) {
  if (!mounted) return
  if (index === props.slider.current) return
  menuStore.setSliderCurrent({ index: props.index, value: index })
}
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
function rightKey() {
  if (fakeIndex.value == 0) return '→'
  if (fakeIndex.value == 1) return "E"
  if (fakeIndex.value == 2) return "6"
}
onBeforeUnmount(() => {
  mounted = false
})
</script>