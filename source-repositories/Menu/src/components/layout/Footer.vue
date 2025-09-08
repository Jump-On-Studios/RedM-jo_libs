<template>
  <div class="footer-text hapna" v-if="menuStore.cItem?.footer !== undefined && menuStore.cItem?.footer.length > 0">
    <div class="divider" v-if="!menuStore.cItem.price"></div>
    <div class="content" v-html="menuStore.cItem.footer">
    </div>
  </div>
</template>

<script setup>
import { useMenuStore } from '../../stores/menus';
const menuStore = useMenuStore()

</script>

<style scoped lang="scss">
.footer-text {
  display: flex;
  align-items: center;
  font-size: 1rem;
  flex-direction: column;

  .content {
    margin-top: 1vh;
    line-height: 1em;
    min-height: 1em;
  }
}
</style>