<script setup>
import { useGroupStore } from '@/stores/group';
import Prompt from './Prompt.vue';
const groupStore = useGroupStore();

</script>

<template>

<div id="group" :class="[groupStore.position]">

    <div id="prompts">
        <Prompt v-for="(prompt, index) in groupStore.prompts" :prompt="prompt" />
    </div>

    <img id="line" v-if="groupStore.title"src="/assets/images/ilo_title_line.png" alt="ilo_title_line">
    <div  v-if="groupStore.title" id="groupTitle" class="crock">{{groupStore.title }}</div>
  
</div>

</template>

<style scoped lang="scss">

#group {
  color: #fff;
  position: relative;
  display: flex;
  flex-direction: column;

  // Prompts container
  #prompts {
    display: flex;
    flex-direction: column;
  }

  // Line image styling
  #line {
    margin: 8px 0;
    width: 140px;
  }

  // Position modifiers

  // For classes starting with "top-": reverse order and right-aligned text.
  &[class^="top-"] {
    flex-direction: column-reverse;
    align-self: flex-start;

  }

  // For classes starting with "bottom-": align to the bottom.
  &[class^="bottom-"] {
    align-self: flex-end;
  }

  // For classes starting with "center": center the group.
  &[class^="center"] {
    align-self: center;
    margin-left: auto;
    margin-right: auto;
  }

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
  &.bottom-right {
    #prompts {
      align-items: end;
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
}



</style>
