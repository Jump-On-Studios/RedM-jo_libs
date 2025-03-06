<script setup>
import { useGroupStore } from '@/stores/group'
import Prompt from './Prompt.vue';
import KeyboardKey from './KeyboardKey.vue';
const groupStore = useGroupStore()



</script>

<template>
  <div id="group"
       v-if="groupStore.prompts.length > 0"
       :class="[groupStore.position]">
    <div id="prompts">
      <Prompt v-for="(prompt, index) in groupStore.prompts[groupStore.currentPageIndex]"
              :key="index"
              :prompt="prompt"
              :isLeft="groupStore.position.includes('left')" />
    </div>

    <img id="line"
         v-if="!(groupStore.title === false)"
         src="/assets/images/ilo_title_line.png"
         alt="ilo_title_line" />

    <div v-if="groupStore.title"
         id="groupTitle"
         class="crock">
      {{ groupStore.title }}
      <KeyboardKey v-if="groupStore.prompts.length > 1"
                   :kkey="groupStore.nextPageKey"
                   :isNextPage="true"></KeyboardKey>
    </div>
  </div>
</template>

<style scoped lang="scss">
#group {
  color: #fff;
  position: relative;
  display: flex;
  flex-direction: column;

  #groupTitle {
    display: flex;
    gap: 0.5rem;
  }

  // Prompts container
  #prompts {
    display: flex;
    flex-direction: column;
    align-items: start;
  }

  // Line image styling
  #line {
    margin: 0.33rem 0;
    width: 5.75rem;
  }

  // Position modifiers

  // For classes starting with "top-": reverse order and right-aligned text.
  &[class^='top-'] {
    flex-direction: column-reverse;
    align-self: flex-start;
  }

  // For classes starting with "bottom-": align to the bottom.
  &[class^='bottom-'] {
    align-self: flex-end;
  }

  // For classes starting with "center": center the group.
  // &[class^='center'] {
  //   align-self: center;
  //   margin-left: auto;
  //   margin-right: auto;
  // }

  // Right side adjustments: apply to top-right, bottom-right, and center-right.
  &.top-right,
  &.bottom-right,
  &.center-right {
    margin-left: auto;
    text-align: right;

    // Align the line image to the right.
    #line {
      margin-left: auto;
    }
  }

  // For top-right and bottom-right: align prompts to the end.
  &.top-right,
  &.bottom-right,
  &.center-right {
    #prompts {
      align-items: end;
    }

    #groupTitle {
      justify-content: end;
    }
  }

  // Left side adjustments.
  &.top-left,
  &.bottom-left {
    margin-right: auto;

  }

  &.center-left {
    align-self: center;
    margin-right: auto;
  }

  &.center-right {
    align-self: center;
    margin-left: auto;

  }
}
</style>
