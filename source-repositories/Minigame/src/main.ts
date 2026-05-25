import { createApp } from "vue";
import { createPinia } from "pinia";
import { i18n, uiScaler } from "./directives";
import App from "./App.vue";
import "./styles/animations.css";

const app = createApp(App);

app.use(createPinia());
app.directive("ui-scaler", uiScaler);
app.directive("i18n", i18n);
app.mount("#app");
