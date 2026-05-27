<template>
  <div v-if="devMode" style="position: absolute; left: 0; top: 0; z-index:999; color: white; display: flex; flex-direction: column;align-items: start;">
    <span>{{ datas.showMenu }}, {{ datas.keepBackground }}</span>
    <button @click="HideButton()">Toggle show {{ datas.showMenu }}</button>
    <button @click="SoftButton()">Toggle keepBackground {{ datas.showMenu }}</button>
  </div>
  <img v-if="devMode" style="position: absolute; left: 0; top: 0; width:100vw;height:100vh" src="/assets/images/background_dev.jpg">
  <Menu />
</template>

<style lang="scss">
@use "./scss/_main.scss" as *;
</style>

<script setup>
import Menu from './components/Menu.vue'
import _ from './dev'

import { useDataStore } from './stores/datas';
import { useMenuStore } from './stores/menus';
let datas = {}
let menuStore = {}

const devMode = import.meta.env.DEV;
if (devMode) {
  datas = useDataStore();
  menuStore = useMenuStore();
}

function HideButton() {
  window.postMessage({
    event: "updateShow",
    show: !datas.showMenu,
  });
}

function SoftButton() {
  datas.defineKeepBackground(true);
  window.postMessage({
    event: "updateShow",
    show: !datas.showMenu,
    cancelable: true,
  });
}
</script>
