import { createApp } from 'vue'
import App from './App.vue'
import API from './API'
import { createPinia } from 'pinia'

const pinia = createPinia()

const app = createApp(App)
app.use(pinia)
app.provide('API', API)
app.mount('#app')