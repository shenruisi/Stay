<template>
  <div class="stay-popup-warpper">
    <!-- <div class="hide-temp"></div> -->
    <Header>{{t(selectedTab.name)}}</Header>
    <div class="tab-content">
      <MatchedScript v-if="selectedTab.id==1"></MatchedScript>
      <template v-if="selectedTab.id==2 || selectedTab.id==3">
        <template v-if="isStayPro">
          <DarkMode v-if="selectedTab.id==2" :darkmodeToggleStatus="darkmodeToggleStatus" :siteEnabled="siteEnabled"></DarkMode>
          <Sniffer v-if="selectedTab.id==3" :browserUrl="browserRunUrl"></Sniffer>
        </template>
          <!-- <DarkMode v-if="selectedTab.id==2"></DarkMode>
          <Sniffer v-if="selectedTab.id==3" :browserUrl="browserRunUrl"></Sniffer> -->
        <UpgradePro v-else></UpgradePro>
      </template>
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
import UpgradePro from '../components/UpgradePro.vue';
import MatchedScript from '../components/MatchedScript.vue';
import { useI18n } from 'vue-i18n';


export default {
  name: 'popupView',
  components: {
    Header,
    TabMenu,
    ConsolePusher,
    Sniffer,
    DarkMode,
    UpgradePro,
    MatchedScript
  },
  setup(props, { emit, attrs, slots }) {
    const { t, tm, locale } = useI18n();
    // 获取全局对象`
    const global = inject('global');
    const store = global.store;
    const localLan = store.state.localeLan;
    locale.value = store.state.localeLan;
    console.log('localLan====', localLan, store.state.selectedTab);
    // {id: 3, selected: 0, name: 'downloader_tab'},
    const state = reactive({
      selectedTab: store.state.selectedTab,
      localLan,
      browserUrl: '',
      isStayPro: store.state.isStayPro,
      darkmodeToggleStatus: 'on',
      siteEnabled: true,
    })
    
    const setTabName = (selectedTab) => {
      state.selectedTab = selectedTab;
      store.commit('setSelectedTab', state.selectedTab);
    }

    global.browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
      const from = request.from;
      const operate = request.operate;
      if('background' === from){
        if (operate == 'giveDarkmodeConfig'){
          console.log('giveDarkmodeConfig==res==', request);
          state.isStayPro = request.isStayAround=='a'?true:false;
          store.commit('setIsStayPro', state.isStayPro);
          state.darkmodeToggleStatus = request.darkmodeToggleStatus;
          state.siteEnabled = request.enabled;
        }
      }
      return true;
    });

    const fetchStayProConfig = () => {
      global.browser.tabs.getSelected(null, (tab) => {
        console.log('fetchStayProConfig----tab-----', tab);
        state.browserUrl = tab.url;
        store.commit('setBrowserUrl', state.browserUrl);
      })
      global.browser.runtime.sendMessage({ type: 'popup', operate: 'FETCH_DARKMODE_CONFIG'}, (response) => {})
    }

    fetchStayProConfig();

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
  width: 100%;
  // height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: start;
  flex: 1;
  padding-bottom: 52px;
  .hide-temp{
    height: 38px;
    width: 100%;
  }
  .tab-content{
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: start;
    background-color: var(--dm-bg);
    flex: 1;
    // padding-bottom: 52px;
  }
}
@supports (bottom: constant(safe-area-inset-bottom)) or (bottom: env(safe-area-inset-bottom)) {
  .stay-popup-warpper{
    padding-bottom: 80px;
    // padding-bottom: calc(52px + env(safe-area-inset-bottom));
    // margin-bottom: constant(safe-area-inset-bottom);
    // margin-bottom: env(safe-area-inset-bottom);  
	}
}
</style>
