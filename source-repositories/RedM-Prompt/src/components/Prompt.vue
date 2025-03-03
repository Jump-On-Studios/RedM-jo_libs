<script setup>
const props = defineProps({
  prompt: Object,
})
</script>

<template>
  <div id="prompt">
    <div id="label" class="crock">
      {{ props.prompt.label }}
    </div>
    <div id="keyboardKeys">
      <div
        v-for="(keyboardKey, index) in props.prompt.keyboardKeys"
        :key="index"
        class="keyboardKey bebas"
        :class="{ holdable: props.prompt.holdTime }"
      >
        {{ keyboardKey }}
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
#prompt {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-bottom: 15px;
  &:last-child {
    margin-bottom: 0;
  }

  #label {
    margin-right: 12px;
  }

  #keyboardKeys {
    display: flex;
    flex-direction: row;
    align-items: center;
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
  }
}
</style>
