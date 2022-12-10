<template>
  <div class="stay-popup-warpper">
    <div class="hide-temp">hello Stay</div>
    <Header>{{t(selectedTab.name)}}</Header>
    <div class="tab-content">
      <div class="matched-script" v-if="selectedTab.id==1">
        匹配脚本
      </div>
      <template v-if="selectedTab.id==2 || selectedTab.id==3">
        <template v-if="isStayPro">
          <DarkMode v-if="selectedTab.id==2"></DarkMode>
          <Sniffer v-if="selectedTab.id==3" :browserUrl="browserRunUrl"></Sniffer>
        </template>
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
import { useI18n } from 'vue-i18n';


export default {
  name: 'popupView',
  components: {
    Header,
    TabMenu,
    ConsolePusher,
    Sniffer,
    DarkMode,
    UpgradePro
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
      browserUrl: '',
      isStayPro: store.state.isStayPro,
      darkmodeToggleStatus: 'on',
      siteEnabled: true,
    })

    const setTabName = (selectedTab) => {
      state.selectedTab = selectedTab;
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
          // if(shouldToFetchScript){
          //   fetchMatchedScriptList();
          // }
        }
      }
      return true;
    });

    function fetchMatchedScriptConsole(){
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'fetchMatchedScriptLog' }, (response) => {
        // logIsFetched = true;
        console.log('fetchMatchedScriptLog response----', response)
        // if (response && response.body && response.body.length > 0) {
        //   response.body.forEach(item => {
        //     if (item.logList && item.logList.length > 0) {
        //       item.logList.forEach(logMsg => {
        //         let logType = logMsg.msgType ? logMsg.msgType : 'log'
        //         let dateTime = logMsg && logMsg.time ? logMsg.time : ''
        //         let data = {
        //           uuid: item.uuid,
        //           name: item.name,
        //           time: dateTime,
        //           //Fixed wrong variable logMsg.
        //           msgType: logType,
        //           message: logMsg.msg
        //         };
        //         scriptConsole.push(data)
        //       })
        //     }
        //   })
        //   if (!showLogNotify && scriptConsole.length>0) {
        //     let count = scriptConsole.length
        //     let readCount = window.localStorage.getItem('console_count');
        //     readCount = readCount ? Number(readCount) : 0
        //     if (count - readCount > 0){
        //       window.localStorage.setItem('console_count', count);
        //       showLogNotify = true
        //       logNotifyDom.show()
        //       let showCount = count - readCount;
        //       showCount = showCount > 99 ? '99+' : showCount
        //       logNotifyDom.setInnerHtml(showCount)
        //     }
        //   }
        // } else {
        //   scriptConsole = [];
        // }
      })
    }

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
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: start;
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
    justify-content: start;
    background-color: var(--s-white);
    flex: 1;
    padding-bottom: 52px;
  }
}
</style>
