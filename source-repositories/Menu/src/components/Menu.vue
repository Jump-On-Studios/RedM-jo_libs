<template>
  <Transition :css="datas.openingAnimation">
    <div :class="['menu', { 'right': datas.menuPositionRight }]" v-if="datas.showMenu || datas.keepBackground">
      <div class="smudge"></div>
      <div class="container">
        <div class="background" v-if="!menuStore.cMenu.hideBackground"></div>
        <Header />
        <Main v-if="datas.showMenu" />
      </div>
    </div>
  </Transition>
</template>

<script setup>
import Main from './layout/Main.vue'
import Header from './layout/Header.vue'
import { useDataStore } from '../stores/datas';
const datas = useDataStore()
import { useMenuStore } from '../stores/menus';
const menuStore = useMenuStore()
</script>