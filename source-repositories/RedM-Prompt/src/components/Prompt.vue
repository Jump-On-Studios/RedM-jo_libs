<script setup>
import KeyboardKey from './KeyboardKey.vue'
const props = defineProps({
  prompt: Object,
  isLeft: Boolean
})
</script>

<template>
  <div class="prompt" v-if="prompt.visible" :class="{ isLeft, disabled: prompt.disabled }">
    <div id="label" class="crock">
      <span v-html="props.prompt.label"></span>
    </div>
    <div id="keyboardKeys">
      <KeyboardKey v-for="(keyboardKey, index) in props.prompt.keyboardKeys" :key="index" :holdTime="props.prompt.holdTime" :kkey="keyboardKey" />
    </div>
  </div>
</template>

<style scoped lang="scss">
.prompt {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-bottom: 0.6rem;
  gap: 0.5rem;

  &.isLeft {
    flex-direction: row-reverse;
  }

  &:last-child {
    margin-bottom: 0;
  }

  #label {
    span {
      display: flex;
      align-items: center;
      gap: 0.5rem;

      &:deep {
        img {
          height: .9rem;
        }
      }
    }
  }

  #keyboardKeys {
    display: flex;
    flex-direction: row;
    align-items: center;
  }

  &.disabled {
    opacity: .6
  }
}
</style>
