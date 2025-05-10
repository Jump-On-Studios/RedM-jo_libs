<template>
  <div class="notif">
    <div class="container">
      <h2 class="title">Title</h2>
      <div class="actions">
        <div class="action">
          Confirm
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const notif = ref({})
</script>

<style lang="scss" scoped>
.notif {
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  filter: backdrop(4px);
  background-color: rgba(0, 0, 0, 0.5);
  font-family: Hapna;
  color: white;
}

.container {
  text-align: center;
  background-color: var(--color-background-dark);
  width: 55vw;
  height: fit-content;
  margin-top: 25vh;
  padding: 0.5vw 0.5vw;
}

.title {
  font-weight: bold;
  background-color: var(--color-background-grey);
  width: 100%;
}
</style>