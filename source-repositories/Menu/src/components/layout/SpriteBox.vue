<template>
  <div class="sprite-box">
    <div class="tag" :class="{ 'has-text': sprite.tagText }" v-if="sprite.tagColor || sprite.tagText" :style="{
      backgroundColor: sprite.tagColor || 'white',
      color: sprite.tagTextColor || 'black',
    }">
      {{ sprite.tagText }}
    </div>
    <!-- zoom: the image enlarged inside its padding, cut by it (the slider's imageZoom) -->
    <div v-if="sprite.sprite" :class="['image', { zoomed: zoom != null }]" :style="zoomStyle()">
      <div class="clip">
        <LoadingImage :class="sprite.class" :src="imageSrc()" />
      </div>
    </div>
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
// zoom: the image enlarged (1.5 = 150 %); zoomOrigin: the point it is enlarged from, "center" by default
const props = defineProps(["sprite", "zoom", "zoomOrigin"]);
const API = inject("API");

function imageSrc() {
  return API.isNUIImage(props.sprite.sprite) ? props.sprite.sprite : `./assets/images/${props.sprite.sprite}.png`;
}
function zoomStyle() {
  if (props.zoom == null) return;
  return { "--sprite-zoom": props.zoom, "--sprite-zoom-origin": props.zoomOrigin || "center" };
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

.image {
  width: 100%;
  aspect-ratio: 1 / 1;
  box-sizing: border-box;

  .clip {
    width: 100%;
    height: 100%;
    overflow: hidden;
  }

  &.zoomed :deep(img:not(.spinner)) {
    display: block;
    transform: scale(var(--sprite-zoom));
    transform-origin: var(--sprite-zoom-origin);
  }
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
