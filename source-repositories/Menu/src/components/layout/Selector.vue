<template>
  <div :class="['selector',{'with-icon' : haveIcon()}]" :style="getTop()">
  </div>
</template>

<script setup>
import { useMenuStore } from '../../stores/menus';

const menuStore = useMenuStore()

function haveIcon() {
  return menuStore.cItem.icon
}
function getTop() {
  let top = 0;
  const active = document.getElementsByClassName('item active')[0];
  if (active) {
    const container = document.getElementById('list-items')
    top = active.getBoundingClientRect().top - container.getBoundingClientRect().top 
  }
  return {
      top: top + "px"
  }
}
</script>
