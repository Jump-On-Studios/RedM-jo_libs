<template>
  <div class="description hapna" v-if="needDescription()">
    <div class="title crock" v-if="menuStore.cMenu.type == 'tile'">
      <span class="main" v-html="cItem.title"></span>
      <span class="subtitle hapna" v-if="cItem.subtitle.length > 0" v-html="cItem.subtitle"></span>
    </div>
    <div class="text" v-if="cItem.description" v-html="getDescription(cItem)">
    </div>
    <div class="statistics" v-if="cItem.statistics.length > 0">
      <template v-for="(stat, index) in cItem.statistics" :key="index">
        <Statistic :stat="stat" />
      </template>
    </div>
  </div>
</template>

<script setup>
import Statistic from "./Statistic.vue"
import { useLangStore } from '../../stores/lang';
import { useMenuStore } from '../../stores/menus';
import { storeToRefs } from "pinia";
const lang = useLangStore().lang

const menuStore = useMenuStore()

const { cItem } = storeToRefs(menuStore)

function getDescription(item) {
  if (item.translateDescription) {
    return lang(item.description)
  }
  return item.description
}
function needDescription() {
  if (menuStore.cMenu.type == "tile" && menuStore.cItem.title.length > 0) return true
  if (menuStore.cItem.description == undefined) return false
  if (menuStore.cItem.description.length > 0) return true
  if (menuStore.cItem.statistics.length > 0) return true
  if (menuStore.cItem.grid) return true
  return false
}
</script>

<style scoped lang="scss">
.title {
  margin-bottom: 1vh;
}

.description {
  .text {
    overflow-wrap: break-word;
  }
}
</style>