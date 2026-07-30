import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

import './styles/reset.css'
import './styles/fonts.css'
import './styles/tokens.css'
import './styles/fields.css'
import '@vuepic/vue-datepicker/dist/main.css'
import './styles/datepicker.css'

const app = createApp(App)

app.use(createPinia())
app.mount('#app')
