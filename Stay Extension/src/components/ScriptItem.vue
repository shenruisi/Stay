<template>
  <div class="popup-header-wrapper">

  </div>
</template>

<script>
import { reactive, inject, toRefs } from 'vue'

export default {
  name: 'ScriptItemComp',
  setup (props, {emit, expose}) {
    const global = inject('global');
    const store = global.store;
    const state = reactive({
      browserUrl: store.state.browserUrl,
    });
    /**
     * 获取当前网页可匹配的脚本
     * 初始化tab
     */
    const fetchMatchedScriptList = () => {
      global.browser.runtime.sendMessage({ from: 'bootstrap', operate: 'fetchScripts', url: state.browserUrl, digest: 'yes' }, (response) => {
        console.log('fetchMatchedScriptList---response-----', response);
        try {
          // scriptStateList = response.body;
          // renderScriptContent(scriptStateList);
          // let activeTab = window.localStorage.getItem("stay_popuo_active_tab") || 1;
          // const activeTabDom = document.querySelector(".header-box .header-tab .tab[tab='" + activeTab + "']");
          // handleTabAction(activeTabDom, activeTab);
          // fetchMatchedScriptConsole();
        } catch (e) {
          console.log(e);
        }
      });
      
      
    }

    const startFetchBrowserMatched = () => {
      if(state.browserUrl){
        fetchMatchedScriptList();
      }else{
        global.browser.tabs.getSelected(null, (tab) => {
          console.log('fetchMatchedScriptList-----tab-----', tab);
          state.browserUrl = tab.url;
          store.commit('setBrowserUrl', state.browserUrl);
          fetchMatchedScriptList();
        });
      }
    }

    global.browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
      const from = request.from;
      const operate = request.operate;
      if (from == 'content' && operate == 'giveRegisterMenuCommand') {
        let uuid = request.uuid;
        console.log('giveRegisterMenuCommand--request.data---', uuid, request.data)
        // registerMenuMap[uuid] = request.data;
        // let registerMenu = registerMenuMap[uuid]
        // renderRegisterMenuContent(uuid, registerMenu)
      }
      return true;
    });

    startFetchBrowserMatched();

    return {
      ...toRefs(state)
      
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-header-wrapper{
    width: 100%;
  }
</style>
