<template>
  <button v-if="devMode" style="position: absolute; left: 0; top: 0; z-index:999; color: black" @click="HideButton()">Toggle show {{ datas.showMenu }}</button>
  <img v-if="devMode" style="position: absolute; left: 0; top: 0; width:100vw;height:100vh" src="/assets/images/background_dev.jpg">
  <Menu />
</template>

<style lang="scss">
@import "./scss/_main.scss";
</style>

<script setup>
import Menu from './components/Menu.vue'
import _ from './dev'

import { useDataStore } from './stores/datas';
let datas = {}

const devMode = import.meta.env.DEV;
if (devMode)
  datas = useDataStore();

function HideButton() {
  datas.defineShow(!datas.showMenu);
}
</script>
