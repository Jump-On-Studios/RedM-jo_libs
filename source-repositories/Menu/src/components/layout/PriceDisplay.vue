<template>
  <template v-if="props.price !== undefined && props.price !== false">
    <div class="priceDisplay">
      <div class="monetary">
        <template v-if="props.price.gold">
          <span class="gold">
            <span class="icon">
              <img src="/assets/images/gold.png">
            </span>
            {{ gold() }}
          </span>
        </template>
        <template v-if="props.price.money">
          <span class="dollar">
            <span class="devise">{{ devise() }}</span>
            <span class="round">{{ priceRounded() }}</span>
            <span class="centime">{{ centimes() }}</span>
          </span>
        </template>
      </div>
      <template v-if="props.price.items">
        <div class="items">
          <span :class="['item', { 'with-label': item.displayLabel }]" v-for="item, key in props.price.items" :key="key + item.item">
            <span :class="['quantity', { circle: (item.quantityStyle == 'circle') }]">{{ item.quantity }}<template v-if="item.quantityStyle != 'circle'">x</template></span>
            <div class="icon" v-tooltip.top="{ value: (!item.displayLabel ? item.label : ''), escape: false }">
              <img :src="getImage(item.image)" />
              <span v-if="item.displayLabel" class="label" v-html="item.label" </span>
            </div>
          </span>
        </div>
      </template>
    </div>
  </template>
</template>

<script setup>
import { useLangStore } from '../../stores/lang';
const props = defineProps(['price'])
const lang = useLangStore().lang

function gold() {
  if (props.price.gold % 1 == 0) return props.price.gold.toString()
  return props.price.gold.toFixed(2).toString()
}
function getPrice() {
  if (typeof (props.price) == 'object')
    return props.price.money
  return props.price
}
function priceRounded() {
  let price = getPrice()
  if (getPrice() == 0)
    return lang('free')
  return Math.trunc(price)
}
function centimes() {
  let price = getPrice()
  if (price == 0)
    return ''
  return (price % 1).toFixed(2).toString().substring(2);
}
function devise() {
  if (getPrice() == 0)
    return ''
  return lang('devise')
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