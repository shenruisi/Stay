<template>
  <div class="popup-matched-wrapper">
    <div class="matched-script-box" v-if="scriptStateList && scriptStateList.length">
      <div class="tab-wrapper">
        <div
          class="tab activated"
          @click="tabACtion('activated')"
          :class="{ active: showTab == 'activated' }"
        >
          <div class="tab-text">{{ t("state_actived") }}</div>
        </div>
        <div
          class="tab stopped"
          @click="tabACtion('stopped')"
          :class="{ active: showTab == 'stopped' }"
        >
          <div class="tab-text">{{ t("state_stopped") }}</div>
        </div>
      </div>
      <div class="matched-script-content">
        <!-- <template  v-if="showTab == 'activated'">
          <ScriptItem v-for="(item, i) in activatedScriptList" :key="i" :scriptItem="item" :state="showTab"></ScriptItem>
        </template>
        <template  v-if="showTab == 'stopped'">
          <ScriptItem v-for="(item, i) in stoppedScriptList" :key="i" :scriptItem="item" :state="showTab"></ScriptItem>
        </template> -->
        <ScriptItem v-for="(item, i) in scriptStateList" :key="i" :scriptItem="item" :state="showTab"></ScriptItem>
        
      </div>
    </div>
    <div class="null-data" v-else>
      {{t('null_scripts')}}
    </div>
  </div>
</template>

<script>
import { reactive, inject, toRefs } from 'vue'
import ScriptItem from './ScriptItem.vue';
import { useI18n } from 'vue-i18n';
export default {
  name: 'MatchedScriptComp',
  components: {
    ScriptItem
  },
  setup (props, {emit, expose}) {
    const { t, tm } = useI18n();
    const global = inject('global');
    const store = global.store;
    const state = reactive({
      browserUrl: store.state.browserUrl,
      showTab: 'activated',
      scriptStateList: [],
      activatedScriptList: [],
      stoppedScriptList: [],
    });

    const tabACtion = (tabName) => {
      state.showTab = tabName;
      spliteActivatedScript();
    }

    /**
     * 获取当前网页可匹配的脚本
     * 初始化tab
     */
    const fetchMatchedScriptList = () => {
      console.log('--------fetchMatchedScriptList---start-----');
      global.browser.runtime.sendMessage({ from: 'bootstrap', operate: 'fetchScripts', url: state.browserUrl, digest: 'yes' }, (response) => {
        console.log('fetchMatchedScriptList---response-----', response);
        try {
          state.scriptStateList = response.body;
          state.activatedScriptList = [];
          state.stoppedScriptList = [];
          state.scriptStateList.forEach(item=>{
            if(item.active){
              state.activatedScriptList.push(item);
            }else{
              state.stoppedScriptList.push(item);
            }
          })
          // fetchMatchedScriptConsole();
        } catch (e) {
          console.log(e);
        }
      });
    }

    const spliteActivatedScript = () => {
      state.stoppedScriptList
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
      ...toRefs(state),
      t,
      tm,
      tabACtion,
      
    };
  }
}
</script>

<style lang="less" scoped>
  .popup-matched-wrapper{
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: start;
    align-items: center;
    flex:1;
    .matched-script-box{
      width: 100%;
      .tab-wrapper {
        height: 30px;
        width: 240px;
        margin: 10px auto 0px auto;
        border-radius: 8px;
        background-color: var(--s-f7);
        display: flex;
        justify-content: center;
        justify-items: center;
        align-items: center;
        .tab {
          width: 50%;
          height: 24px;
          line-height: 24px;
          font-size: 13px;
          font-weight: 700;
          color: var(--s-black);
          padding: 0 8px;
          display: flex;
          justify-content: center;
          justify-items: center;
          align-items: center;
          .tab-text {
            width: 100%;
            cursor: pointer;
          }
          &.active .tab-text {
            width: 100%;
            background-color: var(--s-white);
            color: var(--s-main);
            border-radius: 8px;
          }
        }
      }
    }
    .null-data{
      font-size: 16px;
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
      flex: 1;
      justify-content: center;
    }
    
  }
</style>
