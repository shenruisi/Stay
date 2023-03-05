import { createApp } from 'vue'
import App from './App.vue'
import store from '../store';
import i18n from '../locales/setupI18n';
import toast from '../components/toast/index.js';

let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
const app = createApp(App);
const globalClick = (callback) => {
  document.body.addEventListener('click', (event) => {
    callback(event);
  });
};
const openUrlInSafariPopup = (openUrl, target='') => {
  browser.tabs.query({
    active: true,
    currentWindow: true
  }, (tabs) => {
    let message = { from: 'popup', operate: 'windowOpen', openUrl, target: target};
    browser.tabs.sendMessage(tabs[0].id, message, response => {})
  })
  window.close();
}
// 配置全局变量 页面中使用 inject 接收
app.provide('global', {
  store,
  browser,
  toast,
  globalClick,
  openUrlInSafariPopup
});

app.use(i18n).use(store).mount('#app');
if (!(navigator.userAgent.match(/(iPhone|iPod|Android|ios|iOS|Backerry|WebOS|Symbian|Windows Phone|Phone)/i))) {
  document.body.style.height = '480px';
  document.body.style.width = '400px';
  let tagImgs = document.querySelectorAll('.popup-fotter-wrapper .fotter-box .tab-item .tab-img');
  tagImgs.forEach(item=>{
    item.style.top = 0;
  })
  
}