<template>
  <main>
    <div class="article">
      <h2 id="title">
        <span v-html=getTitle()></span>
        <span v-if="menuStore.parentTree.length > 0 || menuStore.cMenu.displayBackButton" class="backer clicker" @click="menuStore.menuBack()">
          <img src="/assets/images/menu/selection_arrow_left.png">
        </span>
      </h2>
      <MenuImage v-if="menuStore.cMenu.image" :image="menuStore.cMenu.image" class="menu-header-image" />
      <template v-if="showItems()">
        <List />
      </template>
    </div>
    <template v-if="datas.showLoader || (menuStore.cMenuItems.length == 0 && menuStore.cMenu.type == 'list')">
      <Loading />
    </template>
    <div class="footer" :key="menuStore.cMenu.refreshKey">
      <template v-if="showItems()">
        <Description />
        <Slider />
      </template>
    </div>
    <Price v-if="showItems()" />
    <Footer v-if="showItems()" />
  </main>
</template>

<script setup>
import List from './List.vue'
import Slider from './Slider.vue'
import Price from './Price.vue'
import Description from './Description.vue'
import MenuImage from './MenuImage.vue'
import Loading from './Loading.vue'
import Footer from './Footer.vue'
import { useDataStore } from '../../stores/datas'
import { useMenuStore } from '../../stores/menus'
import { useLangStore } from '../../stores/lang'
import { inject, onBeforeMount, onBeforeUnmount, onMounted, watch } from 'vue'
import { isWeb, loadedImages, WEB_DELAY } from '../../services/images'
const datas = useDataStore()
const menuStore = useMenuStore()
const lang = useLangStore().lang
const API = inject('API')

// item.preload: images loaded when the item becomes active (the ones its sliders, or the menu it opens, will show), so
// they show at once; set too after the item became active (computed by its onActive). Those of the web are requested
// once the item stays active WEB_DELAY ms: scrolling fast through a menu never preloads the items it passes.
// preloading: the images being loaded, kept until they load or fail (one that fails is preloaded again next time)
const preloading = new Map()
let preloadTimer = null
// a copy of the list: a change inside it (updateValue, deepMerge) preloads too
watch([() => menuStore.cItem, () => Array.isArray(menuStore.cItem?.preload) ? [...menuStore.cItem.preload] : null], ([item, preload]) => {
  clearTimeout(preloadTimer)
  if (!item || !preload) return
  const urls = preload.filter((url) => url && !preloading.has(url) && !loadedImages.has(url))
  const load = (url) => {
    const image = new Image()
    image.onload = () => {
      preloading.delete(url)
      loadedImages.add(url)
    }
    image.onerror = () => preloading.delete(url)
    image.src = url
    preloading.set(url, image)
  }
  urls.filter((url) => !isWeb(url)).forEach(load)
  const web = urls.filter(isWeb)
  if (web.length > 0) preloadTimer = setTimeout(() => web.forEach(load), WEB_DELAY)
}, { immediate: true })

const keyPressed = {}
let focus = false
let mountedDate = 0

function handleKeyUp(e) {
  keyPressed[e.key] = false
}
function handleKeydown(e) {
  if (e.code == "KeyQ")
    datas.defineQwerty(e.key == "q")
  if (focus) return
  if (keyPressed[e.key]) return

  keyPressed[e.key] = true
  if (Date.now() - mountedDate < 100) return
  switch (e.key) {
    case 'Enter':
      menuStore.menuEnter()
      break
    case 'Backspace':
      menuStore.menuBack()
      break
    case 'Escape':
      menuStore.menuBack()
      break
  }
}

function focusIn() {
  focus = true
}
function focusOut() {
  focus = false
}
function getTitle() {
  if (menuStore.cMenu.translateSubtitle) {
    return lang(menuStore.cMenu.subtitle)
  }
  return menuStore.cMenu.subtitle
}

function showItems() {
  return !datas.showLoader && menuStore.cMenuItems.length > 0
}
onBeforeMount(() => {
  window.addEventListener('keydown', handleKeydown);
  window.addEventListener('keyup', handleKeyUp);
  document.addEventListener('focusin', focusIn);
  document.addEventListener('focusout', focusOut);
})
onMounted(() => {
  mountedDate = Date.now();
  if (!datas.openingAnimation) return
  API.PlayAudio('menu_open');
})
onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown);
  window.removeEventListener('keyup', handleKeyUp);
  document.removeEventListener('focusin', focusIn);
  document.removeEventListener('focusout', focusOut);
  if (!datas.openingAnimation) return
  API.PlayAudio('menu_close');
})
</script>

<style scoped lang="scss">
.menu-header-image {
  margin: 0.5vh 0 1vh;
}
</style>