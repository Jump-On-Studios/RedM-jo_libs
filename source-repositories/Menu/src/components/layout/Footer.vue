<template>
  <div class="footer-text hapna" v-if="cItem.footer !== undefined && cItem.footer.length > 0">
    <div class="divider" v-if="!cItem.price"></div>
    <div class="content" v-html="cItem.footer">
    </div>
  </div>
</template>

<script setup>
import { useMenuStore } from '../../stores/menus';
const { cItem } = useMenuStore()

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