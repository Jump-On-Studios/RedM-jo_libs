<template>
  <div class="preview-slider">
    <SpriteBox v-if="getValue" :sprite="getValue" />
  </div>
</template>

<script setup>
import { computed } from 'vue';
import SpriteBox from './SpriteBox.vue';

const props = defineProps(['sliders'])

const getValue = computed(() => {
  for (const slider of props.sliders) {
    if ((slider.type == "color" || slider.type == "sprite") && slider.values.length > 0) {
      return slider.values[slider.current - 1]
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