<template>
  <template v-if="item.previewSlider">
    <PalettePreview v-if="hasPalette" :sliders="item.sliders" />
    <SpritePreview v-else-if="hasSprite" :sliders="item.sliders" />
  </template>
</template>

<script setup>
import { computed } from "vue";
const props = defineProps(['item'])
import PalettePreview from "./PalettePreview.vue"
import SpritePreview from "./SpritePreview.vue";

const hasSprite = computed(() => {
  for (const slider of props.item.sliders) {
    if (slider.type == "switch" && slider.values.length > 1) {
      return false
    }
    if (slider.type == "sprite" || slider.type == "color") {
      return true
    }
  }
  return false

})
const hasPalette = computed(() => {
  for (const slider of props.item.sliders) {
    if (slider.type == "switch" && slider.values.length > 1) {
      return false
    }
    if (slider.type == "palette") {
      return true
    }
  }
  return false
})
</script>