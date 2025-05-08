<template>
  <div class="sufix" v-if="props.slider.type == 'switch' && props.slider.values.length > 1">
    <div class="arrows" @click.stop="">
      <div class="arrow left clicker" @click="menuStore.sliderLeft(props.index)" v-if="props.isCurrent"><img src="/assets/images/menu/selection_arrow_left.png"></div>
      <div class="text hapna">{{ getSufixLabel() }}</div>
      <div class="arrow right clicker" @click="menuStore.sliderRight(props.index)" v-if="props.isCurrent"><img src="/assets/images/menu/selection_arrow_right.png"></div>
    </div>
  </div>
</template>

<script setup>
import { useLangStore } from '../../../stores/lang';
import { useMenuStore } from '../../../stores/menus';
const menuStore = useMenuStore()
const lang = useLangStore().lang
const props = defineProps(['slider', 'isCurrent'])

function getSufixLabel() {
  if (!props.slider.translate) return props.slider.values[props.slider.current - 1].label
  return lang(props.slider.values[props.slider.current - 1].label)
}
</script>