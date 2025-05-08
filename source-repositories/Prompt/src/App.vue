<script setup>
import Group from './components/Group.vue'
import { initGroup } from './dev'
import Bridge from './components/Bridge.vue'

const isDev = import.meta.env.DEV

if (isDev) {
  initGroup()
}
</script>

<template>
  <Bridge />
  <img v-if="isDev"
       id="bg"
       src="/assets/images/capture4.jpg" />
  <Group />
</template>

<style scoped lang="scss">
#bg {
  z-index: -1;
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: bottom;
  pointer-events: none;
}
</style>
