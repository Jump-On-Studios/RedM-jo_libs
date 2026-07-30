import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { uiScaler } from './directives'
import App from './App.vue'

import './styles/reset.scss'
import './styles/fonts.scss'
import './styles/tokens.scss'
import './styles/fields.scss'
import '@vuepic/vue-datepicker/dist/main.css'
import './styles/datepicker.scss'

const app = createApp(App)

app.use(createPinia())
app.directive('ui-scaler', uiScaler)
app.mount('#app')
