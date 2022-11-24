import { createApp } from 'vue'
import App from './App.vue'
import store from '../store';
import i18n from '../locales/setupI18n';

let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
const app = createApp(App);
 
// 配置全局变量 页面中使用 inject 接收
app.provide('global', {
  store,
  browser
});

app.use(i18n).use(store).mount('#app');
