<template>
  <template v-if="props.slider.values.length > 1">
    <div :data-slider-index="props.index" class="slider">
      <h2 v-if="props.slider.title">{{ title() }}</h2>
      <div class="arrows">
        <div class="arrow left clicker" @click="menuStore.sliderLeft(props.index)"><img src="/assets/images/menu/selection_arrow_left.png"></div>
        <div class="text hapna">{{ numItem() }}</div>
        <div class="arrow right clicker" @click="menuStore.sliderRight(props.index)"><img src="/assets/images/menu/selection_arrow_right.png"></div>
      </div>
      <div class="boxes">
        <div v-for="vIndex in props.slider.values.length"
          :key="vIndex"
          :class="['box clicker',{
            'active' : vIndex < props.slider.current,
            'current' : vIndex == props.slider.current,
          }]"
          @click="click(vIndex)"
        >
        </div>
      </div>
    </div>
  </template>
</template>

<script setup>
import { inject } from 'vue';
import { useLangStore } from '../../../stores/lang';
import { useMenuStore } from '../../../stores/menus';
const lang = useLangStore().lang

const menuStore = useMenuStore()

const props = defineProps(['slider','index'])

const API = inject('API')

function title() {
  if (props.slider.translate)
    return lang(props.slider.title)
  return props.slider.title
}

function numItem() {
  return API.sprintf(lang('of'),props.slider.current, props.slider.values.length)
}
function click(vIndex) {
  if (vIndex == props.slider.current) return
  menuStore.setSliderCurrent({index: props.index,value:parseInt(vIndex)})
}
</script>