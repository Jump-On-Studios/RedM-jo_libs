<template>
  <template v-if="slider.values.length > 1 || slider.forceDisplay">
    <div :data-slider-index="index" class="slider">
      <h2 v-if="slider.title">{{ title() }}</h2>
      <div class="arrows">
        <div class="arrow left clicker" @click="menuStore.sliderLeft(index)"><img src="/assets/images/menu/selection_arrow_left.png"></div>
        <div class="text hapna">{{ numItem() }}</div>
        <div class="arrow right clicker" @click="menuStore.sliderRight(index)"><img src="/assets/images/menu/selection_arrow_right.png"></div>
      </div>
      <div :class="['sprites', { 'center': slider.values.length <= 8 }]" id="scroller">
        <div v-for="(value, vIndex) in slider.values" :key="vIndex + 1" :class="['sprite clicker', { 'current': (vIndex + 1) == slider.current, 'hidden': !isRendered(vIndex) }]" :id="'sprite-' + (vIndex + 1)" @click="click(vIndex + 1)">
          <template v-if="isRendered(vIndex)">
            <SpriteBox :sprite="value" />
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
import { inject, onMounted, nextTick } from 'vue';
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
menuStore.$subscribe(() => {
  updateScroll()
})
onMounted(() => {
  updateScroll()
})
</script>