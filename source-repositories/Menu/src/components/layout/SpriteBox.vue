<template>
  <div class="sprite-box">
    <img v-if="sprite.sprite" :class="sprite.class" :src="API.isNUIImage(sprite.sprite) ? sprite.sprite : `./assets/images/${sprite.sprite}.png`" />
    <ColorPaletteBox v-else-if="sprite.rgb" :color="sprite" />
    <ColorPaletteBox v-else-if="sprite.palette" :color="sprite.palette" />
    <ColorPaletteBox v-else :color="sprite" />
    <div class="icon" v-if="sprite.icon" :class="sprite.iconClass"><img :src="API.getImage(sprite.icon)"></div>
  </div>
</template>

<script setup>
import { inject } from 'vue';
const props = defineProps(['sprite'])
const API = inject('API')
import ColorPaletteBox from './ColorPaletteBox.vue';
</script>

<style scoped lang="scss">
.sprite-box {
  position: relative;
  height: 100%;
  width: 100%;
}

.icon {
  position: absolute;
  left: 0rem;
  top: 0rem;
  width: 1rem;
}
</style>