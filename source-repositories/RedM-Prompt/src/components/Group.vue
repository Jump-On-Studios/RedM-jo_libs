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
         src="/assets/images/ilo_title_line.webp"
         alt="ilo_title_line" />

    <div v-if="groupStore.title"
         id="groupTitle"
         class="crock">
      <span v-html="groupStore.title"></span>
      <KeyboardKey v-if="groupStore.prompts.length > 1"
                   :kkey="groupStore.nextPageKey"
                   :isNextPage="true"></KeyboardKey>
    </div>

    <div id="dots"
         v-if="groupStore.prompts.length > 1">
      <div class="dot"
           v-for="(prompt, index) in groupStore.prompts"
           :key="index"
           :class="{ active: groupStore.currentPageIndex === index }">

      </div>
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

  #dots {
    display: flex;
    flex-direction: row;
    gap: 0.3rem;
    position: absolute;

    .dot {
      height: 0.215rem;
      width: 0.215rem;
      background: #fff;
      border-radius: 50%;
      opacity: 0.4;
      box-shadow: 1px 1px rgba(0, 0, 0, 0.3);

      &.active {
        opacity: 1;
      }
    }
  }

  #prompts {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
  }

  #line {
    margin: 0.33rem 0;
    width: 8rem;
  }

  // Position modifiers

  // For classes starting with "top-": reverse order and align to the left.
  &[class^="top-"] {
    flex-direction: column-reverse;
    align-self: flex-start;

    #dots {
      top: -0.5rem;
    }
  }

  // For classes starting with "bottom-": align to the bottom.
  &[class^="bottom-"] {
    align-self: flex-end;

    #dots {
      bottom: -0.5rem;
    }
  }

  // Right side adjustments for top-right and bottom-right.
  &.top-right,
  &.bottom-right {
    margin-left: auto;
    text-align: right;

    #line {
      margin-left: auto;
    }

    #dots {
      right: 0.25rem;
    }

    #prompts {
      align-items: flex-end;
    }

    #groupTitle {
      justify-content: flex-end;
    }
  }

  // Left side adjustments for top-left and bottom-left.
  &.top-left,
  &.bottom-left {
    margin-right: auto;

    #groupTitle {
      flex-direction: row-reverse;
      justify-content: start;
    }

    #dots {
      left: 0.25rem;
    }
  }
}
</style>
