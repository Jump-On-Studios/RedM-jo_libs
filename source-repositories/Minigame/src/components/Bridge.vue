<!-- eslint-disable vue/multi-word-component-names -->
<template><span></span></template>
<script setup lang="ts">
window.addEventListener("message", (event) => {
  // console.log(event)
  const { type, data } = event.data;

  switch (type) {
    case "jo_minigame:show":
      // todo
      break;
  }
});
</script>
