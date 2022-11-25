<template>
  <div class="stay-popup-warpper">
    <!-- hello -->
    <Header>{{"Matched"}}</Header>
    <!-- <TabMenu :tabId="tabId" @setTabName="setTabName"></TabMenu> -->
  </div>
</template>
<script>
import { inject, ref, reactive, watch, toRefs } from 'vue';
import { useStore } from 'vuex';
import Header from './components/Header.vue';
// import TabMenu from './components/TabMenu.vue';
// import { useI18n } from 'vue-i18n';

export default {
  name: 'popup',
  components: {
    Header
    // TabMenu
  },
  setup(props, { emit, attrs, slots }) {
    // const { t, tm } = useI18n();
    // 获取全局对象`
    const global = inject('global');
    const store = useStore();
    const localLan = global.store.state.localeLan;
    console.log("localLan====", localLan);
    // console.log("localLan====", t('matched_scripts_tab'));
    const state = reactive({
      tabName: 'matched_scripts_tab',
      tabId: 1,
      locale: global.store.state.localeLan,
      browserRunUrl: ''
    })

    const setTabName = (tabId, tabName) => {
      state.tabName = tabName;
      state.tabId = tabId;
    }

    /**
     * 获取当前网页可匹配的脚本
     * 初始化tab
     */
    const fetchMatchedScriptList = () => {
      global.browser.tabs.getSelected(null, (tab) => {
        console.log("tab=======", tab);
        state.browserRunUrl = tab.url;
        global.browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts", url: state.browserRunUrl, digest: "yes" }, (response) => {
          console.log("response-----", response);
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
      });
    }
    fetchMatchedScriptList();

    return {
      ...toRefs(state),
      // t,
      // tm,
      setTabName
    };
  }
};
</script>
<style lang="less">
@import "../assets/css/common.less";
#app {
  font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",
    Helvetica, Arial, "Lucida Grande", sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: var(--s-black);
  width: 100%;
  position: relative;
  min-height: 100%;
  height: auto !important;
  height: 100%; /*IE6不识别min-height*/
  position: relative;
  display: flex;
  flex-direction: column;
}

</style>
