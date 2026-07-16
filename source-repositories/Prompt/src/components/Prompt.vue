<script setup>
import KeyboardKey from './KeyboardKey.vue'
import PriceDisplay from './PriceDisplay.vue'

const props = defineProps({
  prompt: Object,
  isLeft: Boolean,
})
</script>

<template>
  <img
    v-if="prompt.visible && prompt.type === 'separator'"
    class="promptSeparator"
    :class="{ isLeft }"
    src="/assets/images/ilo_title_line.webp"
    alt="ilo_title_line"
  />
  <div v-else-if="prompt.visible" class="prompt" :class="{ isLeft, disabled: prompt.disabled }">
    <div id="label" class="crock">
      <span v-html="props.prompt.label"></span>
    </div>
    <PriceDisplay :price="prompt.price" right />
    <div id="keyboardKeys">
      <KeyboardKey
        v-for="(keyboardKey, index) in props.prompt.keyboardKeys"
        :key="index"
        :holdTime="props.prompt.holdTime"
        :kkey="keyboardKey"
        :disabled="prompt.disabled"
      />
    </div>
  </div>
</template>

<style scoped lang="scss">
.prompt {
  --price-height: 1.8rem;

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
          height: 0.9rem;
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
    opacity: 0.6;
  }
}

.promptSeparator {
  width: 7rem;
  margin: 0.05rem 0 0.65rem;
  opacity: 0.5;

  &.isLeft {
    align-self: flex-start;
  }
}
</style>
