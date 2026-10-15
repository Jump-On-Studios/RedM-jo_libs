<template>
  <div class="preview-slider">
    <SpriteBox v-if="getSlider" :sprite="getSlider.values[getSlider.current - 1]" :zoom="getSlider.imageZoom" :zoomOrigin="getSlider.imageZoomOrigin" />
  </div>
</template>

<script setup>
import { computed } from 'vue';
import SpriteBox from './SpriteBox.vue';

const props = defineProps(['sliders'])

const getSlider = computed(() => {
  for (const slider of props.sliders) {
    if ((slider.type == "color" || slider.type == "sprite") && slider.values.length > 0) {
      return slider
    }
  }
  return null
})

</script>

<style scoped>
.preview-slider {
  width: 3vh;
  height: 3vh;
}
</style>