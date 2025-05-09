<template>
  <div class="wrapper" @click="click">
    Hi !
  </div>
</template>

<script setup>
import Swal from 'sweetalert2'

function click() {
  Swal.fire({
    theme: 'dark',
    title: 'confirmSaveCitizen',
    showCancelButton: true,
    confirmButtonText: 'save',
    confirmButtonColor: 'var(--color-green)',
  })
}
</script>
