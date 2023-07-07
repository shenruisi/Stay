<template>
  <div class="stay-popup-warpper" :class="isMobile?'mobile-bottom':'mac-bottom'">
    <Header :titleInfo="t(selectedTab.name)">
      <!-- MatchedScript -->
      <!-- adblock -->
      <div class="tab-wrapper" :class="selectedTab.id==1?'script':'adblock'" v-if="selectedTab.id==1 || selectedTab.id==4">
        <div
          class="tab"
          @click="tabActionClick('tab_1',selectedTab.name)"
          :class="{ active: showTab == 'tab_1' }"
        >
          <div class="tab-text">{{ selectedTab.id==1 ? t("state_actived") :  t("web_tag")}}</div>
        </div>
        <div
          class="tab"
          @click="tabActionClick('tab_2', selectedTab.name)"
          :class="{ active: showTab == 'tab_2' }"
        >
          <div class="tab-text">{{ selectedTab.id==1 ? t("state_stopped") :  t("tag_rules")}}</div>
        </div>
        <div
          class="tab"
          @click="tabActionClick('tab_3', selectedTab.name)"
          :class="{ active: showTab == 'tab_3' }"
          v-if="selectedTab.id==4"
        >
          <div class="tab-text">{{ t("trusted")}}</div>
        </div>
      </div>
    </Header>
    <div class="tab-content" :style="{paddingTop: (selectedTab.id == 1 || selectedTab.id == 4)?'32px':'0'}">
      <MatchedScript v-if="selectedTab.id==1" ref="matchedScriptRef" :currentTab="showTab"></MatchedScript>
      <template v-if="selectedTab.id==2">
        <template v-if="isStayPro">
          <DarkMode v-if="selectedTab.id==2" :darkmodeToggleStatus="darkmodeToggleStatus" :darkmodeTheme="darkmodeTheme" :siteEnabled="siteEnabled" :browserUrl="browserUrl"></DarkMode>
          
        </template>
          <!-- <DarkMode v-if="selectedTab.id==2"></DarkMode>
          <Sniffer v-if="selectedTab.id==3" :browserUrl="browserRunUrl"></Sniffer> -->
        <UpgradePro :tabId="selectedTab.id" v-else>
          <a class="what-it" :href="selectedTab.whatisurl" target="_blank">{{ t(selectedTab.whatistitle) }}</a>
        </UpgradePro>
      </template>
      <Sniffer v-if="selectedTab.id==3" :browserUrl="browserUrl" :longPressStatus="longPressStatus"></Sniffer>
      <AdBlock v-if="selectedTab.id==4" ref="adBlockRef" :currentTab="showTab"></AdBlock>
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
import UpgradePro from '../components/UpgradePro.vue';
import MatchedScript from '../components/MatchedScript.vue';
import AdBlock from '../components/AdBlock.vue';
import { useI18n } from 'vue-i18n';
import { isMobile } from '../utils/util'


export default {
  name: 'popupView',
  components: {
    Header,
    TabMenu,
    AdBlock,
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
    // console.log('localLan====', localLan, store.state.selectedTab);
    // {id: 3, selected: 0, name: 'downloader_tab'},
    const state = reactive({
      selectedTab: store.state.selectedTab,
      localLan,
      browserUrl: '',
      isStayPro: store.state.isStayPro,
      darkmodeToggleStatus: store.state.darkmodeToggleStatus,
      darkmodeTheme: store.state.darkmodeTheme,
      siteEnabled: store.state.siteEnabled,
      longPressStatus: store.state.longPressStatus,
      isMobile: isMobile(),
      showTab:  store.state.tabAction[store.state.selectedTab.name] || 'tab_1'
    })

    const tabActionClick = (tabId, menuName) => {
      state.showTab = tabId;
      let tabAction = store.state.tabAction;
      tabAction[menuName] = tabId;

      store.commit('setTabAction', tabAction);
    }
    
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
          state.darkmodeTheme = request.darkmodeColorTheme;
          store.commit('setDarkmodeTheme', state.darkmodeTheme);
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
      setTabName,
      tabActionClick
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
  .tab-wrapper{
    width: 100%;
    height: 32px;
    display: flex;
    justify-content: flex-start;
    align-items: flex-start;
    &.script{
      .tab-text::after{
        width: 40px;
      }
    }
    &.adblock{
      .tab-text::after{
        width: 50px;
      }
    }
    .tab{
      padding: 2px 10px 0 10px;
      text-align: center;
      height: 100%;
      cursor: pointer;
      position: relative;
      color: var(--dm-font);
      font-weight: 600;
      .tab-text{
        height: 100%;
        font-size: 16px;
        position: relative;
      }
      &.active{
        // background-color: var(--dm-bg);
        color: var(--s-main);
        // border-radius: 8px;
        .tab-text::after{
          content: '';
          height: 2px;
          background-color: var(--s-main);
          position: absolute;
          bottom: 0;
          left: 50%;
          transform: translateX(-50%);
        }
      }
    }
    
  }
  .tab-content{
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-start;
    // background-color: var(--dm-bg);
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
    padding-bottom: 76px;
  }
}
</style>
