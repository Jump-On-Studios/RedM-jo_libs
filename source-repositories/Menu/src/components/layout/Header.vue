<template>
  <header>
    <h1>{{ getTitle() }}</h1>
  </header>
</template>

<script setup>
import { useMenuStore } from '../../stores/menus';
const menuStore = useMenuStore()
import { useLangStore } from '../../stores/lang';
const lang = useLangStore().lang

function getTitle() {
  if (menuStore.cMenu.translateTitle) {
    return lang(menuStore.cMenu.title)
  }
  return menuStore.cMenu.title
}
</script>