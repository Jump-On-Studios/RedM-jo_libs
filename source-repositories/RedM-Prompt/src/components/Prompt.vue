<script setup>
import KeyboardKey from './KeyboardKey.vue'
const props = defineProps({
  prompt: Object,
  isLeft: Boolean
})
</script>

<template>
  <div class="prompt"
       v-if="prompt.visible"
       :class="{ isLeft, disabled: prompt.disabled }">
    <div id="label"
         class="crock">
      {{ props.prompt.label }}
    </div>
    <div id="keyboardKeys">
      <KeyboardKey v-for="(keyboardKey, index) in props.prompt.keyboardKeys"
                   :key="index"
                   :holdTime="props.prompt.holdTime"
                   :kkey="keyboardKey" />
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


  #keyboardKeys {
    display: flex;
    flex-direction: row;
    align-items: center;
  }

  &.disabled {
    opacity: .4
  }
}
</style>
