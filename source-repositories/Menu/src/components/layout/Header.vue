<template>
  <header>
    <div class="background" v-if="datas.showMenu && !menuStore.cMenu.hideBackground || !datas.showMenu && datas.keepBackground"></div>
    <h1 v-html="getTitle()"></h1>
  </header>
</template>

<script setup>
import { useMenuStore } from '../../stores/menus';
const menuStore = useMenuStore()
import { useLangStore } from '../../stores/lang';
import { useDataStore } from '../../stores/datas';
const datas = useDataStore()
const lang = useLangStore().lang

function getTitle() {
  if (!datas.showMenu) {
    return ''
  }
  if (menuStore.cMenu.translateTitle) {
    return lang(menuStore.cMenu.title)
  }
  return menuStore.cMenu.title
}
</script>