<template>
  <div class="notif" v-if="visible">
    <div class="container">
      <template v-for="row, rowIndex in notif.rows" :key="rowIndex">
        <div class="row">
          <template v-for="entry, entryIndex in row" :key="entryIndex">
            <h2 v-if="entry.type == 'title'" :ref="entry.dom" :class="['title', entry.class]" v-html="entry.value" />
            <p v-if="entry.type == 'description'" :ref="entry.dom" :class="[entry.class]" v-html="entry.value" />
            <input v-if="entry.type == 'input'" :ref="entry.dom" type="text" :class="[entry.class, { error: entry.error }]" :placeholder="entry.placeholder" v-model="entry.value" />
            <label v-if="entry.type == 'label'" :ref="entry.dom" :class="[entry.class, { error: entry.error }]" v-html="entry.value" />
            <input v-if="entry.type == 'number'" :ref="entry.dom" type="number" :class="[entry.class, { error: entry.error }]" :placeholder="entry.placeholder" :min="entry.min" :max="entry.max" :step="entry.step" :value="entry.value" v-model="entry.value" />
            <VueDatePicker v-if="entry.type == 'date'" :ref="entry.dom" :class="[entry.class, { error: entry.error }]" :dark="true" position="left" :start-date="new Date('01/01/' + entry.yearRange[0])" :enable-time-picker="false" :placeholder="entry.placeholder" :year-range="entry.yearRange" v-model="entry.value" :format="entry.format" :model-type="entry.format" />
            <button v-if="entry.type == 'action'" :class="['action', entry.class]" v-html="entry.value" @click="click(entry.id)" />
          </template>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import VueDatePicker from '@vuepic/vue-datepicker';

const notif = ref({})
const visible = ref(false)

const typeWithResult = ['input', 'number', 'date']

function log(...data) {
  if (import.meta.env.DEV)
    return console.log(...data)
  return
}

async function post(method, data) {
  log(method, data)
  if (import.meta.env.PROD) {
    const ndata = data === undefined ? '{}' : JSON.stringify(data)
    const settings = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: ndata
    };
    try {
      const fetchResponse = await fetch('https://' + GetParentResourceName() + '/' + method, settings);
      const data = await fetchResponse.json();
      if (data.length == 0 || data === "ok") {
        return true
      }
      return data;
    } catch (e) {
      log(e)
      return e;
    }
  }
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve('done!');
    }, 1000);
  });

}

function missingEntry(entry) {
  for (let index = 0; index < 4; index++) {
    const start = index * 600
    setTimeout(() => { entry.error = true }, start);
    setTimeout(() => { entry.error = false }, start + 300);
  }
}

function processInputs() {
  let result = {}
  let error = false
  notif.value.rows.forEach(rows => {
    rows.forEach(entry => {
      if (typeWithResult.includes(entry.type)) {
        result[entry.id] = entry.value
        if (entry.required && (result[entry.id] === "" || result[entry.id] === null || result[entry.id] === undefined)) {
          missingEntry(entry)
          error = true
        }
      }
    })
  })
  if (error) return false;
  return result
}

function click(id) {
  const result = processInputs()
  if (!result) return
  post('jo_input:click', { id, result: result }).then(success => {
    if (success) visible.value = false;
  })
}

window.addEventListener('message', (e) => {
  const event = e.data.event
  let data = e.data.data
  switch (event) {
    case 'newInput':
      data.rows.forEach((row, rowIndex) => {
        row.forEach((entry, entryIndex) => {
          if (typeWithResult.includes(entry.type)) {
            entry.value = ref(entry.value)
            entry.dom = ref()
            if (entry.id === undefined) {
              entry.id = rowIndex + ":" + entryIndex
            }
          }
        })
      });
      notif.value = data
      visible.value = true
      return;
  }
})

function keypress(event) {
  if (!visible.value) return
  if (event.code == "Escape") {
    post('jo_input:click', false)
    visible.value = false
  }
}

onMounted(() => {
  window.addEventListener('keydown', keypress)
})

onUnmounted(() => {
  window.removeEventListener('keydown', keypress)
})

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
  font-weight: 500;

  & * {
    font-weight: 500;
  }
}

.container {
  text-align: center;
  background-color: var(--color-background-dark);
  width: 55vw;
  height: fit-content;
  margin-top: 25vh;
  padding: var(--global-gap);
  display: flex;
  flex-direction: column;
  gap: var(--element-gap);
}

.row {
  width: 100%;
  display: flex;
  gap: var(--element-gap);
  align-items: center;
}

.title {
  font-weight: bold;
  background-color: var(--color-background-grey);
  width: 100%;
  padding: 0.25em 1.1em;
}

input {
  padding: 0.625em 1.1em;
  border: none;
  color: white;
  background-color: var(--color-background-grey);
  border-radius: 0;
  box-shadow: none;
  flex: 1;
  box-sizing: border-box;

  &:focus,
  &:focus-visible {
    box-shadow: none;
    outline: none;
  }
}

input {
  color-scheme: dark;
  border: 3px solid transparent;
  box-sizing: border-box;
}

.dp__main {
  box-sizing: border-box;
}

.action {
  flex: 1;
  background-color: var(--color-background-grey);
  padding: 0.625em 1.1em;
  transition: all 0.2s ease;

  &.red {
    background-color: var(--color-red);
  }

  &:hover {
    filter: brightness(1.5);
  }
}

p {
  margin-top: 0;
  margin-bottom: 0;
  text-align: center;
  width: 100%;
}

.error {
  box-shadow: 0px 0px 5px var(--color-red-light);
}
</style>