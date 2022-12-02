<template>
  <div class="stay-popup-warpper">
    <div class="hide-temp">hello Stay</div>
    <Header>{{t(selectedTab.name)}}</Header>
    <div class="tab-content">
      <div class="matched-script" v-if="selectedTab.id==1">
        匹配脚本
      </div>
      <DarkMode v-if="selectedTab.id==2"></DarkMode>
      <Sniffer v-if="selectedTab.id==3" :browserUrl="browserRunUrl"></Sniffer>
      <ConsolePusher v-if="selectedTab.id==4"></ConsolePusher>
    </div>
    <TabMenu :tabId="selectedTab.id" @setTabName="setTabName"></TabMenu>
  </div>
</template>
<script>
import { inject, ref, reactive, watch, toRefs } from 'vue';
import { useStore } from 'vuex';
import Header from '../components/Header.vue';
import TabMenu from '../components/TabMenu.vue';
import DarkMode from '../components/DarkMode.vue';
import Sniffer from '../components/Sniffer.vue';
import ConsolePusher from '../components/ConsolePusher.vue';
import { useI18n } from 'vue-i18n';


export default {
  name: 'popupView',
  components: {
    Header,
    TabMenu,
    ConsolePusher,
    Sniffer,
    DarkMode
  },
  setup(props, { emit, attrs, slots }) {
    const { t, tm } = useI18n();
    // 获取全局对象`
    const global = inject('global');
    const store = global.store;
    const localLan = store.state.localeLan;
    console.log('localLan====', localLan);
    // {id: 3, selected: 0, name: 'downloader_tab'},
    const state = reactive({
      selectedTab: {id: 1, name: 'matched_scripts_tab'},
      localLan,
      browserRunUrl: ''
    })

    const setTabName = (selectedTab) => {
      state.selectedTab = selectedTab;
    }

    /**
     * 获取当前网页可匹配的脚本
     * 初始化tab
     */
    const fetchMatchedScriptList = () => {
      global.browser.tabs.getSelected(null, (tab) => {
        console.log('tab-----', tab);
        state.browserRunUrl = tab.url;
        global.browser.runtime.sendMessage({ from: 'bootstrap', operate: 'fetchScripts', url: state.browserRunUrl, digest: 'yes' }, (response) => {
          console.log('response-----', response);
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
      t,
      tm,
      setTabName
    };
  }
};
</script>
<style lang="less">
@import "../assets/css/common.less";
.stay-popup-warpper{
  .hide-temp{
    height: 38px;
    width: 100%;
  }
  .tab-content{
    width: 100%;
    background-color: var(--s-white);
  }
}
</style>
