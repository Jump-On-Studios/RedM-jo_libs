<template>
  <template v-if="!menuStore.cItem.disabled">
    <div :class="['sliders', { full: fullHeight() }]" v-if="menuStore.cItem.sliders && (menuStore.cItem.sliders.length > 0)">
      <template v-for="(slider, index) in menuStore.cItem.sliders" :key="index">
        <template v-if="slider.type == 'palette'">
          <Palette :index="index" :slider="slider" />
        </template>
        <template v-else-if="slider.type == 'switch'" />
        <template v-else-if="slider.type == 'grid'">
          <Grid :index="index" :slider="slider" />
        </template>
        <template v-else-if="slider.type == 'sprite' || slider.type == 'color'">
          <template v-if="slider.values.length > 1">
            <Sprite :index="index" :slider="slider" />
          </template>
        </template>
        <template v-else>
          <template v-if="slider.values.length > 1">
            <Default :index="index" :slider="slider" />
          </template>
        </template>
      </template>
    </div>
  </template>
</template>

<script setup>
import { onBeforeMount, onBeforeUnmount } from 'vue';
import { useMenuStore } from '../../stores/menus';
import Palette from './sliders/Palette.vue'
import Default from './sliders/Default.vue'
import Grid from './sliders/Grid.vue'
import Sprite from './sliders/Sprite.vue'

const menuStore = useMenuStore()
const keyPressed = {}

function handleKeydown(e) {
  if (!menuStore.cItem.sliders) return
  keyPressed[e.code] = true
  switch (e.code) {
    //LEFT
    case 'ArrowLeft':
      if (menuStore.cMenu.type == "tile") return
      menuStore.sliderLeft()
      break;
    case 'KeyQ':
      if (menuStore.cMenu.type == "tile")
        menuStore.sliderLeft()
      else
        menuStore.sliderLeft(1)
      break;
    case 'Numpad4':
      if (menuStore.cMenu.type == "tile")
        menuStore.sliderLeft(1)
      else
        menuStore.sliderLeft(2)
      break;
    case 'Digit4':
      if (menuStore.cMenu.type == "tile")
        menuStore.sliderLeft(1)
      else
        menuStore.sliderLeft(2)
      break;
    //RIGHT
    case 'ArrowRight':
      if (menuStore.cMenu.type == "tile") return
      menuStore.sliderRight()
      break;
    case 'KeyE':
      if (menuStore.cMenu.type == "tile")
        menuStore.sliderRight()
      else
        menuStore.sliderRight(1)
      break;
    case 'Numpad6':
      if (menuStore.cMenu.type == "tile")
        menuStore.sliderRight(1)
      else
        menuStore.sliderRight(2)
      break;
    case 'Digit6':
      if (menuStore.cMenu.type == "tile")
        menuStore.sliderRight(1)
      else
        menuStore.sliderRight(2)
      break;
  }

  if (keyPressed["KeyW"])
    menuStore.gridUp()
  if (keyPressed['KeyA'])
    menuStore.gridLeft()
  if (keyPressed["KeyS"])
    menuStore.gridDown()
  if (keyPressed["KeyD"])
    menuStore.gridRight()
}

function handleKeyup(e) {
  delete keyPressed[e.code]
}

function fullHeight() {
  if (menuStore.cItem.description.length > 0) return false
  if (menuStore.cItem.statistics.length > 0) return false
  return true
}
onBeforeMount(() => {
  window.addEventListener('keydown', handleKeydown, null);
  window.addEventListener('keyup', handleKeyup, null);
})
onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown);
  window.removeEventListener('keyup', handleKeyup);
})
</script>