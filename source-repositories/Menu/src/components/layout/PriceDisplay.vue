<template>
  <template v-if="props.price !== undefined && props.price !== false">
    <template v-if="Array.isArray(props.price)">
      <div class="priceDisplay">
        <template v-for="price, index in sortItems(props.price)" :key="index">
          <div class="price-item">
            <span v-if="price.gold" class="gold">
              <span class="icon">
                <img src="/assets/images/gold.png">
              </span>
              {{ formatPrice(price.gold) }}
            </span>
            <span v-else-if="price.money || props.price.length == 1" class="dollar">
              <span class="devise">{{ devise(price.money) }}</span>
              <span class="round">{{ priceRounded(price.money) }}</span>
              <span class="centime">{{ centimes(price.money) }}</span>
            </span>
            <span v-else-if="price.item" :class="['item', { 'with-label': displayLabel(price) }]">
              <span class="circle-quantity" v-if="getQuantityStyle(price) == 'circle'" v-html="price.quantity || 1"></span>
              <span class="quantity" v-else>{{ price.quantity || 1 }}<template v-if="getQuantityStyle(price) != 'circle'">x</template></span>
              <div class="icon" v-tooltip.top="{ value: (price.tooltip ? price.label : ''), escape: false }">
                <img v-if="hasImage(price)" :src="getImage(price.image)" />
                <span v-if="displayLabel(price)" class="label" v-html="price.label"></span>
              </div>
            </span>
          </div>
          <span v-if="index < props.price.length - 1" class="plus">+</span>
        </template>
      </div>
    </template>
    <template v-else>
      <div class="priceDisplay">
        <div class="monetary">
          <template v-if="props.price.gold">
            <span class="gold">
              <span class="icon">
                <img src="/assets/images/gold.png">
              </span>
              {{ formatPrice(props.price.gold) }}
            </span>
          </template>
          <template v-if="moneyPrice">
            <span class="dollar" v-if="moneyPrice">
              <span class="devise">{{ devise(moneyPrice) }}</span>
              <span class="round">{{ priceRounded(moneyPrice) }}</span>
              <span class="centime">{{ centimes(moneyPrice) }}</span>
            </span>
          </template>
        </div>
      </div>
    </template>
  </template>
</template>

<script setup>
import { computed } from 'vue';
import { useLangStore } from '../../stores/lang';
const props = defineProps(['price'])
const lang = useLangStore().lang

function formatPrice(price) {
  if (price % 1 == 0) return price.toString()
  return price.toFixed(2).toString()
}

const moneyPrice = computed(() => {
  if (typeof props.price == 'number') return props.price
  if (props.price.money) return props.price.money
  return false
})

function priceRounded(price) {
  if (!price || price == 0)
    return lang('free')
  return Math.trunc(price)
}
function centimes(price) {
  if (price == undefined || price == false || price == 0)
    return ''
  return (price % 1).toFixed(2).toString().substring(2);
}
function devise(price) {
  if (price == 0)
    return ''
  return lang('devise')
}

function hasImage(item) {
  return item.image !== undefined && item.image.length > 0
}

function displayLabel(item) {
  return !item.tooltip || !hasImage(item)
}

function isNUIImage(url) {
  return url.includes('://')
}

function getImage(url) {
  if (isNUIImage(url))
    return url
  return `./assets/images/icons/${url}.png`
}

function getQuantityStyle(item) {
  if (!hasImage(item)) return ''
  return item.quantityStyle
}

function sortItems(prices) {
  return prices.sort((a, b) => {
    if (a.item && !b.item) return -1
    if (b.item && !a.item) return 1
    if (a.gold && !b.gold) return -1
    if (b.gold && !a.gold) return 1
    if (a.money && !b.money) return -1
    if (b.money && !a.money) return 1
    return 0
  })
}
</script>

<style lang="scss" scoped>
.priceDisplay {
  position: absolute;
  top: 0.46vh;
  right: 0.92vh;
  display: flex;
  align-items: center;
  font-size: 1.5em;
  height: 100%;
}

.monetary {
  gap: 0.4em;
  display: flex;
  position: relative;

  &>:first-child:not(:last-child) {
    font-size: 0.6em;
    margin-top: 0.93vh;

    img {
      width: 1.85vh;
    }
  }
}

.centime {
  position: relative;
  font-size: 0.6em;
  margin-left: 0.185vh;
  margin-top: 0.185vh;
  height: fit-content;

  &::after {
    content: '';
    position: absolute;
    display: block;
    background-image: url('/assets/images/menu/money_line.png');
    height: 0.46vh;
    width: 100%;
    left: 0;
    bottom: 0;
  }
}

.divider.bottom {
  margin-top: -0.46vh;
}

.gold {
  display: flex;
  align-items: center;

  img {
    height: 1em;
    width: auto;
    margin-right: 0.46vh;
  }
}

.dollar {
  display: flex;
}

.price-item {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.plus {
  padding: 0 0.2em;
}

.quantity {
  font-size: 0.6em;
  margin-bottom: 0.2em;
  margin-right: 0.2em;
}

.circle-quantity {
  font-size: 0.6em;
  position: absolute;
  color: black;
  background: white;
  border-radius: 100%;
  aspect-ratio: 1 / 1;
  min-width: 1.6em;
  text-align: center;
  top: -1px;
  right: 0px;
  font-size: 0.4em;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  font-family: 'Hapna';
  font-weight: bold;
}


.item {
  display: flex;
  align-items: center;
  position: relative;

  .icon {
    display: flex;
    flex-direction: column;
    align-items: center;
    max-width: 2em;
    max-height: var(--price-height);


    img {
      object-fit: cover;
      display: block;
      width: auto;
      height: 1em;
    }

    .label {
      font-size: 0.6em;
      font-family: Hapna;
      overflow-wrap: break-word;
      text-align: center;
    }
  }

  &.with-label {
    .icon img {
      height: calc(var(--price-height) * 0.6);
    }
  }
}

.priceRight {
  .icon {
    margin-top: -0.4vh;
  }

  .label {
    display: none;
  }
}
</style>