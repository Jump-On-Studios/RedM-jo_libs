<template>
  <li v-if="item" :id="`item-${id}`" :class="['item grid clicker with-icon', { 'disabled': item.disabled, 'active': active }]" @click="click()">
    <div :class="[{ 'bw opacity50': item.disabled }, 'image', item.iconClass]">
      <img :src="getImage(item.icon)" />
    </div>
    <div class="current" v-if="isCurrent">
      <div class="tick">
        <img src="/assets/images/menu/tick.png">
      </div>
    </div>
    <div :class="['icon-right', item.iconClass]" v-if="item.iconRight">
      <img :src="getImage(item.iconRight)">
    </div>
    <div class="quantity" v-if="typeof item.quantity != 'boolean'">
      <span class="text">{{ item.quantity }}</span>
      <span :class="['circle', item.quantityCircleClass]"></span>
    </div>
    <div :class="['quality', item.qualityClass]" v-if="item.quality != false">
      <div v-for="i in 3" :key="i" :class="['star', 'star-' + i, { disabled: i > item.quality }]">
        <img src="/assets/images/icons/star.png" />
      </div>
    </div>
    <div :class="['stars', item.starsClass]" v-if="item.stars">
      <div v-for="i in item.stars[1]" :key="i" :class="['star', 'star-' + i, { disabled: i > item.stars[0] }]">
        <img src="/assets/images/icons/star.png" />
      </div>
    </div>
    <div class="background"></div>
  </li>
</template>

<script setup>
import { useMenuStore } from '../../stores/menus'
import { inject } from 'vue'
const menuStore = useMenuStore()
const API = inject('API')

const props = defineProps({
  icon: {
    default: false,
  },
  isCurrent: {
    default: false,
  },
  item: Object,
  active: {
    default: false,
    type: Boolean
  },
  id: Number
})

function click() {
  if (menuStore.cMenu.currentIndex == props.item.id) {
    menuStore.menuEnter()
  } else {
    menuStore.setCurrentIndex(menuStore.currentMenuId, props.item.id)
  }
  API.PlayAudio('button')
}

function isNUIImage(url) {
  return url.includes('://')
}

function getImage(url) {
  if (isNUIImage(url))
    return url
  return `./assets/images/icons/${url}.png`
}
</script>

<style scoped lang="scss">
.item {
  display: grid;
  position: relative;
  width: 100%;
  align-items: center;
  aspect-ratio: 1 / 1;
  padding: 1.5vh;
  scroll-margin-top: var(--list-padding-top);
  scroll-margin-bottom: var(--list-padding-top);

  &.active::after {
    border-color: #d80419;
    border-image-repeat: round;
    border-image-slice: 10 10 10 10 fill;
    border-image-source: url("/assets/images/menu/hover.png");
    border-style: solid;
    border-width: 0.75vh;
    box-sizing: border-box;
    content: "";
    opacity: 1;
    pointer-events: none;
    position: absolute;
    top: calc(-1 * var(--list-padding-top));
    bottom: calc(-1 * var(--list-padding-top));
    left: calc(-1 * var(--padding-background-item));
    right: calc(-1 * var(--padding-background-item));
    z-index: 10;
  }

  &>* {
    display: block;
    z-index: 10;
  }

  .background {
    position: absolute;
    top: var(--padding-background-item);
    bottom: var(--padding-background-item);
    left: calc(1 * var(--padding-background-item));
    right: calc(1 * var(--padding-background-item));
    filter: invert(75%);
    opacity: 0.7;
    z-index: 5;
    background-image: url('/assets/images/menu/scoreboard_bg_1a.png');
    background-size: 100% 100%;
  }

  .image img {
    object-fit: contain;
  }

  .current {
    position: absolute;
    top: 46%;
    transform: translateY(-50%);
    right: 2.6vh;
    width: 3vh;
    height: 3vh;
    z-index: 20;

    &>div {
      width: 100%;
      height: 100%;
      left: 0;
      top: 0;
    }

    img {
      width: 100%;
      height: 100%;
    }
  }
}

.icon-right {
  position: absolute;
  bottom: 0;
  bottom: calc(1 * var(--padding-background-item));
  right: calc(2 * var(--padding-background-item));
  width: 30%;
  z-index: 100;

  img {
    object-fit: contain;
  }
}

.quantity {
  position: absolute;
  bottom: calc(2 * var(--padding-background-item));
  aspect-ratio: 1 / 1;
  right: calc(2 * var(--padding-background-item));
  width: 30%;
  box-shadow: 0px 0px 10px 0px #000000;
  border-radius: 50%;
  z-index: 100;
  display: flex;
  color: #2c2c2c;
  justify-content: center;
  align-items: center;

  .text {
    margin-top: 10%;
  }

  .circle {
    content: '';
    position: absolute;
    z-index: -1;
    left: 0;
    top: 0;
    bottom: 0;
    right: 0;
    background-image: url('/assets/images/menu/circle.png');
    background-size: contain;
  }
}

.star {
  --star-size: 1.46vh;
  width: var(--star-size);
  height: var(--star-size);

  img {
    object-fit: contain;
  }

  &.disabled {
    opacity: 0.5;
  }
}

.quality {
  position: absolute;
  width: 30%;
  left: calc(2 * var(--padding-background-item));
  top: calc(1.5 * var(--padding-background-item));
  z-index: 100;

  .star {
    position: absolute;
  }

  .star-1 {
    left: 50%;
    transform: translateX(-50%);
  }

  .star-2,
  .star-3 {
    top: calc(0.8 * var(--star-size));
  }

  .star-3 {
    right: 0;
  }
}

.stars {
  position: absolute;
  top: 0;
  right: 0;
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
  justify-content: flex-end;
  width: 100%;
  padding: calc(1.5 * var(--padding-background-item)) calc(2 * var(--padding-background-item));
  z-index: 100;
}
</style>
