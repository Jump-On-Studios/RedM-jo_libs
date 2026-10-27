<template>
  <template v-if="slider.values.length > 1 || slider.forceDisplay">
    <div :data-slider-index="index" class="slider">
      <h2 v-if="slider.title">{{ title() }}</h2>
      <div class="arrows">
        <div class="arrow left clicker" @click="menuStore.sliderLeft(index)"><img src="/assets/images/menu/selection_arrow_left.png"></div>
        <div class="text hapna">{{ numItem() }}</div>
        <div class="arrow right clicker" @click="menuStore.sliderRight(index)"><img src="/assets/images/menu/selection_arrow_right.png"></div>
      </div>
      <div :class="['sprites', { 'center': slider.values.length <= 8, 'columns': slider.columns != null }]" :style="spritesStyle(slider)" id="scroller">
        <div v-for="(value, vIndex) in slider.values" :key="vIndex + 1" :class="['sprite clicker', { 'current': (vIndex + 1) == slider.current, 'hidden': !isRendered(vIndex) }]" :style="imagePadding(slider.imagePadding)" :id="'sprite-' + (vIndex + 1)" @click="click(vIndex + 1)">
          <template v-if="isRendered(vIndex)">
            <SpriteBox :sprite="value" :zoom="slider.imageZoom" :zoomOrigin="slider.imageZoomOrigin" />
            <div class="tick" v-if="slider.displayTick && slider.tickIndex == vIndex">
              <img src="/assets/images/menu/tick.png">
            </div>
          </template>
        </div>
      </div>
      <div :class="['slider-description hapna', { last: props.last }]" v-if="slider.description" v-html="slider.description" />
    </div>
  </template>
</template>

<script setup>
import ColorPaletteBox from '../ColorPaletteBox.vue';
import SpriteBox from '../SpriteBox.vue';
import { inject, onMounted, watch } from 'vue';
import { useLangStore } from '../../../stores/lang';
import { useMenuStore } from '../../../stores/menus';
const lang = useLangStore().lang
const menuStore = useMenuStore()

const props = defineProps(['slider', 'index', 'last'])

const API = inject('API')

function title() {
  if (props.slider.translate)
    return lang(props.slider.title)
  return props.slider.title
}

function numItem() {
  return API.sprintf(lang('of'), props.slider.current, props.slider.values.length)
}
function click(vIndex) {
  if (vIndex == props.slider.current) return
  menuStore.setSliderCurrent({ index: props.index, value: parseInt(vIndex) })
}
// slider.imagePadding: the space between the image of a value and the swatch's frame (a number in vh, or a CSS length)
function imagePadding(padding) {
  if (padding == null) return
  return { '--sprite-image-padding': API.cssLength(padding) }
}
// slider.gap: the space between the frames of two values, 1.5vh by default; slider.size: the size of a value, frame
// and its padding included, 5vh by default (each a number in vh, or a CSS length); slider.columns: the number of values
// shown across the slider, the gap then computed from its width; slider.imageZoom: the image of a value enlarged inside
// its frame, cut by it (1.5 = 150 %), as an item's tileZoom; slider.imageZoomOrigin: the point it is enlarged from, as
// CSS transform-origin ("top", "center", "top center"...), "center" by default
function spritesStyle(slider) {
  const style = {}
  if (slider.gap != null) style['--sprites-gap'] = API.cssLength(slider.gap)
  if (slider.size != null) style['--sprite-size'] = API.cssLength(slider.size)
  if (slider.columns != null) style['--sprites-columns'] = slider.columns
  return style
}
function isRendered(vIndex) {
  const gap = 10
  return vIndex >= props.slider.current - gap && vIndex <= props.slider.current + gap
}

let firstScroll = true
function updateScroll() {
  setTimeout(() => {
    const currentIndex = document.querySelector('#scroller #sprite-' + props.slider.current)
    if (!currentIndex) return
    currentIndex.scrollIntoView({ behavior: firstScroll ? 'instant' : 'instant', block: "nearest", inline: "nearest" })
    firstScroll = false
  }, 50);
}
watch(() => props.slider.current, () => {
  updateScroll()
})
onMounted(() => {
  updateScroll()
})
</script>