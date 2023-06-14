<template>
  <div class="popup-adblock-wrapper">
    <div class="web-tagging-box" v-if="showTab == 'webTag'">
      <div class="adblock-manage-box">
        <div class="adblock-manage">
          <div class="manage-info">
            <div class="title">{{  t('taging_manage_title') }}</div>
            <div class="block-status" :class="blockStatus==1?'block-on':'block-off'">{{ blockStatusText }}</div>
          </div>
          <div class="manage-btn" :class="blockerEnabled?'enabled':'disabled'" @click="tagToManageClick">{{  t('taging_manage_btn') }}</div>
        </div>
        <div class="blocker-enabled" v-if="!blockerEnabled">
          <div class="blocker-info">{{  t('blocker_info') }}</div>
          <a class="enable-btn" href="https://www.craft.do/s/Zmlkwi42U4r5N0" target="_blank">{{  t('blocker_enable') }}</a>
        </div>
      </div>
      <div class="taging-status" @click="tagingStatusClick">{{  t('taging_status_btn') }}</div>
      <div class="three-finger-switch" >
        <div class="switch-text">{{  t('taging') }}</div>
        <SwitchComp class="switch" :switchStatus="threeFingerTapStatus" @switchAction="threeFingerSwitchClick"></SwitchComp>
      </div>
    </div>
    <div class="tagging-rules-box" v-if="showTab == 'tagRules'">
      <template v-if="webRuleList && webRuleList.length">
        <div class="rule-item" v-for="(item, index) in webRuleList" :key="index">
          <div class="web-title over-hidden">{{ item['url-filter'] }}</div>
          <div class="web-rule " ><span class="over-hidden" v-html="unHtmlTag(item.selector)"></span></div>
          <div class="delete-icon" @click="deleteRuleClick(item.uuid)"></div>
        </div>
      </template>
      <div class="rule-note">{{ t('rule_note') }}</div>
    </div>
    <div class="trusted-box" v-if="showTab == 'trusted'">
      <div class="trusted-site">
        <div class="site-info">{{ trustedSite }}</div>
        <SwitchComp class="switch-rule" :switchStatus="switchStatus" @switchAction="switchAction"></SwitchComp>
      </div>
    </div>
  </div>
</template>
<script>
import { reactive, inject, toRefs, watch, computed } from 'vue'
import { isMobileOrIpad, unhtml } from '../utils/util'
import { useI18n } from 'vue-i18n';
import SwitchComp from './SwitchComp.vue';
    
    
export default {
  name: 'AdBlockComp',
  props: ['currentTab'],
  components:{
    SwitchComp
  },
  setup (props, {emit, expose}) {
    const global = inject('global');
    const store = global.store;
    const { t, tm } = useI18n();
    const state = reactive({
      scriptConsole: [],
      browserUrl: '',
      blockerEnabled: store.state.blockerEnabled,
      blockStatus: store.state.blockStatus,
      blockStatusText: store.state.blockStatus == 1 ? t('state_actived'):t('state_stopped'),
      isMobileOrIpad: isMobileOrIpad(),
      threeFingerTapStatus: store.state.threeFingerTapStatus,
      threeFingerTapSwitch: store.state.threeFingerTapStatus == 'on' ? t('switch_on') : t('switch_off'),
      showTab: props.currentTab && 'tab_1'== props.currentTab ? 'webTag': ('tab_2'== props.currentTab ?'tagRules':'trusted'),
      webRuleList: [],
      switchStatus: 'off',
      trustedSite: '',
    });

    watch(
      props,
      (newProps) => {
        // 接收到的props的值
        let showTab = props.currentTab && 'tab_1'== props.currentTab ? 'webTag': ('tab_2'== props.currentTab ?'tagRules':'trusted');

        if(state.showTab != showTab){
          state.showTab = showTab;
          if(state.showTab == 'tagRules'){
            fetchWebTagRules();
          }
          if(state.showTab == 'trusted'){
            fetchTrusted();
          }
        }
      },
      { immediate: true, deep: true }
    );

    const unHtmlTag = computed(()=>(s)=>{ //计算属性传递参数
      return unhtml(s)
    })
    const threeFingerSwitchClick = () => {
      // console.log('threeFingerSwitchClick====')
      if(state.threeFingerTapStatus == 'on'){
        state.threeFingerTapStatus = 'off';
      }else{
        state.threeFingerTapStatus = 'on';
      }
      // state.threeFingerTapSwitch = state.threeFingerTapStatus == 'on' ? t('switch_on') : t('switch_off');
      store.commit('setThreeFingerTapStatus', state.threeFingerTapStatus);

      global.browser.tabs.query({
        active: true,
        currentWindow: true
      }, (tabs) => {
        const message = { from: 'popup', operate: 'pushThreeFingerTapStatus', type: 'popup', threeFingerTapStatus:state.threeFingerTapStatus}
        global.browser.tabs.sendMessage(tabs[0].id, message, response => {
          console.log('setThreeFingerTapStatus====',response);
        })
      })
    }

    const fetchTagingStatus = () => {
      global.browser.runtime.sendMessage({ from: 'content_script', operate: 'getThreeFingerTapStatus'}, (response) => {
        console.log('getThreeFingerTapStatus====',response);
        let threeFingerTapStatus = response.threeFingerTapStatus ? response.threeFingerTapStatus : 'on';
        state.threeFingerTapStatus = threeFingerTapStatus;
        state.threeFingerTapSwitch = threeFingerTapStatus == 'on' ? t('switch_on') : t('switch_off');
        store.commit('setThreeFingerTapStatus', state.threeFingerTapStatus);
      })
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'fetchTagStatus'}, (response) => {
        console.log('fetchTagStatus====',response);
        // tag_status
        // enabled
        let blockStatus = response&&response.tag_status ? response.tag_status : 1;
        state.blockStatus = blockStatus;
        state.blockStatusText = blockStatus == 1 ? t('state_actived'):t('state_stopped');
        state.blockerEnabled = response.enabled;
        store.commit('setBlockStatus', state.blockStatus);
        store.commit('setBlockerEnabled', state.blockerEnabled);
      })
    }

    const fetchWebTagRules = () => {
      global.browser.tabs.getSelected(null, (tab) => {
        state.browserUrl = tab.url;
        console.log('state.browserUrl----tab-----', state.browserUrl);
        store.commit('setBrowserUrl', tab.url);
        global.browser.runtime.sendMessage({ from: 'popup', operate: 'fetchTagRules', url: state.browserUrl}, (response) => {
          console.log('fetchTagRules====',response);
          state.webRuleList = response.rules;
        })
      })
      
    }

    const setTrusted = () => {
      global.browser.tabs.getSelected(null, (tab) => {
        state.browserUrl = tab.url;
        // console.log('state.browserUrl----tab-----', state.browserUrl);
        store.commit('setBrowserUrl', tab.url);
        global.browser.runtime.sendMessage({ from: 'popup', operate: 'setTrustedSite', url: state.browserUrl, on: state.switchStatus=='on'?true:false}, (response) => {
          console.log('setTrustedSite====',response);
          global.browser.runtime.sendMessage({ from: 'popup', operate: 'refreshTargetTabs'});
          // state.trustedSite = response.url;
          // state.switchStatus = response.on;
        })
      })
    }

    const fetchTrusted = () => {
      global.browser.tabs.getSelected(null, (tab) => {
        state.browserUrl = tab.url;
        // console.log('state.browserUrl----tab-----', state.browserUrl);
        store.commit('setBrowserUrl', tab.url);
        global.browser.runtime.sendMessage({ from: 'popup', operate: 'getTrustedSite', url: state.browserUrl}, (response) => {
          console.log('trustedSite====',response);
          state.trustedSite = response.url;
          state.switchStatus = response.on&&response.on==true?'on':'off';
          console.log('trustedSite==state.switchStatus==',state.switchStatus);
        })
      })
    }

    const deleteWebTagRule = (uuid) => {
      global.browser.runtime.sendMessage({ from: 'popup', operate: 'deleteTagRule', uuid}, (response) => {
        console.log('deleteTagRule====',response, state.webRuleList);
        state.webRuleList = state.webRuleList.filter(item=>{if(item.uuid!=uuid){return item;}});
        console.log('state.webRuleList====', state.webRuleList);
        global.browser.tabs.query({ active: true, currentWindow: true }, function(tabs) {
          const message = { from: 'popup', operate: 'refreshTargetTabs'};
          global.browser.tabs.sendMessage(tabs[0].id, message, response => {
            global.browser.tabs.reload(tabs[0].id, { bypassCache: true });
          })
          

        });
        // global.browser.runtime.sendMessage({ from: 'popup', operate: 'refreshTargetTabs'});
      })
    }
    const startFetchAboutConfig = () => {
      fetchTagingStatus();
      fetchWebTagRules();
      fetchTrusted();
      // if(state.showTab == 'tagRules'){
        
      // }
      // if(state.showTab == 'trusted'){
        
      // }
    }

    startFetchAboutConfig();
    

    const tagingStatusClick = () => {
      global.browser.tabs.query({
        active: true,
        currentWindow: true
      }, (tabs) => {
        const message = { from: 'popup', operate: 'startMakeupTagStatus', makeupTagStatus: 'on', type: 'popup'};
        global.browser.tabs.sendMessage(tabs[0].id, message, response => {
          console.log('setMakeupTagStatus====',response);
          window.close();
        })

      })
      
      // global.browser.runtime.sendMessage({ from: 'popup', operate: 'setMakeupTagStatus', makeupTagStatus: state.tagingStatus, type: 'popup'}, (response) => {
      //   console.log('setMakeupTagStatus====',response);
      //   window.close();
      // })
    }

    const tagToManageClick = () => {
      if(!state.blockerEnabled){
        return;
      }
      let openUrl = 'stay://x-callback-url/adblock?type=tag';
      global.openUrlInSafariPopup(openUrl);
    }
    
    const deleteRuleClick = (uuid) => {
      if(uuid){
        deleteWebTagRule(uuid)
      }
    }

    const tagToEnableClick = () => {
      let openUrl = 'https://www.craft.do/s/Zmlkwi42U4r5N0';
      global.openUrlInSafariPopup(openUrl);
    }

    const switchAction = (switchStatus) => {
      state.switchStatus = switchStatus;
      console.log('switchAction-------switchStatus===',switchStatus);
      // todo
      setTrusted()
    }
    
    return {
      ...toRefs(state),
      t,
      threeFingerSwitchClick,
      tagingStatusClick,
      tagToManageClick,
      deleteRuleClick,
      unHtmlTag,
      tagToEnableClick,
      switchAction
    };
  }
}
</script>
    
<style lang="less" scoped>
  .popup-adblock-wrapper{
    width: 100%;
    height: 100%;
    padding: 10px;
    .web-tagging-box{
      width: 100%;
      height: 100%;
      .adblock-manage-box{
        width: 100%;
        padding: 8px 13px;
        border: 1px solid var(--dm-bd);
        border-radius: 10px;
        background-color: var(--dm-bg);
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.05);
        margin-bottom: 15px;
        margin-top: 5px;
        .adblock-manage{
          width: 100%;
          display: flex;
          justify-content: space-between;
          align-items: center;
          // padding-bottom: 4px;
          height: 48px;
          cursor: default;
          .manage-info{
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-start;
            height: 44px;
            .title{
              color: var(--dm-font);
              font-size: 16px;
              font-weight: 400;
            }
            .block-status{
              font-size: 13px;
              position: relative;
              padding-left: 20px;
              &::after{
                content: '';
                position: absolute;
                left: 0px;
                width: 10px;
                height: 10px;
                top: 50%;
                transform: translateY(-50%);
                object-fit: contain;
                border-radius: 50%;
              }
            }
            .block-on{
              color: var(--s-main);
              &::after{
                background: var(--s-main);
              }
            }
            .block-off{
              color: var(--dm-bd);
              &::after{
              background: var(--dm-bd);
              }
            }
          }
          .manage-btn{
            width: 90px;
            height: 25px;
            line-height: 23px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 13px;
            &.disabled{
              border: 1px solid var(--dm-bd);
              color: var(--dm-bd);
              opacity: 0.7;
            }
            &.enabled{
              color: var(--s-main);
              border: 1px solid var(--s-main);
            }
          }
        }
        .blocker-enabled{
          width: 100%;
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 2px 0;
          cursor: default;
          .blocker-info{
            height: 25px;
            background-color: rgba(182, 31, 224, 0.1);
            color: var(--s-main);
            border-radius: 8px;
            font-size: 13px;
            padding: 0 8px;
            line-height: 25px;
          }
          .enable-btn{
            width: 90px;
            height: 25px;
            line-height: 23px;
            border-radius: 8px;
            border: 1px solid var(--s-main);
            font-size: 13px;
            color: var(--s-main);
            text-decoration: none;
          }
        }
      }
      .taging-status{
        width: 100%;
        height: 45px;
        line-height: 45px;
        text-align: center;
        font-size: 16px;
        font-weight: 700;
        border-radius: 10px;
        color: var(--s-main);
        border: 1px solid var(--s-main);
        margin-bottom: 18px;
        user-select: none;
        cursor: default;
      }
      .three-finger-switch{
        width: 95%;
        position: fixed;
        z-index: 999;
        bottom: 90px;
        height: 42px;
        border-radius: 8px;
        left: 50%;
        transform: translateX(-50%);
        border: 1px solid var(--dm-bd);
        background-color: var(--dm-bg-f7);
        display: flex;
        padding: 0 60px 0 20px;
        justify-content: center;
        justify-items: center;
        align-items: center;
        user-select: none;
        cursor: default;
        .switch-text{
          width: 100%;
          color: var(--dm-font);
          height: 100%;
          display: flex;
          align-items: center;
          user-select: none;
        }
        .switch{
          position: absolute;
          right: 8px;
          top: 50%;
          transform: translateY(-50%);
        }
        
      }
    }
    .tagging-rules-box{
      width: 100%;
      height: 100%;
      padding-bottom: 30px;
      .rule-item{
        width: 100%;
        height: 70px;
        box-shadow: 0 1px 5px rgba(0, 0, 0, 0.1);
        border: 1px solid var(--dm-bd);
        background-color: var(--dm-bg);
        border-radius: 10px;
        padding: 8px 50px 8px 10px;
        position: relative;
        margin-bottom: 10px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: center;
        cursor: default;
        .delete-icon{
          position: absolute;
          right: 0;
          top: 0;
          width: 50px;
          height: 100%;
          &::after{
            content:'';
            background: url('../assets/images/rule-delete.png') 50% 50% no-repeat;
            width: 20px;
            height: 40px;
            background-size: 100%;
            position: absolute;
            top:50%;
            left: 50%;
            transform: translate(-50%, -50%);
          }

        }
        .over-hidden{
          text-align: left;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-box-orient: vertical;
        }
        .web-title{
          width: 100%;
          font-size: 16px;
          color: var(--dm-font);
          height: 20px;
        }
        .web-rule{
          width: 100%;
          font-size: 13px;
          color: var(--dm-font-2);
          height: 30px;
          line-height: 15px;
          display: flex;
          justify-content: start;
          align-items: end;
          position: relative;
          span{
            -webkit-line-clamp: 2;
          }
        }
        
      }
      .rule-note{
        width: 95%;
        height: 25px;
        border-radius: 8px;
        background-color: var(--s-main-f10);
        color: var(--s-main);
        line-height: 25px;
        text-align: center;
        font-size: 13px;
        position: fixed;
        bottom: 80px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 999;
        user-select: none;
      }
    }
    .trusted-box{
      width: 100%;
      height: 100%;
      padding-top: 10px;
      .trusted-site{
        padding: 8px 80px 8px 8px;
        width: 100%;
        height: 45px;
        border: 1px solid var(--dm-bd);
        background-color: var(--dm-bg);
        border-radius: 10px;
        display: flex;
        justify-content: flex-start;
        align-items: center;
        position: relative;
        .site-info{
          width: 100%;
          height: 45px;
          line-height: 45px;
          text-align: left;
          color: var(--dm-font);
          font-size: 16px;
          overflow: hidden;
          text-overflow: ellipsis;
          display: inline-block;
          -webkit-box-orient: vertical;
        }
        .switch-rule{
          position: absolute;
          right: 8px;
          top: 50%;
          transform: translateY(-50%);
        }
      }
    }
  }
</style>
    