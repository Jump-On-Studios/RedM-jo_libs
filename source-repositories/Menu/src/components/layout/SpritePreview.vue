<template>
  <div class="preview-slider">
    <ColorPaletteBox v-if="isColor" :color="getColor()" />
    <img v-else :src="`./assets/images/${getSprite()}.png`" />
  </div>
</template>

<script setup>
import { computed } from 'vue';
import ColorPaletteBox from './ColorPaletteBox.vue';

const props = defineProps(['sliders'])

const isColor = computed(() => {
  for (const slider of props.sliders) {
    if (slider.type == "color" && slider.values.length > 0) {
      return true
    }
  }
  return false
})

function getSprite() {
  for (const slider of props.sliders) {
    if (slider.type == "sprite" && slider.values.length > 0) {
      return slider.values[slider.current - 1]?.sprite
    }
  }
}
function getColor() {
  for (const slider of props.sliders) {
    if (slider.type == "color" && slider.values.length > 0) {
      return slider.values[slider.current - 1]
    }
  }
}
</script>

<style scoped>
.preview-slider {
  width: 3vh;
  height: 3vh;
}
</style>