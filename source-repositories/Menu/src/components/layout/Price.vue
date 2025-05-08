<template>
  <div class="price" v-if="menuStore.cItemPrice !== false">
    <div class="divider"></div>
    <div class="content">
      <h4 v-if="menuStore.cItem.priceTitle > 0">{{ menuStore.cItem.priceTitle }}</h4>
      <h4 v-else>{{ lang('price') }}</h4>
      <div class="amount">
        <PriceDisplay :price="menuStore.cItemPrice" />
      </div>
    </div>
    <div class="divider bottom"></div>
  </div>
</template>

<script setup>
import { useLangStore } from '../../stores/lang';
import { useMenuStore } from '../../stores/menus';
import PriceDisplay from './PriceDisplay.vue'
const menuStore = useMenuStore()
const lang = useLangStore().lang

</script>
