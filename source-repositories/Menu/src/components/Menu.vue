<template>
  <Transition :css="datas.openingAnimation">
    <div :class="['menu', { 'right': datas.menuPositionRight }]" v-if="datas.showMenu">
      <div class="smudge"></div>
      <div class="container">
        <div class="background"></div>
        <Header />
        <Main />
      </div>
    </div>
  </Transition>
</template>

<script setup>
import Main from './layout/Main.vue'
import Header from './layout/Header.vue'
import { useDataStore } from '../stores/datas';
const datas = useDataStore()
</script>