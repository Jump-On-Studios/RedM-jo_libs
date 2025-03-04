<script setup>
import { useGroupStore } from '@/stores/group'

const groupStore = useGroupStore()

window.addEventListener('message', (event) => {
  const { type, data } = event.data

  switch (type) {
    case 'updateGroup':
      groupStore.updateGroup(data)
      break
    case 'yyyy':
      // todo
      break
  }
})
</script>
