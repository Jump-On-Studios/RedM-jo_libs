import { createApp } from 'vue'
import App from './App.vue'
import PrimeVue from 'primevue/config';
import { definePreset } from '@primeuix/themes';
import Nora from '@primeuix/themes/nora'

import "./sass/index.scss";

import "./dev"

const MyPreset = definePreset(Nora, {
  semantic: {
    primary: {
      50: '{neutral.50}',
      100: '{neutral.100}',
      200: '{neutral.200}',
      300: '{neutral.300}',
      400: '{neutral.400}',
      500: '{neutral.500}',
      600: '{neutral.600}',
      700: '{neutral.700}',
      800: '{neutral.800}',
      900: '{neutral.900}',
      950: '{neutral.950}'
    },
    border: {
      radius: {
        none: '0px',
        xs: '0px',
        sm: '0px',
        md: '0px',
        lg: '0px',
        xl: '0px'
      }
    },
    colorScheme: {
      dark: {
        surface: {
          0: '#ffffff',
          50: '{neutral.50}',
          100: '{neutral.100}',
          200: '{neutral.200}',
          300: '{neutral.300}',
          400: '{neutral.400}',
          500: '{neutral.500}',
          600: '{neutral.600}',
          700: '{neutral.700}',
          800: '{neutral.800}',
          900: '{neutral.900}',
          950: '{neutral.950}'
        },
        formField: {
          background: 'var(--color-background-grey)',
          borderColor: 'none',
          placeholderColor: 'var(--placeholder-color)',
          paddingX: 'var(--padding-input-X)',
          paddingY: 'var(--padding-input-Y)',
        },
      }
    },

  }
});

const app = createApp(App)
app.use(PrimeVue, {
  theme: {
    preset: MyPreset,
    options: {
      darkModeSelector: '.prime-darkmode',
    }
  }
});
app.mount('#app')
