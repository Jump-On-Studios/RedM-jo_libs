<template>
  <div class="dev-background"></div>
</template>

<style scoped lang="scss">
// Stands in for the game behind the panel. Stripped from the build output by
// the excludeBuildOutput plugin.
.dev-background {
  position: fixed;
  inset: 0;
  z-index: -1;
  background-image: url("/assets/ui/capture.webp");
  background-position: center;
  background-size: cover;
}
</style>
