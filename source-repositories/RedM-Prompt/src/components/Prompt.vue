<script setup>
import KeyboardKey from './KeyboardKey.vue'
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
      <KeyboardKey
        v-for="(keyboardKey, index) in props.prompt.keyboardKeys"
        :key="index"
        :holdTime="props.prompt.holdTime"
        :kkey="keyboardKey"
      />
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
  }
}
</style>
