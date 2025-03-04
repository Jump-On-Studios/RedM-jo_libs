<script setup>
const props = defineProps({
  kkey: String,
  holdTime: Number,
})
</script>

<template>
  <div class="keyboardKey bebas" :class="{ holdable: props.holdTime }">{{ props.kkey }}</div>
</template>

<style lang="scss" scoped>
.keyboardKey {
  position: relative;
  background: #fff;
  color: #000;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  min-height: 30px;
  min-width: 30px;
  padding: 0 12px;
  &:not(:first-child) {
    margin-left: 5px;
  }
  &.holdable {
    outline: 4px solid rgba($color: #000000, $alpha: 0.5);

    &::after {
      content: '';
      width: calc(100% + 15px);
      height: 44px;
      position: absolute;
      background: rgba($color: #fff, $alpha: 0.3);
      z-index: -1;
    }
  }
}
</style>
