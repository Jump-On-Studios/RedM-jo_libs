<template>
  <template v-if="props.price !== undefined && props.price !== false">
    <div class="priceDisplay">
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
      <template v-if="props.price.item">
        <span class="item">
          <span class="quantity">{{ props.price.item.quantity }}x</span>
          <div class="icon" v-tooltip.top="props.price.item.label">
            <img :src="getImage(props.price.item.image)" />
            <span class="label">{{ props.price.item.label }}</span>
          </div>
        </span>
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