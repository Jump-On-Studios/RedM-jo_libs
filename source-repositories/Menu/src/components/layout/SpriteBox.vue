<template>
  <div class="sprite-box">
    <div class="tag" :class="{ 'has-text': sprite.tagText }" v-if="sprite.tagColor || sprite.tagText" :style="{
      backgroundColor: sprite.tagColor || 'white',
      color: sprite.tagTextColor || 'black',
    }">
      {{ sprite.tagText }}
    </div>
    <LoadingImage v-if="sprite.sprite" :class="sprite.class" :src="imageSrc()" />
    <ColorPaletteBox v-else-if="sprite.rgb" :color="sprite" />
    <ColorPaletteBox v-else-if="sprite.palette" :color="sprite.palette" />
    <ColorPaletteBox v-else :color="sprite" />
    <div class="icon" v-if="sprite.icon" :class="sprite.iconClass">
      <img :src="API.getImage(sprite.icon)" />
    </div>
  </div>
</template>

<script setup>
import { inject } from "vue";
const props = defineProps(["sprite"]);
const API = inject("API");

function imageSrc() {
  return API.isNUIImage(props.sprite.sprite) ? props.sprite.sprite : `./assets/images/${props.sprite.sprite}.png`;
}
import ColorPaletteBox from "./ColorPaletteBox.vue";
import LoadingImage from "./LoadingImage.vue";
</script>

<style scoped lang="scss">
.sprite-box {
  position: relative;
  height: 100%;
  width: 100%;
}

.tag {
  position: absolute;

  top: -0.75vh;
  right: -0.75vh;
  border: 0.25vh solid black;
  border-radius: 50%;
  width: 1.5vh;
  height: 1.5vh;
  font-size: 1vh;
  color: black;
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: white;

  &.has-text {
    top: -1vh;
    right: -1vh;
    width: 2vh;
    height: 2vh;
  }
}

.icon {
  position: absolute;
  left: 0rem;
  top: 0rem;
  width: 1rem;
}
</style>
