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
      <input type="range" min=0 :max="max" :class="['palette', 'max-' + max]" :style="background()" :value="props.slider.current" @input="change" />
      <div :class="['keyHelpers', 'index-' + fakeIndex]" v-if="fakeIndex > 0">
        <div class=" right" ref="keyRight">
          {{ rightKey() }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onBeforeUnmount, inject, ref, computed, onBeforeMount, watch } from 'vue';
import { useLangStore } from '../../../stores/lang';
const lang = useLangStore().lang
import { useMenuStore } from '../../../stores/menus';
const menuStore = useMenuStore()
const API = inject('API')

const props = defineProps(['index', 'slider'])
let fakeIndex = ref(props.index)
if (menuStore.cMenu.type == 'tile')
  fakeIndex.value += 1
const max = ref(1)
let mounted = false

const url = computed(() => { return `./assets/images/menu/${props.slider.tint}.png` })

function CalculMaxValue() {
  const img = new Image();
  img.src = url.value;

  img.onload = function () {
    max.value = img.naturalWidth - 1; // Largeur originale de l'image
  };
}

onBeforeMount(() => {
  CalculMaxValue()
  mounted = true
})
watch(url, () => {
  CalculMaxValue()
})

function background() {
  return { backgroundImage: `url(${url.value}` }
}
function numItem() {
  return API.sprintf(lang('of'), props.slider.current + 1, max.value + 1)
}
function getTitle() {
  if (!props.slider.translate) return props.slider.title
  return lang(props.slider.title)
}
function change(e) {
  if (!mounted) return

  let value = e.target.value
  e.target.blur()

  if (value == props.slider.current) return
  menuStore.setSliderCurrent({ index: props.index, value: parseInt(value) })
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