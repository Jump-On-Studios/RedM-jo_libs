<template>
  <div style="position:relative">
    <Scroller direction='top' :parent="listEl" :key=scrollTop />
    <ul ref="listEl" id="list-items" :class="['list-items', 'type-' + menuStore.cMenu.type]" :style="setStyle()" @scroll="updateScroller()">
      <component :is="getItemComponent()" v-for="(item, index) in menuStore.cMenuItems" :key="`${item.refreshKey}`" :title="getTitle(item)" :icon="item.icon" :isCurrent="item.index == menuStore.cMenu.equipedItem.index" :item="item" :active="menuStore.cMenu.currentIndex == index" :id=index />
    </ul>
    <Scroller direction='bottom' :parent="listEl" :key=scrollTop />
  </div>
</template>

<script setup>
import ItemList from './ItemList.vue'
import ItemTile from './ItemTile.vue'
import Scroller from './Scroller.vue'
import { useMenuStore } from '../../stores/menus';
const menuStore = useMenuStore()
import { useLangStore } from '../../stores/lang';
import { onBeforeMount, onBeforeUnmount, inject, ref, onUpdated } from 'vue';
const lang = useLangStore().lang
const API = inject('API')

const listEl = ref({})
const scrollTop = ref(0)

function getItemComponent() {
  if (menuStore.cMenu.type == "tile")
    return ItemTile
  return ItemList
}

function updateScroller() {
  scrollTop.value = listEl.value.scrollTop
}

function setStyle() {
  if (menuStore.cMenu.type == "tile")
    return {
      '--numberOnLine': menuStore.cMenu.numberOnLine,
      '--numberLineOnScreen': menuStore.cMenu.numberLineOnScreen,
    }
  return {
    '--numberOnScreen': menuStore.cMenu.numberOnScreen
  }
}

let previousMenu = ''
let previousItem = ''
onUpdated(() => {
  if (previousItem == menuStore.cMenu.currentIndex && previousMenu == menuStore.currentMenuId)
    return
  const currentIndex = document.getElementById('item-' + menuStore.cMenu.currentIndex)
  if (!currentIndex) return
  let firstScroll = previousMenu != menuStore.currentMenuId
  previousMenu = menuStore.currentMenuId
  previousItem = menuStore.cMenu.currentIndex
  currentIndex.scrollIntoView({ behavior: firstScroll ? 'instant' : 'instant', block: "nearest" })
})

function getTitle(item) {
  if (item.title.length > 0) {
    if (!item.translate) return item.title
    return lang(item.title)
  }
  return API.sprintf(lang('number'), item.index)
}
function handleKeydown(e) {
  switch (e.key) {
    case 'ArrowDown':
      e.preventDefault()
      menuStore.menuDown()
      return;
    case 'ArrowUp':
      e.preventDefault()
      menuStore.menuUp()
      return;
    case 'ArrowLeft':
      e.preventDefault()
      menuStore.menuLeft()
      return;
    case 'ArrowRight':
      e.preventDefault()
      menuStore.menuRight()
      return;
  }
  return;
}
function handleWheel(e) {
  if ((e.target.closest('.slider') != null) || (e.target.closest('.colorPicker') != null)) {
    if (e.deltaY < 0) {
      menuStore.sliderLeft()
    } else {
      menuStore.sliderRight()
    }
    return
  }
  if (e.deltaY < 0) {
    if (menuStore.cMenu.type == "tile")
      menuStore.menuLeft()
    else
      menuStore.menuUp()
    // e.preventDefault()
    return false
  } else {
    if (menuStore.cMenu.type == "tile")
      menuStore.menuRight()
    else
      menuStore.menuDown()
    // e.preventDefault()
    return false
  }
}

onBeforeMount(() => {
  window.addEventListener('keydown', handleKeydown, null);
  window.addEventListener('wheel', handleWheel, null);
})
onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown);
  window.removeEventListener('wheel', handleWheel);
})

</script>

<style lang="scss" scoped>
.list-items {
  position: relative;
  overflow-y: hidden;
  display: block;
  --list-padding-top: 0.3vh;
  padding-top: var(--list-padding-top);
  width: calc(100% + 2 * var(--padding-background-item));
  margin-left: calc(-1 * var(--padding-background-item));
  padding-bottom: 0.3vh;
}

.type-list {
  max-height: calc(var(--numberOnScreen) * 4.9vh + 0.6vh),
}

.type-tile {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  align-content: flex-start;
  justify-content: flex-start;
  align-items: center;
  --item-size: calc(var(--container-width)/ var(--numberOnLine));
  max-height: calc(var(--item-size)*var(--numberLineOnScreen) + 2 * var(--list-padding-top));
  // width: 100%;
  // margin-left: 0;
  padding-left: var(--padding-background-item);

  .item {
    width: var(--item-size);
    height: var(--item-size);
  }
}
</style>