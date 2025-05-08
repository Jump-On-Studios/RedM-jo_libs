<template>
  <template v-if="props.price !== undefined && props.price !== false">
    <div class="priceDisplay">
      <template v-if="(typeof (props.price) == 'object') && props.price.gold && props.price.money">
        <span class="gold left">
          <span class="icon">
            <img src="/assets/images/gold.png">
          </span>
          {{ gold() }}
        </span>
      </template>
      <template v-if="props.price.gold && !props.price.money">
        <span class="gold">
          <span class="icon">
            <img src="/assets/images/gold.png">
          </span>
          <span class="round">{{ gold() }}</span>
        </span>
      </template>
      <template v-else>
        <span class="devise">{{ devise() }}</span>
        <span class="round">{{ priceRounded() }}</span>
        <span class="centime">{{ centimes() }}</span>
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
</script>