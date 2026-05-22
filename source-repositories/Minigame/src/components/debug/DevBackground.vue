<template>
  <div class="dev-background"></div>
</template>

<script setup lang="ts"></script>

<style scoped>
.dev-background {
  position: fixed;
  inset: 0;
  z-index: -1;
  width: 100vw;
  height: 100vh;
  background-image: url("/img/capture.jpg");
  background-position: center;
  background-size: cover;
  transition:
    transform 0.5s ease-in-out,
    filter 0.5s ease-in-out;
}
</style>
