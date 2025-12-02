<template>
  <div
    class="price"
    v-if="menuStore.cItemPrice !== false || menuStore.cMenuPrice !== false"
  >
    <div class="divider"></div>
    <div class="content">
      <h4 v-if="menuStore.cItem.priceTitle">
        {{ menuStore.cItem.priceTitle }}
      </h4>
      <h4 v-else-if="menuStore.cMenu.priceTitle">
        {{ menuStore.cMenu.priceTitle }}
      </h4>
      <h4 v-else>{{ lang("price") }}</h4>
      <div class="amount">
        <PriceDisplay :price="menuStore.cItemPrice || menuStore.cMenuPrice" />
      </div>
    </div>
    <!-- <div class="divider bottom"></div> -->
  </div>
</template>

<script setup>
import { useLangStore } from "../../stores/lang";
import { useMenuStore } from "../../stores/menus";
import PriceDisplay from "./PriceDisplay.vue";
const menuStore = useMenuStore();
const lang = useLangStore().lang;
</script>

<style lang="scss" scoped>
.price {
  width: 100%;
  height: var(--price-height);
  max-height: var(--price-height);
  position: relative;

  .content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.46vh 0.92vh;
    height: 100%;

    h4 {
      font-size: 1.5em;
    }
  }
}
</style>
