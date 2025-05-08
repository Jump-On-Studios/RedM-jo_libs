<template>
  <div :class="['scroller', props.direction]">
    <div class="left"></div>
    <div :class="['center', { 'active clicker': getActive() }]" @click="click()"></div>
    <div class="right"></div>
  </div>
  <div class="scounter hapna" v-if="props.direction == 'bottom'">{{ numItem() }}</div>
</template>

<script setup>
import { inject } from 'vue';
import { useLangStore } from '../../stores/lang';
import { useMenuStore } from '../../stores/menus';

const props = defineProps(['direction', 'parent'])

const lang = useLangStore().lang
const menuStore = useMenuStore()
const API = inject('API')

function getActive() {
  if (props.parent == null) return false
  if (props.direction == 'top') {
    return props.parent.scrollTop > 0
  }
  if (props.direction == "bottom") {
    return props.parent.offsetHeight + props.parent.scrollTop < props.parent.scrollHeight
  }
  return false
}
function click() {
  if (props.direction == "bottom") {
    menuStore.menuDown()
  } else {
    menuStore.menuUp()
  }
}
function numItem() {
  return API.sprintf(lang('of'), menuStore.cMenu.currentIndex + 1, menuStore.cMenuItems.length)
}
</script>