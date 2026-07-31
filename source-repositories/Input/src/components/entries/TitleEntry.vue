<template>
  <!-- eslint-disable-next-line vue/no-v-html -- markup comes from the Lua caller -->
  <h2 class="entry-title" :class="entry.class" :style="style" v-html="entry.value" />
</template>

<script setup lang="ts">
import { useEntryStyle } from '@/composables/useEntryStyle'
import type { TitleEntry } from '@/types/entries'

const props = defineProps<{ entry: TitleEntry }>()

const style = useEntryStyle(() => props.entry)
</script>

<style scoped lang="scss">
.entry-title {
  position: relative;
  flex: 0 1 auto;
  width: fit-content;
  max-width: 100%;
  margin: 0 auto;
  min-height: 74px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 18px 72px;
  border: 0;
  background: transparent;
  color: #e6e4e0;
  font-family: Crock, serif;
  font-size: 28px;
  font-weight: 400;
  font-variant-caps: normal;
  line-height: 1.1;
  text-align: center;
  text-transform: uppercase;

  &::before {
    content: "";
    position: absolute;
    inset: 0;
    border: 24px solid transparent;
    border-right-width: 34px;
    border-left-width: 34px;
    border-image-source: url("/assets/ui/menu_header.png");
    border-image-slice: 24 34;
    border-image-width: 24px 34px;
    border-image-repeat: stretch;
    filter: sepia(0.06) saturate(0.35) brightness(0.92);
    pointer-events: none;
  }
}
</style>
