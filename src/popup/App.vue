<template>
  <div class="stay-popup-warpper" :class="isMobile?'mobile-bottom':'mac-bottom'">
    <!-- <div class="hide-temp"></div> -->
    <Header>{{t(selectedTab.name)}}</Header>
    <div class="tab-content">
      <MatchedScript v-if="selectedTab.id==1"></MatchedScript>
      <template v-if="selectedTab.id==2 || selectedTab.id==3">
        <template v-if="isStayPro">
          <DarkMode v-if="selectedTab.id==2" :darkmodeToggleStatus="darkmodeToggleStatus" :siteEnabled="siteEnabled" :browserUrl="browserUrl"></DarkMode>
          <Sniffer v-if="selectedTab.id==3" :browserUrl="browserUrl" :longPressStatus="longPressStatus"></Sniffer>
        </template>
          <!-- <DarkMode v-if="selectedTab.id==2"></DarkMode>
          <Sniffer v-if="selectedTab.id==3" :browserUrl="browserRunUrl"></Sniffer> -->
        <UpgradePro :tabId="selectedTab.id" v-else><a class="what-it" :href="selectedTab.id == 2?'https://www.craft.do/s/PHKJvkZL92BTep':'https://www.craft.do/s/sYLNHtYc0n2rrV'" target="_blank">{{ selectedTab.id == 2 ? t('what_darkmode') : t('what_downloader') }}</a></UpgradePro>
      </template>
      <ConsolePusher v-if="selectedTab.id==4"></ConsolePusher>
    </div>
    <TabMenu :tabId="selectedTab.id" @setTabName="setTabName" ></TabMenu>
  </div>
</template>
<script>
import { inject, ref, reactive, watch, toRefs } from 'vue';
import Header from '../components/Header.vue';
import TabMenu from '../components/TabMenu.vue';
import DarkMode from '../components/DarkMode.vue';
import Sniffer from '../components/Sniffer.vue';
import ConsolePusher from '../components/ConsolePusher.vue';
import UpgradePro from '../components/UpgradePro.vue';
import MatchedScript from '../components/MatchedScript.vue';
import { useI18n } from 'vue-i18n';
import { isMobile } from '../utils/util'


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
      darkmodeToggleStatus: store.state.darkmodeToggleStatus,
      siteEnabled: store.state.siteEnabled,
      longPressStatus: store.state.longPressStatus,
      isMobile: isMobile()
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
          store.commit('setDarkmodeToggleStatus', state.darkmodeToggleStatus);
          state.siteEnabled = request.enabled;
          store.commit('setSiteEnabled', state.siteEnabled);
        }
      }
      return true;
    });

    const fetchStayProConfig = () => {
      console.log('fetchStayProConfig----start-----');
      global.browser.tabs.getSelected(null, (tab) => {
        console.log('fetchStayProConfig----tab-----', tab);
        state.browserUrl = tab.url;
        console.log('state.browserUrl----tab-----', state.browserUrl);
        store.commit('setBrowserUrl', tab.url);
        console.log('store.state.browserUrl====',store.state.browserUrl);
      })
      global.browser.runtime.sendMessage({ type: 'popup', operate: 'FETCH_DARKMODE_CONFIG'}, (response) => {})
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'getLongPressStatus'}, (response) => {
        console.log('getLongPressStatus====',response);
        let longPressStatus = response.longPressStatus ? response.longPressStatus : 'on';
        state.longPressStatus = longPressStatus;
      })
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
.mac-bottom{
  padding-bottom: 60px;
}
.mobile-bottom{
  padding-bottom: 52px;
}
.stay-popup-warpper{
  width: 100%;
  // height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  flex: 1;
  
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
    justify-content: flex-start;
    background-color: var(--dm-bg);
    flex: 1;
    // padding-bottom: 52px;
    a.what-it{
      color: var(--dm-font);
    }
  }
}
@supports (bottom: constant(safe-area-inset-bottom)) or (bottom: env(safe-area-inset-bottom)) {
  .stay-popup-warpper{
   
    // padding-bottom: calc(52px + env(safe-area-inset-bottom));
    // margin-bottom: constant(safe-area-inset-bottom);
    // margin-bottom: env(safe-area-inset-bottom);  
	}
  .mac-bottom{
    padding-bottom: 60px;
  }
  .mobile-bottom{
    padding-bottom: 80px;
  }
}
</style>
