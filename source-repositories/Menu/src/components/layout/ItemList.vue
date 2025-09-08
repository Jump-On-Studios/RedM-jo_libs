<template>
  <li v-if="item" :id="`item-${id}`" :class="[
    'item',
    'clicker',
    { 'with-icon': icon, 'disabled': item.disabled, 'active': active, },
    `icon-size-${item.iconSize}`
  ]" @click="click()">
    <div :class="[{ 'bw opacity50': item.disabled }, 'image', item.iconClass]" v-if="icon">
      <img :src="getImage(item.icon)" />
    </div>
    <div class="current" v-if="item.iconRight">
      <div class="tick">
        <img :src="getImage(item.iconRight)">
      </div>
    </div>
    <h3>
      <div v-if="item.prefix" :class="['prefix', { 'bw opacity50': item.disabled }]">
        <img :class="item.prefix" :src="getImage(item.prefix)" />
      </div>
      <div class="title">
        <span class="main" v-html="item.title"></span>
        <span class="subtitle hapna" v-if="item.subtitle.length > 0" v-html="item.subtitle"></span>
      </div>
      <template v-if="!item.disabled && item.sliders">
        <template v-for="(slider, index) in item.sliders" :key="index">
          <template v-if="slider.type == 'switch'">
            <Switch :slider="slider" :index="index" :isCurrent="item.index == menuStore.cItem.index" />
          </template>
        </template>
      </template>
      <PreviewSlider :item="item" />
      <div class="sufix" v-if="item.textRight">
        <div :class="['textRight', item.textRightClass]">
          <span v-if="item.translateTextRight" v-html="lang(item.textRight)">
          </span>
          <span v-else v-html="item.textRight">
          </span>
        </div>
      </div>
      <div class="priceRight" v-if="!item.iconRight && price !== undefined && price !== false">
        <PriceDisplay :price="price" />
      </div>
    </h3>
    <div class="background"></div>
  </li>
</template>

<script setup>
import PriceDisplay from './PriceDisplay.vue'
import Switch from './sliders/Switch.vue'
import PreviewSlider from './PreviewSlider.vue'
import { useMenuStore } from '../../stores/menus'
import { useLangStore } from '../../stores/lang'
import { inject, computed } from 'vue'
const menuStore = useMenuStore()
const API = inject('API')
const lang = useLangStore().lang

const props = defineProps({
  icon: {
    default: false,
  },
  item: Object,
  active: {
    default: false,
    type: Boolean
  },
  id: Number
})

const price = computed(() => {
  return (props.item.priceRight && (menuStore.cMenu.cItem == props.item)) ? 0 : props.item.priceRight
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
.title {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-start;

  .main {
    width: 100%;
  }
}

.textRight {
  font-family: "Hapna";
  font-weight: 500;
  font-size: 1.1em;

  &.tiny {
    font-size: 0.715em;
    font-family: 'Hapna';
    font-weight: 500;
  }
}

.item {
  display: grid;
  position: relative;
  width: 100%;
  min-height: var(--item-height);
  // grid-template-columns: repeat(auto);
  align-items: center;
  padding: var(--item-padding-v) var(--item-padding-h);
  scroll-margin-top: var(--item-padding-v);
  scroll-margin-bottom: var(--item-padding-v);

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
    right: 0;
    top: -0.3vh;
    bottom: -0.3vh;
    left: 0;
    z-index: 10;
  }

  &>* {
    display: block;
    z-index: 10;
  }

  .background {
    position: absolute;
    top: 0.3vh;
    bottom: 0.3vh;
    left: 0.6vh;
    right: 0.6vh;
    filter: invert(75%);
    z-index: 5;
    background-image: url('/assets/images/menu/selection_box_bg_1d.png');
    background-size: 100% 100%;
  }

  h3 {
    font-size: 1.4em;
    display: flex;
    column-gap: 0.5vh;
    align-items: center;

    .prefix {
      width: 1.85vh;

      .star {
        filter: brightness(0) saturate(100%) invert(90%) sepia(29%) saturate(3711%) hue-rotate(349deg) brightness(108%) contrast(101%);
      }
    }

    .title {
      flex: 1 1 auto;
      padding-top: 0.93vh;
      padding-bottom: 0.93vh;

      .under {
        font-size: 0.7em;
        margin-top: -0.46vh;
        display: block;
      }
    }

    .sufix {
      font-size: 0.65em;

      .arrows {
        column-gap: 0.93vh;
      }
    }
  }

  &.with-icon {
    grid-template-columns: 5.5vh auto;
    grid-gap: 1.85vh;
    height: calc(2* var(--item-height));

    .image {
      display: flex;
      align-items: center;
    }

    &.icon-size-small {
      height: inherit;
      grid-template-columns: calc(0.7*var(--item-height) - 2*var(--item-padding-v)) auto;
      grid-gap: 1vh;
    }

    .background {
      background-image: url('/assets/images/menu/background_item.png');
    }
  }

  .image img {
    width: 100%;
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

  .textRight {
    display: flex;

    img {
      height: 2.8vh;
    }

    .colorCustom {
      width: 2.8vh;
    }
  }

  &.disabled {
    color: gray;

    .textRight {
      opacity: 0.5;
    }
  }

}

.title {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-start;

  .main {
    width: 100%;
  }
}

.textRight {
  &.tiny {
    font-size: 0.715em;
    font-family: 'Hapna';
    font-weight: 500;
  }
}

.priceRight {
  --price-height: 4.6vh;
  font-size: 0.8em;
  position: relative;
  display: block;
  top: -0.16vh;
}
</style>
