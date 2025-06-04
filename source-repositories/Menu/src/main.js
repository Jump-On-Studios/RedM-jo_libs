import { createApp } from 'vue'
import App from './App.vue'
import API from './API'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config';
import Nora from '@primeuix/themes/nora';
import Tooltip from 'primevue/tooltip';

const pinia = createPinia()

const app = createApp(App)
app.use(pinia)
app.use(PrimeVue, {
  theme: {
    preset: Nora,
    options: {
      prefix: 'p',
      darkModeSelector: 'menu',
      cssLayer: {
        name: 'primevue',
        order: 'app-styles, primevue, another-css-library'
      }
    }
  }
});
app.directive('tooltip', Tooltip);
app.provide('API', API)
app.mount('#app')