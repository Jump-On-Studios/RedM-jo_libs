<template>
  <div class="dev-bg" v-if="isDev()">
    <img src="/assets/ui/dev_bg.jpg" />
  </div>
  <div class="notif" v-if="visible">
    <div class="container">
      <template v-for="row, rowIndex in notif.rows" :key="rowIndex">
        <div class="row">
          <template v-for="entry, entryIndex in row" :key="entryIndex">
            <h2 v-if="entry.type == 'title'" :ref="(el) => { entry.dom = el }" :style="style(entry)" :class="['title', entry.class]" v-html="entry.value" />

            <p v-if="entry.type == 'description'" :ref="(el) => { entry.dom = el }" :style="style(entry)" :class="[entry.class]" v-html="entry.value" />

            <input v-if="entry.type == 'text'" @keydown.enter="enterPressed" :ref="(el) => { entry.dom = el }" type="text" :style="style(entry)" :class="[entry.class, { error: entry.error }]" :placeholder="entry.placeholder" v-model="entry.value" />

            <label v-if="entry.type == 'label'" @keydown.enter="enterPressed" :ref="(el) => { entry.dom = el }" :style="style(entry)" :class="[entry.class, { error: entry.error }]" v-html="entry.value" />

            <input v-if="entry.type == 'number'" @keydown.enter="enterPressed" :ref="(el) => { entry.dom = el }" type="number" :style="style(entry)" :class="[entry.class, { error: entry.error }]" :placeholder="entry.placeholder" :min="entry.min" :max="entry.max" :step="entry.step" :value="entry.value" v-model="entry.value" />

            <VueDatePicker v-if="entry.type == 'date'" @keydown.enter="enterPressed" :ref="(el) => { entry.dom = el }" :style="style(entry)" :class="[entry.class, { error: entry.error }]" :dark="true" position="left" :start-date="new Date('01/01/' + entry.yearRange[0])" :enable-time-picker="false" :placeholder="entry.placeholder" :year-range="entry.yearRange" v-model="entry.value" :format="entry.format" :model-type="entry.format" auto-apply prevent-min-max-navigation />

            <button v-if="entry.type == 'action'" :style="style(entry)" :class="['action', entry.class]" v-html="entry.value" @click="click(entry.id, entry.ignoreRequired)" />
          </template>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, onUpdated } from 'vue'
import VueDatePicker from '@vuepic/vue-datepicker';

const notif = ref({})
const visible = ref(false)
let hasAction = false
let firstInput = null
let ignoreEnter = false
let lastMessageDate = 0

const typeWithResult = ['text', 'number', 'date']

function isDev() {
  return import.meta.env.DEV
}

function log(...data) {
  if (!isDev()) return
  console.log(...data)
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

function click(id, ignoreRequired) {
  let result = {}
  if (!ignoreRequired) {
    result = processInputs()
    if (!result) return
  }
  post('jo_input:click', {
    action: id.toLowerCase(),
    result: result
  })
  visible.value = false;
}

function style(entry) {
  let style = {}
  if (entry.width) {
    style.flex = "none"
    if (typeof entry.width == "string")
      style.width = entry.width
    else
      style.width = entry.width + "%"
  }
  if (entry.style) {
    style = { ...style, ...entry.style }
  }
  return style
}

function enterPressed() {
  if (ignoreEnter) return
  if (Date.now() - lastMessageDate < 1000) {
    ignoreEnter = true
    return
  }
  click("Enter")
}

window.addEventListener('message', (e) => {
  const event = e.data.event
  let data = e.data.data
  firstInput = null
  switch (event) {
    case 'newInput':
      lastMessageDate = Date.now()
      hasAction = false
      data.rows.forEach((row, rowIndex) => {
        row.forEach((entry, entryIndex) => {
          if (entry.type == "action") {
            hasAction = true
          }
          if (typeWithResult.includes(entry.type)) {
            entry.value = ref(entry.value)
            entry.dom = null
            if (firstInput === null) {
              if (entry.type == 'date')
                firstInput = false
              else
                firstInput = entry
            }
            if (entry.id === undefined) {
              entry.id = rowIndex + ":" + entryIndex
            }
          }
        })
      });
      notif.value = data
      visible.value = true
      nextTick(() => {
        setTimeout(() => {
          if (firstInput === null || !firstInput) return
          firstInput.dom.focus()
        }, 500)
      })
      break
  }

})

function keydown(event) {
  if (!visible.value) return
  if (event.code == "Escape") {
    post('jo_input:click', false)
    visible.value = false
    return
  }
  if (event.code == "Enter") {
    if (ignoreEnter) return
    if (Date.now() - lastMessageDate < 1000) {
      ignoreEnter = true
      return
    }
    if (document.activeElement.tagName != "BODY") return
    if (hasAction) return
    click("Enter")
  }
}

function keyup(event) {
  if (event.code == "Enter")
    ignoreEnter = false
}

onMounted(() => {
  window.addEventListener('keydown', keydown)
  window.addEventListener('keyup', keyup)
})

onUnmounted(() => {
  window.removeEventListener('keydown', keydown)
  window.removeEventListener('keyup', keyup)
})

</script>

<style lang="scss" scoped>
.notif {
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  background-color: rgba(0, 0, 0, 0.8);
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
  width: 54vw;
  height: fit-content;
  margin-top: 26vh;
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
  flex: 1;
  padding: 0.25em 1.1em;
  font-variant-caps: small-caps;
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
  white-space: nowrap;
}

.error {
  box-shadow: 0px 0px 5px var(--color-red-light);
}

.dev-bg {
  position: fixed;
  left: 0;
  top: 0;
  width: 100%;
  z-index: -1;

  img {
    width: 100%;
  }
}
</style>